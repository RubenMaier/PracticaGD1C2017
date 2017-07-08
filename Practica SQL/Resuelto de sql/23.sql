SELECT  YEAR(F.fact_fecha) 'Año',
		I.item_producto 'Producto mas vendido',
		(SELECT COUNT(*) FROM Composicion WHERE comp_producto = I.item_producto) 'Cant. Componentes',
		COUNT(DISTINCT F.fact_tipo + F.fact_sucursal + F.fact_numero) 'Facturas',
		(SELECT TOP 1 fact_cliente
		FROM Factura JOIN Item_Factura
			ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
		WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha) AND item_producto = I.item_producto
		GROUP BY fact_cliente
		ORDER BY SUM(item_cantidad) DESC) 'Cliente mas Compras',
		SUM(ISNULL(I.item_cantidad, 0)) /
			(SELECT SUM(item_cantidad)
			FROM Factura JOIN Item_Factura
				ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
			WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha))*100 'Porcentaje'
FROM Factura F JOIN Item_Factura I
    ON (F.fact_tipo + F.fact_sucursal + F.fact_numero = I.item_tipo + I.item_sucursal + I.item_numero)
WHERE  I.item_producto = (SELECT TOP 1 item_producto
							   FROM Item_Factura
							   JOIN Composicion
							     ON item_producto = comp_producto
							   JOIN Factura
							     ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
							 WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha)
							 GROUP BY item_producto
							 ORDER BY SUM(item_cantidad) DESC)
GROUP BY YEAR(F.fact_fecha), I.item_producto
ORDER BY SUM(I.item_cantidad) DESC