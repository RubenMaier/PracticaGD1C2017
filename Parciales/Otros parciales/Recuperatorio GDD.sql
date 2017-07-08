/*PARCIAL RESTAGNO 06/07/2016*/
use GD2015C1

/*
PUNTO 1

Escriba una consulta que retorne para todos los productos las siguientes columnas:
-Codigo de producto
-Detalle del producto
-Compuesto (Debería mostrar S o N según corresponda)
-Promedio histórico de precios al que fue vendido (si nunca se vendió el promedio debe mostrarse como 0)
-Cantidad máxima que se vendió en un mes

El resultado debe ser ordenado por detalle de la familia del producto ascendente

*/

SELECT 

	prod_codigo
		AS codigo,

	prod_detalle
		AS detalle,

	(case when comp_producto is not null then 'S' else 'N' end)
		AS compuesto,

	(SELECT isnull(AVG(item_precio),0)
	 FROM Item_Factura
	 WHERE item_producto=prod_codigo)
		AS precio_promedio_historico,

	isnull((SELECT TOP 1 SUM(item_cantidad)
	 FROM Item_Factura JOIN Factura ON item_numero=fact_numero AND item_tipo=fact_tipo AND item_sucursal=fact_sucursal
	 WHERE item_producto=prod_codigo
	 GROUP BY YEAR(fact_fecha), MONTH(fact_fecha)
	 ORDER BY SUM(item_cantidad) DESC
	 ),0)AS maximo_mensual

FROM Producto LEFT JOIN Composicion ON prod_codigo=comp_producto JOIN Familia ON prod_familia = fami_id
GROUP BY prod_codigo, prod_detalle, fami_detalle, comp_producto
ORDER BY fami_detalle ASC

/*
PUNTO 2

Cree el/los objetos de bases de datos necesarios para que automáticamente se cumpla la siguiente regla de negocio
"El encargado de un depósito debe pertenecer a un departamento cuya zona coincida con la zona del depósito que tiene a cargo"
A partir de la aplicación de la creación de estos objetos (los datos que ya existen que no la cumplen deben continuar como están).
En la actualidad la regla NO se cumple. No se conoce la forma de acceso a los datos ni el procedimiento por el cual se emiten las mismas.

la regla se puede romper:
-cuando un encargado cambia de departamento
-cuando se crea un encargado con un departamento incompatible
-cuando un deposito cambia de encargado
-cuando un deposito cambia de zona
-cuando un departamento cambia de zona
*/


GO
IF EXISTS(SELECT name FROM sysobjects WHERE name='trigger_EMPLEADO_encargado')
	DROP TRIGGER trigger_EMPLEADO_encargado
GO

CREATE TRIGGER trigger_EMPLEADO_encargado ON Empleado FOR UPDATE, INSERT
AS BEGIN
	IF UPDATE(empl_departamento)
	BEGIN
		IF EXISTS
		(
			/* me fijo si existen empleados en la tabla "inserted (actualizados)" que vivan en un departamento
			con zona distinta al deposito que tiene acargo */
			SELECT empl_codigo
			FROM inserted 
				JOIN DEPOSITO 
					ON depo_encargado = empl_codigo 
				JOIN Departamento 
					ON empl_departamento = depa_codigo
			WHERE depa_zona <> depo_zona
		)
		BEGIN -- esto pertenece al if exist
			RAISERROR('la zona del departamento que se quiere asignar al encargado no coincide con la del deposito',1,1)
			ROLLBACK TRANSACTION
			RETURN
		END
	END
END
GO

IF EXISTS(SELECT name FROM sysobjects WHERE name='trigger_DEPOSITO_encargado')
	DROP TRIGGER trigger_DEPOSITO_encargado
GO

CREATE TRIGGER trigger_DEPOSITO_encargado ON DEPOSITO FOR UPDATE, INSERT
AS
BEGIN
	IF UPDATE(depo_zona) OR UPDATE(depo_encargado)
	BEGIN
		IF EXISTS
		(
			SELECT empl_codigo
			FROM inserted 
				JOIN Empleado 
					ON depo_encargado = empl_codigo 
				JOIN Departamento 
					ON empl_departamento = depa_codigo
			WHERE depa_zona <> depo_zona
		)
		BEGIN
			RAISERROR('se intento modificar la zona o el encargado de un deposito con encargado en un departamento de otra zona',1,1)
			ROLLBACK TRANSACTION
			RETURN
		END
	END
END
GO

IF EXISTS(SELECT name FROM sysobjects WHERE name='trigger_DEPARTAMENTO_encargado')
	DROP TRIGGER trigger_DEPARTAMENTO_encargado
GO

CREATE TRIGGER trigger_DEPARTAMENTO_encargado ON Departamento FOR UPDATE, INSERT
AS
BEGIN
	IF UPDATE(depa_zona)
	BEGIN
		IF EXISTS
		(
			SELECT empl_codigo
			FROM inserted JOIN Empleado ON empl_departamento=depa_codigo
						  JOIN DEPOSITO ON depo_encargado=empl_codigo
			WHERE depa_zona <> depo_zona
		)
		BEGIN
			RAISERROR('se intento modificar la zona de un departamento de empleado a cargo de un deposito de otra zona',1,1)
			ROLLBACK TRANSACTION
			RETURN
		END
	END
END
GO