SELECT g.*
FROM [Group] g
WHERE g.GroupTypeId = 49
    AND g.IsActive = 1
    AND g.IsArchived != 1
    AND NOT EXISTS (
        SELECT 1
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 14434
                AND (
                    w.[Status] != 'Leader Input'
                    AND w.[Status] NOT LIKE '%Remove Leader%'
                    )
                AND av.Value = TRY_CAST(g.Guid AS NVARCHAR(50))
        INNER JOIN AttributeValue avq
            ON w.Id = avq.EntityId
                AND avq.AttributeId = 16359
        INNER JOIN DefinedValue AS cqdf
            ON avq.[Value] = CAST(cqdf.Guid AS VARCHAR(50))
                AND cqdf.[Value] = 'Fall 2025'
        )
    AND NOT EXISTS (
        SELECT 1
        FROM GroupType AS gt
        INNER JOIN [Group] AS g2
            ON gt.Id = g2.GroupTypeId
                AND gt.Id = 49
                AND g.Id = g2.Id
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
                AND cqdf.[Value] = 'Fall 2025'
        )