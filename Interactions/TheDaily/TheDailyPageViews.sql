WITH InteractionDates
AS (
    SELECT CAST(i.InteractionDateTime AS DATE) InteractionDate,
        InteractionComponentId,
        p.Id
    FROM Interaction i
    INNER JOIN PersonAlias pa ON i.PersonAliasId = pa.Id
    INNER JOIN Person p ON pa.PersonId = p.Id
    WHERE i.InteractionComponentId IN (326528, 326808, 326548, 326566,114861) -- 109365 Home Page For Testing, 326808
        --   AND i.InteractionDateTime < CAST(GETDATE() AS DATE)
    GROUP BY CAST(i.InteractionDateTime AS DATE),
        i.InteractionComponentId,
        p.Id
    ),
Streaks
AS (
    SELECT InteractionDate,
        CASE 
            WHEN LAG(InteractionDate) OVER (
                    ORDER BY InteractionDate
                    ) = DATEADD(day, 0, InteractionDate)
                OR (
                    DATEPART(weekday, InteractionDate) = 2
                    AND DATEADD(day, - 3, InteractionDate) = LAG(InteractionDate) OVER (
                        ORDER BY InteractionDate
                        )
                    )
                THEN 1
            ELSE 0
            END AS IsConsecutive
    FROM InteractionDates
    ),
CurrentStreak
AS (
    SELECT SUM(IsConsecutive) AS Streak
    FROM Streaks
    WHERE InteractionDate >= (
            SELECT MAX(InteractionDate)
            FROM Streaks
            WHERE IsConsecutive = 0
            )
    )
SELECT id.InteractionDate,
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
            END) [Success]
FROM InteractionDates idStart
INNER JOIN InteractionDates id ON id.InteractionDate = idStart.InteractionDate
    AND id.Id = idStart.Id
WHERE idStart.InteractionComponentId = 326528
GROUP BY id.InteractionDate
ORDER BY id.InteractionDate DESC

