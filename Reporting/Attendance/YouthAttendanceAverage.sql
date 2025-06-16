SELECT CAST(SUM([MV].[YValue]) AS INT) AS [TotalAttendance],
    CAST(SUM([MV].[YValue]) AS INT) / COUNT(DISTINCT mv.MetricValueDateTime) AS [AverageAttendance],
    COUNT(DISTINCT mv.MetricValueDateTime) AS [TimesMet]

FROM Category cArea
INNER JOIN MetricCategory mc ON cArea.Id = mc.CategoryId
INNER JOIN Metric m ON mc.MetricId = m.Id
INNER JOIN [MetricValue] AS [MV] ON mv.MetricId = m.Id
LEFT JOIN [MetricValuePartition] AS mvps
    ON mv.Id = mvps.MetricValueId
LEFT JOIN [MetricPartition] AS mps
    ON mvps.MetricPartitionId = mps.Id
        AND mps.EntityTypeId = 54
LEFT JOIN [Schedule] AS s
    ON mvps.EntityId = s.Id
INNER JOIN [MetricPartition] AS [MPCampus]
    ON [MPCampus].[MetricId] = m.[Id]
INNER JOIN [EntityType] AS [ETCampus]
    ON [ETCampus].[Id] = [MPCampus].[EntityTypeId]
        AND [ETCampus].[Name] = 'Rock.Model.Campus'
INNER JOIN [MetricValuePartition] AS [MVCampus]
    ON [MVCampus].[MetricValueId] = [MV].[Id]
        AND [MVCampus].[MetricPartitionId] = [MPCampus].[Id]
INNER JOIN [Campus] AS [C]
    ON [C].[Id] = [MVCampus].[EntityId]
INNER JOIN AnalyticsSourceDate asd
    ON convert(DATE, mv.MetricValueDateTime, 101) = asd.DATE
WHERE  [MV].[YValue] != 0
    AND (
        (
            [MV].[MetricID] = 10
            )
        )
    AND c.Id != 8
    --AND mv.MetricValueDateTime BETWEEN '2025-01-01' AND '2025-04-30'
    AND mv.MetricValueDateTime BETWEEN '2024-01-01' AND '2024-12-31'
