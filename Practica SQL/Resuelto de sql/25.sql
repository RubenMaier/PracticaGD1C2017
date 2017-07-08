SELECT YEAR(fact_fecha) 'Año',
		prod_familia 'Cod. Familia',
		(SELECT fami_detalle FROM Familia WHERE fami_id = prod_familia) 'Familia', --EXTRA
		(SELECT COUNT(DISTINCT prod_rubro) FROM Producto WHERE prod_familia = p1.prod_familia) 'Cant. Rubros',
		(SELECT COUNT(*) FROM Composicion WHERE comp_producto =
			(SELECT TOP 1 prod_codigo
			FROM Factura JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
						 JOIN Producto     ON item_producto = prod_codigo
			WHERE YEAR(fact_fecha) = YEAR(f1.fact_fecha) AND prod_familia = p1.prod_familia
			GROUP BY prod_codigo
			ORDER BY SUM(item_cantidad) DESC)) 'Cant. Componentes',
		COUNT(DISTINCT fact_tipo + fact_sucursal + fact_numero) 'Cant. Facturas',
		(SELECT TOP 1 fact_cliente
		FROM Factura
			JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
			JOIN Producto  ON item_producto = prod_codigo
		WHERE YEAR(fact_fecha) = YEAR(f1.fact_fecha) AND prod_familia = p1.prod_familia
		GROUP BY fact_cliente
		ORDER BY SUM(item_cantidad) DESC) 'Cliente mas Compras',
		(SUM(item_cantidad * item_precio) /
		(SELECT SUM(fact_total) FROM Factura WHERE YEAR(fact_fecha) = YEAR(f1.fact_fecha))) * 100 'Porcentaje'
FROM Factura f1 JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
				JOIN Producto p1  ON item_producto = prod_codigo
WHERE prod_familia = (SELECT TOP 1 prod_familia
						FROM Factura JOIN Item_Factura ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
									 JOIN Producto     ON item_producto = prod_codigo
						WHERE YEAR(fact_fecha) = YEAR(f1.fact_fecha)
						GROUP BY prod_familia
						ORDER BY SUM(item_cantidad) DESC)
GROUP BY YEAR(fact_fecha), prod_familia
ORDER BY SUM(item_cantidad)