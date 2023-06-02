-- Implmented at: https://admin.oneandall.church/reporting/dataviews?DataViewId=1691&ExpandedIds=C311%2cC749%2cC809%2cC644
SELECT DISTINCT p.Id
FROM Person p
INNER JOIN PersonAlias pa ON pa.PersonId = p.Id
INNER JOIN AttributeValue avp ON TRY_CAST(avp.Value AS UNIQUEIDENTIFIER) = pa.Guid
    AND avp.AttributeId = 32021
INNER JOIN Workflow w ON w.Id = avp.EntityId
    AND w.WorkflowTypeId = 494
WHERE EXISTS (
        SELECT 1
        FROM AttributeValue av
        WHERE av.AttributeId IN (32024, 32016, 32017)
            AND LOWER(av.[Value]) != 'none'
            AND LOWER(av.[Value]) != 'n/a'
            AND LOWER(av.[Value]) != 'na'
            AND av.EntityId = w.Id
        )
