use GD2015C1
go

/* --- EJERCICIO 3 ---

Realizar una consulta SQL que retorne:
-> a�o
-> cantidad de productos compuestos vendidos en el a�o
-> cantidad de facturas realizadas en el a�o
-> monto total facturado en el a�o
-> monto total facturado en el a�o anterior

Considerar solo aquellos a�os donde la cantidad de unidades vendidas de todos los
articulos sea mayor a 10.

El resultado tiene que mostrar primero los a�os donde la cantidad vendida de todo
los articulos este entre 50 y 100 unidades.

*/

SELECT 
	year(f.fact_fecha) as a�o,

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
	) as facturacion_a�o_anterior


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

/* me falta el order by con la condicion de que me muestre primero aquellos a�os donde la cantidad vendida
de todos los articulos esten entre 50 y 100 */


/* ------- TEORIA ----------

1) Si bien el indice arbol B+ es util durante la inserci�n o eliminaci�n de datos puesto que 
agiliza su busqueda, estos esenarios no son adecuados cuando la tabla es muy grande puesto que
implicaria una reorganizaci�n de todas las estructuras lo que consumir�a tiempo y recursos de procesamiento.

2) Si, lo va a usar. Los �ndices non clustered, son utiles a la hora de satisfacer cl�usulas WHERE sobre los campos del �ndice
que devuelven un conjunto muy peque�o de registros. Si bien en este caso no es peque�a la cantidad de resultados
hay que tener en cuenta que tambien se usan para satisfacer consultas cuyos campos est�n todos incluidos en el �ndice, 
por lo que no ser� necesario acceder a la tabla en este caso puesto que toda la informaci�n est� en el �ndice.