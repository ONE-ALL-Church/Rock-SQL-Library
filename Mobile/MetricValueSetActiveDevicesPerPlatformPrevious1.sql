--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=67&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetActiveDevicesPerPlatformPrevious1.sql

DECLARE @OADateTime DATE
SET @OADateTime = CONVERT(DATE, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');
DECLARE @Cutoff DATE
SET @Cutoff = CONVERT(DATE, DATEADD(d, -15, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time'));

SELECT COUNT(DISTINCT i.PersonalDeviceId) Devices,
asd.[Date] [MetricValueDateTime],
pdplatdv.Id Platform
FROM AnalyticsSourceDate asd
INNER JOIN Interaction i ON i.InteractionDateTime BETWEEN DATEADD(d, -1, asd.[Date]) AND DATEADD(d, 1, asd.[Date])
INNER JOIN InteractionComponent icom ON i.InteractionComponentId = icom.Id
INNER JOIN PersonalDevice pd ON i.PersonalDeviceId = pd.Id
INNER JOIN DefinedValue pdplatdv ON pd.PlatformValueId = pdplatdv.Id
WHERE asd.[Date] >= @Cutoff AND asd.[Date] < @OADateTime
AND icom.InteractionChannelId = 15
GROUP BY asd.[Date], pdplatdv.Id
ORDER BY asd.[Date]