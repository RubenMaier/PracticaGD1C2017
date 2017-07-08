SELECT STR(YEAR(fact_fecha))+STR(MONTH(fact_fecha)) 'Periodo',
		prod_codigo 'Código Producto',
		prod_detalle 'Detalle Producto',
		SUM(ISNULL(item_cantidad, 0)) 'Cantidad Vendida',
		(SELECT SUM(ISNULL(item_cantidad, 0))
		FROM Factura JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
		WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha)-1 AND
			MONTH(fact_fecha) = MONTH(F.fact_fecha) AND
			item_producto = prod_codigo) 'Ventas año anterior',
		COUNT(*) 'Cant. Facturas'
FROM Factura F JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
			JOIN Producto ON prod_codigo = item_producto
GROUP BY YEAR(fact_fecha), MONTH(fact_fecha), prod_codigo, prod_detalle
ORDER BY 1, 2