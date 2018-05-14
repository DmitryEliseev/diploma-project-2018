CREATE FUNCTION guest.org_one_side_severance_share (@OrgID INT)

/*
Скандальность заказчика: доля контрактов с разрывом отношений в одностороннем порядке по решению заказчика.
Под разрывом в одностороннем порядке понимается:
8326974 - По решению заказчика в одностороннем порядке
8361022 - Решение заказчика об одностороннем отказе от исполнения контракта
8724082 - Односторонний отказ заказчика от исполнения контракта в соответствии с гражданским законодательством
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = guest.org_num_of_contracts(@OrgID)
  DECLARE @num_of_bad_contracts INT = (
  	SELECT COUNT(*)
  	FROM
  	(
  		SELECT DISTINCT cntr.ID
  		FROM DV.f_OOS_Value AS val
  		INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
  		INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  		INNER JOIN DV.d_OOS_ClosContracts As cntrCls ON cntrCls.RefContract = cntr.ID
  		INNER JOIN DV.fx_OOS_ContractStage AS cntrStg ON cntrStg.ID = cntr.RefStage
  		INNER JOIN DV.d_OOS_TerminReason AS trmnRsn ON trmnRsn.ID = cntrCls.RefTerminReason
  		WHERE 
  			trmnRsn.Code IN (8326974,8361022,8724082) AND
  			org.ID = @OrgID
  	)t
  )
  
  -- Обработка случая, когда у заказщика нет завершенных контрактов
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  RETURN ROUND(@num_of_bad_contracts / @num_of_contracts, 5)
END