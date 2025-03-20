-- Implemented At: https://admin.oneandall.church/admin/system/jobs/128
-- Tracked At: Check-in/SendKidsFollowUpSMS.sql

DECLARE @OADateTime DATETIME

SET @OADateTime = GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';
--SET @OADateTime = '2024-10-05 6:00PM';

SELECT *
FROM (
    SELECT MIN(Final.Person) Person
        , Final.SundayDate
        , Final.ContentChannelGuid
        , Final.Kids
        , Final.ActionContentChannel
        , Final.NumberFormatted
        , Final.EC
        , MIN(Final.ActionItem) ActionItem
    FROM (
        SELECT pa.Guid Person
            , ParentChannelKidsGrouped.*
            , cci.Guid ActionItem
            , cc.Guid ActionContentChannel
            , pn.NumberFormatted
            , pn.NumberTypeValueId
        FROM (
            SELECT CommListParentsKids.SundayDate
                , CommListParentsKids.PersonId
                , CommListParentsKids.ContentChannelGuid
                , CommListParentsKids.EC
                , CASE 
                    WHEN COUNT(DISTINCT CommListParentsKids.Nickname) > 1
                        THEN REVERSE(STUFF(REVERSE(STRING_AGG(CommListParentsKids.Nickname, ', ')), CHARINDEX(',', REVERSE(STRING_AGG(CommListParentsKids.Nickname, ', '))), 1, 'dna '))
                    ELSE STRING_AGG(CommListParentsKids.Nickname, ', ')
                    END Kids
            FROM (
                SELECT ao.SundayDate
                    , p.NickName
                    , avContentChannel.Value ContentChannelGuid
                    , parentgm.PersonId
                    , CASE 
                        WHEN g.GroupTypeId = 36 OR g.Id = 31 THEN 1
                        WHEN g.Id = 141 THEN 2
                        ELSE 0
                    END EC
                FROM [Group] g
                INNER JOIN AttendanceOccurrence ao
                    ON g.Id = ao.GroupId
                        AND g.GroupTypeId IN (19, 20, 21, 36)
                INNER JOIN Schedule s
                    ON ao.ScheduleId = s.Id
                        AND s.CategoryId != 285
                        AND DATEADD(mi, TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 19, 2) AS INT), DATEADD(hh, TRY_CAST(SUBSTRING(s.iCalendarContent, CHARINDEX('DTSTART:', s.iCalendarContent) + 17, 2) AS INT), TRY_CAST(ao.OccurrenceDate AS DATETIME))) BETWEEN DATEADD(hh, - 2, @OADateTime) AND DATEADD(mi, - 35, @OADateTime)
                INNER JOIN AttributeValue avContentChannel
                    ON g.Id = avContentChannel.EntityId
                INNER JOIN Attribute aContentChannel
                    ON aContentChannel.Id = avContentChannel.AttributeId
                        AND aContentChannel.[Key] = 'FollowUpMessageContentChannel'
                        AND aContentChannel.EntityTypeId = 16
                        AND aContentChannel.FieldTypeId = 76
                INNER JOIN Attendance a
                    ON a.OccurrenceId = ao.Id
                        AND a.DidAttend = 1
                INNER JOIN PersonAlias pa
                    ON a.PersonAliasId = pa.Id
                INNER JOIN Person p
                    ON pa.PersonId = p.Id
                INNER JOIN [GroupMember] gm
                    ON p.Id = gm.PersonId
                        AND gm.GroupMemberStatus = 1
                INNER JOIN [Group] fam
                    ON gm.GroupId = fam.Id
                        AND fam.IsActive = 1
                        AND fam.IsArchived = 0
                        AND fam.GroupTypeId = 10
                INNER JOIN GroupMember parentgm
                    ON fam.Id = parentgm.GroupId
                        AND parentgm.PersonId != p.Id
                        AND parentgm.GroupMemberStatus = 1
                        AND parentgm.PersonId IN (
                            SELECT commListGroupMember.PersonId
                            FROM GroupMember commListGroupMember
                            WHERE commListGroupMember.GroupId = 301252
                                AND commListGroupMember.GroupMemberStatus = 1
                            )
                GROUP BY ao.SundayDate
                    , p.NickName
                    , avContentChannel.Value
                    , parentgm.PersonId
                    , CASE 
                        WHEN g.GroupTypeId = 36 OR g.Id = 31 THEN 1
                        WHEN g.Id = 141 THEN 2
                        ELSE 0
                    END
                ) CommListParentsKids
            GROUP BY CommListParentsKids.SundayDate
                , CommListParentsKids.PersonId
                , CommListParentsKids.ContentChannelGuid
                , CommListParentsKids.EC
            ) ParentChannelKidsGrouped
        INNER JOIN ContentChannel cc
            ON cc.GUID = TRY_CAST(ParentChannelKidsGrouped.ContentChannelGuid AS UNIQUEIDENTIFIER)
        CROSS APPLY (
            SELECT CASE 
                    WHEN cc.Id = 533
                        THEN (
                                SELECT TOP 1 cci.Guid
                                FROM ContentChannelItem cci
                                INNER JOIN AttributeValue av
                                    ON cci.Id = av.EntityId
                                        AND av.Value IS NOT NULL
                                        AND TRIM(av.Value) != ''
                                INNER JOIN Attribute a
                                    ON av.AttributeId = a.Id
                                        AND a.[Key] = 'SMSDriveHomePrompt'
                                WHERE cc.Id = cci.ContentChannelId
                                ORDER BY NEWID()
                                )
                    ELSE (
                            SELECT TOP 1 cci.Guid
                            FROM ContentChannelItem cci
                            INNER JOIN AnalyticsSourceDate asd
                                ON TRY_CAST(cci.StartDateTime AS DATE) = asd.DATE
                                    AND asd.SundayDate = ParentChannelKidsGrouped.SundayDate
                            INNER JOIN AttributeValue avCategory ON cci.Id = avCategory.EntityId AND avCategory.AttributeId = 16287
                            INNER JOIN AttributeValue av
                                ON cci.Id = av.EntityId
                                    AND av.Value IS NOT NULL
                                    AND TRIM(av.Value) != ''
                            INNER JOIN Attribute a
                                ON av.AttributeId = a.Id
                                    AND a.[Key] = 'SMSDriveHomePrompt'
                            WHERE cc.Id = cci.ContentChannelId
                                AND ((avCategory.Value LIKE '%infant-kinder%' AND ParentChannelKidsGrouped.EC = 1) 
                                OR (avCategory.Value LIKE '%1st-5th-grade%' AND ParentChannelKidsGrouped.EC = 0)
                                OR (avCategory.Value LIKE '%5th-grade%' AND ParentChannelKidsGrouped.EC = 2)
                                )
                                
                            )
                    END [Guid]
            ) cci
        INNER JOIN PersonAlias pa
            ON pa.AliasPersonId = ParentChannelKidsGrouped.PersonId --AND pa.PersonId = 26
        INNER JOIN PhoneNumber pn
            ON pn.PersonId = pa.PersonId
                AND pn.NumberTypeValueId = 12
        ) Final
    GROUP BY Final.SundayDate
        , Final.ContentChannelGuid
        , Final.Kids
        , Final.ActionContentChannel
        , Final.NumberFormatted
        , Final.EC
    ) InteractionCheck
WHERE NOT EXISTS (
    SELECT 1
    FROM PersonAlias pa
    INNER JOIN PhoneNumber pn
        ON pn.PersonId = pa.PersonId
            AND pn.NumberTypeValueId = 12
    INNER JOIN PhoneNumber pn2
        ON pn.NumberFormatted = pn2.NumberFormatted
            AND pn2.NumberTypeValueId = 12
    INNER JOIN ContentChannelItem cciAction
        ON TRY_CAST(InteractionCheck.ActionItem AS UNIQUEIDENTIFIER) = cciAction.Guid
    INNER JOIN PersonAlias pa2
        ON pn2.PersonId = pa2.PersonId
    INNER JOIN Interaction i
        ON i.PersonAliasId = pa2.Id
    INNER JOIN AnalyticsSourceDate asdInteraction ON i.InteractionDateKey = asdInteraction.DateKey
    INNER JOIN AnalyticsSourceDate asdNow ON TRY_CAST(@OADateTime AS DATE) = asdNow.Date
    INNER JOIN InteractionComponent ic
        ON i.InteractionComponentId = ic.Id
    INNER JOIN ContentChannelItem cciInteraction ON ic.EntityId = cciInteraction.Id
    INNER JOIN InteractionChannel ich
        ON ic.InteractionChannelId = ich.Id
            AND ich.ComponentEntityTypeId = 209
    WHERE pa.Guid = TRY_CAST(InteractionCheck.Person AS UNIQUEIDENTIFIER)
    AND ((ic.EntityId = cciAction.Id AND cciAction.ContentChannelId != 533)
    OR (cciAction.ContentChannelId = 533 AND cciInteraction.ContentChannelId = 533 AND asdNow.SundayDate = asdInteraction.SundayDate ))
    ) 