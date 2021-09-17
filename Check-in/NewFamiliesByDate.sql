SELECT 
    asd.[Date]
    , AllKids.Kids [All]
    , NewKids.Kids [New]
    , FORMAT(NewKids.Kids / CAST(AllKids.Kids AS float), 'P') [PercentNew]
    , AllFamilies.Kids [AllFamilies]
    , NewFamilies.Kids [NewFamilies]
FROM (
    SELECT afa.SundayDate, COUNT( DISTINCT pa.PersonId) Kids
    FROM [AnalyticsFactAttendance] afa
    INNER JOIN PersonAlias pa ON pa.Id = afa.PersonAliasId
    WHERE afa.AttendanceTypeId = 14
    GROUP BY afa.SundayDate
) AllKids
INNER JOIN AnalyticsSourceDate asd ON AllKids.SundayDate = asd.[Date]
OUTER APPLY (
    SELECT COUNT(DISTINCT pa.PersonId) Kids
    FROM [AnalyticsFactAttendance] afa2
    INNER JOIN PersonAlias pa ON pa.Id = afa2.PersonAliasId
    WHERE afa2.IsFirstAttendanceOfType = 1 AND afa2.AttendanceTypeId = 14 AND afa2.SundayDate = asd.[Date]
    GROUP BY afa2.SundayDate
) NewKids
OUTER APPLY (
    SELECT COUNT(DISTINCT p.PrimaryFamilyId) Kids
    FROM [AnalyticsFactAttendance] afa2
    INNER JOIN PersonAlias pa ON pa.Id = afa2.PersonAliasId
    INNER JOIN Person p ON pa.PersonId = p.Id
    WHERE afa2.AttendanceTypeId = 14 AND afa2.SundayDate = asd.[Date]
    GROUP BY afa2.SundayDate
) AllFamilies
OUTER APPLY (
    SELECT COUNT(DISTINCT p.PrimaryFamilyId) Kids
    FROM [AnalyticsFactAttendance] afa2
    INNER JOIN PersonAlias pa ON pa.Id = afa2.PersonAliasId
    INNER JOIN Person p ON pa.PersonId = p.Id
    WHERE afa2.IsFirstAttendanceOfType = 1 AND afa2.AttendanceTypeId = 14 AND afa2.SundayDate = asd.[Date] AND
    NOT EXISTS (
        SELECT 1
        FROM [AnalyticsFactAttendance] afa3
        INNER JOIN PersonAlias pa2 ON pa2.Id = afa3.PersonAliasId
        INNER JOIN Person p2 ON pa2.PersonId = p2.Id AND p2.PrimaryFamilyId = p.PrimaryFamilyId
        WHERE afa2.AttendanceTypeId = 14 AND afa3.SundayDate < asd.[Date]
    )
    GROUP BY afa2.SundayDate
) NewFamilies
ORDER BY asd.SundayDate
