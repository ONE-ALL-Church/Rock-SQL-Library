SELECT CAST(i.CreatedDateTime AS date) [Date], COUNT(DISTINCT i.Id) [Views], COUNT(DISTINCT i.InteractionSessionId) [Sessions], COUNT(DISTINCT pa.PersonId) LoggedInPeople
FROM Interaction i 
LEFT JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
WHERE i.InteractionComponentId = 331537
GROUP BY CAST(i.CreatedDateTime AS date)
ORDER BY CAST(i.CreatedDateTime AS date) DESC