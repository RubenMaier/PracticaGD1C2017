SELECT prod_detalle 'Detalle Producto',
		(SELECT TOP 1 fact_cliente
		FROM Factura JOIN Item_Factura
			ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
		WHERE item_producto = prod_codigo
		GROUP BY fact_cliente
		ORDER BY SUM(item_cantidad) DESC) 'Código Cliente'
FROM Producto
WHERE prod_codigo IN (SELECT TOP 10 item_producto
					  FROM Item_Factura
					  GROUP BY item_producto
					  ORDER BY SUM(item_cantidad) DESC)
	OR
	prod_codigo IN (SELECT TOP 10 item_producto
					FROM Item_Factura
					GROUP BY item_producto
					ORDER BY SUM(item_cantidad) ASC)