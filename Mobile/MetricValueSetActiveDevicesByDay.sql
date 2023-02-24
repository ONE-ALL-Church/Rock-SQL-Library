--Implemented At: https://admin.oneandall.church/reporting/metrics?MetricCategoryId=87&ExpandedIds=C758%2CC596
-- Tracked At: Mobile/MetricValueSetActiveDevicesByDay.sql
DECLARE @OADateTime DATETIME
SET @OADateTime = GETUTCDATE() AT TIME ZONE 'Pacific Standard Time';

SELECT COUNT(DISTINCT Soonest.PersonalDeviceId), asd.[Date] [MetricValueDateTime]
FROM AnalyticsSourceDate asd
INNER JOIN (
    SELECT i.PersonalDeviceId,
    CAST(MIN(i.InteractionDateTime) AS DATE) [MinDate]
    FROM InteractionChannel ichan
    INNER JOIN InteractionComponent icom ON ichan.Id = icom.InteractionChannelId
    INNER JOIN Interaction i ON icom.Id = i.InteractionComponentId AND  i.InteractionDateTime >= '2020-10-03'
    INNER JOIN PersonalDevice pd ON i.PersonalDeviceId = pd.Id 
    WHERE ichan.Id = 15 
    GROUP BY i.PersonalDeviceId
    ) Soonest ON asd.[Date] >= Soonest.MinDate  
WHERE asd.[Date] < DATEADD(d, -1, @OADateTime) AND asd.[Date] >= '2020-10-03'
GROUP BY asd.[Date]
ORDER BY asd.[Date]
