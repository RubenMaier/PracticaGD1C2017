SELECT  rubr_detalle 'Rubro',
		DATEPART(QUARTER, fact_fecha) 'Trimestre',
		COUNT(DISTINCT fact_tipo + fact_sucursal + fact_numero) 'Facturas',
		COUNT(DISTINCT prod_codigo) 'Productos Diferentes'
FROM Rubro JOIN Producto ON rubr_id = prod_rubro
		   JOIN Item_Factura ON item_producto = prod_codigo
		   JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
WHERE prod_codigo NOT IN (SELECT comp_producto FROM Composicion)
GROUP BY rubr_detalle, DATEPART(QUARTER, fact_fecha)
HAVING COUNT(DISTINCT fact_tipo + fact_sucursal + fact_numero) > 100
ORDER BY 1, 3 DESC