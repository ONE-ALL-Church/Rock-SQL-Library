SELECT 
    fa.Id,
    fa.Name,
    ftd.CreatedDateTime MostRecentTransactionDate,
    ftd.SourceTypeValueId MostRecentTransactionType,
    ftd.SourceType MostRecentTransactionTypeValue,
    ftd.FinancialGatewayId MostRecentTransactionGateway,
    ftd.Summary MostRecentTransactionSummary,
    fa.*
FROM FinancialAccount fa
OUTER APPLY (
    SELECT TOP 1 ftd.CreatedDateTime AS CreatedDateTime,
        ft.SourceTypeValueId AS SourceTypeValueId,
        dv.[Value] AS SourceType,
        ft.FinancialGatewayId AS FinancialGatewayId,
        ft.Summary AS Summary
    FROM FinancialTransactionDetail ftd
    INNER JOIN FinancialTransaction ft ON ft.Id = ftd.TransactionId
    INNER JOIN DefinedValue dv ON dv.Id = ft.SourceTypeValueId
    WHERE ftd.AccountId = fa.Id AND ft.FinancialGatewayId IS NOT NULL
    ORDER BY ftd.CreatedDateTime DESC
    ) ftd
WHERE fa.IsPublic = 0
ORDER BY ftd.CreatedDateTime DESC
