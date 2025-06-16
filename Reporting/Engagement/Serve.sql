/* ============================================================
   Unique people who served in the last 12 months
   Scope: any descendant of ParentGroupId = 56
          whose GroupTypePurposeValueId = 184
   Result: one row, one column (UniqueServers)
   ============================================================*/

DECLARE @EndDate   DATE = CAST(GETUTCDATE() AT TIME ZONE 'Pacific Standard Time' AS DATE);
DECLARE @StartDate DATE = DATEADD(month, -12, @EndDate);   -- rolling 12-month window

/* 1️⃣  Recursively gather every “serve” team */
;WITH CommGroups AS (
    /* root level */
    SELECT g.Id, gt.GroupTypePurposeValueId
    FROM   [Group]   g
    JOIN   GroupType gt ON gt.Id = g.GroupTypeId
    WHERE  g.ParentGroupId = 56

    UNION  ALL

    /* children & deeper levels */
    SELECT child.Id, gt2.GroupTypePurposeValueId
    FROM   [Group]     child
    JOIN   GroupType   gt2   ON gt2.Id = child.GroupTypeId
    JOIN   CommGroups  parent ON child.ParentGroupId = parent.Id
),

/* 2️⃣  Keep only teams whose purpose marks them as “serving / volunteer” */
ServeGroups AS (
    SELECT Id
    FROM   CommGroups
    WHERE  GroupTypePurposeValueId = 184
),

/* 3️⃣  Distinct people whose membership interval overlaps the 12-month window */
PeopleInWindow AS (
    SELECT DISTINCT gm.PersonId
    FROM   ServeGroups            sg
    JOIN   GroupMember            gm  ON gm.GroupId = sg.Id
    JOIN   GroupMemberHistorical  gmh ON gmh.GroupMemberId = gm.Id
    JOIN   GroupHistorical        gh  ON gh.GroupId = sg.Id
    WHERE  gh.IsActive   = 1
      AND  gh.IsArchived = 0
      AND  gmh.IsArchived = 0
      AND  gmh.GroupMemberStatus <> 0          -- active / pending / etc.
      /* group & member intervals overlap the window */
      AND  gh.EffectiveDateTime  <= @EndDate
      AND  gh.ExpireDateTime     >= @StartDate
      AND  gmh.EffectiveDateTime <= @EndDate
      AND  gmh.ExpireDateTime    >= @StartDate
      /* ensure the team had >1 non-leader volunteers in the window */
      AND (
            SELECT COUNT(*)
            FROM   GroupMemberHistorical gmh2
            JOIN   GroupTypeRole gtr2 ON gtr2.Id = gmh2.GroupRoleId
            WHERE  gmh2.GroupId = sg.Id
              AND  gtr2.IsLeader = 0
              AND  gmh2.IsArchived = 0
              AND  gmh2.GroupMemberStatus <> 0
              AND  gmh2.EffectiveDateTime <= @EndDate
              AND  gmh2.ExpireDateTime    >= @StartDate
          ) > 1
)

/* 4️⃣  Final count */
SELECT COUNT(*) AS UniqueServersLast12Months
FROM   PeopleInWindow;
