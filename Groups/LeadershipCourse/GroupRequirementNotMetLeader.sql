DECLARE @MemberFakePersonId INT = 8029;
DECLARE @GroupId TABLE (Id INT);

INSERT INTO @GroupId
VALUES (342015);

DECLARE @SignatureDocumentTemplateId INT = 6;

SELECT gmr.Guid GroupMemberRequirement
FROM GroupMemberRequirement gmr
INNER JOIN GroupMember gm ON gm.Id = gmr.GroupMemberId
--  AND gm.PersonId = @MemberFakePersonId
WHERE gm.GroupId IN (
        SELECT Id
        FROM @GroupId
        )
    AND gmr.RequirementMetDateTime IS NULL
    AND  NOT EXISTS (
        SELECT 1
        FROM SignatureDocument sd
        INNER JOIN PersonAlias pa ON sd.AppliesToPersonAliasId = pa.Id
            AND pa.PersonId = gm.PersonId
        WHERE sd.SignatureDocumentTemplateId = @SignatureDocumentTemplateId
        )
