SELECT prod_detalle 'Detalle',
		MAX(ISNULL(stoc_cantidad, 0)) 'Maximo Stock'
FROM Producto
	JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING
	(SELECT COUNT(*)
	FROM STOCK
	WHERE stoc_cantidad > 0 AND stoc_producto = prod_codigo)
	= (SELECT COUNT(*) FROM Deposito)