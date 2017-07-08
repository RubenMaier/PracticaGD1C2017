SELECT prod_codigo 'Código Producto', prod_detalle 'Detalle Producto', COUNT(ISNULL(comp_producto, 0)) 'Componentes'
FROM Producto LEFT JOIN Composicion ON prod_codigo = comp_producto
			  JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING AVG(stoc_cantidad) > 100