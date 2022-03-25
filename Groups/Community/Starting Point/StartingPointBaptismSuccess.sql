SELECT asd.CalendarYear
    , asd.CalendarMonth
    , Count(DISTINCT gm.PersonId) Attendees
    , COUNT( DISTINCT CASE 
            WHEN avBaptism.[VALUE] IS NOT NULL
                AND avBaptism.[ValueAsDateTime] < FirstAttendance.OccurrenceDate
                THEN gm.PersonId
            ELSE NULL
            END) BaptizedBeforeSP
    , COUNT( DISTINCT CASE 
            WHEN avBaptism.[VALUE] IS NOT NULL
                AND avBaptism.[ValueAsDateTime] > FirstAttendance.OccurrenceDate
                AND avBaptism.ValueAsDateTime < DATEADD(year, 1, FirstAttendance.OccurrenceDate)
                THEN gm.PersonId
            ELSE NULL
            END) BaptizedIn12moAfterSP
    , FORMAT(ISNULL(COUNT( DISTINCT CASE 
                    WHEN avBaptism.[VALUE] IS NOT NULL
                        AND avBaptism.[ValueAsDateTime] > FirstAttendance.OccurrenceDate
                        AND avBaptism.ValueAsDateTime < DATEADD(year, 1, FirstAttendance.OccurrenceDate)
                        THEN gm.PersonId
                    ELSE NULL
                    END) / NULLIF(CAST((
                        Count(DISTINCT gm.PersonId) - COUNT( DISTINCT CASE 
                                WHEN avBaptism.[VALUE] IS NOT NULL
                                    AND avBaptism.[ValueAsDateTime] > FirstAttendance.OccurrenceDate
                                    AND avBaptism.ValueAsDateTime < DATEADD(year, 1, FirstAttendance.OccurrenceDate)
                                    THEN gm.PersonId
                                ELSE NULL
                                END)
                        ) AS FLOAT), 0), 0), 'P0') PercentBaptizedNotBaptizedBeforeSP
FROM GroupType gt
INNER JOIN [Group] g
    ON gt.Id = g.GroupTypeId
        AND gt.Id = 49 --AND g.IsActive = 1 AND g.IsArchived != 1
INNER JOIN [AttributeValue] avm
    ON g.Id = avm.EntityId
        AND avm.AttributeId = 6309
INNER JOIN AttributeMatrix am
    ON am.Guid = TRY_CAST(avm.[Value] AS uniqueidentifier)
INNER JOIN AttributeMatrixItem ami
    ON am.Id = ami.AttributeMatrixId
INNER JOIN AttributeValue avt
    ON ami.Id = avt.EntityId
        AND avt.AttributeId = 6307
INNER JOIN DefinedValue sqdf
    ON TRY_CAST(avt.[Value] AS uniqueidentifier) = sqdf.Guid
        AND sqdf.Id = 2116
INNER JOIN AttributeValue avq
    ON ami.Id = avq.EntityId
        AND avq.AttributeId = 6312
INNER JOIN GroupMember gm
    ON gm.GroupId = g.Id
INNER JOIN AttributeValue avst
    ON ami.Id = avst.EntityId
        AND avst.AttributeId = 13732
INNER JOIN AttributeValue avet
    ON ami.Id = avet.EntityId
        AND avet.AttributeId = 13733
OUTER APPLY (
    SELECT TOP 1 ao.OccurrenceDate
    FROM AttendanceOccurrence ao
    INNER JOIN Attendance a
        ON ao.Id = a.OccurrenceId AND a.DidAttend = 1
     INNER JOIN GroupMemberHistorical gmh
        ON gm.Id = gmh.GroupMemberId
            AND gmh.GroupMemberStatus != 0
            AND ao.OccurrenceDate BETWEEN gmh.EffectiveDateTime AND gmh.ExpireDateTime
    INNER JOIN GroupTypeRole gtr
        ON gmh.GroupRoleId = gtr.Id
            AND gtr.IsLeader = 0
    INNER JOIN PersonAlias pa
        ON pa.PersonId = gm.PersonId
    WHERE g.Id = ao.GroupId AND ao.OccurrenceDate BETWEEN avst.ValueAsDateTime AND avet.ValueAsDateTime
    ORDER BY ao.OccurrenceDate 
    ) FirstAttendance
INNER JOIN AnalyticsSourceDate asd
    ON FirstAttendance.OccurrenceDate = asd.[Date]
LEFT JOIN AttributeValue avBaptism
    ON avBaptism.EntityId = gm.PersonId
        AND avBaptism.AttributeId = 174
GROUP BY asd.CalendarYear
    , asd.CalendarMonth
ORDER BY asd.CalendarYear
    , asd.CalendarMonth
