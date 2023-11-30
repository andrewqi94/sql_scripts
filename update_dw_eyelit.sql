USE [Eyelit]
GO

/****** Object:  View [dbo].[VIEW_PROC_THERMAL]    Script Date: 8/21/2023 3:42:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[VIEW_PROC_THERMAL] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_THERMAL WITH (NOLOCK)
GO


ALTER VIEW [dbo].[VIEW_PROC_MICROWAVE] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_MICROWAVE WITH (NOLOCK)
GO


ALTER VIEW [dbo].[VIEW_PROC_PLT] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_PLT WITH (NOLOCK)
GO

ALTER VIEW [dbo].[VIEW_PROC_CO2] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_CO2 WITH (NOLOCK)
GO

ALTER VIEW [dbo].[VIEW_PROC_SPD] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_SPD WITH (NOLOCK)
GO

ALTER VIEW [dbo].[VIEW_PROC_CARB] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_CARB WITH (NOLOCK)
GO

ALTER VIEW [dbo].[VIEW_PROC_CSC] AS
SELECT *
  FROM [LYT-BAY-MESDB1].[EyelitDB].[rpt].VIEW_PROC_CSC WITH (NOLOCK)
GO




/** DW PBI */

ALTER   VIEW [pbi].[VIEW_MET_BET] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_BET m with (nolock)
 ON m.SampleID = s._name;
GO

ALTER   VIEW [pbi].[VIEW_MET_COND] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_Conductivity m with (nolock)
 ON m.SampleID = s._name;
GO


ALTER   VIEW [pbi].[VIEW_MET_PSA] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_PSA m with (nolock)
 ON m.SampleID = s._name;
GO


ALTER   VIEW [pbi].[VIEW_MET_RAMAN] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_Raman m with (nolock)
 ON m.SampleID = s._name;
GO


ALTER   VIEW [pbi].[VIEW_MET_TGA] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_TGA m with (nolock)
 ON m.SampleID = s._name;
GO

ALTER   VIEW [pbi].[VIEW_MET_XRF] AS
SELECT e.LOT_ID as LotId, e.PRODUCT_ID as ProductId, m.*
FROM pbi.VIEW_LOT_DETAILS e
LEFT JOIN Alchemy.rpt.mv_Sample s with (nolock) ON s.SampleLot = e.LOT_ID
LEFT JOIN Alchemy.rpt.mv_XRF m with (nolock)
 ON m.SampleID = s._name;
GO



