CREATE FUNCTION sup_okpd_experience_share (@SupID INT, @OKPDCode INT)

/**
Доля контрактов по указанному ОКПД среди всех завершенных контрактов 
**/

RETURNS FLOAT
AS
BEGIN
  DECLARE @num_of_contracts FLOAT = guest.sup_num_of_contracts(@SupID)
  DECLARE @cur_okpd_contracts_num INT = (
    SELECT COUNT(*)
    FROM
    (
      SELECT DISTINCT cntr.ID
      FROM DV.f_OOS_Product AS prod
      INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = prod.RefSupplier
      INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = prod.RefContract
      INNER JOIN DV.fx_OOS_ContractStage AS cntrSt ON cntrSt.ID = cntr.RefStage
      INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
      INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
      WHERE 
        sup.ID = @SupID AND 
        okpd.Code = @OKPDCode AND
        cntrSt.ID in (3, 4)
    )t
  )
  
  -- Обработка случая, когда у поставщика еще нет ни одного завершенного контракта
  IF @num_of_contracts = 0
  BEGIN
    RETURN 0
  END
  
  -- КОСТЫЛЬ: округление значений больших 1 до 1
  DECLARE @share FLOAT = ROUND(@cur_okpd_contracts_num / @num_of_contracts, 5)
  IF @share > 1
  BEGIN
    RETURN 1
  END
  
  RETURN @share
END