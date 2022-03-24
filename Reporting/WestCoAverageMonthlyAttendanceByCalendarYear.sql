
            SELECT
               asd.CalendarYear, asd.CalendarMonth,  SUM(YValue) AS Total
            FROM
                [MetricValue] AS mv
            LEFT JOIN  [MetricValuePartition] AS mvps ON mv.Id = mvps.MetricValueId
            INNER JOIN [MetricPartition] AS mps ON mvps.MetricPartitionId = mps.Id AND mps.EntityTypeId = 54
            LEFT JOIN [Schedule] AS s ON mvps.EntityId = s.Id

            LEFT JOIN  [MetricValuePartition] AS mvpc ON mv.Id = mvpc.MetricValueId
            INNER JOIN [MetricPartition] AS mpc ON mvpc.MetricPartitionId = mpc.Id AND mpc.EntityTypeId = 67
            INNER JOIN [Campus] AS C ON mvpc.EntityId = c.Id AND c.Id = 9
            INNER JOIN AnalyticsSourceDate asd on convert(date,mv.MetricValueDateTime,101) = asd.Date

            WHERE
                mv.MetricId IN (6,7,8,10,16,17,18)
                AND (s.CategoryId = 50 OR s.Id = 4498 OR s.CategoryId = 326)
             --   AND mv.MetricValueDateTime <= @PreviousSunday AND mv.MetricValueDateTime >=  DATEADD(WEEK, -12, @PreviousSunday) AND mv.MetricValueDateTime != '2019-12-22' AND mv.MetricValueDateTime != '2021-12-26'
               -- AND asd.EasterWeekIndicator != 1 AND asd.Date != '2019-12-22' AND asd.Date != '2021-12-26'
            AND asd.CalendarYearMonth NOT IN (201909, 202003, 202102, 202203)
            GROUP BY asd.CalendarYear, asd.CalendarMonth
            Order BY asd.CalendarYear, asd.CalendarMonth
SELECT CalendarYear, CAST(AVG(Total) AS INT) AverageMonthlyAttendance
FROM
(
            SELECT
               asd.CalendarYear, asd.CalendarMonth,  SUM(YValue) AS Total
            FROM
                [MetricValue] AS mv
            LEFT JOIN  [MetricValuePartition] AS mvps ON mv.Id = mvps.MetricValueId
            INNER JOIN [MetricPartition] AS mps ON mvps.MetricPartitionId = mps.Id AND mps.EntityTypeId = 54
            LEFT JOIN [Schedule] AS s ON mvps.EntityId = s.Id

            LEFT JOIN  [MetricValuePartition] AS mvpc ON mv.Id = mvpc.MetricValueId
            INNER JOIN [MetricPartition] AS mpc ON mvpc.MetricPartitionId = mpc.Id AND mpc.EntityTypeId = 67
            INNER JOIN [Campus] AS C ON mvpc.EntityId = c.Id AND c.Id = 9
            INNER JOIN AnalyticsSourceDate asd on convert(date,mv.MetricValueDateTime,101) = asd.Date

            WHERE
                mv.MetricId IN (6,7,8,10,16,17,18)
                AND (s.CategoryId = 50 OR s.Id = 4498 OR s.CategoryId = 326)
             --   AND mv.MetricValueDateTime <= @PreviousSunday AND mv.MetricValueDateTime >=  DATEADD(WEEK, -12, @PreviousSunday) AND mv.MetricValueDateTime != '2019-12-22' AND mv.MetricValueDateTime != '2021-12-26'
               -- AND asd.EasterWeekIndicator != 1 AND asd.Date != '2019-12-22' AND asd.Date != '2021-12-26'
            AND asd.CalendarYearMonth NOT IN (201909, 202003, 202102, 202203)
            GROUP BY asd.CalendarYear, asd.CalendarMonth
          
) ByYear
GROUP BY CalendarYear