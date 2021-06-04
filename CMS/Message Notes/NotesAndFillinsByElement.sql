SELECT n.CreatedDateTime, n.ModifiedDateTime, Mes.*, p.NickName, p.LastName, n.Text, oj.*
FROM Note n
OUTER APPLY OPENJSON(n.Text) oj
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
ORDER BY n.CreatedDateTime DESC