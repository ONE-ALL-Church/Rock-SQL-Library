-- Implmemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=130&ExpandedIds=C758%2CC266

DECLARE @OADateTimeCutoff DATE
SET @OADateTimeCutoff = DATEADD(d, - 0, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');
DECLARE @OADateTimeStart DATE
SET @OADateTimeStart = DATEADD(month, - 1, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');

SELECT [Groups].[Count] [GroupMemberCount]
    , asd.[Date] [MetricValueDateTime]
    , [Groups].[CampusId]
FROM AnalyticsSourceDate asd
OUTER APPLY (
    SELECT COUNT(DISTINCT gm.PersonId) [Count]
        , gh.CampusId
    FROM GroupMember gm
    INNER JOIN GroupHistorical gh
        ON gh.GroupId = gm.GroupId
            AND asd.[Date] BETWEEN gh.EffectiveDateTime AND gh.ExpireDateTime
            AND gh.IsActive = 1
            AND gh.IsArchived != 1
    INNER JOIN GroupMemberHistorical gmh
        ON gm.Id = gmh.GroupMemberId
            AND asd.[Date] BETWEEN gmh.EffectiveDateTime AND gmh.ExpireDateTime
            AND gmh.GroupMemberStatus != 0
            AND gmh.IsArchived = 0
    INNER JOIN GroupTypeRole gtr
        ON gm.GroupRoleId = gtr.Id
    INNER JOIN AttributeValue serverole
        ON serverole.AttributeId = 12476
            AND serverole.EntityId = gtr.Id
            AND serverole.[Value] = 'True'
    LEFT JOIN AttributeValue servereg
        ON gh.GroupId = servereg.EntityId
            AND servereg.AttributeId = 13211
    WHERE (
        (
            servereg.ValueAsBoolean = 1
            OR servereg.ValueAsBoolean IS NULL
            )
        AND gh.GroupTypeId != 73
        AND gh.ParentGroupId != 117432
        )
    OR (gm.CreatedDateTime > DATEADD(month, - 1, GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
    GROUP BY gh.CampusId
    ) Groups
WHERE asd.[Date] BETWEEN @OADateTimeStart AND @OADateTimeCutoff
