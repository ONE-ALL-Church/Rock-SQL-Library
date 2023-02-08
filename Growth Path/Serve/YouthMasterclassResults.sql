SELECT p.NickName, p.LastName
FROM Workflow w 
INNER JOIN AttributeValue avPerson ON w.Id = avPerson.EntityId AND avPerson.AttributeId = 28014
INNER JOIN PersonAlias pa ON TRY_CAST(avPerson.[Value] AS uniqueidentifier) = pa.Guid
INNER JOIN Person p ON pa.PersonId = p.Id
WHERE w.WorkflowTypeId = 418