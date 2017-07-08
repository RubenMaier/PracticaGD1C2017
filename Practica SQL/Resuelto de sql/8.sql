SELECT prod_detalle 'Detalle',
		MAX(ISNULL(stoc_cantidad, 0)) 'Maximo Stock'
FROM Producto
	JOIN STOCK ON prod_codigo = stoc_producto
WHERE stoc_cantidad > 0
GROUP BY prod_codigo, prod_detalle
HAVING COUNT(stoc_producto) = (SELECT COUNT(*) FROM Deposito)