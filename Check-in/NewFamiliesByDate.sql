DECLARE @MaxRetentionDate DATE, @MinNewDate DATE

SELECT @MaxRetentionDate = (
        SELECT DATEADD(week, -8,MAX(afa.SundayDate))
        FROM [AnalyticsSourceAttendance] afa
        WHERE afa.AttendanceTypeId = 14
            AND afa.DidAttend = 1
        )

SELECT @MinNewDate = (
        SELECT DATEADD(week, 16, MIN(afa.SundayDate))
        FROM [AnalyticsSourceAttendance] afa
        WHERE afa.AttendanceTypeId = 14
            AND afa.DidAttend = 1
        )

SELECT asd.[Date]
    , AllKids.Kids [AllKids]
    , NewKids.[Count] [NewKids]
    , AllFamilyRetention.FamilyCount AllFamilies
    , NewFamilyRetention.FamilyCount  NewFamilies
    , FORMAT(NewKids.[Count] / CAST(AllKids.Kids AS FLOAT), 'P0') [PercentNewKids]
    , FORMAT(NewFamilyRetention.FamilyCount / CAST(AllFamilyRetention.FamilyCount AS FLOAT), 'P0') [PercentNewFamilies]
    , CASE 
        WHEN asd.SundayDate > @MaxRetentionDate
            THEN NULL
        ELSE AllKidsRetention.[PercentRetention]
        END AllKidsRetentionPercent
    , CASE 
        WHEN asd.SundayDate > @MaxRetentionDate
            THEN NULL
        ELSE NewKids.[PercentRetention]
        END NewKidsRetentionPercent
    
    , CASE 
        WHEN asd.SundayDate > @MaxRetentionDate
            THEN NULL
        ELSE AllFamilyRetention.PercentRetention
        END AllFamilyRetentionPercent
    , CASE 
        WHEN asd.SundayDate > @MaxRetentionDate
            THEN NULL
        ELSE NewFamilyRetention.PercentRetention
        END NewFamilyRetentionPercent
FROM (
    SELECT afa.SundayDate
        , COUNT(DISTINCT pa.PersonId) Kids
    FROM [AnalyticsSourceAttendance] afa
    INNER JOIN PersonAlias pa
        ON pa.Id = afa.PersonAliasId
    WHERE afa.AttendanceTypeId = 14
        AND afa.DidAttend = 1
    GROUP BY afa.SundayDate
    ) AllKids
INNER JOIN AnalyticsSourceDate asd
    ON AllKids.SundayDate = asd.[Date]
OUTER APPLY (
    SELECT FORMAT(AVG(FamAttendances.[Count] / 8.00), 'P0') [PercentRetention]
    FROM (
        SELECT COUNT(DISTINCT afaFuture.SundayDate) [Count]
        FROM (
            SELECT DISTINCT p.Id [Id]
            FROM [AnalyticsSourceAttendance] afa
            INNER JOIN PersonAlias pa
                ON pa.Id = afa.PersonAliasId
            INNER JOIN Person p
                ON pa.PersonId = p.Id
            WHERE afa.AttendanceTypeId = 14
                AND afa.SundayDate = asd.[Date]
                AND afa.DidAttend = 1
            ) P
        INNER JOIN PersonAlias pafm
            ON p.Id = pafm.PersonId
        LEFT JOIN [AnalyticsSourceAttendance] afaFuture
            ON pafm.Id = afaFuture.PersonAliasId
                AND afaFuture.SundayDate BETWEEN DATEADD(week, 1, asd.[Date]) AND DATEADD(week, 9, asd.[Date])
                AND afaFuture.AttendanceTypeId = 14
                AND afaFuture.DidAttend = 1
        GROUP BY p.Id
        ) FamAttendances
    ) AllKidsRetention
OUTER APPLY (
    SELECT FORMAT(AVG(FamAttendances.[Count] / 8.00), 'P0') [PercentRetention]
         ,COUNT(DISTINCT FamAttendances.Id) [Count]
    FROM (
        SELECT COUNT(DISTINCT afaFuture.SundayDate) [Count], p.Id
        FROM (
            SELECT DISTINCT p.Id [Id]
            FROM [AnalyticsSourceAttendance] afa
            INNER JOIN PersonAlias pa
                ON pa.Id = afa.PersonAliasId
            INNER JOIN Person p
                ON pa.PersonId = p.Id
            WHERE afa.AttendanceTypeId = 14
                AND afa.SundayDate = asd.[Date]
                AND afa.DidAttend = 1
                AND NOT EXISTS (
                    SELECT 1
                    FROM [AnalyticsSourceAttendance] afa3
                    INNER JOIN PersonAlias pa2
                        ON pa2.Id = afa3.PersonAliasId AND pa2.PersonId = p.Id
                    WHERE (afa3.AttendanceTypeId = 14 OR (afa3.AttendanceTypeId IS NULL AND afa3.SundayDate < '2018-07-01'))
                        AND afa3.SundayDate < asd.[Date]
                        AND afa3.SundayDate > DATEADD(year, -2, asd.[Date])
                        AND afa3.DidAttend = 1
                    )
            ) P
        INNER JOIN PersonAlias pafm
            ON p.Id = pafm.PersonId
        LEFT JOIN [AnalyticsSourceAttendance] afaFuture
            ON pafm.Id = afaFuture.PersonAliasId
                AND afaFuture.SundayDate BETWEEN DATEADD(week, 1, asd.[Date]) AND DATEADD(week, 9, asd.[Date])
                AND afaFuture.AttendanceTypeId = 14
                AND afaFuture.DidAttend = 1
        GROUP BY p.Id
        ) FamAttendances
    ) NewKids
OUTER APPLY (
    SELECT FORMAT(AVG(FamAttendances.[Count] / 8.00), 'P0') [PercentRetention]
        , COUNT(DISTINCT FamAttendances.FamiliesId) FamilyCount
    FROM (
        SELECT COUNT(DISTINCT afaFuture.SundayDate) [Count]
            , Families.Id FamiliesId
        FROM (
            SELECT DISTINCT p.PrimaryFamilyId [Id]
            FROM [AnalyticsSourceAttendance] afa
            INNER JOIN PersonAlias pa
                ON pa.Id = afa.PersonAliasId
            INNER JOIN Person p
                ON pa.PersonId = p.Id
            WHERE afa.AttendanceTypeId = 14
                AND afa.SundayDate = asd.[Date]
                AND afa.DidAttend = 1
            ) Families
        INNER JOIN Person fm
            ON Families.Id = fm.PrimaryFamilyId
        INNER JOIN PersonAlias pafm
            ON fm.Id = pafm.PersonId
        LEFT JOIN [AnalyticsSourceAttendance] afaFuture
            ON pafm.Id = afaFuture.PersonAliasId
                AND afaFuture.SundayDate BETWEEN DATEADD(week, 1, asd.[Date]) AND DATEADD(week, 9, asd.[Date])
                AND afaFuture.AttendanceTypeId = 14
                AND afaFuture.DidAttend = 1
        GROUP BY Families.Id
        ) FamAttendances
    ) AllFamilyRetention
OUTER APPLY (
    SELECT FORMAT(AVG(FamAttendances.[Count] / 8.00), 'P0') [PercentRetention]
        , COUNT(DISTINCT FamAttendances.FamiliesId) FamilyCount
    FROM (
        SELECT COUNT(DISTINCT afaFuture.SundayDate) [Count]
            , Families.Id FamiliesId
        FROM (
            SELECT DISTINCT p.PrimaryFamilyId [Id]
            FROM [AnalyticsSourceAttendance] afa
            INNER JOIN PersonAlias pa
                ON pa.Id = afa.PersonAliasId
            INNER JOIN Person p
                ON pa.PersonId = p.Id
            WHERE afa.AttendanceTypeId = 14
                AND afa.SundayDate = asd.[Date]
                AND afa.DidAttend = 1
                AND NOT EXISTS (
                    SELECT 1
                    FROM [AnalyticsSourceAttendance] afa3
                    INNER JOIN PersonAlias pa2
                        ON pa2.Id = afa3.PersonAliasId
                    INNER JOIN Person p2
                        ON pa2.PersonId = p2.Id
                            AND p2.PrimaryFamilyId = p.PrimaryFamilyId
                    WHERE (afa3.AttendanceTypeId = 14 OR (afa3.AttendanceTypeId IS NULL AND afa3.SundayDate < '2018-07-01'))
                        AND afa3.SundayDate < asd.[Date]
                        AND afa3.SundayDate > DATEADD(year, -2, asd.[Date])
                        AND afa3.DidAttend = 1
                    )
            ) Families
        INNER JOIN Person fm
            ON Families.Id = fm.PrimaryFamilyId
        INNER JOIN PersonAlias pafm
            ON fm.Id = pafm.PersonId
        LEFT JOIN [AnalyticsSourceAttendance] afaFuture
            ON pafm.Id = afaFuture.PersonAliasId
                AND afaFuture.SundayDate BETWEEN DATEADD(week, 1, asd.[Date]) AND DATEADD(week, 9, asd.[Date])
                AND afaFuture.AttendanceTypeId = 14
                AND afaFuture.DidAttend = 1
        GROUP BY Families.Id
        ) FamAttendances
    ) NewFamilyRetention
ORDER BY asd.SundayDate
