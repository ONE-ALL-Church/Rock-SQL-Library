SELECT Pivoted.[Year]
    , Pivoted.Week
    , CAST(Pivoted.[DateTime] AS date ) [Date]
    , CAST(Pivoted.[San Dimas Campus] AS INT) AS SanDimasCampus
    , CAST(Pivoted.[Rancho Cucamonga Campus] AS INT) AS RanchoCampus
    , CAST(Pivoted.[Lone Hill Campus] AS INT) AS LoneHillCampus
    , CAST(Pivoted.[West Covina Campus] AS INT) AS WestCovinaCampus
    , CAST(Pivoted.Total AS INT) Total
    , CAST(Aver.Average AS INT) Average
FROM (
    SELECT *
        , ISNULL([San Dimas Campus], 0) + ISNULL([Rancho Cucamonga Campus], 0) + ISNULL([Lone Hill Campus], 0) + ISNULL([West Covina Campus], 0) + ISNULL([Online Campus], 0) AS Total
    FROM (
        SELECT asd.CalendarYear AS Year
            , asd.CalendarWeek AS [Week]
            , SUM([MV].[YValue]) AS [Value]
            , [MV].[MetricValueDateTime] AS [DateTime]
            , [C].[Name] AS [Campus]
            , 'Line' AS [Schedule]
        FROM [MetricValue] AS [MV]
        INNER JOIN [Metric] AS [M]
            ON [M].[Id] = [MV].[MetricId]
        LEFT JOIN [MetricValuePartition] AS mvps
            ON mv.Id = mvps.MetricValueId
        LEFT JOIN [MetricPartition] AS mps
            ON mvps.MetricPartitionId = mps.Id
                AND mps.EntityTypeId = 54
        LEFT JOIN [Schedule] AS s
            ON mvps.EntityId = s.Id
        INNER JOIN [MetricPartition] AS [MPCampus]
            ON [MPCampus].[MetricId] = [M].[Id]
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
        WHERE [MV].[MetricId] IN (7, 6, 8, 10, 16, 17, 18, 19, 20, 21, 51, 52, 53)
            AND [MV].[MetricValueDateTime] > DATEADD(YEAR, - 8, GETDATE())
            AND [MV].[YValue] != 0
            AND (
                (
                    [MV].[MetricID] NOT IN (51, 52, 53)
                    AND s.CategoryId IN (171, 50, 286, 326)
                    AND mps.EntityTypeId IS NOT NULL
                    )
                OR [MV].[MetricValueDateTime] < '2018-08-05'
                )
            AND [MetricValueDateTime] >= '01/01/2017'
            AND c.Id != 8
        GROUP BY asd.CalendarYear
            , ASD.CalendarWeek
            , [MV].[MetricValueDateTime]
            , [C].[Name]
        ) Att
    PIVOT(SUM([Value]) FOR Campus IN ([San Dimas Campus], [Rancho Cucamonga Campus], [Lone Hill Campus], [West Covina Campus], [Online Campus])) AS PivotSales
    ) Pivoted
INNER JOIN (
    SELECT Dates.[DateTime]
        , AVG(Av.[Value]) AS [Average]
    FROM (
        SELECT [MV].[MetricValueDateTime] AS [DateTime]
        FROM [MetricValue] AS [MV]
        INNER JOIN [Metric] AS [M]
            ON [M].[Id] = [MV].[MetricId]
        INNER JOIN AnalyticsSourceDate asd
            ON convert(DATE, mv.MetricValueDateTime, 101) = asd.DATE
        WHERE [MV].[MetricId] IN (7, 6, 8, 10, 16, 17, 18, 19, 20, 21, 51, 52, 53)
            AND [MV].[MetricValueDateTime] > DATEADD(YEAR, - 8, GETDATE())
            AND [MV].[YValue] != 0
            AND (
                [MV].[MetricID] NOT IN (51, 52, 53)
                OR [MV].[MetricValueDateTime] < '2018-08-05'
                )
        GROUP BY [MV].[MetricValueDateTime]
        ) Dates
    INNER JOIN (
        SELECT asd.CalendarYear AS Year
            , asd.CalendarWeek AS [Week]
            , SUM([MV].[YValue]) AS [Value]
            , [MV].[MetricValueDateTime] AS [DateTime]
        FROM [MetricValue] AS [MV]
        INNER JOIN [Metric] AS [M]
            ON [M].[Id] = [MV].[MetricId]
        LEFT JOIN [MetricValuePartition] AS mvps
            ON mv.Id = mvps.MetricValueId
        LEFT JOIN [MetricPartition] AS mps
            ON mvps.MetricPartitionId = mps.Id
                AND mps.EntityTypeId = 54
        LEFT JOIN [Schedule] AS s
            ON mvps.EntityId = s.Id
        INNER JOIN [MetricPartition] AS [MPCampus]
            ON [MPCampus].[MetricId] = [M].[Id]
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
        WHERE [MV].[MetricId] IN (7, 6, 8, 10, 16, 17, 18, 19, 20, 21, 51, 52, 53)
            AND [MV].[MetricValueDateTime] > DATEADD(YEAR, - 8, GETDATE())
            AND [MV].[YValue] != 0
            AND (
                (
                    [MV].[MetricID] NOT IN (51, 52, 53)
                    AND s.CategoryId IN (171, 50, 286, 326)
                    AND mps.EntityTypeId IS NOT NULL
                    )
                OR [MV].[MetricValueDateTime] < '2018-08-05'
                )
            AND asd.EasterWeekIndicator != 1
            AND asd.ChristmasWeekIndicator != 1
            AND NOT (
                asd.CalendarMonth = 12
                AND asd.DayNumberInCalendarMonth IN (23, 24)
                )
            AND c.Id != 8
        GROUP BY asd.CalendarYear
            , ASD.CalendarWeek
            , [MV].[MetricValueDateTime]
        ) Av
        ON Av.[DateTime] BETWEEN DATEADD(WEEK, - 12, Dates.[DateTime]) AND Dates.[DateTime]
    GROUP BY Dates.[DateTime]
    ) Aver
    ON Aver.[DateTime] = Pivoted.[DateTime]
ORDER BY Year
    , Week
