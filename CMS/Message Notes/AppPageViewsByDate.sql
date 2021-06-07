SELECT CAST(i.CreatedDateTime AS date) [Date], COUNT(DISTINCT i.InteractionSessionId) PageViews
FROM Interaction i 
WHERE i.InteractionComponentId = 114866
GROUP BY CAST(i.CreatedDateTime AS date)
ORDER BY CAST(i.CreatedDateTime AS date) DESC