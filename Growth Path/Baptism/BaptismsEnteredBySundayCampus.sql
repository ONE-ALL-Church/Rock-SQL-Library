-- Purpose: Baptisms Entered By Sunday Campus
-- Tracked: /Growth Path/Baptism/BaptismsEnteredBySundayCampus.sql
-- Implmented At: https://admin.oneandall.church/page/2275

SELECT asd.SundayDate
   -- , c.Id CampusId
    , c.Name CampusName
    , COUNT(DISTINCT p.Id) Baptized
FROM Workflow w
LEFT JOIN AttributeValue avP
    ON w.Id = avP.EntityId
        AND avP.AttributeId = 21372
LEFT JOIN Person p
    ON avP.ValueAsPersonId = p.Id
LEFT JOIN AttributeValue avC
    ON w.Id = avC.EntityId
        AND avC.AttributeId = 21376
LEFT JOIN Campus c
    ON avC.[Value] = c.Guid
INNER JOIN AttributeValue avDate ON avDate.EntityId = w.Id AND avDate.AttributeId = 25178
INNER JOIN AnalyticsSourceDate asd ON CAST(avDate.[ValueAsDateTime] AS DATE) = asd.Date
WHERE w.WorkflowTypeId = 309
GROUP BY asd.SundayDate, c.Id, c.Name
ORDER BY asd.SundayDate DESC, c.Name