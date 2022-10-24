SELECT i.InteractionSummary BlogTitle
    , MIN(i.InteractionData) [URL]
    , COUNT(DISTINCT i.Id) PageViews
    , COUNT(DISTINCT s.Id) UniqueSessions
    , COUNT(DISTINCT pa.PersonID) LoggedInViewers
    , MIN(i.InteractionDateTime) FirstViewed
    , MAX(i.InteractionDateTime) LastViewed
    , MIN(ic.InteractionChannelId)
FROM InteractionSession s
INNER JOIN Interaction i
    ON s.Id = i.InteractionSessionId
INNER JOIN InteractionComponent ic
    ON i.InteractionComponentId = ic.Id
INNER JOIN InteractionDeviceType d
    ON s.DeviceTypeId = d.Id
LEFT JOIN PersonAlias pa
    ON i.PersonAliasId = pa.Id
WHERE ic.InteractionChannelId IN (42, 43)
 AND i.InteractionDateTime > '2022-10-01'
GROUP BY i.InteractionSummary
ORDER BY MIN(i.InteractionDateTime) DESC
