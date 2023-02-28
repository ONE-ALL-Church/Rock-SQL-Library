-- Implmented At: https://admin.oneandall.church/page/103?Page=2272&ExpandedIds=12%2c17%2c1474
-- Tracked At: /Interactions/Media/MediaElement_Messages_MinutesWatched_Users

SELECT cci.Id,
    me.Id MediaId,
    cci.Title,
    ROUND((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60, 0) MinutesWatched,
    COUNT(pa.PersonId) AS UniqueViewers,
    ROUND(((SUM(i.InteractionLength) / 100 * me.DurationSeconds) / 60) / COUNT(pa.PersonId), 1) AvgMinutesPerUser,
    me.CreatedDateTime
FROM ContentChannelItem cci
INNER JOIN AttributeValue av ON av.AttributeId = 27146
    AND cci.Id = av.EntityId
INNER JOIN MediaElement me ON TRY_CAST(av.[Value] AS UNIQUEIDENTIFIER) = me.Guid
LEFT JOIN InteractionComponent ic ON ic.InteractionChannelId = 28
    AND ic.EntityId = me.Id
LEFT JOIN Interaction i ON i.InteractionComponentId = ic.Id
LEFT JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
WHERE cci.ContentChannelId = 5
GROUP BY cci.Id,
    cci.Title,
    cci.StartDateTime,
    me.Id,
    me.DurationSeconds,
    me.CreatedDateTime
ORDER BY cci.StartDateTime DESC
