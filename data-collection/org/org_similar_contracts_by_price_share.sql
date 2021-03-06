CREATE FUNCTION guest.org_similar_contracts_by_price_share (@OrgID INT, @CntrPrice BIGINT)

/*
Количество завершенных заказов у заказчика, цена которых отличается от цены текущего контракте не более, чем на 20%
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = (
    SELECT org_stats.org_cntr_num FROM org_stats WHERE org_stats.OrgID = @OrgID
  )
  DECLARE @num_of_similar_contracts_by_price FLOAT = (
	SELECT COUNT(cntr.ID)
  	FROM DV.f_OOS_Value AS val
  	INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
  	INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  	INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
  	WHERE 
		  org.ID = @OrgID AND 
  		cntrSt.ID IN (3, 4) AND 
  		ABS(val.Price - @CntrPrice) <= 0.2*@CntrPrice
  )
  
  -- Обработка случая, когда у заказчика еще нет ни одного завершенного контракта
  -- Такое теоретически невозможно, но на практике встречается
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@num_of_similar_contracts_by_price / @num_of_contracts, 5)
END