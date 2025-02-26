--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=67&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetActiveDevicesPerPlatformPrevious1.sql

DECLARE @OADateTime DATE;
SET @OADateTime = CONVERT(DATE, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');
DECLARE @Cutoff DATE;
SET @Cutoff = CONVERT(DATE, DATEADD(day, -15, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time'));

-- Define all date-platform combinations
WITH DatePlatform AS (
    SELECT 
        asd.[Date],
        pdplatdv.Id AS Platform
    FROM AnalyticsSourceDate asd
    CROSS JOIN DefinedValue pdplatdv
    WHERE asd.[Date] >= @Cutoff 
    AND asd.[Date] < @OADateTime
    AND pdplatdv.Id IN (1682, 1683)
    -- Optional: Add WHERE pdplatdv.Id IN (1682, 1683, 1684, 1817, 1818) if specific platforms are needed
),

-- Aggregate interactions by date and platform
InteractionAggregate AS (
    SELECT 
        CAST(i.InteractionDateTime AS DATE) AS MetricValueDateTime,
        pd.PlatformValueId AS Platform,
        COUNT(DISTINCT i.PersonalDeviceId) AS Devices
    FROM Interaction i
    INNER JOIN InteractionComponent icom 
        ON i.InteractionComponentId = icom.Id 
        AND icom.InteractionChannelId = 15
    INNER JOIN PersonalDevice pd 
        ON i.PersonalDeviceId = pd.Id
    WHERE i.InteractionDateTime >= @Cutoff 
    AND i.InteractionDateTime < @OADateTime
    GROUP BY CAST(i.InteractionDateTime AS DATE), pd.PlatformValueId
)

-- Combine date-platform pairs with interaction counts
SELECT 
    COALESCE(ia.Devices, 0) AS Devices,
    dp.[Date] AS MetricValueDateTime,
    dp.Platform
FROM DatePlatform dp
LEFT JOIN InteractionAggregate ia 
    ON dp.[Date] = ia.MetricValueDateTime 
    AND dp.Platform = ia.Platform
ORDER BY dp.[Date], dp.Platform;