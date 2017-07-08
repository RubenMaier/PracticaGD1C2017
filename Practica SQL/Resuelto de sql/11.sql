SELECT  fami_detalle 'Familia',
		COUNT(DISTINCT prod_codigo) 'Cantidad de Productos',
		SUM(item_precio * item_cantidad) 'Ventas sin Impuestos'
FROM Familia
	 JOIN Producto
		ON fami_id = prod_familia
	 JOIN Item_Factura
		ON prod_codigo = item_producto
	 JOIN Factura
		ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
GROUP BY fami_id, fami_detalle
HAVING EXISTS (SELECT 1 --fact_numero, fact_tipo, fact_sucursal
				FROM Factura
					JOIN Item_Factura
						ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
					JOIN Producto
						ON item_producto = prod_codigo
				WHERE YEAR(fact_fecha) = 2012 AND prod_familia = fami_id
			  --GROUP BY fact_numero, fact_tipo, fact_sucursal
				HAVING SUM(item_precio * item_cantidad) > 20000)
ORDER BY 2 DESC