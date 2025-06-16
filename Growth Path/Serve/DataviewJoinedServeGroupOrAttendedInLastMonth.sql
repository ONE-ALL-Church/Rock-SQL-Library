--Implemented At: https://admin.oneandall.church/reporting/dataviews?DataViewId=1332&ExpandedIds=C648%2CC675%2CC688%2CC689
-- Tracked At: Growth Path/Serve/DataviewJoinedServeGroupOrAttendedInLastMonth.sql
/* === 1.  Pre-compute the date boundary just once ======================= */
DECLARE @StartDate DATETIME2(0) =
       DATEADD(MONTH, -1,
               SYSUTCDATETIME() AT TIME ZONE 'Pacific Standard Time');

/* === 2.  People who hold the “right kind” of active group membership === */
;WITH ActiveGroupMembers AS (
    SELECT  gm.PersonId ,
            gm.GroupId ,
            gm.CreatedDateTime
    FROM    GroupMember      gm
    JOIN    [Group]          g   ON g.Id          = gm.GroupId
                                  AND g.IsActive  = 1
                                  AND g.IsArchived = 0
    JOIN    GroupTypeRole    gtr ON gtr.Id        = gm.GroupRoleId
    JOIN    AttributeValue   av  ON av.AttributeId = 12476   -- “opt-in” flag
                                  AND av.EntityId   = gtr.Id
                                  AND av.[Value]   = 'True'
    WHERE   gm.IsArchived        = 0
      AND   gm.GroupMemberStatus <> 0           -- active / pending
),

/* === 3.  Those members created in the last month ======================= */
RecentMembers AS (
    SELECT DISTINCT PersonId
    FROM   ActiveGroupMembers
    WHERE  CreatedDateTime >= @StartDate
),

/* === 4.  Those members who attended their group in the last month ====== */
RecentAttendees AS (
    SELECT DISTINCT pa.PersonId
    FROM   AttendanceOccurrence ao
    JOIN   Attendance           a   ON a.OccurrenceId = ao.Id
    JOIN   PersonAlias          pa  ON pa.Id          = a.PersonAliasId
    JOIN   ActiveGroupMembers   gm  ON gm.GroupId     = ao.GroupId
                                     AND gm.PersonId  = pa.PersonId
    WHERE  ao.OccurrenceDate >= @StartDate
)

/* === 5.  Final result =================================================== */
SELECT DISTINCT PersonId
FROM (
    SELECT PersonId FROM RecentMembers
    UNION
    SELECT PersonId FROM RecentAttendees
) p;