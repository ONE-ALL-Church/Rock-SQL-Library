SELECT cci.Id,
    cci.Title,
    ROUND((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60, 0) MinutesWatched,
    COUNT(pa.PersonId) AS UniqueViewers,
    ROUND(((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60) / COUNT(pa.PersonId), 1) AvgMinutesPerUser,
    me.CreatedDateTime
FROM ContentChannelItem cci
INNER JOIN AttributeValue av ON av.AttributeId = 27146
    AND cci.Id = av.EntityId
INNER JOIN MediaElement me ON TRY_CAST(av.[Value] AS UNIQUEIDENTIFIER) = me.Guid
INNER JOIN InteractionComponent ic ON ic.InteractionChannelId = 28
    AND ic.EntityId = me.Id
INNER JOIN Interaction i ON i.InteractionComponentId = ic.Id
INNER JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
WHERE cci.ContentChannelId = 5
GROUP BY cci.Id,
    cci.Title,
    cci.StartDateTime,
    me.DurationSeconds,
    me.CreatedDateTime
ORDER BY cci.StartDateTime DESC
