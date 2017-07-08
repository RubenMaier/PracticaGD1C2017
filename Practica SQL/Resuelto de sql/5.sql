SELECT prod_codigo 'Código', prod_detalle 'Detalle Producto', SUM(ISNULL(item_cantidad, 0)) 'Egresos'
FROM Producto
	JOIN Item_Factura ON prod_codigo = item_producto
	JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
HAVING SUM(ISNULL(item_cantidad, 0)) >
	(SELECT SUM(ISNULL(item_cantidad, 0))
	FROM Item_Factura
		JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
	WHERE YEAR(fact_fecha) = 2011 AND item_producto = prod_codigo)