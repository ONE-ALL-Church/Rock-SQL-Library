SELECT asd.SundayDate
    , ROUND(SUM(i.MinutesWatched),0) MinutesWatched
    , SUM(i.UniqueWatchers) Views
    , SUM(i.TotalInteractions) TotalInteractions
FROM (
    SELECT cci.StartDateTime,
        cci.Title,
        dvSpeaker.[Value],
        (SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60 MinutesWatched,
        COUNT(DISTINCT pa.PersonId) UniqueWatchers,
        COUNT(i.Id) TotalInteractions,
        i.InteractionDateKey
    FROM Interaction i
    INNER JOIN AnalyticsSourceDate asd ON i.InteractionDateKey = asd.DateKey
    INNER JOIN InteractionComponent ic ON i.InteractionComponentId = ic.Id
        AND ic.InteractionChannelId = 28
    INNER JOIN MediaElement me ON ic.EntityId = me.Id
    LEFT JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
    INNER JOIN AttributeValue av ON TRY_CAST(av.[Value] AS UNIQUEIDENTIFIER) = me.Guid
        AND av.AttributeId = 29293
    INNER JOIN ContentChannelItem cci ON av.EntityId = cci.Id
    LEFT JOIN AttributeValue avSpeaker ON avSpeaker.[EntityId] = cci.Id
        AND avSpeaker.AttributeId = 29299
    LEFT JOIN DefinedValue dvSpeaker ON TRY_CAST(avSpeaker.[Value] AS UNIQUEIDENTIFIER) = dvSpeaker.Guid
    WHERE i.InteractionLength IS NOT NULL
    GROUP BY i.InteractionDateKey,
        me.Id,
        me.Name,
        me.DurationSeconds,
        me.CreatedDateTime,
        cci.StartDateTime,
        cci.Title,
        dvSpeaker.[Value]
    ) i
INNER JOIN AnalyticsSourceDate asd ON i.InteractionDateKey = asd.DateKey
GROUP BY asd.SundayDate
ORDER BY asd.SundayDate DESC