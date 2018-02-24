SELECT
t.cntrID,
guest.org_num_of_contracts(t.orgID) AS 'org_cntr_num',
guest.org_one_side_severance_share(t.orgID) AS 'org_1s_sev',
guest.org_one_side_supplier_severance_share(t.orgID) AS 'org_1s_sup_sev',

guest.sup_num_of_contracts(t.supID) AS 'sup_cntr_num',
guest.sup_avg_contract_price(t.supID) AS 'sup_cntr_avg_price',
guest.sup_avg_penalty_share(t.supID) AS 'sup_cntr_avg_penalty',
guest.sup_no_penalty_cntr_share(t.supID) AS 'sup_no_pnl_share',
guest.sup_okpd_experience_share(t.supID, t.okpdCode) AS 'sup_okpd_exp',
guest.sup_one_side_severance_share(t.supID) AS 'sup_1s_sev',
guest.sup_one_side_org_severance_share(t.supID) AS 'sup_1s_org_sev',
guest.sup_similar_contracts_by_price_share(t.supID, t.valPrice) AS 'sup_sim_price',
CASE
  WHEN t.valPrice > t.valPMP THEN 1
  ELSE 0
END AS price_higher_pmp,
CASE
  WHEN t.valPrice <= t.valPMP * 0.6 THEN 1
  ELSE 0
END AS price_too_low,

guest.pred_variable(t.cntrID) AS 'cntr_result'

FROM 
(
  SELECT DISTINCT
  cntr.ID AS cntrID,
  org.ID AS orgID, 
  sup.ID AS supID, 
  okpd.Code AS okpdCode, 
  val.Price AS valPrice,
  val.PMP AS valPMP
  FROM DV.f_OOS_Value AS val
  INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
  INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  INNER JOIN DV.f_OOS_Product AS prod ON prod.RefContract = cntr.ID
  INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
  INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
  WHERE 
    guest.pred_variable(cntr.ID) = 0 AND
    val.Price > 0 AND --Контракт реальный
    cntr.RefTypePurch != 6 --Не закупка у единственного поставщика
)t

/*
Лимит 100 строк, первое исполнение
17.02.18
Без DISTINCT: 33 секунды,  
С DISTINCT: 120 секунд +, а также ошибка деления на 0

23.02.18
Без DISTINCT: 50 секунд
С DISTINCT: 600+ секунд

24.02.18
Только плохие контракты без DISTINCT: 50 секунд
Только плохие контракты с DISTINCT: 50 секунд
Только плохие контракты без TOP(100) с DISTINCT: 125 сек
Только плохие контракты без TOP(100) с DISTINCT + доп.условие на обоюдное согласие: 2220 сек (37 мин)
*/