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

t.supType,
t.orgForm,

CASE
  WHEN (t.valPMP > 0) AND (t.valPrice > t.valPMP) THEN 1
  ELSE 0
END AS price_higher_pmp,
CASE
  WHEN t.valPrice <= t.valPMP * 0.6 THEN 1
  ELSE 0
END AS price_too_low,

t.valPrice as 'price',
t.valPMP as 'pmp',
t.okpdCode as 'okpd',

guest.pred_variable(t.cntrID) AS 'cntr_result'

FROM 
(
  SELECT DISTINCT
  cntr.ID AS cntrID,
  org.ID AS orgID, 
  sup.ID AS supID, 
  okpd.Code AS okpdCode, 
  val.Price AS valPrice,
  val.PMP AS valPMP,
  supType.Code AS supType,
  orgForm.code as orgForm
  FROM DV.f_OOS_Value AS val
  INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
  INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  INNER JOIN DV.f_OOS_Product AS prod ON prod.RefContract = cntr.ID
  INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
  INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
  INNER JOIN DV.fx_OOS_PartType AS supType ON supType.ID = sup.RefPartType
  INNER JOIN DV.fx_OOS_OrgForm AS orgForm ON orgForm.ID = sup.RefFormOrg
   WHERE 
    guest.pred_variable(cntr.ID) = 0 AND
    val.Price > 0 AND --Контракт реальный
    cntr.RefTypePurch != 6 --Не закупка у единственного поставщика
)t

UNION
SELECT TOP(6000)
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

t.supType,
t.orgForm,

CASE
  WHEN (t.valPMP > 0) AND (t.valPrice > t.valPMP) THEN 1
  ELSE 0
END AS price_higher_pmp,
CASE
  WHEN t.valPrice <= t.valPMP * 0.6 THEN 1
  ELSE 0
END AS price_too_low,

t.valPrice as 'price',
t.valPMP as 'pmp',
t.okpdCode as 'okpd',

guest.pred_variable(t.cntrID) AS 'cntr_result'

FROM 
(
  SELECT DISTINCT
  cntr.ID AS cntrID,
  org.ID AS orgID, 
  sup.ID AS supID, 
  okpd.Code AS okpdCode, 
  val.Price AS valPrice,
  val.PMP AS valPMP,
  supType.Code AS supType,
  orgForm.code as orgForm
  FROM DV.f_OOS_Value AS val
  INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
  INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
  INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  INNER JOIN DV.f_OOS_Product AS prod ON prod.RefContract = cntr.ID
  INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
  INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
  INNER JOIN DV.fx_OOS_PartType AS supType ON supType.ID = sup.RefPartType
  INNER JOIN DV.fx_OOS_OrgForm AS orgForm ON orgForm.ID = sup.RefFormOrg
  WHERE 
    guest.pred_variable(cntr.ID) = 1 AND
    val.Price > 0 AND --Контракт реальный
    cntr.RefTypePurch != 6 --Не закупка у единственного поставщика
)t

/*
25.02 
Общее время выполнения запроса около 80 мин

Создан индекс. При параллельном выполнении обоих частей запроса
выполнение скрипта занимает 25 минут
*/