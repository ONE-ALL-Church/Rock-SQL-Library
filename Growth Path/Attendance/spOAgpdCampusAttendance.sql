DECLARE @CampusEntityType INT = 67
DECLARE @ScheduleEntityType INT = 54
DECLARE @GrowTogetherMetricId INT = 123

-- Returns Row for Each Campus according to Parameters:
--  CampusId
--  CampusName
--  Total
--  Thirteen Week Average
--  Previous Year Thirteen Week Average
--  First Sunday Thirteen Week Average

DECLARE @PreviousSunday DATETIME = CONVERT(DATETIME, @ReportingSunday)

DECLARE @PreviousYearSunday DATETIME

SELECT @PreviousYearSunday = MAX([Date])
FROM [AnalyticsSourceDate]
WHERE DATEPART(year, [Date]) = DATEPART(year, @PreviousSunday) -1
    AND DATEPART(WEEK, [Date]) <= DATEPART(WEEK, @PreviousSunday)
    AND DayOfWeek = 0

SELECT Agg.CampusId
    , Agg.CampusName
    , PreviousSundayTable.Total AS "Total"
    , Agg.ThirteenAverage
    , PreviousYearAverage.ThirteenWeekAverage AS "PreviousYearThirteenAverage"
    , FirstSundayAverage.ThirteenWeekAverage AS "FirstSundayThirteenAverage"
FROM (
    SELECT sub.CampusName
        , sub.CampusId
        , AVG(Total) AS ThirteenAverage
    FROM (
        SELECT mv.MetricValueDateTime
            , mvpc.EntityId AS CampusId
            , c.Name AS CampusName
            , SUM(YValue) AS Total
        FROM [MetricValue] AS mv
        LEFT JOIN [MetricValuePartition] AS mvps
            ON mv.Id = mvps.MetricValueId
        INNER JOIN [MetricPartition] AS mps
            ON mvps.MetricPartitionId = mps.Id
                AND mps.EntityTypeId = @ScheduleEntityType
        LEFT JOIN [Schedule] AS s
            ON mvps.EntityId = s.Id
        LEFT JOIN [MetricValuePartition] AS mvpc
            ON mv.Id = mvpc.MetricValueId
        INNER JOIN [MetricPartition] AS mpc
            ON mvpc.MetricPartitionId = mpc.Id
                AND mpc.EntityTypeId = @CampusEntityType
        INNER JOIN [Campus] AS C
            ON mvpc.EntityId = c.Id
        INNER JOIN AnalyticsSourceDate asd
            ON convert(DATE, mv.MetricValueDateTime, 101) = asd.DATE
        WHERE mv.MetricId IN (6, 7, 8, 16, 17, 18, 161, 162)
            AND (
                s.CategoryId = 50
                OR s.Id = 4498
                OR s.CategoryId = 326
                )
            AND (
                [MV].[MetricID] NOT IN (161, 162)
                OR [MV].[MetricValueDateTime] > '2025-01-13'
            )
            AND mv.MetricValueDateTime <= @PreviousSunday
            AND mv.MetricValueDateTime >= DATEADD(WEEK, - 12, @PreviousSunday)
            AND mv.MetricValueDateTime != '2019-12-22'
            AND mv.MetricValueDateTime != '2021-12-26'
            AND asd.EasterWeekIndicator != 1
            AND asd.DATE != '2019-12-22'
            AND asd.DATE != '2021-12-26'
        GROUP BY mvpc.EntityId
            , c.Name
            , mv.MetricValueDateTime
        ) sub
    GROUP BY sub.CampusName
        , sub.CampusId
    ) Agg
LEFT JOIN (
    SELECT mvpc.EntityId AS CampusId
        , c.Name AS CampusName
        , SUM(YValue) AS Total
    FROM [MetricValue] AS mv
    LEFT JOIN [MetricValuePartition] AS mvps
        ON mv.Id = mvps.MetricValueId
    INNER JOIN [MetricPartition] AS mps
        ON mvps.MetricPartitionId = mps.Id
            AND mps.EntityTypeId = @ScheduleEntityType
    LEFT JOIN [Schedule] AS s
        ON mvps.EntityId = s.Id
    LEFT JOIN [MetricValuePartition] AS mvpc
        ON mv.Id = mvpc.MetricValueId
    INNER JOIN [MetricPartition] AS mpc
        ON mvpc.MetricPartitionId = mpc.Id
            AND mpc.EntityTypeId = @CampusEntityType
    INNER JOIN [Campus] AS C
        ON mvpc.EntityId = c.Id
    WHERE mv.MetricId IN (6, 7, 8, 16, 17, 18, 161, 162)
        AND (
            s.CategoryId IN (50, 326, 337)
            OR s.Id = 4498
            )
        AND (
            [MV].[MetricID] NOT IN (161, 162)
            OR [MV].[MetricValueDateTime] > '2025-01-13'
            )
        AND mv.MetricValueDateTime = @PreviousSunday
    GROUP BY mvpc.EntityId
        , c.Name
    ) AS PreviousSundayTable
    ON Agg.CampusId = PreviousSundayTable.CampusId
LEFT JOIN (
    SELECT C.Id AS CampusId
        , SUM([MV].[YValue]) / COUNT(DISTINCT DATEPART(isowk, mv.MetricValueDateTime)) AS ThirteenWeekAverage
    FROM [MetricValue] AS [MV]
    INNER JOIN [Metric] AS [M]
        ON [M].[Id] = [MV].[MetricId]
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
    WHERE [MV].[MetricId] IN (7, 6, 8, 16, 17, 18, 51, 52, 53, 161, 162)
        AND [MV].[MetricValueDateTime] > DATEADD(YEAR, - 8, GETDATE())
        AND [MV].[YValue] != 0
        AND (
            [MV].[MetricID] NOT IN (51, 52, 53)
            OR [MV].[MetricValueDateTime] < '2018-08-05'
            )
        AND (
            [MV].[MetricID] NOT IN (161, 162)
            OR [MV].[MetricValueDateTime] > '2025-01-13'
            )
        AND mv.MetricValueDateTime BETWEEN DATEADD(WEEK, - 12, @PreviousYearSunday) AND @PreviousYearSunday
        AND mv.MetricValueDateTime != '2019-12-22'
        AND mv.MetricValueDateTime != '2021-12-26'
        AND asd.EasterWeekIndicator != 1
    GROUP BY c.Id
    ) AS PreviousYearAverage
    ON Agg.CampusId = PreviousYearAverage.CampusId
LEFT JOIN (
    SELECT C.Id AS CampusId
        , SUM([MV].[YValue]) / COUNT(DISTINCT DATEPART(isowk, mv.MetricValueDateTime)) AS ThirteenWeekAverage
    FROM [MetricValue] AS [MV]
    INNER JOIN [Metric] AS [M]
        ON [M].[Id] = [MV].[MetricId]
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
    WHERE [MV].[MetricId] IN (7, 6, 8, 10, 16, 17, 18, 51, 52, 53, 161, 162)
        AND [MV].[MetricValueDateTime] > DATEADD(YEAR, - 8, GETDATE())
        AND [MV].[YValue] != 0
        AND (
            [MV].[MetricID] NOT IN (51, 52, 53)
            OR [MV].[MetricValueDateTime] < '2018-08-05'
            )
        AND (
            [MV].[MetricID] NOT IN (161, 162)
            OR [MV].[MetricValueDateTime] > '2025-01-13'
            )
        AND mv.MetricValueDateTime BETWEEN DATEADD(WEEK, - 12, @FirstSunday) AND @FirstSunday
        AND mv.MetricValueDateTime != '2019-12-22'
        AND mv.MetricValueDateTime != '2021-12-26'
        AND asd.EasterWeekIndicator != 1
    GROUP BY c.Id
    ) AS FirstSundayAverage
    ON Agg.CampusId = FirstSundayAverage.CampusId
WHERE @CampusId = ''
    OR @CampusId = Agg.CampusId