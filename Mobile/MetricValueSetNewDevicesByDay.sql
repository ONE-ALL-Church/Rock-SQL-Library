--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=68&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetNewDevicesByDay.sql
SELECT COUNT(*) NewDevices,
    NewDevice.[Date] [MetricValueDateTime]
FROM (
    SELECT CAST(MIN(i.InteractionDateTime) AS DATE) [Date]
    FROM InteractionChannel ichan
    INNER JOIN InteractionComponent icom ON ichan.Id = icom.InteractionChannelId
    INNER JOIN Interaction i ON icom.Id = i.InteractionComponentId
    INNER JOIN PersonalDevice pd ON i.PersonalDeviceId = pd.Id
    INNER JOIN DefinedValue pddv ON pd.PersonalDeviceTypeValueId = pddv.Id
    INNER JOIN DefinedValue pdplatdv ON pd.PlatformValueId = pdplatdv.Id
    INNER JOIN InteractionSession ises ON i.InteractionSessionId = ises.Id
    WHERE ichan.Id = 15
        AND i.[InteractionDateTime] >= '2020-10-03'
    GROUP BY pd.Id
    ) NewDevice
GROUP BY NewDevice.[Date]
ORDER BY NewDevice.[Date]
