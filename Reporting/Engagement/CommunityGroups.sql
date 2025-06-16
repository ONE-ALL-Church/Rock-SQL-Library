/* -----------------------------------------------------------
   Unique people in a Community Group (purpose value 2568)
   at any point in the last 12 months (rolling window)
   -----------------------------------------------------------*/

DECLARE @EndDate   DATE = '2024-04-30';
DECLARE @StartDate DATE = DATEADD(month, -12, @EndDate);

/* 1️⃣  Community-Group lookup */
;WITH CommGroups AS (
    SELECT g.Id
    FROM   [Group]      g
    JOIN   GroupType    gt ON gt.Id = g.GroupTypeId
    WHERE  gt.GroupTypePurposeValueId = 2568            -- “Community Group”
),

/* 2️⃣  People whose membership interval overlaps the rolling window
        ( uses GroupMemberHistorical to respect status + archival ) */
PeopleInWindow AS (
    SELECT DISTINCT gm.PersonId
    FROM   CommGroups           cg
    JOIN   GroupMember          gm  ON gm.GroupId = cg.Id
    JOIN   GroupMemberHistorical gmh ON gmh.GroupMemberId = gm.Id
    WHERE  gmh.IsArchived = 0
      AND  gmh.GroupMemberStatus <> 0                   -- active / pending / etc.
      /* Overlap test: membership interval intersects last-12-months window */
      AND  gmh.EffectiveDateTime <= @EndDate
      AND  gmh.ExpireDateTime    >= @StartDate
)

/* 3️⃣  Final unique-person count */
SELECT COUNT(*) AS UniqueCommunityGroupPeopleLast12Months
FROM   PeopleInWindow;
