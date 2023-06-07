DECLARE @MemberFakePersonId INT = 8029;
DECLARE @GroupId TABLE (Id INT);

INSERT INTO @GroupId
VALUES (340355),
    (340338);

DECLARE @SignatureDocumentTemplateId INT = 5;
DECLARE @GroupRequirementId INT = 5;

SELECT gmr.Guid GroupMemberRequirement --, gmr.GroupMemberId, gmr.GroupRequirementId
FROM GroupMemberRequirement gmr
INNER JOIN GroupMember gm ON gm.Id = gmr.GroupMemberId
    -- AND gm.PersonId = @MemberFakePersonId
WHERE gm.GroupId IN (
        SELECT Id
        FROM @GroupId
        )
    AND gmr.RequirementMetDateTime IS NULL
    AND gmr.GroupRequirementId = @GroupRequirementId
    AND NOT EXISTS (
        SELECT 1
        FROM SignatureDocument sd
        INNER JOIN PersonAlias pa ON sd.AppliesToPersonAliasId = pa.Id
            AND pa.PersonId = gm.PersonId
        WHERE sd.SignatureDocumentTemplateId = @SignatureDocumentTemplateId
        )
