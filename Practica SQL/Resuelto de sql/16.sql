SELECT  clie_razon_social 'Razón Social',
		clie_domicilio 'Domicilio',	
		SUM(item_cantidad) 'Unidades totales compradas',
		(SELECT TOP 1 item_producto
		FROM Item_Factura JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
		WHERE YEAR (fact_fecha) = 2012 AND fact_cliente = clie_codigo
		GROUP BY item_producto
		ORDER BY SUM(item_cantidad) DESC, item_producto ASC) 'Producto mas comprado'
FROM Cliente JOIN Factura ON clie_codigo = fact_cliente
			 JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY clie_codigo, clie_razon_social, clie_domicilio
HAVING SUM(item_cantidad) < 1.00/3*(SELECT TOP 1 SUM(item_cantidad)
									FROM Item_Factura
										JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
									WHERE YEAR(fact_fecha) = 2012
									GROUP BY item_producto
									ORDER BY SUM(item_cantidad) DESC)
ORDER BY clie_domicilio ASC