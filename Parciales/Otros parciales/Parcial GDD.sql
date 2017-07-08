/*PARCIAL DE RESTAGNO GESTION DE DATOS 22/06/2016*/
/*
SQL
1-Desarrolle una consulta que muestre para cada empleado que no tenga gente a cargo el indice de productividad
periodo x periodo (periodo x periodo implica periodo mensual AÑOMES).
Dicho índice es el porcentaje respecto a la cantidad de facturas que vendio ese vendedor en el periodo respecto
al periodo en el que mas facturas vendió (en el periodo en que más facturas vendió es %100).
  I.  Código de empleado
 II.  Nombre y apellido
III.  Periodo (AAAAMM)
 IV.  Índice de productividad
  V.  Periodo de referencia (periodo en el que más vendió histórico)
El resultado debe ser ordenado por la edad del empleado de manera descendente y periodo ascendente.
No se puede utilizar subselect en el FROM
*/
use GD2015C1
SELECT 
	   --I
	   empl_codigo AS Codigo,
	   
	   --II
	   empl_nombre + ' ' + empl_apellido AS Nombre, 
	   
	   --III
	   CONCAT( YEAR(fact_fecha) , RIGHT(CONCAT('0', MONTH(fact_fecha)), 2)) AS Periodo,
	   
	   --IV
	   CONCAT(
		CONVERT(DECIMAL(5,2),
						COUNT(*)*100.00/ 
						(SELECT TOP 1(COUNT(*))
						FROM Factura f1
						WHERE f1.fact_vendedor=empl_codigo
						GROUP BY YEAR(f1.fact_fecha),MONTH(f1.fact_fecha)
						ORDER BY COUNT(*) DESC)
				)
		,'%') AS Indice_Productividad,

	   --V
	   (SELECT TOP 1 CONCAT( YEAR(f2.fact_fecha) , RIGHT(CONCAT('0', MONTH(f2.fact_fecha)), 2))
		FROM Factura f2 
		WHERE empl_codigo=f2.fact_vendedor
		GROUP BY YEAR(f2.fact_fecha),MONTH(f2.fact_fecha)
		ORDER BY COUNT(*) DESC) AS Periodo_Referencia

FROM Empleado JOIN Factura ON empl_codigo=fact_vendedor 
GROUP BY empl_codigo,empl_nombre,empl_apellido, empl_nacimiento,YEAR(fact_fecha),MONTH(fact_fecha)
ORDER BY empl_nacimiento ASC, YEAR(fact_fecha) DESC, MONTH(fact_fecha) DESC

GO

/*
T-SQL
2-Cree el/los objetos de bases de datos necesarios para que automáticamente se cumpla la siguiente regla de
negocio "Ninguna factura puede contener más de 12 ítems".
La regla en la actualidad se cumple. No se conoce la forma de acceso a los datos ni el procedimiento por el
cual se emiten las mismas.
*/

/*PARA CADA ITEM INSERTADO, HAY QUE VERIFICAR QUE SU FACTURA NO CONTIENE MÁS DE 12 ITEMS*/

IF EXISTS(SELECT name FROM sysobjects WHERE name='trigger_12_items_factura')
	DROP TRIGGER trigger_12_items_factura
GO

CREATE TRIGGER trigger_12_items_factura ON Item_Factura FOR INSERT, UPDATE
AS BEGIN
	--sin cursores
	IF EXISTS --si al menos una factura cumple que:
	(
		SELECT *
		-- 1.a todos los items de las facturas con items insertados...
		FROM Item_Factura itf 
			JOIN inserted ins 
				ON  itf.item_numero = ins.item_numero 
				AND itf.item_sucursal = ins.item_sucursal 
				AND itf.item_tipo = ins.item_tipo
				/*esto seria una tabla de todos los items de las facturas 
				que tuvieron items insertados, está llena de repetidos 
				ya que cada item de una factura aparece n veces por las n 
				inserciones que se hicieron ahi, pero al aplicar distinct 
				en el count se arregla todo*/
		--2. se los agrupa por factura...
		GROUP BY itf.item_sucursal , itf.item_tipo, itf.item_numero
		--3. y se toman los grupos con mas de 12 items
		HAVING COUNT (DISTINCT itf.item_producto) > 12 -- no hay facturas iguales se supone...
	)
	BEGIN
		RAISERROR('Error: se intentaron insertar mas de 12 items en una factura',1,1)
		ROLLBACK TRANSACTION
		RETURN
	END
END
GO

SELECT item_sucursal, item_tipo, item_numero, COUNT(*) 
	FROM Item_Factura ite 
	GROUP BY ite.item_sucursal , ite.item_tipo, ite.item_numero

SELECT * 
	FROM Item_Factura

--prueba insert
/*
INSERT INTO Item_Factura VALUES ('A','0003','00068710','00001415',6.00,1.24)
*/

--prueba update
/*
UPDATE Item_Factura
	SET item_numero='00068710'
WHERE item_numero ='00068711'
	AND item_tipo='A'
	AND item_sucursal='0003'
	AND item_producto not in (SELECT item_producto FROM Item_Factura WHERE item_tipo='A' AND item_sucursal='0003' AND item_numero='00068710')
*/