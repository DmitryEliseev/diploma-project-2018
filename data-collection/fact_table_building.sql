GO
SELECT DISTINCT TOP(50)
cntr.ID AS cntrID,
org.ID AS orgID, 
sup.ID AS supID, 
sup.RefStatusSup AS sup_status,

supType.Code AS sup_type,
orgForm.code AS org_form,
org.RefTypeOrg AS org_type,

guest.sup_stats.sup_cntr_num AS sup_cntr_num,
guest.sup_stats.sup_cntr_avg_price AS sup_cntr_avg_price,
guest.sup_stats.sup_cntr_avg_penalty AS sup_cntr_avg_penalty,
guest.sup_stats.sup_no_pnl_share AS sup_no_pnl_share,
guest.sup_stats.sup_1s_sev AS sup_1s_sev,
guest.sup_stats.sup_1s_org_sev AS sup_1s_org_sev,
guest.sup_okpd_experience_share(sup.ID, okpd.Code) AS sup_okpd_exp,
guest.sup_similar_contracts_by_price_share(sup.ID, val.Price) AS sup_sim_price,

guest.org_stats.org_cntr_num AS org_cntr_num,
guest.org_stats.org_cntr_avg_price AS org_cntr_avg_price,
guest.org_stats.org_1s_sev AS org_1s_sev,
guest.org_stats.org_1s_sup_sev AS org_1s_sup_sev,

cntr.RefTypePurch AS purch_type,

guest.okpd_stats.cntr_num AS okpd_cntr_num,
1.0 * guest.okpd_stats.good_cntr_num / guest.okpd_stats.cntr_num AS good_okpd_share,

okpd.Code AS okpd, 
val.Price AS price,
val.PMP AS pmp,

val.RefLevelOrder AS cntr_lvl,
cntr.RefSignDate AS sign_date,
cntr.RefExecution AS exec_date,

CASE
  WHEN (val.PMP > 0) AND (val.Price > val.PMP) THEN 1
  ELSE 0
END AS price_higher_pmp,
CASE
  WHEN val.Price <= val.PMP * 0.6 THEN 1
  ELSE 0
END AS price_too_low,

guest.pred_variable(cntr.ID) AS cntr_result

FROM DV.f_OOS_Value AS val
INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
INNER JOIN DV.f_OOS_Product AS prod ON prod.RefContract = cntr.ID
INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
INNER JOIN DV.fx_OOS_PartType AS supType ON supType.ID = sup.RefPartType
INNER JOIN DV.fx_OOS_OrgForm AS orgForm ON orgForm.ID = sup.RefFormOrg
INNER JOIN guest.sup_stats ON sup.ID = guest.sup_stats.SupID
INNER JOIN guest.org_stats ON org.ID = guest.org_stats.OrgID
INNER JOIN guest.okpd_stats ON okpd.Code = guest.okpd_stats.code
WHERE 
  guest.pred_variable(cntr.ID) = 0 AND
  val.Price > 0 AND --Контракт реальный
  cntr.RefTypePurch != 6 AND --Не закупка у единственного поставщика
  cntr.RefStage != -1 AND --Контракт завершен
  cntr.RefStage != 1 AND
  cntr.RefStage != 2 AND
  cntr.RefSignDate > 20150000 --Контракт заключен не ранее 2015 года

GO
--Выбор на 30% больше хороших контрактов
SELECT TOP(CAST(@@ROWCOUNT*1.3 AS INT))
cntr.ID AS cntrID,
org.ID AS orgID, 
sup.ID AS supID, 
sup.RefStatusSup AS sup_status,

supType.Code AS sup_type,
orgForm.code AS org_form,
org.RefTypeOrg AS org_type,

guest.sup_stats.sup_cntr_num AS sup_cntr_num,
guest.sup_stats.sup_cntr_avg_price AS sup_cntr_avg_price,
guest.sup_stats.sup_cntr_avg_penalty AS sup_cntr_avg_penalty,
guest.sup_stats.sup_no_pnl_share AS sup_no_pnl_share,
guest.sup_stats.sup_1s_sev AS sup_1s_sev,
guest.sup_stats.sup_1s_org_sev AS sup_1s_org_sev,
guest.sup_okpd_experience_share(sup.ID, okpd.Code) AS sup_okpd_exp,
guest.sup_similar_contracts_by_price_share(sup.ID, val.Price) AS sup_sim_price,

guest.org_stats.org_cntr_num AS org_cntr_num,
guest.org_stats.org_cntr_avg_price AS org_cntr_avg_price,
guest.org_stats.org_1s_sev AS org_1s_sev,
guest.org_stats.org_1s_sup_sev AS org_1s_sup_sev,

cntr.RefTypePurch AS purch_type,

guest.okpd_stats.cntr_num AS okpd_cntr_num,
1.0 * guest.okpd_stats.good_cntr_num / guest.okpd_stats.cntr_num AS good_okpd_share,

okpd.Code AS okpd, 
val.Price AS price,
val.PMP AS pmp,

val.RefLevelOrder AS cntr_lvl,
cntr.RefSignDate AS sign_date,
cntr.RefExecution AS exec_date,

CASE
  WHEN (val.PMP > 0) AND (val.Price > val.PMP) THEN 1
  ELSE 0
END AS price_higher_pmp,
CASE
  WHEN val.Price <= val.PMP * 0.6 THEN 1
  ELSE 0
END AS price_too_low,

guest.pred_variable(cntr.ID) AS cntr_result

FROM DV.f_OOS_Value AS val
INNER JOIN DV.d_OOS_Suppliers AS sup ON sup.ID = val.RefSupplier
INNER JOIN DV.d_OOS_Org AS org ON org.ID = val.RefOrg
INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
INNER JOIN DV.f_OOS_Product AS prod ON prod.RefContract = cntr.ID
INNER JOIN DV.d_OOS_Products AS prods ON prods.ID = prod.RefProduct
INNER JOIN DV.d_OOS_OKPD2 AS okpd ON okpd.ID = prods.RefOKPD2
INNER JOIN DV.fx_OOS_PartType AS supType ON supType.ID = sup.RefPartType
INNER JOIN DV.fx_OOS_OrgForm AS orgForm ON orgForm.ID = sup.RefFormOrg
INNER JOIN guest.sup_stats ON sup.ID = guest.sup_stats.SupID
INNER JOIN guest.org_stats ON org.ID = guest.org_stats.OrgID
INNER JOIN guest.okpd_stats ON okpd.Code = guest.okpd_stats.code
WHERE 
  guest.pred_variable(cntr.ID) = 1 AND
  val.Price > 0 AND --Контракт реальный
  cntr.RefTypePurch != 6 AND --Не закупка у единственного поставщика
  cntr.RefStage != -1 AND --Контракт завершен
  cntr.RefStage != 1 AND
  cntr.RefStage != 2 AND
  cntr.RefSignDate > 20150000 --Контракт заключен не ранее 2015 года
ORDER BY NEWID()