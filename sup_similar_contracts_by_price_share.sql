﻿CREATE FUNCTION sup_similar_contracts_by_price_share (@SupID INT, @CntrPrice BIGINT)

/*
Количество завершенных заказов у поставщика, цена которых отличается от текущего на не более 20%
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = guest.sup_num_of_contracts(@SupID)
  DECLARE @num_of_similar_contracts_by_price FLOAT = (
	SELECT COUNT(cntr.ID)
  	FROM DV.f_OOS_Value AS val
  	INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  	INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  	INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
  	WHERE 
		sup.ID = @SupID AND 
  		cntrSt.ID IN (3, 4) AND 
  		ABS(val.Price - @CntrPrice) <= 0.2*@CntrPrice
  )
  
    -- Обработка случая, когда у поставщика еще нет ни одного завершенного контракта
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@num_of_similar_contracts_by_price / @num_of_contracts, 5)
END