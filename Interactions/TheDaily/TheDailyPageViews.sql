WITH InteractionDates
AS (
    SELECT CAST(i.InteractionDateTime AS DATE) InteractionDate,
        InteractionComponentId,
        p.Id
    FROM Interaction i
    INNER JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
    INNER JOIN Person p ON pa.PersonId = p.Id
    WHERE i.InteractionComponentId IN (326528, 326808, 326548, 326566, 114861) -- 109365 Home Page For Testing, 326808
        --   AND i.InteractionDateTime < CAST(GETDATE() AS DATE)
    GROUP BY CAST(i.InteractionDateTime AS DATE),
        i.InteractionComponentId,
        p.Id
    )
SELECT idStart.InteractionDate,
    COUNT(DISTINCT id.Id) [Start],
    COUNT(DISTINCT CASE 
            WHEN id.InteractionComponentId = 326548
                THEN id.Id
            ELSE NULL
            END) [Notes],
    COUNT(DISTINCT CASE 
            WHEN id.InteractionComponentId = 326566
                THEN id.Id
            ELSE NULL
            END) [Prayer Session],
    COUNT(DISTINCT CASE 
            WHEN id.InteractionComponentId = 114861
                THEN id.Id
            ELSE NULL
            END) [Prayer Entry],
    COUNT(DISTINCT CASE 
            WHEN id.InteractionComponentId = 326808
                THEN id.Id
            ELSE NULL
            END) [Success],
    CASE 
        WHEN COUNT(DISTINCT id.Id) != 0
            THEN FORMAT(CAST(COUNT(DISTINCT CASE 
                                WHEN id.InteractionComponentId = 326808
                                    THEN id.Id
                                ELSE NULL
                                END) AS FLOAT) / CAST(COUNT(DISTINCT id.Id) AS FLOAT), 'P')
        ELSE NULL
        END [PercentCompleted]
FROM InteractionDates idStart
INNER JOIN InteractionDates id ON id.InteractionDate = idStart.InteractionDate
    AND id.Id = idStart.Id
WHERE idStart.InteractionComponentId = 326528
    AND DATEPART(dw, idStart.InteractionDate) NOT IN (1, 7)
    AND idStart.InteractionDate >= '2023-05-08'
GROUP BY idStart.InteractionDate
ORDER BY idStart.InteractionDate DESC
