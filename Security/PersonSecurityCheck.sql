-- =====================================================================================================
-- Author:      Randy Aufrecht
-- Create Date: 7/28/2020
-- Description: Shows various permissions associated with a provided person. 
--              Taken from https://community.rockrms.com/recipes/80/removing-staff-from-rock
--
-- Implemented at: https://admin.oneandall.church/page/868
-- Change History:
--   7/6/2022 Luke Taylor: Updated to get all person aliases not just primary alias, added 
--            Workflow Assign Activity to Person Actions
-- =====================================================================================================

IF @Person != ''
DECLARE @PersonId INT = (SELECT [PersonId] FROM 
    [PersonAlias] WHERE [Guid] = @Person
    )



IF @Person != ''
-- 1. Security Groups
SELECT g.Id
	, g.Name AS 'Group'
	, g.IsActive
	, g.IsArchived
	, gs.SyncDataViewId
FROM [Group] g
INNER JOIN GroupMember gm ON g.id = gm.GroupId
	AND gm.IsArchived != 1
INNER JOIN GroupType gt ON g.GroupTypeid = gt.Id
LEFT JOIN GroupSync gs ON g.Id = gs.GroupId
WHERE g.IsSecurityRole = 1
AND gm.[PersonId] = @PersonId
ORDER BY g.Name;


IF @Person != ''
-- 2. Approval Groups | Used for Room Reservation Plugin
SELECT g.Id
	, g.Name AS 'Group'
	, g.IsActive
	, g.IsArchived
	, gs.SyncDataViewId
FROM [Group] g
INNER JOIN GroupMember gm ON g.id = gm.GroupId
	AND gm.IsArchived != 1
INNER JOIN GroupType gt ON g.GroupTypeid = gt.Id
LEFT JOIN GroupSync gs ON g.Id = gs.GroupId
WHERE g.GroupTypeId = 34
    AND gm.[PersonId] = @PersonId
ORDER BY gt.Name;


IF @person != ''
-- 3. Connector Groups | The person is in a connector group and could be assigned
SELECT g.Id
	, g.Name AS 'Group'
	, g.IsActive
	, g.IsArchived
	, gs.SyncDataViewId
FROM [Group] g
INNER JOIN GroupMember gm ON g.id = gm.GroupId
	AND gm.IsArchived != 1
INNER JOIN GroupType gt ON g.GroupTypeid = gt.Id
LEFT JOIN GroupSync gs ON g.Id = gs.GroupId
WHERE g.GroupTypeId = 55
AND gm.[PersonId] = @PersonId
ORDER BY gt.Name;


IF @person != ''
-- 4. Group Leadership
SELECT g.Id AS 'GroupId'
	, g.Name AS 'GroupName'
	, g.IsActive
	, g.IsArchived
FROM [Group] g
INNER JOIN GroupMember gm ON g.Id = gm.GroupId
	AND gm.IsArchived != 1
INNER JOIN GroupTypeRole gtr ON gm.GroupRoleId = gtr.Id
	AND gtr.IsLeader = 1
WHERE
    gm.[PersonId] = @PersonId;


IF @person != ''
-- 5. Default Connector | The person is the default connector for a connection
SELECT co.Id
	, co.ConnectionTypeId
	, co.Name
	, c.Name AS 'CampusName'
FROM ConnectionOpportunity co
INNER JOIN ConnectionOpportunityCampus coc ON co.Id = coc.ConnectionOpportunityId
INNER JOIN PersonAlias pa ON coc.DefaultConnectorPersonAliasId = pa.Id AND pa.[PersonId] = @PersonId
INNER JOIN Campus c ON coc.CampusId = c.Id

ORDER BY co.Name
	, c.Name;


IF @person != ''
-- 6. Active Connections | The person has active connections. They should be re-assigned to other people
SELECT cr.Id
	, co.Name AS 'ConnectionOpportunity'
	, p.NickName + ' ' + p.LastName AS 'PersonName'
FROM ConnectionRequest cr
INNER JOIN PersonAlias pa ON cr.ConnectorPersonAliasId = pa.Id
	AND cr.ConnectionState = 0
	AND pa.PersonId = @PersonId
INNER JOIN ConnectionOpportunity co ON cr.ConnectionOpportunityId = co.Id
INNER JOIN PersonAlias pa2 ON cr.PersonAliasId = pa2.Id
INNER JOIN Person p ON pa2.PersonId = p.Id
ORDER BY co.Name
	, cr.Id;


IF @person != ''
-- 7. Active Event Contact | This person is an event contact and may be displayed on the website as such.
SELECT eio.Id
	, ei.Name
FROM EventItem ei
INNER JOIN EventItemOccurrence eio ON ei.Id = eio.EventItemId
INNER JOIN Schedule s ON eio.ScheduleId = s.Id
	AND s.EffectiveEndDate > getdate()
INNER JOIN PersonAlias pa ON eio.ContactPersonAliasId = pa.Id
	AND pa.PersonId = @PersonId
WHERE ei.IsActive = 1;


IF @person != ''
-- 8. Active Registration Contact | This person is a registration contact and may be contacted about registrations.
SELECT ri.Id
	, ri.Name
FROM RegistrationInstance AS ri
INNER JOIN Registrationtemplate rt ON ri.RegistrationTemplateId = rt.Id
INNER JOIN PersonAlias pa ON ri.ContactPersonAliasId = pa.Id
	AND pa.[PersonId] = @PersonId
WHERE ri.IsActive = 1
	AND ri.EndDateTime > getdate();


IF @Person != ''
-- 9. Org Chart
SELECT g.Id
	, g.Name AS 'Group'
	, g.IsActive
	, g.IsArchived
	, gs.SyncDataViewId
FROM [Group] g
INNER JOIN GroupMember gm ON g.id = gm.GroupId
	AND gm.IsArchived != 1
    AND gm.[PersonId] = @PersonId
INNER JOIN GroupType gt ON g.GroupTypeid = gt.Id
LEFT JOIN GroupSync gs ON g.Id = gs.GroupId
WHERE g.GroupTypeId = 28
ORDER BY g.Name;


IF @Person != ''
-- 10. Miscellaneous Security Settings | Various permissions throughout Rock. As I have identified the type of Entity I have joined in the entity table to get enough details to be able to remove the person's permissions
SELECT DISTINCT Page.InternalName AS PageName
	, g.Name AS GroupName
	, a.EntityTypeId AS EntityType
	, et.FriendlyName AS EntityName
	, a.EntityId AS EntityId
	, rt.Name AS RegName
	, dv.Name AS Dataview
	, r.Name AS Report
	, b.Name AS Block
	, b.PageId
	, s.Name AS Schedule
FROM Auth a
INNER JOIN PersonAlias pa ON a.PersonAliasId = pa.Id
	AND pa.PersonId = @PersonID
INNER JOIN EntityType et ON a.EntityTypeId = et.Id
LEFT JOIN Page ON a.EntityId = page.Id
	AND et.Id = 2
LEFT JOIN [Group] g ON a.EntityId = g.Id
	AND et.Id = 16
LEFT JOIN RegistrationTemplate rt ON a.EntityId = rt.Id
	AND et.Id = 234
LEFT JOIN DataView dv ON a.EntityId = dv.Id
	AND et.Id = 34
LEFT JOIN Report r ON a.EntityId = r.Id
	AND et.Id = 107
LEFT JOIN Block b ON a.EntityId = b.Id
	AND et.Id = 9
LEFT JOIN schedule s ON a.EntityId = s.Id
	AND et.Id = 54
ORDER BY et.FriendlyName;


IF @Person != ''
-- 11. SMS From Values | This person is attached to SMS numbers that may receive SMS messages.
SELECT dv.[Value]
	, dv.[Description]
FROM DefinedValue dv
INNER JOIN AttributeValue av ON dv.Id = av.EntityId
	AND av.AttributeId = 949
INNER JOIN [PersonAlias] pa ON CAST(pa.[Guid] AS NVARCHAR(50)) = av.[Value] 
    AND pa.[PersonId] = @PersonId
WHERE DefinedTypeId = 32;


IF @Person != ''
-- 12. Reservations | Used with the Room Reservation Plugin to identify people who have reserved rooms
SELECT r.Id
	, r.Name
FROM _com_centralaz_RoomManagement_Reservation r
INNER JOIN PersonAlias pa ON r.EventContactPersonAliasId = pa.Id
	AND pa.PersonId = @personid

IF @Person != ''
-- 13. Campus Roles
select c.Id
    , c.Name as CampusName
    , gtr.Name as RoleName
from GroupMember gm
inner join GroupTypeRole gtr 
    ON gtr.Id = gm.GroupRoleId
inner join Campus c
    ON c.TeamGroupId = gm.GroupId
where gm.PersonId = @PersonId;

IF @Person != ''
-- 14. Assigned Workflow Activities
SELECT wt.[Id]
    , wt.[Name] AS [WorkflowType]
    , wact.[Name] AS [Activity]
    , wacto.[Name] AS [Action]
FROM
    [WorkflowActionType] wacto 
    INNER JOIN [WorkflowActivityType] wact ON wact.[Id] = wacto.[ActivityTypeId]
    INNER JOIN [WorkflowType] wt ON wt.[Id] = wact.[WorkflowTypeId]
    INNER JOIN [AttributeValue] av ON av.[EntityId] = wacto.[Id]
    INNER JOIN [Attribute] a ON a.[Id] = av.[AttributeId]
    INNER JOIN [PersonAlias] pa ON CAST(pa.[Guid] AS NVARCHAR(50)) = av.[Value]
    INNER JOIN [Person] p ON p.[Id] = pa.[PersonId]
    WHERE
        a.[EntityTypeId] = 115
        AND
        a.[EntityTypeQualifierColumn] = 'EntityTypeId'
        AND
        a.[EntityTypeQualifierValue] = '192'
        AND
        p.[Id] = @PersonId

