CREATE FUNCTION guest.sup_num_of_contracts (@SupID INT)

/*
Количество завершенных контрактов у поставщика
*/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_all_finished_contracts FLOAT = (
	SELECT COUNT(cntr.ID)
	FROM DV.f_OOS_Value AS val
	INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
	INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
	INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
	WHERE 
		sup.ID = @SupID AND 
		cntrSt.ID IN (3, 4)
  )
  RETURN @num_of_all_finished_contracts
END