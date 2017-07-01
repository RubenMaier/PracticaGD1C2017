--EJERCICIO 1
/* Explique al menos 1 escenario en donde no sería adecuado utilizar sobre una tabla un indice
de árbol B+ */

Un caso no adecuado serian situaciones en las que constantemente tengo que ingresar por cualquier otro dato 
de la tabla o casos particulares (como el del ejercicio 2) donde tengo que barrer constantemente toda la tabla
y no ingresar por un indice en particular o un rango de indices.

--EJERCICIO 2
/*Si se sabe de antemanos que hay 1 millons de registros en una tabla T, y que el minimo valor de una columna C
de la tabla T es 1, siendo el dominio de c integer, y ademas se sabe que esta indexado sobre esa columna con un 
indice NON-CLUSTERED, con un arbol B. Responda si el siguiente query, utiliza dicho indice para calcular el resultado. 
justifique su respuesta:
-> SELECT * FROM T WHERE C >= 1*/

No lo utiliza, debido a que ya de por si al ser el minimo = 1 debera recorrer toda la tabla de todas maneras.
En este caso el indice es mas costoso porque acceder al arbol tiene un costo adicional, mientras que barrer
la tabla es lineal. El costo de acceder a la tabla es n (la cantidad de registros) y el del arbol es mucho mayor.
Esto obviamente no es lo mismo si le pidieramos un registro en especifico o una menor cantidad de registros
ya que necesitaria una cantidad limitada de accesos (4 o 5 como ejemplo) contra muchos mas si tiene que barrer
la tabla (400 500)

--EJERCICIO 3

select year(fact_fecha) ANIO, 
(
 select SUM(ITEM_CANTIDAD) from ITEM_FACTURA
 JOIN FACTURA on item_sucursal = fact_sucursal and
item_tipo = fact_tipo and
item_numero = fact_numero
 where ITEM_PRODUCTO in (select comp_producto from Composicion)
 and year(fact_fecha) = year(f.fact_fecha)
) CANT_PROD_COMP_VEND,
(SELECT COUNT(*) 
from Factura
where year(fact_fecha) = year(f.fact_fecha)) CANT_FACT_ANIO, SUM(ITEM_CANTIDAD * ITEM_PRECIO) MONTO_TOTAL_ANIO, 
(
select SUM(ITEM_CANTIDAD * ITEM_PRECIO)

 from ITEM_FACTURA i
JOIN FACTURA
on item_sucursal = fact_sucursal and
item_tipo = fact_tipo and
item_numero = fact_numero
where  year(f.FACT_FECHA) - 1 = year(fact_fecha) 
) MONTO_TOTAL_ANIO_ANT
from ITEM_FACTURA join Factura f
on item_sucursal = fact_sucursal and
item_tipo = fact_tipo and
item_numero = fact_numero where 10 < (
select top 1 ISNULL(SUM(ITEM_CANTIDAD),0) from 
PRODUCTO LEFT JOIN ITEM_FACTURA on item_producto = prod_codigo --ESTOY PIDIENDO DE TODOS LOS ARTICULOS NO SOLO LOS QUE ESTAN EN FACTURA (HAY ALGUNOS EN CERO)
LEFT join Factura f
on item_sucursal = fact_sucursal and
item_tipo = fact_tipo and
item_numero = fact_numero and year(f.fact_fecha) = year(fact_fecha)
 group by ITEM_PRODUCTO --ASUMO QUE SI PIDE CANTIDAD VENDIDA De TODOS LOS ARTICULOS ES POR CADA ARTICULO SINO DIRIA LA CANTIDAD VENDIDA EN EL AﾑO POR ESO EL GROUP BY POR ITEM PRODUCTO
 order by 1 ASC
 )
group by year(fact_fecha)
order by
(select top 1 CASE WHEN ISNULL(SUM(ITEM_CANTIDAD),0) between 50 and 100 THEN 1 else 0 END from 
PRODUCTO LEFT JOIN ITEM_FACTURA on item_producto = prod_codigo --ESTOY PIDIENDO DE TODOS LOS ARTICULOS NO SOLO LOS QUE ESTAN EN FACTURA (HAY ALGUNOS EN CERO)
LEFT join Factura f
on item_sucursal = fact_sucursal and
item_tipo = fact_tipo and
item_numero = fact_numero and year(f.fact_fecha) = year(fact_fecha)
 group by ITEM_PRODUCTO --ASUMO QUE SI PIDE CANTIDAD VENDIDA De TODOS LOS ARTICULOS ES POR CADA ARTICULO SINO DIRIA LA CANTIDAD VENDIDA EN EL AﾑO POR ESO EL GROUP BY POR ITEM PRODUCTO
 having SUM(ITEM_CANTIDAD) between 50 and 100
 ) 





 --EJERCICIO 4

 
CREATE TRIGGER fact_prod_00 ON ITEM_FACTURA AFTER INSERT, UPDATE
AS
BEGIN

	DECLARE @i_producto char(8)
	DECLARE @diferencia decimal(12,2)
	DECLARE @diferencia_comp decimal(12,2)
	DECLARE @stock_disponible decimal(12,2)
	DECLARE @comp_prod char(8)
	DECLARE @stock_comp decimal(12,2)


	DECLARE FACTURACION CURSOR for
	select i.item_cantidad - isnull(d.item_cantidad,0), i.item_producto, 
	comp_componente, ISNULL(comp_cantidad,0) * (i.item_cantidad - isnull(d.item_cantidad,0))
	FROM INSERTED i LEFT JOIN DELETED d on i.item_tipo = d.item_tipo and i.item_numero = d.item_numero and i.item_sucursal = d.item_sucursal
	LEFT JOIN Composicion on comp_producto = i.item_producto
	and i.item_producto = d.item_producto 

	OPEN FACTURACION 
	
	WHILE @@FETCH_STATUS = 0  
	
	FETCH NEXT from FACTURACION into @diferencia,@i_producto,@comp_prod,@diferencia_comp
	
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		select @stock_disponible = stoc_cantidad from STOCK 
		where stoc_deposito = '00' and stoc_producto = @i_producto 

		select @stock_comp = stoc_cantidad from STOCK
		where stoc_deposito = '00' and stoc_producto = @comp_prod
		


		if (@stock_disponible < @diferencia or @stock_comp < @diferencia_comp)
		BEGIN
			rollback transaction
			RAISERROR('No hay suficiente stock en el deposito "00" para agregar ese articulo',16,1)
		END
		else 
		commit
		
		FETCH NEXT from FACTURACION into @diferencia,@i_producto,@comp_prod,@diferencia_comp
	END
	
	CLOSE FACTURACION

END

GO