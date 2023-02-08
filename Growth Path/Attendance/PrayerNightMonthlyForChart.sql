SELECT DISTINCT mv.MetricValueDateTime AS [Date]
FROM MetricValue AS mv
WHERE mv.MetricId = 9
    AND MetricValueDateTime > dateadd(year, - 1, getdate())
    AND mv.YValue IS NOT NULL
    AND mv.YValue != 0

SELECT DISTINCT mv.MetricValueDateTime AS [Date]
    , campuses.Name as SeriesName
    , campuses.Id as CampusId
    , metrics.YValue AS [YValue]
FROM MetricValue AS mv
OUTER APPLY (SELECT c.Id, c.Name from Campus c WHERE c.CampusTypeValueId=2295 and c.CampusStatusValueId=2292) campuses
INNER JOIN (SELECT DISTINCT YValue
    , c2.Id
    , mv2.MetricValueDateKey
FROM MetricValue AS mv2
LEFT JOIN [MetricValuePartition] AS mvps2
    ON mv2.Id = mvps2.MetricValueId
INNER JOIN [MetricPartition] AS mps2
    ON mvps2.MetricPartitionId = mps2.Id
        AND mps2.EntityTypeId = 54
LEFT JOIN [Schedule] AS s2
    ON mvps2.EntityId = s2.Id
LEFT JOIN [MetricValuePartition] AS mvpc2
    ON mv2.Id = mvpc2.MetricValueId
INNER JOIN [MetricPartition] AS mpc2
    ON mvpc2.MetricPartitionId = mpc2.Id
        AND mpc2.EntityTypeId = 67
INNER JOIN [Campus] AS c2
    ON mvpc2.EntityId = c2.Id
WHERE mv2.MetricId = 9
    AND mv2.MetricValueDateTime > dateadd(year, - 1, getdate())
    AND mv2.YValue IS NOT NULL
    AND mv2.YValue != 0) metrics
    ON metrics.Id = campuses.Id AND metrics.MetricValueDateKey = mv.MetricValueDateKey
WHERE mv.MetricId = 9
    AND mv.MetricValueDateTime > dateadd(year, - 1, getdate())
    AND mv.YValue IS NOT NULL
    AND mv.YValue != 0
ORDER BY campuses.Id, mv.MetricValueDateTime