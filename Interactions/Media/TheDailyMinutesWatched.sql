SELECT cci.StartDateTime
    , cci.Title
    , dvSpeaker.[Value]
    , (SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60 MinutesWatched
    , COUNT(DISTINCT pa.PersonId) UniqueWatchers
FROM Interaction i
INNER JOIN InteractionComponent ic
    ON i.InteractionComponentId = ic.Id
        AND ic.InteractionChannelId = 28
INNER JOIN MediaElement me
    ON ic.EntityId = me.Id
INNER JOIN PersonAlias pa
    ON i.PersonAliasId = pa.Id
INNER JOIN AttributeValue av
    ON TRY_CAST(av.[Value] AS UNIQUEIDENTIFIER) = me.Guid
        AND av.AttributeId = 29293
INNER JOIN ContentChannelItem cci
    ON av.EntityId = cci.Id
LEFT JOIN AttributeValue avSpeaker
    ON avSpeaker.[EntityId] = cci.Id
        AND avSpeaker.AttributeId = 29299
LEFT JOIN DefinedValue dvSpeaker
    ON TRY_CAST(avSpeaker.[Value] AS UNIQUEIDENTIFIER) = dvSpeaker.Guid
WHERE i.InteractionLength IS NOT NULL
GROUP BY me.Id
    , me.Name
    , me.DurationSeconds
    , me.CreatedDateTime
    , cci.StartDateTime
    , cci.Title
    , dvSpeaker.[Value]
ORDER BY cci.StartDateTime
