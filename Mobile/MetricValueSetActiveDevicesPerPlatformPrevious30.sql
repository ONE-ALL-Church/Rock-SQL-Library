--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=90&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetActiveDevicesPerPlatformPrevious30.sql

DECLARE @OADateTime DATE
SET @OADateTime = CAST(GETUTCDATE() AT TIME ZONE 'Pacific Standard Time' AS date);
DECLARE @Cutoff DATE
SET @Cutoff = CAST(DATEADD(d, -8, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time') AS date);

SELECT COUNT(DISTINCT i.PersonalDeviceId) Devices,
asd.[Date] [MetricValueDateTime],
pdplatdv.Id Platform
FROM AnalyticsSourceDate asd
INNER JOIN InteractionChannel ichan ON ichan.Id = 15
INNER JOIN InteractionComponent icom ON ichan.Id = icom.InteractionChannelId
INNER JOIN AnalyticsSourceDate asdSeven ON asdSeven.[Date] <= asd.[Date] AND asdSeven.[Date] > DATEADD(d,-30, asd.[Date])
INNER JOIN Interaction i ON i.InteractionDateKey  =  asdSeven.DateKey
INNER JOIN PersonalDevice pd ON i.PersonalDeviceId = pd.Id 
INNER JOIN DefinedValue pdplatdv ON pd.PlatformValueId = pdplatdv.Id
WHERE  asd.[Date] >= @Cutoff AND asd.[Date] < @OADateTime
GROUP BY asd.Date, pdplatdv.Id
ORDER BY asd.[Date]