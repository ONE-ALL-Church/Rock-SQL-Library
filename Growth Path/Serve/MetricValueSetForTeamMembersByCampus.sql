-- Implmemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=130&ExpandedIds=C758%2CC266

DECLARE @OADateTimeCutoff DATE

SET @OADateTimeCutoff = DATEADD(d, - 0, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');

DECLARE @OADateTimeStart DATE

SET @OADateTimeStart = DATEADD(month, - 1, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');
SET @OADateTimeStart = '2021-09-05'

SELECT [Groups].[Count] [GroupMemberCount],
    asd.[Date] [MetricValueDateTime],
    [Groups].[CampusId]
FROM AnalyticsSourceDate asd
OUTER APPLY (
    SELECT COUNT(DISTINCT gm.PersonId) [Count],
        CASE 
            WHEN asph.CampusId IS NOT NULL
                THEN asph.CampusId
            ELSE p.PrimaryCampusId
            END CampusId
    FROM GroupMember gm
    INNER JOIN Person p ON gm.PersonId = p.Id
    LEFT JOIN AnalyticsDimPersonHistorical asph ON asph.PersonId = p.Id
        AND asd.[Date] BETWEEN asph.EffectiveDate
            AND asph.ExpireDate
    INNER JOIN GroupHistorical gh ON gh.GroupId = gm.GroupId
        AND asd.[Date] BETWEEN gh.EffectiveDateTime
            AND gh.ExpireDateTime
        AND gh.IsActive = 1
        AND gh.IsArchived != 1
    INNER JOIN GroupMemberHistorical gmh ON gm.Id = gmh.GroupMemberId
        AND asd.[Date] BETWEEN gmh.EffectiveDateTime
            AND gmh.ExpireDateTime
        AND gmh.GroupMemberStatus != 0
        AND gmh.IsArchived = 0
    WHERE gm.GroupId = 272183
    GROUP BY CASE 
            WHEN asph.CampusId IS NOT NULL
                THEN asph.CampusId
            ELSE p.PrimaryCampusId
            END
    ) Groups
WHERE asd.[Date] BETWEEN @OADateTimeStart
        AND @OADateTimeCutoff
ORDER BY asd.[Date] ASC
