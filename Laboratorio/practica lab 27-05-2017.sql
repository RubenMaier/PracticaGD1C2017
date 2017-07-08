-- EJERCICIO 10

/*

SELECT prod_codigo, prod_detalle, (
	SELECT TOP 1 c.clie_codigo
	FROM Cliente c
		JOIN Factura f
			ON c.clie_codigo = f.fact_cliente -- trae todas las facturas de un cliente
		JOIN Item_Factura itf -- trae todos los items de facturas para un cliente
			ON itf.item_sucursal = f.fact_sucursal
			AND itf.item_tipo = f.fact_tipo
			AND itf.item_numero = f.fact_numero
			AND itf.item_producto = prod_codigo -- para un producto especifico
	GROUP BY c.clie_codigo -- agrupo por clientes el item comprado
	ORDER BY SUM(itf.item_cantidad) DESC -- hago una sumatorio para cada cliente de las veces que compro ese producto
)
FROM Producto
WHERE prod_codigo in (
	SELECT TOP 10 p.prod_codigo
	FROM Item_Factura itf
		JOIN Producto p
			ON p.prod_codigo = itf.item_producto
	GROUP BY p.prod_codigo, p.prod_detalle
	ORDER BY SUM(itf.item_cantidad) DESC
)
OR prod_codigo in (
	SELECT TOP 10 p.prod_codigo
	FROM Item_Factura itf
		JOIN Producto p
			ON p.prod_codigo = itf.item_producto
	GROUP BY p.prod_codigo, p.prod_detalle
	ORDER BY SUM(itf.item_cantidad) ASC
)
ORDER BY 1
*/

-- algo asi lo hizo nico...
/* 
SELECT prod_codigo, prod_detalle, (
	SELECT TOP 1 c.clie_codigo
	FROM Cliente c
		JOIN Factura f
			ON c.clie_codigo = f.fact_cliente
		JOIN Item_Factura 
			ON f.fact_sucursal = item_sucursal 
			AND f.fact_tipo = item_tipo 
			AND f.fact_numero = item_numero
			AND p.prod_codigo = item_producto
	GROUP BY f.fact_cliente
	ORDER BY SUM(item_cantidad) DESC
)
FROM producto p
WHERE prod_codigo IN (
SELECT TOP 10 prod_codigo 
FROM producto
	JOIN item_factura 
		ON prod_codigo = item_producto
GROUP BY prod_codigo
ORDER BY SUM(item_cantidad) DESC
)
OR prod_codigo IN (
	SELECT TOP 10 prod_codigo 
	FROM Producto 
		JOIN Item_Factura 
			ON prod_codigo = item_producto
	GROUP BY prod_codigo 
	ORDER BY SUM(item_cantidad)
) 
ORDER BY 1
*/

-- EJERCICIO 15
/*
SELECT 
	a.prod_codigo, a.prod_detalle, b.prod_codigo, b.prod_detalle, count(*) cantidad_vendida
FROM 
	producto a, item_factura ia, producto b, item_factura ib
WHERE 
	a.prod_codigo = ia.item_producto -- obtengo un elemento a
	AND b.prod_codigo = ib.item_producto -- obtengo un elemento b
	AND ia.item_numero = ib.item_numero -- chequeo que producto a y producto b esten en una misma factura
	AND ia.item_sucursal = ib.item_sucursal -- idem
	AND ia.item_tipo = ib.item_tipo -- idem
	AND a.prod_codigo > b.prod_codigo -- chequeo que el producto a sea distinto del b
GROUP BY
	a.prod_codigo, b.prod_codigo, a.prod_detalle, b.prod_detalle
HAVING
	count(*) >= 500
*/


-- EJERCICIO 16

traigo productos mas vendidos
considero el producto mas vendido como el 100%
en funcion a este maximo genero un promedio de venta para todos los otros productos vendidos

traigo todos los productos que compro cada cliente
para cada cliente hago una sumatoria de sus productos

para cada producto comprado chequeo que la cantidad de productos comprados sean
menores al 33%

considero el cliente con mas compras de un mismo producto como el 100%
en funcion a este maximo genero un promedio de compras por cada producto

clientes y una sumatoria de los productos comprados
promedio de compra del cliente
