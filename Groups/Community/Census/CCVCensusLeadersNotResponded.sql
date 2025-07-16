SELECT DISTINCT gm.PersonId AS 'Id'
    , g.Id AS 'GroupId'
    , g.Guid AS 'GroupGuid'
    , ctdf.Value AS 'Topic'
FROM GroupType AS gt
INNER JOIN [Group] AS g
    ON gt.Id = g.GroupTypeId
        AND gt.Id = 49
        AND g.IsActive = 1
        AND g.IsArchived != 1
INNER JOIN [AttributeValue] AS av
    ON g.Id = av.EntityId
        AND av.AttributeId = 6309
INNER JOIN AttributeMatrix AS am
    ON av.[Value] = TRY_CAST(am.Guid AS NVARCHAR(50))
INNER JOIN AttributeMatrixItem AS cami
    ON am.Id = cami.AttributeMatrixId
INNER JOIN AttributeValue AS cqav
    ON cami.Id = cqav.EntityId
        AND cqav.AttributeId = 6312
INNER JOIN AttributeValue AS ctav
    ON cami.Id = ctav.EntityId
        AND ctav.AttributeId = 6307
INNER JOIN DefinedValue AS cqdf
    ON TRY_CAST(cqav.[Value] AS UNIQUEIDENTIFIER) = cqdf.Guid
        AND (
            cqdf.[Value] = 'Winter 2025'
            --OR cqdf.[Value] = 'Summer 2022'
            )
INNER JOIN DefinedValue AS ctdf
    ON TRY_CAST(ctav.[Value] AS UNIQUEIDENTIFIER) = ctdf.Guid
INNER JOIN AttributeValue avHomeGroup
    ON ctdf.Id = avHomeGroup.EntityId
        AND avHomeGroup.AttributeId = 14710
        AND avHomeGroup.ValueAsBoolean = 1
INNER JOIN GroupMember gm
    ON g.Id = gm.GroupId
        AND gm.IsArchived != 1
        AND gm.GroupMemberStatus != 0
INNER JOIN GroupTypeRole gtr
    ON gm.GroupRoleId = gtr.Id
        AND gtr.IsLeader = 1
        AND gtr.Id = 69
WHERE NOT EXISTS (
        SELECT 1
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 14434
                AND (
                    w.[Status] != 'Leader Input'
                    AND w.[Status] NOT LIKE '%Remove Leader%'
                    )
                AND TRY_CAST(g.Guid AS NVARCHAR(50)) = av.[Value]
        INNER JOIN AttributeValue avq
            ON w.Id = avq.EntityId
                AND avq.AttributeId = 16359
        INNER JOIN DefinedValue AS cqdf
            ON avq.[Value] = CAST(cqdf.Guid AS VARCHAR(50))
                AND cqdf.[Value] = 'Spring 2025'
        )
    AND NOT EXISTS (
        SELECT 1
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 14434
                AND w.[Status] LIKE '%Remove Leader%'
                AND w.Id > 166801
        INNER JOIN AttributeValue avq
            ON w.Id = avq.EntityId
                AND avq.AttributeId = 16359
        INNER JOIN DefinedValue AS cqdf
            ON avq.[Value] = CAST(cqdf.Guid AS VARCHAR(50))
                AND cqdf.[Value] = 'Spring 2025'
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
    AND NOT EXISTS (
        SELECT 1
        FROM GroupType AS gt
        INNER JOIN [Group] AS g2
            ON gt.Id = g2.GroupTypeId
                AND gt.Id = 49
                AND g2.Id = g.Id
        INNER JOIN [AttributeValue] dav
            ON g2.Id = dav.EntityId
                AND dav.AttributeId = 5920
                AND dav.[Value] != 'Students'
        INNER JOIN [AttributeValue] AS av
            ON g2.Id = av.EntityId
                AND av.AttributeId = 6309
        INNER JOIN AttributeMatrix AS am
            ON av.[Value] = convert(NVARCHAR(50), am.Guid)
        INNER JOIN AttributeMatrixItem AS cami
            ON am.Id = cami.AttributeMatrixId
        INNER JOIN AttributeValue AS cqav
            ON cami.Id = cqav.EntityId
                AND cqav.AttributeId = 6312
        INNER JOIN AttributeValue AS ctav
            ON cami.Id = ctav.EntityId
                AND ctav.AttributeId = 6307
        INNER JOIN DefinedValue AS cqdf
            ON cqav.[Value] = CAST(cqdf.Guid AS VARCHAR(50))
                AND cqdf.[Value] = 'Spring 2025'
        )