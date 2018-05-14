CREATE FUNCTION guest.org_avg_contract_price (@OrgID INT)

/*
Средняя цена контракта заказчика
*/

RETURNS BIGINT
AS
BEGIN
  DECLARE @AvgPrice BIGINT = (
    SELECT AVG(val.Price)
    FROM DV.f_OOS_Value AS val
    INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
    INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
    INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
    WHERE 
		org.ID = @OrgID AND 
		cntrSt.ID IN (3, 4)
  )
  RETURN @AvgPrice
END