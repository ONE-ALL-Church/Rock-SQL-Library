-- Implemented At: https://admin.oneandall.church/admin/system/jobs/128
-- Tracked At: Check-in/SendKidsFollowUpSMS.sql

DECLARE @OADateTime DATETIME;
SET @OADateTime = GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';
--SET @OADateTime = '2025-03-02 10:15AM';

-- CTE to precompute attendance times and apply initial filters
WITH AttendanceTimes AS (
    SELECT 
        ao.Id AS OccurrenceId,
        ao.SundayDate,
        ao.GroupId,
        ao.ScheduleId,
        DATEADD(
            mi, 
            TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 19, 2) AS INT),
            DATEADD(
                hh, 
                TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 17, 2) AS INT),
                TRY_CAST(ao.OccurrenceDate AS DATETIME)
            )
        ) AS AttendanceTime
    FROM AttendanceOccurrence ao
    INNER JOIN Schedule s ON ao.ScheduleId = s.Id
    WHERE s.CategoryId != 285
      AND DATEADD(
              mi, 
              TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 19, 2) AS INT),
              DATEADD(
                  hh, 
                  TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 17, 2) AS INT),
                  TRY_CAST(ao.OccurrenceDate AS DATETIME)
              )
          ) BETWEEN DATEADD(hh, -2, @OADateTime) AND DATEADD(mi, -35, @OADateTime)
),
-- Subquery to gather parent and child data, replacing IN clause with a join
CommListParentsKids AS (
    SELECT 
        at.SundayDate,
        p.NickName,
        avContentChannel.Value AS ContentChannelGuid,
        parentgm.PersonId,
        CASE 
            WHEN g.GroupTypeId = 36 OR g.Id = 31 THEN 1
            WHEN g.Id = 141 THEN 2
            ELSE 0
        END AS EC
    FROM [Group] g
    INNER JOIN AttendanceTimes at ON g.Id = at.GroupId
    INNER JOIN AttributeValue avContentChannel ON g.Id = avContentChannel.EntityId
    INNER JOIN Attribute aContentChannel ON aContentChannel.Id = avContentChannel.AttributeId
        AND aContentChannel.[Key] = 'FollowUpMessageContentChannel'
        AND aContentChannel.EntityTypeId = 16
        AND aContentChannel.FieldTypeId = 76
    INNER JOIN Attendance a ON a.OccurrenceId = at.OccurrenceId AND a.DidAttend = 1
    INNER JOIN PersonAlias pa ON a.PersonAliasId = pa.Id
    INNER JOIN Person p ON pa.PersonId = p.Id 
    INNER JOIN [GroupMember] gm ON p.Id = gm.PersonId AND gm.GroupMemberStatus = 1
    INNER JOIN [Group] fam ON gm.GroupId = fam.Id 
        AND fam.IsActive = 1 
        AND fam.IsArchived = 0 
        AND fam.GroupTypeId = 10
    INNER JOIN GroupMember parentgm ON fam.Id = parentgm.GroupId 
        AND parentgm.PersonId != p.Id 
        AND parentgm.GroupMemberStatus = 1
    INNER JOIN GroupMember commListGroupMember ON parentgm.PersonId = commListGroupMember.PersonId 
        AND commListGroupMember.GroupId = 301252 
        AND commListGroupMember.GroupMemberStatus = 1
    GROUP BY 
        at.SundayDate,
        p.NickName,
        avContentChannel.Value,
        parentgm.PersonId,
        CASE 
            WHEN g.GroupTypeId = 36 OR g.Id = 31 THEN 1
            WHEN g.Id = 141 THEN 2
            ELSE 0
        END
),
-- Aggregate kids' nicknames per parent
ParentChannelKidsGrouped AS (
    SELECT 
        CommListParentsKids.SundayDate,
        CommListParentsKids.PersonId,
        CommListParentsKids.ContentChannelGuid,
        CommListParentsKids.EC,
        CASE 
            WHEN COUNT(DISTINCT CommListParentsKids.NickName) > 1
                THEN REVERSE(STUFF(
                    REVERSE(STRING_AGG(CommListParentsKids.NickName, ', ')), 
                    CHARINDEX(',', REVERSE(STRING_AGG(CommListParentsKids.NickName, ', '))), 
                    1, 
                    'dna '
                ))
            ELSE STRING_AGG(CommListParentsKids.NickName, ', ')
        END AS Kids
    FROM CommListParentsKids
    GROUP BY 
        CommListParentsKids.SundayDate,
        CommListParentsKids.PersonId,
        CommListParentsKids.ContentChannelGuid,
        CommListParentsKids.EC
),
-- Join with content channels and apply action item logic
Final AS (
    SELECT 
        pa.Guid AS Person,
        ParentChannelKidsGrouped.*,
        cci.Guid AS ActionItem,
        cc.Guid AS ActionContentChannel,
        pn.NumberFormatted,
        pn.NumberTypeValueId
    FROM ParentChannelKidsGrouped
    INNER JOIN ContentChannel cc ON cc.GUID = TRY_CAST(ParentChannelKidsGrouped.ContentChannelGuid AS UNIQUEIDENTIFIER)
    CROSS APPLY (
        SELECT 
            CASE 
                WHEN cc.Id = 533 THEN (
                    SELECT TOP 1 cci.[Guid]
                    FROM ContentChannelItem cci
                    INNER JOIN AttributeValue av ON cci.Id = av.EntityId 
                        AND av.Value IS NOT NULL 
                        AND TRIM(av.Value) != ''
                    INNER JOIN Attribute a ON av.AttributeId = a.Id 
                        AND a.[Key] = 'SMSDriveHomePrompt'
                    WHERE cc.Id = cci.ContentChannelId
                    ORDER BY NEWID()
                )
                ELSE (
                    SELECT TOP 1 cci.[Guid]
                    FROM ContentChannelItem cci
                    INNER JOIN AnalyticsSourceDate asd ON TRY_CAST(cci.StartDateTime AS DATE) = asd.[Date] 
                        AND asd.SundayDate = ParentChannelKidsGrouped.SundayDate
                    INNER JOIN AttributeValue avCategory ON cci.Id = avCategory.EntityId 
                        AND avCategory.AttributeId = 16287
                    INNER JOIN AttributeValue av ON cci.Id = av.EntityId 
                        AND av.Value IS NOT NULL 
                        AND TRIM(av.Value) != ''
                    INNER JOIN Attribute a ON av.AttributeId = a.Id 
                        AND a.[Key] = 'SMSDriveHomePrompt'
                    WHERE cc.Id = cci.ContentChannelId
                      AND (
                        ((avCategory.Value LIKE '%infant-kinder%') AND ParentChannelKidsGrouped.EC = 1) 
                        OR ((avCategory.Value LIKE '%1st-5th-grade%') AND ParentChannelKidsGrouped.EC = 0)
                        OR ((avCategory.Value = '5th-grade' OR avCategory.Value LIKE '%,5th grade') AND ParentChannelKidsGrouped.EC = 2)
                      )
                )
            END AS [Guid]
    ) cci
    INNER JOIN PersonAlias pa ON pa.AliasPersonId = ParentChannelKidsGrouped.PersonId
    INNER JOIN PhoneNumber pn ON pn.PersonId = pa.PersonId AND pn.NumberTypeValueId = 12
)
-- Final aggregation and output
SELECT 
    MIN(Final.Person) AS Person,
    Final.SundayDate,
    Final.ContentChannelGuid,
    Final.Kids,
    Final.ActionContentChannel,
    Final.NumberFormatted,
    Final.EC,
    MIN(Final.ActionItem) AS ActionItem,
    MAX(Final.ActionItem) AS ActionItemMax,
    COUNT(Final.ActionItem) AS ActionItemCount
FROM Final
GROUP BY 
    Final.SundayDate,
    Final.ContentChannelGuid,
    Final.Kids,
    Final.ActionContentChannel,
    Final.NumberFormatted,
    Final.EC;