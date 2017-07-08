SELECT  prod_codigo 'Código Producto',
		prod_detalle 'Detalle Producto',
		SUM(item_cantidad) 'Unidades Facturadas'
FROM Producto JOIN Composicion ON prod_codigo = comp_producto
			  JOIN Item_Factura ON prod_codigo = item_producto
			  JOIN Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
WHERE fact_vendedor IN (SELECT TOP 2 empl_codigo FROM Empleado ORDER BY empl_comision DESC)
GROUP BY prod_codigo, prod_detalle
HAVING COUNT(*) >= 5
ORDER BY 3 DESC