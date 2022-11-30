DECLARE @TargetDate DATETIME = '2022-08-01' 
SELECT
    asd.Date,
    gBadge.Id,
    MIN(gBadge.Name) AS Name,
    COUNT(DISTINCT p.Id)
FROM
    AnalyticsSourceDate AS asd
    INNER JOIN [dbo].[Person] p ON EXISTS (
        SELECT
            1
        FROM
            GroupType gt
            INNER JOIN [Group] g ON gt.Id = g.GroupTypeId
            INNER JOIN [GroupMember] gmComm ON g.Id = gmComm.GroupId
            AND gmComm.PersonId = p.Id
            INNER JOIN [GroupMemberHistorical] gmHist ON g.Id = gmHist.GroupId
            AND gmHist.GroupMemberId = gmComm.Id
            AND gmHist.IsArchived = 0
            AND gmHist.GroupMemberStatus = 1
            AND asd.Date BETWEEN gmHist.EffectiveDateTime
            AND gmHist.ExpireDateTime
        WHERE
            gt.GroupTypePurposeValueId = 2568
    )
    INNER JOIN [GroupMember] gmBadge ON gmBadge.PersonId = p.Id
    INNER JOIN [Group] gBadge ON gBadge.Id = gmBadge.GroupId
    AND gBadge.ParentGroupId = 272181
    AND EXISTS (
        SELECT
            1
        FROM
            [GroupMemberHistorical] gmHistServe 
            WHERE gmHistServe.GroupMemberId = gmBadge.Id
            AND gmHistServe.IsArchived = 0
            AND gmHistServe.GroupMemberStatus = 1
            AND asd.Date BETWEEN gmHistServe.EffectiveDateTime
            AND gmHistServe.ExpireDateTime
    )
WHERE
    asd.[Date] BETWEEN '2021-09-05'
    AND GETDATE()
    AND asd.SundayDate = asd.[Date]
GROUP BY
    asd.[Date],
    gBadge.Id
ORDER BY
    asd.[Date]