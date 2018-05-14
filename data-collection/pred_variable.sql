CREATE FUNCTION guest.pred_variable (@CntrID INT)

/*
Функция, которая определяет является ли контракт хорошим или плохим (целевая переменная).
Завершенный контракт является хорошим ("1"), если
1) Причина разрыва контракта не указана ИЛИ
2) Контракт разорван по обоюдному соглашению, И контракт выполнен на более 60%
В остальных случая контракт считается плохим плохой ("0").
*/

RETURNS INT
AS
BEGIN
  DECLARE @PredVar INT = (
    SELECT 'pred_var' =
  	  CASE
    		WHEN
    		  t.Code = 0 OR
    		  (
    			t.Code IN (8361024,8724080,1) AND 
          t.Price > 0 AND
    			t.Done / t.Price >= 0.6
    		  ) THEN 1
    		ELSE 0
  	  END
  	FROM
  	(
      -- Выбор последней записи для контрактов с несколькими стадиями,
      -- проблемы у которых начались не с первой стадии
  	  SELECT TOP(1)
      cntr.ID, trmn.Code, sum(clsCntr.FactPaid) AS Done, val.Price,
      ROW_NUMBER() over (ORDER BY cntr.ID) as rowNum
  	  FROM DV.f_OOS_Value as val
  	  INNER JOIN DV.d_OOS_Contracts AS cntr ON cntr.ID = val.RefContract
  	  INNER JOIN DV.d_OOS_ClosContracts AS clsCntr ON clsCntr.RefContract = cntr.ID
  	  INNER JOIN DV.d_OOS_TerminReason AS trmn ON trmn.ID = clsCntr.RefTerminReason
  	  WHERE cntr.ID = @CntrID
  	  GROUP BY cntr.ID, trmn.Code, val.Price
      ORDER BY rowNum DESC
  	)t
  )
  RETURN @PredVar
END