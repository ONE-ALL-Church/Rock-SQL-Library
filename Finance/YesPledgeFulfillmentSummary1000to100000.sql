SELECT SUM(yp.CurGiving) AmountGiven
    , SUM(yp.Pledge) AmountPledged
    , FORMAT(CAST(SUM(yp.CurGiving) AS FLOAT) / SUM(yp.Pledge), 'P0' ) PercentGivenOfPledges
    , AVG(yp.CurGiving) AvgGiven
    , AVG(yp.Pledge) AvgPledged
    , FORMAT(AVG(CAST(ISNULL(yp.CurGiving, 0) AS FLOAT) / yp.Pledge), 'P0') AvgPercentGivenOfPledgeByFamily
FROM [dbo].[CCVYesPledgeDetail] yp
WHERE Pledge IS NOT NULL
    AND Pledge > 1000 AND Pledge < 100000
    
