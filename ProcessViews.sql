/**DROP VIEW IF EXISTS rpt.VIEW_PROC_THERMAL;
DROP VIEW IF EXISTS rpt.VIEW_PROC_MICROWAVE;
DROP VIEW IF EXISTS rpt.VIEW_PROC_PLT;
DROP VIEW IF EXISTS rpt.VIEW_PROC_SPD;
DROP VIEW IF EXISTS rpt.VIEW_PROC_CO2;
DROP VIEW IF EXISTS rpt.VIEW_PROC_CARB;
DROP VIEW IF EXISTS rpt.VIEW_PROC_CSC;
*/

/** Thermal */
 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_THERMAL  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''T%[_]100'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
  FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_THERMAL'' )
, L2 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
  FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_SIEVE'' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_RC_YIELD', default) + ' )
, P2 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_SIEVE', default) + ' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
SELECT D.MFDUNIT_ID as LotId
, D.PARENT as Parent
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, L1.RESOURCE_ID as ReactorId
, L1.RECIPE_ID as RecipeId
, L1.LOAD_DATE as ReactorLoadTime
, L1.LOAD_BY as ReactorLoadBy
, L1.UNL_DATE as ReactorUnloadTime
, L1.UNL_BY as ReactorUnloadBy
, L1.COMMENTS as ReactorComments
, DATEPART(week, L1.UNL_DATE) as ReactorUnloadWeek
, TRY_CAST(P1.CYC as float) as CYC_g
, TRY_CAST(P1.FIL as float)as FIL_g
, TRY_CAST(P1.FilCycRatio as float) as FilCycRatio
, TRY_CAST(P1.TotalOST as float) as TotalOST_s
, P1.Comments as ReactorYieldComments
, P1.PERFORMED_DATE as ReactorLogTime
, P1.PERFORMED_BY as ReactorLogBy
, L2.RESOURCE_ID as ShakerId
, L2.RECIPE_ID as SieveId
, L2.LOAD_DATE as SieveLoadTime
, L2.LOAD_BY as SieveLoadBy
, L2.UNL_DATE as SieveUnloadTime
, L2.UNL_BY as SieveUnloadBy
, L2.COMMENTS as SieveComments
, TRY_CAST(P2.PreWt as float) as PreSieveQty_g
, TRY_CAST(P2.PostWt as float) as PostSieveQty_g
, TRY_CAST(P2.Yield as float) as SieveYield_pct
, P2.PERFORMED_DATE SieveLogTime
, P2.PERFORMED_BY SieveLogBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = COALESCE(D.PARENT, D.MFDUNIT_ID) AND L1.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = COALESCE(D.PARENT, D.MFDUNIT_ID) AND P1.RECENT = 1
LEFT JOIN L2 ON L2.LOT_ID = D.MFDUNIT_ID AND L2.RECENT = 1
LEFT JOIN P2 ON P2.COMPONENT_ID = D.MFDUNIT_ID AND P2.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
'

exec sp_executesql @sql;
GO

/** Microwave */
 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_MICROWAVE  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''M%[_]100'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_MICROWAVE'' )
, L2 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_SIEVE'' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_MICROWAVE', default) + ' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
SELECT D.MFDUNIT_ID as LotId
, D.PARENT as Parent
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, L1.RESOURCE_ID as ReactorId
, L1.RECIPE_ID as RecipeId
, L1.LOAD_DATE as ReactorLoadTime
, L1.LOAD_BY as ReactorLoadBy
, L1.UNL_DATE as ReactorUnloadTime
, L1.UNL_BY as ReactorUnloadBy
, L1.COMMENTS as ReactorComments
, DATEPART(week, L1.UNL_DATE) as ReactorUnloadWeek
, TRY_CAST(P1.CYC as float) as CYC_g
, TRY_CAST(P1.FIL as float) as FIL_g
, TRY_CAST(P1.FilCycRatio as float) as FilCycRatio
, TRY_CAST(P1.Duration as float) as OST_m
, P1.Comments as ReactorYieldComments
, P1.PERFORMED_DATE as ReactorLogTime
, P1.PERFORMED_BY as ReactorLogBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = COALESCE(D.PARENT, D.MFDUNIT_ID) AND L1.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = COALESCE(D.PARENT, D.MFDUNIT_ID) AND P1.RECENT = 1
LEFT JOIN L2 ON L2.LOT_ID = D.MFDUNIT_ID AND L2.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
'

exec sp_executesql @sql;
GO

/** Pelletization */
 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_PLT  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''%[_]PLT'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_PLT'' )
, L2 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_SIEVE'' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_PLT', default) + ' )
, P2 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_SIEVE_SPLIT', default) + ' )
, C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]100'' GROUP BY LOT_ID )
, C2 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]PPF'' GROUP BY LOT_ID )
, C3 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID = ''TOLUENE'' GROUP BY LOT_ID )
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as ReactorLots
, C1.TOTAL_QTY as ReactorLotsQty_g
, C2.CONSUMED_LOTS as PPFLot
, C2.TOTAL_QTY as PPFQty_g
, C3.TOTAL_QTY as Toluene_g
, L1.RESOURCE_ID as PellId
, L1.LOAD_DATE as PellLoadTime
, L1.LOAD_BY as PellLoadBy
, L1.UNL_DATE as PellUnloadTime
, L1.UNL_BY as PellUnloadBy
, L1.COMMENTS as PellComments
, try_cast(P1.PreWt as float) as PrePellQty_g
, try_cast(P1.PostWt as float) as PostPellQty_g
, try_cast(P1.Yield as float) as PellYield_pct
, try_cast(P1.Duration as float) as Duration_m
, P1.Comments as PellYieldComments
, P1.PERFORMED_DATE as PellLogTime
, P1.PERFORMED_BY as PellLogBy
, TRY_CAST(P2.PreWt as float) as PreSieveQty_g
, TRY_CAST(P2.PostWt as float) as PostSieveQty_g
, TRY_CAST(P2.Yield as float) as SieveYield_pct
, TRY_CAST(P2.ByproductQty as float) as ByproductQty_g
, P2.PERFORMED_DATE SieveLogTime
, P2.PERFORMED_BY SieveLogBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = D.MFDUNIT_ID AND P1.RECENT = 1
LEFT JOIN L2 ON L2.LOT_ID = D.MFDUNIT_ID AND L2.RECENT = 1
LEFT JOIN P2 ON P2.COMPONENT_ID = D.MFDUNIT_ID AND P2.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
LEFT JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
LEFT JOIN C2 ON C2.LOT_ID = D.MFDUNIT_ID
LEFT JOIN C3 ON C3.LOT_ID = D.MFDUNIT_ID
'

exec sp_executesql @sql;
GO

/** CO2 */

 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_CO2  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''%[_]CO2'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_RTF'')
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_RTF', default) + ' )
, C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]PLT'' GROUP BY LOT_ID )
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as PellLots
, C1.TOTAL_QTY as PellLotsQty_g
, L1.RESOURCE_ID as FurnaceId
, L1.LOAD_DATE as FurnaceLoadTime
, L1.LOAD_BY as FurnaceLoadBy
, L1.UNL_DATE as FurnaceUnloadTime
, L1.UNL_BY as FurnaceUnloadBy
, L1.COMMENTS as FurnaceComments
, TRY_CAST(P1.SoakTime as float) as SoakTime
, TRY_CAST(P1.PreWt as float) as PreFurnaceQty_g
, TRY_CAST(P1.PostWt as float) as PostFurnaceQty_g
, TRY_CAST(P1.Yield as float) as FurnaceYield_pct
, 100 - TRY_CAST(P1.Yield as float) as FurnaceWeightLoss_pct
, P1.Comments as FurnaceYieldComments
, P1.PERFORMED_DATE as FurnaceLogTime
, P1.PERFORMED_BY FurnaceLogBy
, L1R.RESOURCE_ID as Rwk_FurnaceId
, L1R.LOAD_DATE as Rwk_FurnaceLoadTime
, L1R.LOAD_BY as Rwk_FurnaceLoadBy
, L1R.UNL_DATE as Rwk_FurnaceUnloadTime
, L1R.UNL_BY as Rwk_FurnaceUnloadBy
, L1R.COMMENTS as Rwk_FurnaceComments
, TRY_CAST(P1R.SoakTime as float) as Rwk_SoakTime
, TRY_CAST(P1R.PreWt as float) as Rwk_PreFurnaceQty_g
, TRY_CAST(P1R.PostWt as float) as Rwk_PostFurnaceQty_g
, TRY_CAST(P1R.Yield as float) as Rwk_FurnaceYield_pct
, P1R.Comments as Rwk_FurnaceYieldComments
, P1R.PERFORMED_DATE as Rwk_FurnaceLogTime
, P1R.PERFORMED_BY Rwk_FurnaceLogBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT2 = 1 AND L1.LOAD_POSITION NOT LIKE ''%RWK%''
LEFT JOIN L1 AS L1R ON L1R.LOT_ID = D.MFDUNIT_ID AND L1R.RECENT2 = 1 AND L1R.LOAD_POSITION LIKE ''%RWK%''
LEFT JOIN P1 ON P1.COMPONENT_ID = D.MFDUNIT_ID AND P1.RECENT2 = 1 AND P1.CURRENT_POSITION NOT LIKE ''%RWK%''
LEFT JOIN P1 AS P1R ON P1R.COMPONENT_ID = D.MFDUNIT_ID AND P1R.RECENT2 = 1 AND P1R.CURRENT_POSITION LIKE ''%RWK%''
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
LEFT JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
'

exec sp_executesql @sql;
GO


/** Spray Dry */

 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_SPD  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''%[_]SPD'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_SPD'' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_PT_HIGH_SHEAR', default) + ' )
, P2 AS ( ' + rpt.sqlPivotDCv2('QC_HIGH_SHEAR_VISCOSITY', default) + ' )
, P3 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_SPD', default) + ' )
, P4 AS ( ' + rpt.sqlPivotDCv2('CONS_WATER1', default) + ' )
, P5 AS ( ' + rpt.sqlPivotDCv2('LOG_MOISTURE_CONTENT', default) + ')
, C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]CO2'' OR CONS_PRODUCT_ID LIKE ''%[_]RAW'' GROUP BY LOT_ID )
, C2 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID IN (''PEI'', ''PAN'') GROUP BY LOT_ID )
, C3 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID IN (''DMF'') GROUP BY LOT_ID )
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as CO2Lots
, C1.TOTAL_QTY as CO2LotsQty_g
, C2.CONSUMED_LOTS as Binder
, C2.TOTAL_QTY as BinderQty_g
, COALESCE(C3.CONSUMED_LOTS, P4.Part) as Solvent
, COALESCE(TRY_CAST(P4.Qty as float), C3.TOTAL_QTY) as SolventQty_g
, L1.RESOURCE_ID as SprDryId
, L1.LOAD_DATE as SprDryLoadTime
, L1.LOAD_BY as SprDryLoadBy
, L1.UNL_DATE as SprDryUnloadTime
, L1.UNL_BY as SprDryUnloadBy
, L1.COMMENTS as SprDryComments
, TRY_CAST(COALESCE(P1.Viscosity, P2.Viscosity) as float) as Viscosity
, TRY_CAST(P3.Clogs as float) as Clogs
, TRY_CAST(P3.PreWtC as float) as PreSprDryQty_g
, TRY_CAST(P3.PostWt as float) as PostSprDryQty_g
, TRY_CAST(P3.Yield as float) as SprDryYield_pct
, TRY_CAST(P3.Duration as float) as SprDryDuration_m
, P1.Comments as SprDryYieldComments
, P5.MOISTURECONTENT as MC
, P2.PERFORMED_DATE SieveLogTime
, P2.PERFORMED_BY SieveLogBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = D.MFDUNIT_ID AND P1.RECENT = 1
LEFT JOIN P2 ON P2.COMPONENT_ID = D.MFDUNIT_ID AND P2.RECENT = 1
LEFT JOIN P3 ON P3.COMPONENT_ID = D.MFDUNIT_ID AND P3.RECENT = 1
LEFT JOIN P4 ON P4.COMPONENT_ID = D.MFDUNIT_ID AND P4.RECENT = 1
LEFT JOIN P5 ON P5.COMPONENT_ID = D.MFDUNIT_ID AND P5.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
LEFT JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
LEFT JOIN C2 ON C2.LOT_ID = D.MFDUNIT_ID
LEFT JOIN C3 ON C3.LOT_ID = D.MFDUNIT_ID
'
exec sp_executesql @sql;
GO

/** Carb Oven */

 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_CARB  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''%[_]CARB'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2
   FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_OVEN'' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_PT_CARB_START', default) + ' )
, P2 AS ( ' + rpt.sqlPivotDCv2('QC_TAP_DENSITY', default) + ' )
, P3 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_OVEN', default) + ' )
, C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]SPD'' GROUP BY LOT_ID )
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as SPDLots
, C1.TOTAL_QTY as SPDLotsQty_g
, L1.RESOURCE_ID as CarbOvenId
, L1.LOAD_DATE as CarbOvenLoadTime
, L1.LOAD_BY as CarbOvenLoadBy
, P1.StartTime as CarbOvenStartTime
, P1.PERFORMED_BY as CarbOvenStartBy
, L1.UNL_DATE as CarbOvenUnloadTime
, L1.UNL_BY as CarbOvenUnloadBy
, L1.COMMENTS as CarbOvenComments
, CAST(P2.TapDensity as float) as TapDensity
, P2.Comments as TapDensityComments
, P2.PERFORMED_DATE as TapDensityTime
, P2.PERFORMED_BY as TapDensityBy
, TRY_CAST(P3.PreWtC as float) as PreOvenQty_g
, TRY_CAST(P3.PostWt as float) as PostOvenQty_g
, TRY_CAST(P3.Yield as float) as OvenYield_pct
, P3.PERFORMED_DATE AS OvenYieldLogTime
, P3.PERFORMED_BY AS OvenYieldLogBy
, P3.Comments as OvenYieldComments
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = D.MFDUNIT_ID AND P1.RECENT = 1
LEFT JOIN P2 ON P2.COMPONENT_ID = D.MFDUNIT_ID AND P2.RECENT = 1
LEFT JOIN P3 ON P3.COMPONENT_ID = D.MFDUNIT_ID AND P3.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
LEFT JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
'

exec sp_executesql @sql;
GO

/** CSC */

 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_CSC  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, RELEASE_DATE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID LIKE ''%[_]CSC'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, L1 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2 
  FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_BLENDER'' )
, L2 AS ( SELECT LOT_ID, RESOURCE_ID, RECIPE_ID, LOAD_OPERATION, UNL_OPERATION, LOAD_BY, LOAD_DATE, LOAD_POSITION, UNL_DATE, UNL_BY, COMMENTS, UNL_POSITION, RECENT, RECENT2 
  FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''LOAD_OVEN'' )
, P0 AS ( ' + rpt.sqlPivotDCv2('TRANSFER', default) + ' )
, P1 AS ( ' + rpt.sqlPivotDCv2('LOG_THERMOCOUPLE', default) + ' )
, P2 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_MLT', default) + ' )
, P3 AS ( ' + rpt.sqlPivotDCv2('LOG_YIELD_SIEVE', default) + ' )
, P4 AS ( ' + rpt.sqlPivotDCv2('QC_TAP_DENSITY', default) + ' )
, C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID LIKE ''%[_]CARB'' GROUP BY LOT_ID )
, C2 AS (
	SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID = ''SULFUR'' GROUP BY LOT_ID
)
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as CarbLots
, C1.TOTAL_QTY as CarbLotsQty_g
, C2.CONSUMED_LOTS as Sulfur
, C2.TOTAL_QTY as SulfurQty_g
, L1.RESOURCE_ID as BlenderId
, L1.LOAD_DATE as BlenderLoadTime
, L1.LOAD_BY as BlenderLoadBy
, L1.UNL_DATE as BlenderUnloadTime
, L1.UNL_BY as BlenderUnloadBy
, L1.COMMENTS as BlenderComments
, L2.RESOURCE_ID as MeltOvenId
, L2.LOAD_DATE as MeltOvenLoadTime
, L2.LOAD_BY as MeltOvenLoadBy
, P1.Time as TCTime
, TRY_CAST(P1.Temperature as float) as TCTemperature_C
, P1.Comments as TCComments
, P1.PERFORMED_BY as TCLogBy
, L2.UNL_DATE as MeltOvenUnloadTime
, L2.UNL_BY as MeltOvenUnloadBy
, L2.COMMENTS as MeltOvenComments
, TRY_CAST(P2.PreWt as float) as PreOvenQty_g
, TRY_CAST(P2.PostWt as float) as PostOvenQty_g
, TRY_CAST(P2.Yield as float) as OvenYield_pct
, P2.PERFORMED_DATE AS OvenYieldLogTime
, P2.PERFORMED_BY AS OvenYieldLogBy
, P2.Comments as OvenYieldComments
, TRY_CAST(P3.PreWt as float) as PreSieveQty_g
, TRY_CAST(P3.PostWt as float) as PostSieveQty_g
, TRY_CAST(P3.Yield as float) as SieveYield_pct
, P3.Comments as SieveComments
, P3.PERFORMED_DATE AS SieveYieldLogTime
, P3.PERFORMED_BY AS SieveYieldLogBy
, TRY_CAST(P4.TapDensity as float) as TapDensity
, P4.Comments as TapDensityComments
, P4.PERFORMED_DATE as TapDensityTime
, P4.PERFORMED_BY as TapDensityBy
, TRY_CAST(P0.Quantity as float) as TransferQty_g
, P0.Shelf as Shelf
, P0.PERFORMED_DATE as TransferTime
, DATEPART(week, P0.PERFORMED_DATE) as TransferWeek
, P0.PERFORMED_BY as TransferBy
FROM D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT = 1
LEFT JOIN L2 ON L2.LOT_ID = D.MFDUNIT_ID AND L2.RECENT = 1
LEFT JOIN P1 ON P1.COMPONENT_ID = D.MFDUNIT_ID AND P1.RECENT = 1
LEFT JOIN P2 ON P2.COMPONENT_ID = D.MFDUNIT_ID AND P2.RECENT = 1
LEFT JOIN P3 ON P3.COMPONENT_ID = D.MFDUNIT_ID AND P3.RECENT = 1
LEFT JOIN P4 ON P4.COMPONENT_ID = D.MFDUNIT_ID AND P3.RECENT = 1
LEFT JOIN P0 ON P0.COMPONENT_ID = D.MFDUNIT_ID AND P0.RECENT = 1
LEFT JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
LEFT JOIN C2 ON C2.LOT_ID = D.MFDUNIT_ID
'

exec sp_executesql @sql;
GO

 DECLARE @sql nvarchar(max)= 'CREATE OR ALTER VIEW rpt.VIEW_PROC_SHIP_CSC  AS 
WITH D AS ( SELECT MFDUNIT_ID, PRODUCT_ID, PARENT, WIP_TYPE, STATE, NEXT_OPERATION 
  FROM dbo.E_CS_MFDUNIT_DETAILS WHERE PRODUCT_ID = ''600-00061'' AND STATE <> ''TERMINATED'' AND WIP_TYPE <> ''TEST'')
, O1 AS (
	SELECT [OBJECT_ID], [OPERATION_ID], [SEQ_ID], [PERFORMED_BY], [PERFORMED_DATE]
		, RANK() OVER(PARTITION BY [OBJECT_ID], [OPERATION_ID] ORDER BY PERFORMED_DATE) as RNK
	FROM [dbo].[E_CS_OPERATION_EXECUTION]
	WHERE OPERATION_ID = ''FINISH'' AND OBJECT_TYPE = ''MFDUNIT''
)
, C1 AS ( SELECT LOT_ID, CONS_LOT_ID as CONSUMED_LOTS, CONS_PRODUCT_ID, TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE PRODUCT_ID = ''600-00061'' )
SELECT D.MFDUNIT_ID as ShippedLot
, C1.CONSUMED_LOTS as CSCLot
, C1.TOTAL_QTY as CSCQty_g
, C1.CONS_PRODUCT_ID as CSCProductId
, O1.PERFORMED_DATE as FinishDate
, DATEPART(week, O1.PERFORMED_DATE) as FinishWeek
, O1.PERFORMED_BY as FinishBy
FROM D
JOIN C1 ON C1.LOT_ID = D.MFDUNIT_ID
JOIN O1 ON O1.[OBJECT_ID] = D.MFDUNIT_ID AND RNK = 1
WHERE D.STATE = ''FINISHED''
--ORDER BY FinishDate DESC
'
EXEC sp_executesql @sql;
GO

/**
WHERE StartTime BETWEEN :$DATE.BEGIN_TIME AND :$DATE.END_TIME
*/


 DECLARE @sql nvarchar(max)= '
CREATE OR ALTER VIEW rpt.VIEW_METROLOGY_REQUESTS AS 
WITH T AS ( ' + rpt.sqlPivotDCv2('METRO_REQUEST', default) + '
), DC AS (
	SELECT G.*
	, A.recordId
	, RANK() OVER(PARTITION BY DC_ID, LOT_ID ORDER BY PERFORMED_DATE DESC) as RNK
	FROM (
		SELECT S.DATA_COLLECTED_ID,
			O.OPERATION_ID as DC_ID,
			[COMPONENT_ID] as LOT_ID,
			O.PERFORMED_DATE,
			CASE WHEN COUNT(CASE WHEN [IN_SPECS] = ''F'' THEN 1 ELSE NULL END) > 0 THEN ''F'' ELSE ''T'' END AS IN_SPEC
		FROM [EyelitDB].[dbo].[E_CS_SAMPLES_DETAILS] S
		JOIN dbo.E_CS_OPERATION_EXECUTION O ON O.SEQ_ID = S.DATA_COLLECTED_ID AND OPERATION_ID LIKE ''MET[_]%''
		GROUP BY O.OPERATION_ID, S.DATA_COLLECTED_ID, [COMPONENT_ID], O.PERFORMED_DATE
	) as G
	LEFT JOIN (
		SELECT DATA_COLLECTED_ID, VAL as recordId 
		FROM E_CS_SAMPLES_DETAILS 
		where DCE_ID IN (''RecID'', ''recordId'') AND VAL is not NULL
	) AS A ON A.DATA_COLLECTED_ID = G.DATA_COLLECTED_ID
)
SELECT R.LotId
, D.PRODUCT_ID as ProductId 
, R.RequestedTest
, R.Required
, R.SubmitBy
, R.SubmitTime
, DATEPART(week, R.SubmitTime) as WorkWeek
, DC.PERFORMED_DATE as CompletedAt 
, DC.IN_SPEC as InSpec
, DC.recordId as AlchemyMetrologyId
, R.SampleRecordId as AlchemySampleId
, R.RequestProcessId as AlchemyProcessId
FROM (
	SELECT T.COMPONENT_ID as LotId
	, M.value AS RequestedTest
	, CASE WHEN M.value IN (MetroRequired, MetroOptional) THEN ''T'' ELSE ''F'' END AS Required
	, T.PERFORMED_BY as SubmitBy
	, T.PERFORMED_DATE as SubmitTime
	, SampleRecordId
	, RequestProcessId
	FROM T
	CROSS APPLY STRING_SPLIT(CONCAT_WS('','', MetroRequired, MetroOptional), '','') as M
) R
JOIN (
	SELECT * FROM E_CS_MFDUNIT_DETAILS WHERE WIP_TYPE <> ''TEST''
) D ON D.MFDUNIT_ID = R.LotId
LEFT JOIN DC ON D.MFDUNIT_ID = DC.LOT_ID AND DC.DC_ID = R.RequestedTest AND DC.RNK = 1
WHERE RequestedTest <> ''NONE''
--ORDER BY WorkWeek DESC, RequestedTest ASC, D.PRODUCT_ID ASC, SubmitTime DESC
';

exec sp_executesql @sql;
GO


 DECLARE @sql nvarchar(max)= '
CREATE OR ALTER VIEW rpt.VIEW_MIX_C01 AS
WITH CONS AS (
	SELECT *, RANK() OVER(PARTITION BY COMPONENT_ID, Idx ORDER BY PERFORMED_DATE DESC) AS RNK
	FROM ( ' + rpt.sqlPivotDCv2('CONS_FOR_C01', default) + ' ) T
), LOG AS (
	SELECT *, RANK() OVER(PARTITION BY COMPONENT_ID, Idx ORDER BY PERFORMED_DATE DESC) AS RNK
	FROM ( ' + rpt.sqlPivotDCv2('LOG_MIXER', default) + ' ) T
), CONS_R AS (
	SELECT *, RANK() OVER(PARTITION BY COMPONENT_ID, Idx ORDER BY PERFORMED_DATE DESC) AS RNK
	FROM ( ' + rpt.sqlPivotDCv2('RWK_SOLVENT1', default) + ' ) T
), LOG_R AS (
	SELECT *, RANK() OVER(PARTITION BY COMPONENT_ID, Idx ORDER BY PERFORMED_DATE DESC) AS RNK
	FROM ( ' + rpt.sqlPivotDCv2('LOG_REMIXER', default) + ' ) T
)
SELECT C1.COMPONENT_ID as LotId
, TRY_CAST(C1.Idx as integer) MixCount
, TRY_CAST(0 as bit) as Rework
, CASE WHEN TRY_CAST(C1.Solvent1Qty AS float) > 0 THEN LEFT(C1.Solvent1Id, CHARINDEX('' ('', C1.Solvent1Id) - 1) ELSE null END AS Solvent1Id
, TRY_CAST(C1.Solvent1Qty as float) as Solvent1Qty
, CASE WHEN TRY_CAST(C1.Binder1Qty as float) > 0 THEN LEFT(C1.Binder1Id, CHARINDEX('' ('', C1.Binder1Id) - 1) ELSE null END AS Binder1Id
, TRY_CAST(C1.Binder1Qty as float) as Binder1Qty
, CASE WHEN TRY_CAST(C1.Binder2Qty as float) > 0 THEN LEFT(C1.Binder2Id, CHARINDEX('' ('', C1.Binder2Id) - 1) ELSE null END AS Binder2Id
, TRY_CAST(C1.Binder2Qty as float) as Binder2Qty
, CASE WHEN TRY_CAST(C1.Active1Qty as float) > 0 THEN LEFT(C1.Active1Id, CHARINDEX('' ('', C1.Active1Id) - 1) ELSE null END AS Active1Id
, TRY_CAST(C1.Active1Qty as float) as Active1Qty
, C1.PERFORMED_DATE AS ConsumedTime
, TRY_CAST(L1.MixTime AS float) AS MixDuration
, TRY_CAST(L1.Speed1 AS float) AS PlanetaryRPM
, TRY_CAST(L1.Speed2 AS float) AS DisperserRPM
, TRY_CAST(L1.TempC as float) AS ChillerTempC
, TRY_CAST(L1.Vacuum as float) AS VacuumPsi
, TRY_CAST(L1.VacTime as float) AS VacuumDuration
, L1.PERFORMED_DATE AS LoggedTime
FROM (SELECT * FROM CONS WHERE RNK = 1 AND Idx IS NOT NULL) AS C1
LEFT JOIN (SELECT * FROM LOG WHERE RNK = 1 AND Idx IS NOT NULL) AS L1
ON C1.COMPONENT_ID = L1.COMPONENT_ID AND C1.Idx = L1.Idx 
UNION ALL
SELECT C1.COMPONENT_ID as LotId
, TRY_CAST(C1.Idx AS integer) MixCount
, TRY_CAST(1 AS bit) AS Rework
, CASE WHEN TRY_CAST(C1.Solvent1Qty AS float) > 0 THEN LEFT(C1.Solvent1Id, CHARINDEX('' ('', C1.Solvent1Id) - 1) ELSE null END AS Solvent1Id
, TRY_CAST(C1.Solvent1Qty as float) as Solvent1Qty
, null AS Binder1Id
, null as Binder1Qty
, null AS Binder2Id
, null AS Binder2Qty
, null AS Active1Id
, null AS Active1Qty
, C1.PERFORMED_DATE AS ConsumedTime
, TRY_CAST(L1.MixTime AS float) AS MixDuration
, TRY_CAST(L1.Speed1 AS float) AS PlanetaryRPM
, TRY_CAST(L1.Speed2 AS float) AS DisperserRPM
, TRY_CAST(L1.TempC as float) AS ChillerTempC
, TRY_CAST(L1.Vacuum as float) AS VacuumPsi
, TRY_CAST(L1.VacTime as float) AS VacuumDuration
, L1.PERFORMED_DATE AS LoggedTime
FROM (SELECT * FROM CONS_R WHERE RNK = 1 AND Idx IS NOT NULL) AS C1
LEFT JOIN (SELECT * FROM LOG_R WHERE RNK = 1 AND Idx IS NOT NULL) AS L1
ON C1.COMPONENT_ID = L1.COMPONENT_ID AND C1.Idx = L1.Idx 
';

EXEC sp_executesql @sql;
GO

/** Load/Unload history */
GO

CREATE OR ALTER VIEW [rpt].[VIEW_LOAD_HISTORY] AS 
SELECT O.LOT_ID
	 ,T.[RESOURCE_ID]
	 ,R.RECIPE_ID
	 ,O.LOAD_OPERATION
	 ,O.UNL_OPERATION
	 ,O.LOAD_DATE
	 ,O.LOAD_BY
	 ,O.LOAD_POSITION
	 ,O.LOAD_STEP
	 ,O.UNL_DATE
	 ,O.UNL_BY
   ,T.[COMMENTS]
	 ,O.UNL_POSITION
	 ,O.UNL_STEP
	 ,RANK() OVER(PARTITION BY O.LOT_ID, O.LOAD_OPERATION ORDER BY O.LOAD_DATE DESC) as RECENT
	 ,RANK() OVER(PARTITION BY O.LOT_ID, O.LOAD_OPERATION, O.LOAD_POSITION ORDER BY O.LOAD_DATE DESC) as RECENT2
 FROM [dbo].[E_CS_LOADEQP_EXECUTION] T
 LEFT JOIN [dbo].[E_CS_LOADRECIPE_EXECUTION] R
	ON T.IDENT_SEQ_ID = R.IDENT_SEQ_ID
 LEFT JOIN (
	SELECT O1.OBJECT_ID as LOT_ID
	, O1.OPERATION_ID as LOAD_OPERATION
	, O2.OPERATION_ID as UNL_OPERATION
	, O1.PERFORMED_BY as LOAD_BY
	, O2.PERFORMED_BY as UNL_BY
	, O1.STEP_ID as LOAD_STEP
	, O2.STEP_ID as UNL_STEP
	, O1.CURRENT_POSITION as LOAD_POSITION
	, O2.CURRENT_POSITION as UNL_POSITION
	, O1.PERFORMED_DATE as LOAD_DATE
	, O2.PERFORMED_DATE as UNL_DATE
	, O1.COMMENTS as LOAD_COMMENTS
	, O1.SEQ_ID
	, RANK() OVER(PARTITION BY O1.SEQ_ID ORDER BY O2.PERFORMED_DATE ASC) as RNK
	FROM (
		SELECT O.OBJECT_ID, O.OBJECT_TYPE, O.VERSION, O.OPERATION_ID, O.OPERATION_VERSION, O.SEQ_ID, O.PERFORMED_BY, O.PERFORMED_DATE, O.CURRENT_POSITION, O.COMMENTS 
		, dbo.GetStringToken(CURRENT_POSITION, char(10), 3) as STEP_ID
		FROM [dbo].[E_CS_OPERATION_EXECUTION] O
		JOIN [dbo].E_CS_LOADEQP_EXECUTION L ON L.SEQ_ID = O.SEQ_ID
	) as O1 
	LEFT JOIN (
		SELECT O.OBJECT_ID, O.OBJECT_TYPE, O.VERSION, O.OPERATION_ID, O.OPERATION_VERSION, O.SEQ_ID, O.PERFORMED_BY, O.PERFORMED_DATE, O.CURRENT_POSITION, O.COMMENTS 
		, dbo.GetStringToken(CURRENT_POSITION, char(10), 3) as STEP_ID
		FROM [dbo].[E_CS_OPERATION_EXECUTION] O
		JOIN (
			SELECT SEQ_ID FROM dbo.E_CS_ACTION_HISTORY WHERE ACTION_TYPE = 'com.eyelit.view.ResourceReleaseView'
		) A ON A.SEQ_ID = O.SEQ_ID
	) as O2
	ON O1.OBJECT_ID = O2.OBJECT_ID AND O1.PERFORMED_DATE < O2.PERFORMED_DATE
	AND O1.STEP_ID = O2.STEP_ID
 ) as O ON O.SEQ_ID = T.SEQ_ID AND RNK = 1
 WHERE LOT_ID is not null;

GO

/** mixer */


 DECLARE @sql nvarchar(max)= '
CREATE OR ALTER VIEW rpt.VIEW_PROC_MIX_C01 AS
WITH P1 AS ( ' + rpt.sqlPivotDCv2('WI_MIX_C01', default) + ' 
), L1 AS (
	SELECT * FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''SELECT_MIXER'' 
), L2 AS ( 
	SELECT * FROM rpt.VIEW_LOAD_HISTORY WHERE LOAD_OPERATION = ''SELECT_REMIXER'' 
), QC AS ( ' + rpt.sqlPivotDCv2('QC_SLURRY', default) + '
), C1 AS ( SELECT LOT_ID, STRING_AGG(CONS_LOT_ID, '','') as CONSUMED_LOTS, SUM(TOTAL_QTY) as TOTAL_QTY 
	FROM rpt.VIEW_LOT_CONSUMPTION WHERE CONS_PRODUCT_ID = ''600-00061'' GROUP BY LOT_ID 
) 
SELECT D.MFDUNIT_ID as LotId
, D.PRODUCT_ID as ProductId
, D.WIP_TYPE as LotType
, D.RELEASE_DATE as StartTime
, DATEPART(week, D.RELEASE_DATE) as StartWeek
, D.STATE as State
, D.NEXT_OPERATION as Operation
, C1.CONSUMED_LOTS as CSCLots
, C1.TOTAL_QTY as CSCQty_g
, L1.RESOURCE_ID as MixerId
, L2.RESOURCE_ID as RemixerId
, QC1.Viscosity001 as ViscosityAt1
, QC1.Viscosity010 as ViscosityAt10
, QC1.Viscosity100 as ViscosityAt100
, QC1.Solids as Solids
, QC1.Hegman as Hegman
FROM (
	SELECT * FROM dbo.E_CS_MFDUNIT_DETAILS D
	WHERE WIP_TYPE <> ''TEST'' AND PRODUCT_ID = ''600-00110''
) as D
LEFT JOIN L1 ON L1.LOT_ID = D.MFDUNIT_ID AND L1.RECENT = 1
LEFT JOIN L2 ON L2.LOT_ID = D.MFDUNIT_ID AND L2.RECENT = 1
LEFT JOIN P1 ON D.MFDUNIT_ID = P1.COMPONENT_ID AND P1.RECENT = 1
LEFT JOIN C1 ON D.MFDUNIT_ID = C1.LOT_ID
LEFT JOIN QC as QC1 ON D.MFDUNIT_ID = QC1.COMPONENT_ID AND QC1.RECENT = 1
';

exec sp_executesql @sql;
GO

