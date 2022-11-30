SELECT me.Id, me.Name, (SUM(i.InteractionLength)/100 * me.DurationSeconds)/60
FROM Interaction i
INNER JOIN InteractionComponent ic ON i.InteractionComponentId = ic.Id AND ic.InteractionChannelId = 28
INNER JOIN MediaElement me ON ic.EntityId = me.Id
INNER JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
WHERE i.InteractionLength IS NOT NULL
GROUP BY me.Id, me.Name,me.DurationSeconds, me.CreatedDateTime
ORDER BY me.CreatedDateTime
