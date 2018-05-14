CREATE FUNCTION guest.sup_avg_penalty_share (@SupID INT)

/*
Усредненная доля начисленных пени от цены контракта по всем заверщенным контрактам
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @avg_penalty_share FLOAT = (
    SELECT AVG(t.share)
    FROM
    (
  		SELECT DISTINCT pnl.Accrual / val.Price AS share
  		FROM DV.f_OOS_Value AS val
      INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier    
  		INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  		INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
  		INNER JOIN DV.d_OOS_Penalties AS pnl ON pnl.RefContract = cntr.ID
  		WHERE
  			sup.ID = @SupID AND 
  			cntrSt.ID IN (3, 4) 
    )t 
  )
  
  -- Если штрафов по контрактам нет совсем
  IF @avg_penalty_share IS NULL
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@avg_penalty_share, 5)
END