SELECT asd.CalendarYear
    , asd.CalendarMonth
    , Count(DISTINCT Attendees.PersonId) SPAttendees
    , SUM(CASE 
            WHEN TSAttendancesCount > 20
                THEN 1
            ELSE 0
            END) Attended20TSWeeks
    , FORMAT(ISNULL(SUM(CASE 
                    WHEN TSAttendancesCount > 20
                        THEN 1
                    ELSE 0
                    END) / NULLIF(CAST((Count(DISTINCT Attendees.PersonId)) AS FLOAT), 0), 0), 'P0') PercentAttended20TSWeeks
    , SUM(CASE 
            WHEN TSAttendancesCount > 0
                THEN 1
            ELSE 0
            END) Attended1TSWeek
    , FORMAT(ISNULL(SUM(CASE 
                    WHEN TSAttendancesCount > 1
                        THEN 1
                    ELSE 0
                    END) / NULLIF(CAST((Count(DISTINCT Attendees.PersonId)) AS FLOAT), 0), 0), 'P0') PercentAttended1TSWeeks
    , AVG(TSAttendancesCount) AVGTSWeeksOverall
    , AVG(CASE 
            WHEN TSAttendancesCount > 0
                THEN TSAttendancesCount
            ELSE NULL
            END) AVGTSWeeksOfTSAttendees
FROM (
    SELECT gm.PersonId
        , MIN(FirstAttendance.OccurrenceDate) OccurrenceDate
        , COUNT(DISTINCT CASE 
                WHEN TSAttendances.OccurrenceDate < DATEADD(week, 75, FirstAttendance.OccurrenceDate)
                    THEN TSAttendances.OccurrenceDate
                END) TSAttendancesCount
    -- , MAX(TSAttendances.OccurrenceDate)
    FROM GroupType gt
    INNER JOIN [Group] g
        ON gt.Id = g.GroupTypeId
            AND gt.Id = 49 --AND g.IsActive = 1 AND g.IsArchived != 1
    INNER JOIN [AttributeValue] avm
        ON g.Id = avm.EntityId
            AND avm.AttributeId = 6309
    INNER JOIN AttributeMatrix am
        ON am.Guid = TRY_CAST(avm.[Value] AS UNIQUEIDENTIFIER)
    INNER JOIN AttributeMatrixItem ami
        ON am.Id = ami.AttributeMatrixId
    INNER JOIN AttributeValue avt
        ON ami.Id = avt.EntityId
            AND avt.AttributeId = 6307
    INNER JOIN DefinedValue sqdf
        ON TRY_CAST(avt.[Value] AS UNIQUEIDENTIFIER) = sqdf.Guid
            AND sqdf.Id = 2116
    INNER JOIN AttributeValue avq
        ON ami.Id = avq.EntityId
            AND avq.AttributeId = 6312
    INNER JOIN AttributeValue avst -- TopicStartTime
        ON ami.Id = avst.EntityId
            AND avst.AttributeId = 13732
    INNER JOIN AttributeValue avet -- TopicEndTime
        ON ami.Id = avet.EntityId
            AND avet.AttributeId = 13733
    INNER JOIN GroupMember gm
        ON gm.GroupId = g.Id
    OUTER APPLY (
        SELECT TOP 1 ao.OccurrenceDate
        FROM AttendanceOccurrence ao
        INNER JOIN Attendance a
            ON ao.Id = a.OccurrenceId
                AND a.DidAttend = 1
        INNER JOIN PersonAlias pa
            ON pa.PersonId = gm.PersonId
        INNER JOIN GroupMemberHistorical gmh
            ON gm.Id = gmh.GroupMemberId
                AND gmh.GroupMemberStatus != 0
                AND ao.OccurrenceDate BETWEEN gmh.EffectiveDateTime AND gmh.ExpireDateTime
        INNER JOIN GroupTypeRole gtr
            ON gmh.GroupRoleId = gtr.Id
                AND gtr.IsLeader = 0
        WHERE g.Id = ao.GroupId
            AND ao.OccurrenceDate BETWEEN avst.ValueAsDateTime AND avet.ValueAsDateTime
        ORDER BY ao.OccurrenceDate
        ) FirstAttendance
    OUTER APPLY (
        SELECT DISTINCT TOP 32 aoTS.OccurrenceDate
        FROM GroupMember gmTS
        INNER JOIN [Group] gTS
            ON gmTS.GroupId = gTS.Id
        INNER JOIN GroupTypeRole gtr
            ON gmTS.GroupRoleId = gtr.Id
                AND gtr.IsLeader = 0
        INNER JOIN [AttributeValue] avmTS
            ON gTS.Id = avmTS.EntityId
                AND avmTS.AttributeId = 6309
        INNER JOIN AttributeMatrix amTS
            ON amTS.Guid = TRY_CAST(avmTS.[Value] AS UNIQUEIDENTIFIER)
        INNER JOIN AttributeMatrixItem amiTS
            ON amTS.Id = amiTS.AttributeMatrixId
        INNER JOIN AttributeValue avtTS
            ON amiTS.Id = avtTS.EntityId
                AND avtTS.AttributeId = 6307
        INNER JOIN DefinedValue sqdfTS
            ON TRY_CAST(avtTS.[Value] AS UNIQUEIDENTIFIER) = sqdfTS.Guid
                AND sqdfTS.Id = 2117
        INNER JOIN AttributeValue avqTS
            ON amiTS.Id = avqTS.EntityId
                AND avqTS.AttributeId = 6312
        INNER JOIN AttendanceOccurrence aoTS
            ON gTS.Id = aoTs.GroupId
        /*     INNER JOIN GroupMemberHistorical gmhTS
            ON gmTS.Id = gmhTS.GroupMemberId
                AND aoTS.OccurrenceDate BETWEEN gmhTS.EffectiveDateTime AND gmhTS.ExpireDateTime
        INNER JOIN GroupTypeRole gtrTS
            ON gmhTS.GroupRoleId = gtrTS.Id
                AND gtr.IsLeader = 0 */
        INNER JOIN Attendance aTS
            ON aoTS.Id = aTS.OccurrenceId
                AND aTS.DidAttend = 1
        INNER JOIN AttributeValue avstTS -- TopicStartTime
            ON amiTS.Id = avstTS.EntityId
                AND avst.AttributeId = 13732
        INNER JOIN AttributeValue avetTS -- TopicEndTime
            ON amiTS.Id = avetTS.EntityId
                AND avet.AttributeId = 13733
        INNER JOIN PersonAlias paTS
            ON aTS.PersonAliasId = paTS.Id
                AND paTS.PersonId = gm.PersonId
        WHERE gmTs.PersonId = gm.PersonId
            AND aoTS.OccurrenceDate BETWEEN avstTS.ValueAsDateTime AND avetTS.ValueAsDateTime
        ORDER BY aoTS.OccurrenceDate
        ) TSAttendances
    WHERE FirstAttendance.OccurrenceDate IS NOT NULL
    GROUP BY gm.PersonId
        --HAVING COUNT(DISTINCT TSAttendances.OccurrenceDate) > 20 AND MAX(TSAttendances.OccurrenceDate) > DATEADD(year, - 1, @OADateTime)
    ) Attendees
INNER JOIN AnalyticsSourceDate asd
    ON Attendees.OccurrenceDate = asd.[Date]
GROUP BY asd.CalendarYear
    , asd.CalendarMonth
ORDER BY asd.CalendarYear
    , asd.CalendarMonth
