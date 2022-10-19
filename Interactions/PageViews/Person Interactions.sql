SELECT ic.Name, i.*, pd.*, s.*
FROM Interaction i
INNER JOIN InteractionComponent ic ON ic.Id = i.InteractionComponentId
INNER JOIN InteractionSession s ON s.Id = i.InteractionSessionId
INNER JOIN PersonalDevice pd ON pd.Id = i.PersonalDeviceId
INNER JOIN PersonAlias pa on i.PersonAliasId = pa.Id AND pa.PersonId = 16854 
ORDER BY i.InteractionDateTime DESC