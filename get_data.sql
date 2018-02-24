﻿CREATE FUNCTION get_date(@DateID INT)

/**
Функция, возвращающая дату из таблицы fx_Date_YearDayUNV по ее ID
**/

RETURNS VARCHAR(20)
AS
BEGIN
  DECLARE @data VARCHAR(20)

  SET @data = (
    SELECT dt.DateYear + ' ' + dt.DateMonth + ' ' + dt.DateDay 
    FROM DV.fx_Date_YearDayUNV AS dt
    WHERE dt.ID = @DateID
    )
    
  RETURN @data
END