SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[CCVYouthCensusLeadersNotResponded] AS

SELECT DISTINCT gm.PersonId AS 'Id'
    , g.Id AS 'GroupId'
    , g.Guid AS 'GroupGuid'
FROM GroupType AS gt
INNER JOIN [Group] AS g
    ON gt.Id = g.GroupTypeId
        AND g.IsActive = 1
        AND g.IsArchived != 1
INNER JOIN GroupMember gm
    ON g.Id = gm.GroupId
        AND gm.IsArchived != 1
        AND gm.GroupMemberStatus != 0
INNER JOIN GroupTypeRole gtr
    ON gm.GroupRoleId = gtr.Id
        AND gtr.IsLeader = 1
WHERE gt.Id = 105 AND
     NOT EXISTS (
        SELECT1 
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 33257
                AND (
                    w.[Status] != 'Leader Input'
                    AND w.[Status] NOT LIKE '%Remove Leader%'
                    )
                AND TRY_CAST(g.Guid AS NVARCHAR(50)) = av.[Value]
        )
    AND NOT EXISTS (
        SELECT 1
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 33257
                AND w.[Status] LIKE '%Remove Leader%'
                AND w.Id > 166801
        INNER JOIN AttributeValue avp
            ON w.Id = avp.EntityId
        INNER JOIN Attribute ap
            ON avp.AttributeId = ap.Id
                AND ap.[Key] = 'Person'
        INNER JOIN GroupMember gm2
            ON avp.ValueAsPersonId = gm2.PersonId
                AND gm2.Id = gm.Id
        INNER JOIN [Group] g
            ON gm2.GroupId = g.Id
                AND av.[Value] = g.Guid
        )




GO
