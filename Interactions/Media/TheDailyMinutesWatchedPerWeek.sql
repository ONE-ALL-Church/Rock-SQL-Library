WITH InteractionSummary
AS (
    SELECT asd.DateKey AS InteractionDateKey,
        me.Id AS MediaElementId,
        pa.PersonId,
        (SUM(i.InteractionLength) * 0.01 * me.DurationSeconds) / 60 AS MinutesWatched,
        COUNT(i.Id) AS TotalInteractions
    FROM Interaction i
    JOIN AnalyticsSourceDate asd ON i.InteractionDateKey = asd.DateKey
    JOIN InteractionComponent ic ON i.InteractionComponentId = ic.Id
        AND ic.InteractionChannelId = 28
    JOIN MediaElement me ON ic.EntityId = me.Id
    LEFT JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
    JOIN AttributeValue av ON TRY_CAST(av.[Value] AS UNIQUEIDENTIFIER) = me.Guid
        AND av.AttributeId = 29293
    JOIN ContentChannelItem cci ON av.EntityId = cci.Id
    WHERE i.InteractionLength IS NOT NULL
    GROUP BY asd.DateKey,
        me.Id,
        me.DurationSeconds,
        pa.PersonId
    )
SELECT asd.SundayDate,
    ROUND(SUM(isum.MinutesWatched), 0) AS MinutesWatched,
    COUNT(*) AS SumDailyViewers,
    COUNT(DISTINCT isum.PersonId) AS WeeklyUniqueViewers,
    SUM(isum.TotalInteractions) AS TotalInteractions
FROM InteractionSummary isum
JOIN AnalyticsSourceDate asd ON isum.InteractionDateKey = asd.DateKey
GROUP BY asd.SundayDate
ORDER BY asd.SundayDate DESC
