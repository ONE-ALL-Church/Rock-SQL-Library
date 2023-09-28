DECLARE @CreatedOrUsedDate Date = '2022-09-15';

WITH RelevantAccounts AS (
    SELECT fpsa.Id
    FROM FinancialPersonSavedAccount fpsa
    INNER JOIN FinancialPaymentDetail fpd ON fpsa.Id = fpd.FinancialPersonSavedAccountId
    INNER JOIN FinancialTransaction ft ON fpd.Id = ft.FinancialPaymentDetailId
    LEFT JOIN FinancialScheduledTransaction fst ON ft.ScheduledTransactionId = fst.Id
    GROUP BY fpsa.Id
    HAVING MAX(ft.TransactionDateTime) >= @CreatedOrUsedDate
        OR MIN(fpsa.CreatedDateTime) >= @CreatedOrUsedDate
        OR SUM(CASE WHEN fst.IsActive = 1 THEN 1 ELSE 0 END) > 0
)

SELECT fpsa.PersonAliasId
    , p.LastName
    , p.FirstName
    , p.Email
    , l.Street1
    , l.Street2
    , l.City
    , l.STATE
    , l.PostalCode
    , l.Country
    , CASE 
        WHEN fpd.CurrencyTypeValueId = 156 THEN 'CARD'
        ELSE dfc.Value
      END AS CurrencyType
    , CASE 
        WHEN fpd.CurrencyTypeValueId = 157 THEN 'CHECKING'
      END AS AccountType
    , '' AS AccountNumber
    , '' AS RoutingNumber
    , '' AS CVC
    , FORMAT(fpd.CardExpirationDate, 'MM/yy') AS CardExpirationDate
    , fpsa.GatewayPersonIdentifier AS PreviousGatewayPersonIdentifier
    , fpsa.ReferenceNumber AS PreviousReferenceNumber
FROM FinancialPersonSavedAccount AS fpsa
LEFT JOIN PersonAlias AS ps ON ps.Id = fpsa.PersonAliasId
LEFT JOIN Person AS p ON p.Id = ps.PersonId
LEFT JOIN FinancialPaymentDetail AS fpd ON fpd.Id = fpsa.FinancialPaymentDetailId
LEFT JOIN DefinedValue AS dfc ON dfc.Id = fpd.CurrencyTypeValueId
LEFT JOIN Location AS l ON l.Id = fpd.BillingLocationId
LEFT JOIN FinancialGateway fg ON fg.Id = fpsa.FinancialGatewayId
LEFT JOIN EntityType et ON et.Id = fg.EntityTypeId
WHERE et.Name = 'Rock.NMI.Gateway'
    AND fpsa.Id IN (SELECT Id FROM RelevantAccounts)
