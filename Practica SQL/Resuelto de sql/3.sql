SELECT prod_codigo 'Código', prod_detalle 'Detalle Producto', SUM(ISNULL(stoc_cantidad,0)) 'Stock'
FROM Producto JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle