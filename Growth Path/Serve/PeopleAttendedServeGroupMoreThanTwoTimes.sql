DECLARE @OADateTime DATETIME

SET @OADateTime = GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';

SELECT COUNT(DISTINCT PersonId) People,
    SUM(AttendanceCount) Attendances
FROM (
    SELECT pa.PersonId,
        COUNT(DISTINCT ao.Id) AS 'AttendanceCount'
    FROM GroupTypeRole gtr
    INNER JOIN AttributeValue av ON av.AttributeId = 12476
        AND av.EntityId = gtr.Id
        AND av.[Value] = 'True'
    INNER JOIN GroupMember gm ON gtr.Id = gm.GroupRoleId
        AND gm.IsArchived = 0
        AND gm.GroupMemberStatus != 0
    INNER JOIN [Group] ON gm.GroupId = [Group].Id
        AND [Group].GroupTypeId != 49
    INNER JOIN PersonAlias pa ON gm.PersonId = pa.PersonId
    INNER JOIN Attendance a ON a.DidAttend = 1
        AND a.PersonAliasId = pa.Id
    INNER JOIN AttendanceOccurrence ao ON gm.GroupId = ao.GroupId
        AND a.OccurrenceId = ao.Id
        AND ao.OccurrenceDate > DATEADD(week, - 12, @OADateTime)
    GROUP BY pa.PersonId
    HAVING COUNT(DISTINCT ao.Id) >= 2
    ) AS Persons