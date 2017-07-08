SELECT  prod_detalle 'Producto',
		COUNT(DISTINCT fact_cliente) 'Cantidad Compradores',
		SUM(item_precio*item_cantidad) / SUM(item_cantidad) 'Precio Promedio',
		(SELECT COUNT(stoc_deposito)
			FROM STOCK WHERE stoc_producto = prod_codigo
			AND stoc_cantidad > 0) 'Depositos con Stock',
		(SELECT SUM(ISNULL(stoc_cantidad, 0)) FROM STOCK
			WHERE stoc_producto = prod_codigo) 'Stock Total'
FROM Producto
	JOIN Item_Factura
		ON item_producto = prod_codigo
	JOIN Factura
		ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad*item_precio) DESC