--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=90&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetActiveDevicesPerPlatformPrevious30.sql
-- Declare variables for date range
DECLARE @CurrentDate DATE;

SET @CurrentDate = CONVERT(DATE, GETUTCDATE() AT TIME ZONE 'Pacific Standard Time');

DECLARE @CutoffDate DATE;

SET @CutoffDate = DATEADD(DAY, - 15, @CurrentDate);-- Starting 15 days back

-- Generate a list of the last 15 days
WITH DateList
AS (
    SELECT @CutoffDate AS MetricDate,
        1 AS DayNum
    
    UNION ALL
    
    SELECT DATEADD(DAY, 1, MetricDate),
        DayNum + 1
    FROM DateList
    WHERE DayNum < 15
    ),
    -- Retrieve all platforms from DefinedValue
PlatformList
AS (
    SELECT Id AS Platform
    FROM DefinedValue
    WHERE Id IN (1682, 1683)
    ),
    -- Create all possible date-platform combinations
DatePlatform
AS (
    SELECT dl.MetricDate,
        pl.Platform
    FROM DateList dl
    CROSS JOIN PlatformList pl
    ),
    -- Calculate distinct device counts per date and platform
DeviceCounts
AS (
    SELECT dp.MetricDate,
        dp.Platform,
        COUNT(DISTINCT i.PersonalDeviceId) AS Devices
    FROM DatePlatform dp
    LEFT JOIN (
        Interaction i INNER JOIN InteractionComponent icom ON i.InteractionComponentId = icom.Id
            AND icom.InteractionChannelId = 15 -- Filter for specific interaction channel
        INNER JOIN PersonalDevice pd ON i.PersonalDeviceId = pd.Id
        ) ON i.InteractionDateTime >= DATEADD(DAY, - 29, dp.MetricDate) -- Start of 30-day window
        AND i.InteractionDateTime < DATEADD(DAY, 1, dp.MetricDate) -- End of 30-day window
        AND pd.PlatformValueId = dp.Platform -- Match device platform to DefinedValue Id
    GROUP BY dp.MetricDate,
        dp.Platform
    )
-- Final output with zero counts for no interactions
SELECT 
    COALESCE(Devices, 0) AS DevicesWithInteractions,
    dp.MetricDate AS MetricValueDateTime,
    dp.Platform AS Platform
FROM DeviceCounts dp
ORDER BY MetricValueDateTime,
    Platform;
