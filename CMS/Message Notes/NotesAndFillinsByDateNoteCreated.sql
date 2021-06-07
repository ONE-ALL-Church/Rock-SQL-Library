SELECT CAST(n.CreatedDateTime AS Date) CreatedDate, COUNT(DISTINCT n.Id) Notes
FROM Note n
INNER JOIN ContentChannelItem cci ON n.EntityId = cci.Id
WHERE n.NoteTypeId = 25
GROUP BY CAST(n.CreatedDateTime AS Date)
ORDER BY CAST(n.CreatedDateTime AS Date) DESC
