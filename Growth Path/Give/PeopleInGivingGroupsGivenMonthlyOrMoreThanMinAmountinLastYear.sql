--Implemented At: https://admin.oneandall.church/reporting/dataviews?DataViewId=1322&ExpandedIds=C648%2CC675%2CC676%2CC677
-- Tracked At: Growth Path/Give/PeopleInGivingGroupsGivenMonthlyOrMoreThanMinAmountinLastYear.sql
DECLARE @OADate DATETIME
SET @OADate = CAST(GETUTCDATE() AT TIME ZONE 'Pacific Standard Time' AS DATE);

SELECT p.Id 
FROM Person p 
WHERE p.GivingLeaderId IN (
    SELECT p.GivingLeaderId
    FROM FinancialTransaction ft 
    
    INNER JOIN FinancialTransactionDetail ftd ON ft.Id = ftd.TransactionId
    INNER JOIN FinancialAccount fa ON ftd.AccountId = fa.Id AND fa.ParentAccountId = 1
    INNER JOIN PersonAlias pa ON ft.AuthorizedPersonAliasId = pa.Id
    INNER JOIN Person p ON pa.PersonId = p.Id
    OUTER APPLY(
        SELECT CASE 
        WHEN ft.TransactionDateTime >= DATEADD(day, -1, DATEADD(month, -1, @OADate)) THEN ft.SundayDate
        ELSE NULL
        END AS Id
    )Last1Month
    OUTER APPLY(
        SELECT CASE 
        WHEN ft.TransactionDateTime >=DATEADD(day, -1, DATEADD(month, -2, @OADate)) THEN ft.SundayDate
        ELSE NULL
        END AS Id
    )Last2Months
    OUTER APPLY(
        SELECT CASE 
        WHEN ft.TransactionDateTime >= DATEADD(day, -1, DATEADD(month, -3, @OADate)) THEN ft.SundayDate
        ELSE NULL
        END AS Id
    )Last3Months
    OUTER APPLY(
        SELECT CASE 
        WHEN ft.TransactionDateTime >= DATEADD(day, -1,DATEADD(month, -4, @OADate)) THEN ft.SundayDate
        ELSE NULL
        END AS Id
    )Last4Months
    WHERE  ft.TransactionDateTime BETWEEN DATEADD(month, -4, @OADate) AND @OADate
    GROUP BY p.GivingLeaderId
    HAVING COUNT( DISTINCT Last1Month.Id) >= 1 OR COUNT( DISTINCT Last2Months.Id) >= 2 OR COUNT( DISTINCT Last3Months.Id) >= 3 OR COUNT( DISTINCT Last4Months.Id) >= 4 OR SUM(ftd.Amount) >= 4000
    )