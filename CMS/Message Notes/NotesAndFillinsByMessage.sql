SELECT CAST(cci.StartDateTime AS Date) MessageDate, Mes.Title, COUNT(DISTINCT p.Id) Notes
FROM Note n
INNER JOIN ContentChannelItem cci ON n.EntityId = cci.Id
OUTER APPLY (
    SELECT  TOP 1 m.Id, m.Title
    FROM ContentChannelItemAssociation  ccia
    INNER JOIN ContentChannelItem m ON ccia.ContentChannelItemId = m.Id AND m.ContentChannelId = 5
    WHERE cci.Id = ccia.ChildContentChannelItemId
) [Mes]
INNER JOIN PersonAlias pa ON n.CreatedByPersonAliasId = pa.Id
INNER JOIN Person p ON pa.PersonId = p.Id
WHERE n.NoteTypeId = 25
GROUP BY mes.Id, mes.Title, cci.StartDateTime
ORDER BY cci.StartDateTime DESC
