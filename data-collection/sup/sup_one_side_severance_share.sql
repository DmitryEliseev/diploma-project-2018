CREATE FUNCTION guest.sup_one_side_severance_share (@SupID INT)

/*
Сканадальность поставщика. Доля контрактов с разрывом отношений в одностороннем порядке по решению поставшика, а именно:
8326975 - По решению поставщика в одностороннем порядке
8361023 - Решение поставщика (подрядчика, исполнителя) об одностороннем отказе от исполнения контракта
8724083 - Односторонний отказ поставщика (подрядчика, исполнителя) от исполнения контракта в соответствии с гражданским законодательством
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = guest.sup_num_of_contracts(@SupID)
  DECLARE @num_of_bad_contracts INT = (
  	SELECT COUNT(*)
  	FROM
  	(
  		SELECT DISTINCT cntr.ID
  		FROM DV.f_OOS_Value AS val
  		INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  		INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  		INNER JOIN DV.d_OOS_ClosContracts As cntrCls ON cntrCls.RefContract = cntr.ID
  		INNER JOIN DV.fx_OOS_ContractStage AS st ON st.ID = cntr.RefStage
  		INNER JOIN DV.d_OOS_TerminReason AS t ON t.ID = cntrCls.RefTerminReason
  		WHERE 
  			t.Code IN (8326975,8361023,8724083) AND 
  			sup.ID = @SupID
  	)t
  )
  
  -- Обработка случая, когда у поставщика еще нет ни одного завершенного контракта
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@num_of_bad_contracts / @num_of_contracts, 5)
END