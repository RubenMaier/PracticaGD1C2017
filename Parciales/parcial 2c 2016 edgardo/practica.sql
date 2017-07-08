 -- Ejercicio 3 --
 /*
 Se requiere hacer un analisis profundo respecto a las ventas del año 2015, para lo cual el area de
 Marketing ha solicitado un reporte de cierta información para la toma de decisiones. Dicho reporte
 debera incluir para los 3 productos mas venidos y 3 productos menos vendidos el nombre del producto,
 idicar si es simple/compuesto (segun si el producto ocnsiste en una composicion) y una leyenda que
 indique "producto exitoso", si corresponde a los 3 mas vendidos o "producto a evaluar", si
 corresponde a los 3 menos vendidos. Mostrar solo aquellos productos que hayan tenido mas de 5 ventas
 en el año 2010
 Nota: no se permite el uso de sub-select en el FROM para este punto.
 */
USE [GD2015C1]
GO

SELECT p.prod_codigo, p.prod_detalle as 'nombre', 
	CASE WHEN EXISTS(SELECT 1 FROM Composicion c WHERE c.comp_producto = p.prod_codigo) 
		THEN 'Compuesto'
		 ELSE 'Simple' 
	END AS 'Composicion',
	'Producto exitoso' AS 'Leyenda'
	FROM Producto p
	WHERE p.prod_codigo IN(SELECT TOP 3 i2.item_producto
								FROM Item_Factura i2
								INNER JOIN Factura f2 ON i2.item_numero = f2.fact_numero AND
													 i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
								WHERE YEAR(f2.fact_fecha) = 2015
								GROUP BY i2.item_producto
								HAVING (SELECT ISNULL(SUM(i3.item_cantidad),0) FROM Item_Factura i3
											INNER JOIN Factura f3 ON f3.fact_numero = i3.item_numero AND f3.fact_tipo = i3.item_tipo
																	 AND f3.fact_sucursal = i3.item_sucursal
											WHERE i3.item_producto = i2.item_producto AND YEAR(f3.fact_fecha) = 2010) > 5
								ORDER BY SUM(f2.fact_total) DESC)
	GROUP BY p.prod_codigo, p.prod_detalle
UNION ALL
SELECT p.prod_codigo, p.prod_detalle as 'nombre', 
	CASE WHEN EXISTS(SELECT 1 FROM Composicion c WHERE c.comp_producto = p.prod_codigo) 
		THEN 'Compuesto'
		 ELSE 'Simple' 
	END AS 'Composicion',
	'Producto a evaluar' as 'Leyenda'
	FROM Producto p
	WHERE p.prod_codigo IN(SELECT TOP 3 i2.item_producto
								FROM Item_Factura i2
								INNER JOIN Factura f2 ON i2.item_numero = f2.fact_numero AND
													 i2.item_tipo = f2.fact_tipo AND i2.item_sucursal = f2.fact_sucursal
								WHERE YEAR(f2.fact_fecha) = 2015
								GROUP BY i2.item_producto
								HAVING (SELECT ISNULL(SUM(i3.item_cantidad),0) FROM Item_Factura i3
											INNER JOIN Factura f3 ON f3.fact_numero = i3.item_numero AND f3.fact_tipo = i3.item_tipo
																	 AND f3.fact_sucursal = i3.item_sucursal
											WHERE i3.item_producto = i2.item_producto AND YEAR(f3.fact_fecha) = 2010) > 5
								ORDER BY SUM(f2.fact_total) ASC)
	GROUP BY p.prod_codigo, p.prod_detalle

 -- Ejercicio 4 --
 /*
 ENUNCIADO: Implementar el/los objetos necesarios para que cada vez que se decida incrementar la comisión
 de un empleado no se permita incrementar mas de un 5% la comisión de aquellos empleados responsables
 de menos de 4 depositos

 ALGORITMO: Basicamente lo que este trigger hace es chequear que en la tabla de "modificados (inserted)"
 que empleados que tengan menos de 4 depositos a su cargo hayan sido modificado con comiciones
 mayores al 5% y así modificarlas de nuevo y estandarizarlas a 5% final.
 */

USE [GD2015C1]
GO

CREATE TRIGGER tcontrolarcargacomision 
	ON Empleado
	FOR INSERT, UPDATE 
	AS BEGIN TRANSACTION
		UPDATE empleado SET empl_comision = 5
			WHERE EXISTS(SELECT 1 FROM Inserted 
							WHERE empl_codigo = empleado.empl_codigo
								and (SELECT COUNT(*) FROM DEPOSITO WHERE depo_encargado = empl_codigo) < 4
								and Empleado.empl_comision > 5)
	COMMIT TRANSACTION