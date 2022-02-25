SELECT CASE 
        WHEN roleoptions.[value] IS NULL AND campusoptions.[value] IS NULL THEN 'Team Night Total' 
        WHEN roleoptions.[VALUE] IS NULL THEN  campusoptions.[value] + ' Total'
        ELSE campusoptions.[value]
        END  [Campus]
    ,  roleoptions.[value] [Role], SUM(Registrations.Count) Registrants
FROM AttributeQualifier aqCampus
CROSS APPLY STRING_SPLIT(aqCampus.[Value], ',', 1) campusoptions
INNER JOIN AttributeQualifier aqRole
    ON aqRole.AttributeId = 26305
        AND aqRole.[Key] = 'values'
CROSS APPLY STRING_SPLIT(aqRole.[Value], ',', 1) roleoptions
OUTER APPLY (
    SELECT COUNT(*) [Count]
    FROM Registration r
    INNER JOIN RegistrationRegistrant rr
        ON rr.RegistrationId = r.Id
    INNER JOIN AttributeValue avCampus
        ON avCampus.AttributeId = 26304
            AND campusoptions.[value] = avCampus.[Value]
            AND rr.Id = avCampus.EntityId
    INNER JOIN AttributeValue avRole
        ON avRole.AttributeId = 26305
            AND roleoptions.[value] = avRole.[Value]
            AND rr.Id = avRole.EntityId
    WHERE r.RegistrationInstanceId = 1036
    ) Registrations
WHERE aqCampus.AttributeId = 26304
    AND aqCampus.[Key] = 'values'
GROUP BY ROLLUP(campusoptions.[value], roleoptions.[value])
ORDER BY CASE 
        WHEN campusoptions.[value] IS NULL
            THEN 1
        ELSE 0
        END
    , campusoptions.[value]
    , CASE 
        WHEN roleoptions.[value] IS NULL
            THEN 1
        ELSE 0
        END
    , roleoptions.[value]
