SELECT  rubr_detalle 'Rubro',
		SUM(item_cantidad*item_precio) 'Total Ventas',
		(SELECT TOP 1 prod_codigo 
		 FROM Producto JOIN Item_Factura
			ON prod_codigo = item_producto
		 WHERE prod_rubro = rubr_id
		 GROUP BY prod_codigo
		 ORDER BY SUM(item_cantidad) DESC) 'Producto mas Vendido',
		ISNULL((SELECT TOP 1 prod_codigo 
				 FROM Producto JOIN Item_Factura
					ON prod_codigo = item_producto
				 WHERE prod_rubro = rubr_id AND prod_codigo != (SELECT TOP 1 prod_codigo 
																FROM Producto JOIN Item_Factura
																		ON prod_codigo = item_producto
																WHERE prod_rubro = rubr_id
																GROUP BY prod_codigo
																ORDER BY SUM(item_cantidad) DESC)
				GROUP BY prod_codigo
				ORDER BY SUM(item_cantidad) DESC) , 0) 'Segundo Producto mas Vendido',
		ISNULL((SELECT TOP 1 fact_cliente
				 FROM Producto
						JOIN Item_Factura ON item_producto = prod_codigo
						JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
				WHERE prod_rubro = rubr_id AND fact_fecha > DATEADD(DAY,-30, (SELECT MAX(fact_fecha) FROM Factura))
				GROUP BY fact_cliente
				ORDER BY SUM(item_cantidad) DESC),'-') 'Cliente'
FROM Rubro
	 JOIN Producto ON rubr_id = prod_rubro
	 JOIN Item_Factura ON prod_codigo = item_producto
GROUP BY rubr_id, rubr_detalle
ORDER BY COUNT(DISTINCT prod_codigo)