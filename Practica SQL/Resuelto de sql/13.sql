SELECT  Principal.prod_detalle 'Producto',
		Principal.prod_precio 'Precio',
		SUM(Componente.prod_precio*comp_cantidad) 'Suma Precios Componentes'
FROM Producto Principal
	JOIN Composicion
		ON Principal.prod_codigo = comp_producto
	JOIN Producto Componente
		ON Componente.prod_codigo = comp_componente
GROUP BY Principal.prod_codigo, Principal.prod_detalle, Principal.prod_precio
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC