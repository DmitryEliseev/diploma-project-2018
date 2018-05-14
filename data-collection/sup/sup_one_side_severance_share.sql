CREATE FUNCTION guest.sup_one_side_severance_share (@SupID INT)

/*
Сканадальность поставщика: доля контрактов с разрывом отношений в одностороннем порядке по решению поставшика. 
Под разрывом в одностороннем порядке понимается:
- разрыв по решению поставщика в одностороннем порядке (код в БД: 8326975);
- решение поставщика об одностороннем отказе от исполнения контракта (код в БД: 8361023);
- односторонний отказ поставщика от исполнения контракта в соответствии с гражданским законодательством (код в БД: 8724083)
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
  			t.Code IN (8326975, 8361023, 8724083) AND 
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