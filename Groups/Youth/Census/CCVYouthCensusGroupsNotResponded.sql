SELECT g.*
FROM [Group] g
WHERE g.GroupTypeId = 105
    AND g.IsActive = 1
    AND g.IsArchived != 1
    AND NOT EXISTS (
        SELECT 1
        FROM Workflow w
        INNER JOIN AttributeValue av
            ON w.Id = av.EntityId
                AND av.AttributeId = 33257
                AND (
                    w.[Status] != 'Leader Input'
                    AND w.[Status] NOT LIKE '%Remove Leader%'
                    )
                AND av.Value = TRY_CAST(g.Guid AS NVARCHAR(50))
                AND w.CompletedDateTime > DATEADD(month, 4, GETDATE()) 
    )