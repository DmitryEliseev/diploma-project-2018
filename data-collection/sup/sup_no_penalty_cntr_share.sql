CREATE FUNCTION guest.sup_no_penalty_cntr_share (@SupID INT)

/*
Доля контрактов без пени от общего числе завершенных поставщиком контрактов
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = guest.sup_num_of_contracts(@SupID)
  DECLARE @no_penalty_cntr_num INT = (
    SELECT COUNT(*)
    FROM
    (
      SELECT DISTINCT cntr.ID
  		FROM DV.f_OOS_Value AS val
      INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  		INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  		INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
      LEFT JOIN DV.d_OOS_Penalties AS pnl ON pnl.RefContract = cntr.ID
      WHERE
        sup.ID = @SupID AND 
    	  cntrSt.ID IN (3, 4) AND
        pnl.Accrual IS NULL
    )t 
  )
  
  -- Обработка случая, когда у поставщика еще нет ни одного завершенного контракта
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@no_penalty_cntr_num / @num_of_contracts, 5)
END