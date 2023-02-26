--Implemented At: https://admin.oneandall.church/reporting/dataviews?DataViewId=1332&ExpandedIds=C648%2CC675%2CC688%2CC689
-- Tracked At: Mobile/DataviewJoinedServeGroupOrAttendedInLastMonth.sql
DECLARE @OADateTime DATETIME
SET @OADateTime = GETUTCDATE() AT TIME ZONE 'Pacific Standard Time';

SELECT DISTINCT gm.PersonId
FROM GroupTypeRole gtr
INNER JOIN AttributeValue av ON av.AttributeId = 12476 AND av.EntityId = gtr.Id AND av.[Value] = 'True'
INNER JOIN GroupMember gm ON gtr.Id = gm.GroupRoleId AND gm.IsArchived = 0 AND gm.GroupMemberStatus != 0
INNER JOIN [Group] g ON gm.GroupId = g.Id AND g.IsActive = 1 AND g.IsArchived != 1 
WHERE 
        (gm.CreatedDateTime > DATEADD(month, -1, GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time') OR
        EXISTS (
            SELECT 1
            FROM PersonAlias pa 
            INNER JOIN Attendance a ON gm.PersonId = pa.PersonId AND a.PersonAliasId = pa.Id
            INNER JOIN AttendanceOccurrence ao ON a.OccurrenceId = ao.Id AND gm.GroupId = ao.GroupId AND ao.OccurrenceDate >  DATEADD(month, -1, GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time')
        )
    )
