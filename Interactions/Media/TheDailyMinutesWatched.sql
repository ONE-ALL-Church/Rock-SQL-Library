SELECT cci.StartDateTime
    , cci.Title
    , dvSpeaker.[Value]
    , ROUND((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60,0) MinutesWatched
    , COUNT(DISTINCT pa.PersonId) UniqueWatchers
    , Round(CAST(me.DurationSeconds AS float) /60,1) LengthMinutes
    , ROUND(((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60) / COUNT(pa.PersonId), 1) AvgMinutesPerUser
    , FORMAT(ROUND(((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60) / COUNT(pa.PersonId), 1) / Round(CAST(me.DurationSeconds AS float) /60,1), 'P0') PercentWatched
--, COUNT(i.Id) TotalInteractions
FROM Interaction i
INNER JOIN InteractionComponent ic
    ON i.InteractionComponentId = ic.Id
        AND ic.InteractionChannelId = 28
INNER JOIN MediaElement me
    ON ic.EntityId = me.Id
LEFT JOIN PersonAlias pa
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
