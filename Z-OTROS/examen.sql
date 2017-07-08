use GD2015C1
go

/* --- EJERCICIO 3 ---

Realizar una consulta SQL que retorne:
-> año
-> cantidad de productos compuestos vendidos en el año
-> cantidad de facturas realizadas en el año
-> monto total facturado en el año
-> monto total facturado en el año anterior

Considerar solo aquellos años donde la cantidad de unidades vendidas de todos los
articulos sea mayor a 10.

El resultado tiene que mostrar primero los años donde la cantidad vendida de todo
los articulos este entre 50 y 100 unidades.

*/

SELECT 
	year(f.fact_fecha) as año,

	(SELECT SUM(item_Cantidad)
		FROM Factura f2
			JOIN Item_Factura
				ON fact_tipo = item_tipo
				AND fact_sucursal = item_sucursal
				AND fact_numero = item_numero
			JOIN Producto p
				ON item_producto = prod_codigo
			JOIN Composicion
				ON prod_codigo = comp_producto
		WHERE year(f2.fact_fecha) = year(f.fact_fecha)
	) as cantidad_productos_compuestos_vendidos,

	(SELECT COUNT(*)
		FROM Factura f3
		WHERE year(f3.fact_fecha) = year(f.fact_fecha)
	) as cantidad_facturas_realizadas,

	(SELECT SUM(f4.fact_total)
		FROM Factura f4
		WHERE year(f4.fact_fecha) = year(f.fact_fecha)
		GROUP BY year(f4.fact_fecha)
	) as facturacion,

	(SELECT SUM(f5.fact_total)
		FROM Factura f5
		WHERE year(f5.fact_fecha) = year(f.fact_fecha)-1
		GROUP BY year(f5.fact_fecha)
	) as facturacion_año_anterior


FROM Factura f
	JOIN Item_Factura
		ON fact_tipo = item_tipo
		AND fact_sucursal = item_sucursal
		AND fact_numero = item_numero
	JOIN Producto p
		ON item_producto = prod_codigo


GROUP BY year(f.fact_fecha)

HAVING 
		(SELECT SUM(item_Cantidad)
			FROM Factura f6
				JOIN Item_Factura
					ON fact_tipo = item_tipo
					AND fact_sucursal = item_sucursal
					AND fact_numero = item_numero
				JOIN Producto p
					ON item_producto = prod_codigo
			WHERE year(f6.fact_fecha) = year(f.fact_fecha)
		) > 10

/* me falta el order by con la condicion de que me muestre primero aquellos años donde la cantidad vendida
de todos los articulos esten entre 50 y 100 */


/* ------- TEORIA ----------

1) Si bien el indice arbol B+ es util durante la inserción o eliminación de datos puesto que 
agiliza su busqueda, estos esenarios no son adecuados cuando la tabla es muy grande puesto que
implicaria una reorganización de todas las estructuras lo que consumiría tiempo y recursos de procesamiento.

2) Si, lo va a usar. Los índices non clustered, son utiles a la hora de satisfacer cláusulas WHERE sobre los campos del índice
que devuelven un conjunto muy pequeño de registros. Si bien en este caso no es pequeña la cantidad de resultados
hay que tener en cuenta que tambien se usan para satisfacer consultas cuyos campos están todos incluidos en el índice, 
por lo que no será necesario acceder a la tabla en este caso puesto que toda la información está en el índice.