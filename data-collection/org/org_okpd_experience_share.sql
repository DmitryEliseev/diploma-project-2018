CREATE FUNCTION guest.org_okpd_cntr_num (@OrgID INT, @OKPDCode INT)

/*
Количество контрактов для конкретного ОКПД и заказчика
*/

RETURNS INT
AS
BEGIN
  DECLARE @cur_okpd_contracts_num INT = (
    SELECT COUNT(*)
    FROM
    (
      SELECT DISTINCT cntr.ID
      FROM DV.f_OOS_Product AS prod
      INNER JOIN DV.d_OOS_Org AS org ON org.ID = prod.RefOrg
      INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = prod.RefContract
      INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
      INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
      INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
      WHERE 
        org.ID = @OrgID AND 
        okpd.Code = @OKPDCode AND
        cntrSt.ID in (3, 4)
    )t
  )
  RETURN @cur_okpd_contracts_num
END