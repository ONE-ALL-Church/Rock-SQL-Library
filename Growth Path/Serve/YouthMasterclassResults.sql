SELECT p.NickName,
    p.LastName,
    w.ActivatedDateTime [MasterclassStarted],
    w.CompletedDateTime [MasterclassCompleted],
    LastActivity.Name AS LastActivity,
    LastActivity.CompletedDateTime AS LastActivityCompletedDateTime
FROM Workflow w
INNER JOIN AttributeValue avPerson ON w.Id = avPerson.EntityId
    AND avPerson.AttributeId = 28014
INNER JOIN PersonAlias pa ON TRY_CAST(avPerson.[Value] AS UNIQUEIDENTIFIER) = pa.Guid
INNER JOIN Person p ON pa.PersonId = p.Id
OUTER APPLY (
    SELECT TOP 1 wat.Name, wa.CompletedDateTime, wat.Id
    FROM WorkflowActivity wa
    INNER JOIN WorkflowActivityType wat ON wa.ActivityTypeId = wat.Id AND wat.Id != 1256
    WHERE wa.WorkflowId = w.Id and wa.CompletedDateTime IS NOT NULL 
    ORDER BY  wa.ActivatedDateTime DESC
    ) LastActivity
WHERE w.WorkflowTypeId = 418
ORDER BY w.ActivatedDateTime DESC
