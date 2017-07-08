SELECT prod_codigo, prod_detalle
FROM Producto, Factura, Item_Factura
WHERE prod_codigo = item_producto AND
	  fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero AND
	  YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad)