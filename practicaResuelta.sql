use GD2015C1
  /*******************************************************/
 /*                         SQL                         */
/*******************************************************/


/*
1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea
mayor o igual a $ 1000 ordenado por código de cliente.
*/
SELECT clie_codigo, clie_razon_social
FROM Cliente
WHERE clie_limite_credito>=1000
ORDER BY clie_codigo asc


/*
2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados
por cantidad vendida.
*/
SELECT prod_codigo, prod_detalle
FROM Producto p 
	JOIN Item_Factura i 
		ON p.prod_codigo=i.item_producto
	JOIN Factura f 
		ON f.fact_tipo = i.item_tipo
	   AND f.fact_sucursal = i.item_sucursal
	   AND f.fact_numero = i.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(i.item_cantidad);
/*
3. Realizar una consulta que muestre código de producto, nombre de producto y el
stock total, sin importar en que deposito se encuentre, los datos deben ser ordenados
por nombre del artículo de menor a mayor.
*/
SELECT prod_codigo, prod_detalle, SUM(stoc_cantidad)
FROM Producto 
	JOIN STOCK 
		ON prod_codigo=stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle asc;

/*
4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad
de artículos que lo componen. Mostrar solo aquellos artículos para los cuales el
stock promedio por depósito sea mayor a 100.
*/

SELECT prod_codigo, prod_detalle, SUM(comp_cantidad) prod_componentes
FROM Producto p
	LEFT JOIN Composicion c
		ON p.prod_codigo=c.comp_producto
	JOIN STOCK s
		ON p.prod_codigo=s.stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING AVG(s.stoc_cantidad)>100.00


/*
5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos
de stock que se realizaron para ese artículo en el año 2012 (egresan los productos
que fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el
2011.
*/
SELECT prod_codigo, prod_detalle, SUM(item_cantidad) as egresos
FROM Producto p
	JOIN Item_Factura i1 
		ON p.prod_codigo=i1.item_producto
	JOIN Factura f1
		ON f1.fact_tipo = i1.item_tipo
	   AND f1.fact_sucursal = i1.item_sucursal
	   AND f1.fact_numero = i1.item_numero
GROUP BY p.prod_codigo, p.prod_detalle
HAVING SUM(i1.item_cantidad) > (
	(
	SELECT SUM(i2.item_cantidad)
	FROM Item_Factura i2
		JOIN Factura f2 
			ON f2.fact_tipo = i2.item_tipo
		   AND f2.fact_sucursal = i2.item_sucursal
		   AND f2.fact_numero = i2.item_numero
	WHERE YEAR(fact_fecha) = 2011
	  AND item_producto=p.prod_codigo
	)
)

/*
6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de
ese rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos
artículos que tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.
*/
SELECT rubr_id, rubr_detalle, COUNT (DISTINCT prod_codigo) productos, SUM(stoc_cantidad) stock
FROM Rubro 
	JOIN Producto p 
		ON prod_rubro = rubr_id
	JOIN STOCK s
		ON prod_codigo = stoc_producto
WHERE -- puede ir tambien como condicion del JOIN
	  (SELECT SUM(stoc_cantidad)
	  FROM STOCK
	  WHERE stoc_producto=p.prod_codigo)--se interpreta como stock total del producto, si fuera del deposito '00' se agrega con un AND
	  >
	  (SELECT SUM(stoc_cantidad)
	  FROM STOCK
	  WHERE stoc_producto LIKE '00000000'
		AND stoc_deposito LIKE '00')
GROUP BY rubr_id, rubr_detalle;
/*
7. Generar una consulta que muestre para cada articulo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio
= 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que
posean stock.
*/
SELECT									  
	prod_codigo, 
	prod_detalle,
	MAX(prod_precio) precio_maximo,
	MIN(prod_precio) precio_minimo,
	case when MIN(prod_precio)=0 then 0 else(MAX(prod_precio)/ MIN(prod_precio)-1)*100 end diferencia_porcentual
FROM Producto JOIN STOCK ON prod_codigo=stoc_producto
GROUP BY prod_codigo, prod_detalle
HAVING SUM(ISNULL(stoc_cantidad,0))>0
/*
8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.
*/
SELECT prod_detalle, MAX(stoc_cantidad) stock_mayor, COUNT(stoc_deposito) cantidad_depositos
FROM Producto JOIN STOCK ON prod_codigo=stoc_producto
						AND	ISNULL(stoc_cantidad,0)>0
GROUP BY prod_detalle
HAVING COUNT(stoc_deposito) = (SELECT COUNT(stoc_deposito)FROM STOCK)--da null porque no hay un producto con stock en todos los depositos
/*
9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.
*/
SELECT j.empl_codigo jefe, e.empl_codigo empleado, e.empl_nombre nombre_empleado,
	(SELECT COUNT(depo_codigo)
	 FROM DEPOSITO
	 WHERE depo_encargado=j.empl_codigo) depos_jefe,
	 (SELECT COUNT(depo_codigo)
	 FROM DEPOSITO
	 WHERE depo_encargado=e.empl_codigo) depos_empleado
FROM Empleado e JOIN Empleado j ON e.empl_jefe=j.empl_codigo 
/*
10. Mostrar los 10 productos mas vendidos en la historia y también los 10 productos
menos vendidos en la historia. Además mostrar de esos productos, quien fue el
cliente que mayor compra realizo.
*/
--Este salio horrendamente horrendo

SELECT TOP 10 prod_detalle mas_vendidos, (
									   SELECT TOP 1 clie_codigo
											FROM Cliente c
											JOIN Factura f
												ON f.fact_cliente=c.clie_codigo --En las facturas del cliente
											JOIN Item_Factura i --En los items de dichas facturas
												ON  i.item_tipo = f.fact_tipo
												AND i.item_numero = f.fact_numero
												AND i.item_sucursal = f.fact_sucursal 
											WHERE item_producto=prod_codigo --En los items que coinciden con el producto
											GROUP BY clie_codigo --Ordenar a cada cliente...
											ORDER BY SUM(i.item_cantidad) --...por la suma de dichos items
								  ) mayor_comprador
FROM Producto p JOIN Item_Factura
				ON prod_codigo = item_producto
			  JOIN Factura
				ON item_producto = prod_codigo
				AND item_tipo = fact_tipo
				AND item_numero = fact_numero
				AND item_sucursal = fact_sucursal
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) DESC

SELECT TOP 10 prod_detalle mas_vendidos, (
									   SELECT TOP 1 clie_codigo
											FROM Cliente c
											JOIN Factura f
												ON f.fact_cliente=c.clie_codigo --En las facturas del cliente
											JOIN Item_Factura i --En los items de dichas facturas
												ON  i.item_tipo = f.fact_tipo
												AND i.item_numero = f.fact_numero
												AND i.item_sucursal = f.fact_sucursal 
											WHERE item_producto=prod_codigo --En los items que coinciden con el producto
											GROUP BY clie_codigo --Ordenar a cada cliente...
											ORDER BY SUM(i.item_cantidad) --...por la suma de dichos items
								  ) mayor_comprador
FROM Producto p JOIN Item_Factura
				ON prod_codigo = item_producto
			  JOIN Factura
				ON item_producto = prod_codigo
				AND item_tipo = fact_tipo
				AND item_numero = fact_numero
				AND item_sucursal = fact_sucursal
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) ASC 


/*
11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos
tenga, solo se deberán mostrar las familias que tengan una venta superior a 20000
pesos para el año 2012.
*/
/*OK ESTE NO SE ENTENDIO UN JORACA LO QUE PIDEN, PERO MI INTERPRETACIÓN ES QUE QUIEREN POR FAMILIA LA CANT
DE PRODUCTOS DIFERENTES QUE SE VENDIERON, Y ADEMÁS EL MONTO TOTAL DE TODAS LAS VENTAS DE SUS PRODUCTOS.
SE INCLUYEN NOMÁS LAS FAMILIAS QUE EN 2012 TIENEN UNA FACTURA EN LA CUAL SUS PRODS SUMAN MAS DE 20000*/
SELECT fami_detalle, COUNT(DISTINCT prod_codigo) as cant_prod, SUM(item_precio * item_cantidad) as monto_ventas
FROM Familia fam
	 JOIN Producto p ON fami_id = prod_familia
	 JOIN Item_Factura i ON prod_codigo = item_producto
	 JOIN Factura fac ON item_numero = fact_numero
				 AND item_tipo = fact_tipo
				 AND item_sucursal = fact_sucursal
GROUP BY fami_detalle,fami_id
HAVING
		EXISTS(SELECT TOP 1 fact_numero, fact_tipo, fact_sucursal
		FROM Factura JOIN Item_Factura ON fact_sucursal=item_sucursal AND fact_tipo=item_tipo AND fact_numero=item_numero
					 JOIN Producto ON item_producto = prod_codigo
		WHERE YEAR(fact_fecha)=2012 AND prod_familia=fam.fami_id
		GROUP BY fact_numero, fact_tipo, fact_sucursal
		HAVING SUM(item_precio * item_cantidad)>20000)
ORDER BY monto_ventas DESC
/*
12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron
importe promedio pagado por el producto, cantidad de depósitos en lo cuales hay
stock del producto y stock actual del producto en todos los depósitos. Se deberán
mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos
deberán ordenarse de mayor a menor por monto vendido del producto.
*/
--SE INTERPRETA (AL NO ESPECIFICAR NIVELES) QUE NO HAY COMPOSICION
SELECT 
--nombre
	p.prod_detalle
	AS producto,
--cantidad clientes distintos que lo compraron
	(SELECT COUNT(DISTINCT f1.fact_cliente)
	 FROM Factura f1 JOIN Item_Factura i1 ON i1.item_numero=f1.fact_numero AND i1.item_sucursal=f1.fact_sucursal AND i1.item_tipo=f1.fact_tipo
	 WHERE i1.item_producto=p.prod_codigo)
	AS compradores,
--importe promedio del producto (interpreto suma de precio*cantidad en cada factura dividido la cantidad vendida en todas las facturas)
	(SELECT SUM(i1.item_precio*i1.item_cantidad)/SUM(i1.item_cantidad)
	 FROM Item_Factura i1 WHERE i1.item_producto=p.prod_codigo)
	AS importe_promedio,
--cantidad depositos con stock
	(SELECT COUNT(s1.stoc_deposito)
	 FROM STOCK s1
	 WHERE s1.stoc_producto=p.prod_codigo AND ISNULL(s1.stoc_cantidad,0)>0)
	AS Depositos_con_stock,
--stock en todos los depositos (interpreto sumatoria de todos los depositos)
	isnull((SELECT SUM(isnull(s1.stoc_cantidad,0))
			FROM STOCK s1 WHERE s1.stoc_producto=p.prod_codigo)
			,0)
	AS stock_total
--operaciones se interpreta como ventas
FROM Producto p JOIN Item_Factura i ON i.item_producto=p.prod_codigo
				JOIN Factura f ON i.item_numero=f.fact_numero AND i.item_sucursal=f.fact_sucursal AND i.item_tipo=f.fact_tipo
WHERE YEAR(f.fact_fecha)=2012
GROUP BY p.prod_codigo, p.prod_detalle
--se interpreta ordenar por monto vendido en 2012
ORDER BY SUM(i.item_cantidad*i.item_precio) DESC
/*
13. Realizar una consulta que retorne para cada producto que posea composición
nombre del producto, precio del producto, precio de la sumatoria de los precios por
la cantidad de los productos que lo componen. Solo se deberán mostrar los
productos que estén compuestos por más de 2 productos y deben ser ordenados de
mayor a menor por cantidad de productos que lo componen.
*/
SELECT p.prod_detalle AS nombre, p.prod_precio AS precio, SUM(componente.prod_precio*c.comp_cantidad) AS precio_componentes
FROM Producto p JOIN Composicion c ON P.prod_codigo=comp_producto
				JOIN Producto componente ON componente.prod_codigo=comp_componente
GROUP BY p.prod_codigo,p.prod_detalle, p.prod_precio
HAVING COUNT(*)>2
ORDER BY COUNT(*) DESC

/*
14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos
que debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que
compro en el último año.
No se deberán visualizar NULLs en ninguna columna
*/
SELECT clie_codigo 
			AS codigo,
	   
	   COUNT(DISTINCT CONCAT(fact_sucursal,fact_tipo,fact_numero))
			AS cant_compras,
	   
	   (SELECT AVG(fact_total)--no meto el AVG directamente porque fact_total se repite por cada item de la factura gracias al JOIN
	   FROM Factura
	   WHERE YEAR(fact_fecha)=(SELECT MAX(YEAR(fact_fecha)) FROM Factura) AND fact_cliente=clie_codigo)
			AS promedio_compra,
	   
	   COUNT(DISTINCT item_producto)
			AS prods_diferentes,
	   
	   MAX(fact_total)
			AS monto_maximo

FROM Cliente LEFT JOIN 
		(Factura JOIN Item_Factura ON fact_sucursal= item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo)
		ON fact_cliente=clie_codigo
			
WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
GROUP BY clie_codigo



/*
15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos
juntos (en la misma factura) más de 500 veces. El resultado debe mostrar el código
y descripción de cada uno de los productos y la cantidad de veces que fueron
vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se
vendieron juntos dichos productos. Los distintos pares no deben retornarse más de
una vez.
Ejemplo de lo que retornaría la consulta:
PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2
*/
SELECT p1.prod_codigo PROD1, p1.prod_detalle DETALLE1, p2.prod_codigo PROD2, p2.prod_detalle DETALLE2, COUNT(*) VECES
FROM (Producto p1 JOIN Item_Factura i1 ON i1.item_producto=p1.prod_codigo) JOIN
	 (Producto p2 JOIN Item_Factura i2 ON i2.item_producto=p2.prod_codigo)
	  ON i2.item_numero=i1.item_numero AND i2.item_tipo=i1.item_tipo AND i2.item_sucursal=i1.item_sucursal AND p1.prod_codigo!=p2.prod_codigo
WHERE p1.prod_codigo>p2.prod_codigo --aca ta la magia para que no se repitan
GROUP BY p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_detalle
HAVING COUNT(*)>500
ORDER BY VECES


/*
16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos
compran en la empresa, se pide una consulta SQL que retorne aquellos clientes
cuyas ventas son inferiores a 1/3 del promedio de ventas del/los producto/s que más
se vendieron en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
Aclaraciones:
La composición es de 2 niveles, es decir, un producto compuesto solo se compone
de productos no compuestos.
Los clientes deben ser ordenados por código de provincia ascendente.
*/
--no SE ENTIENDE UNA GOMA LO DE PROMEDIO DE VENTAS (FACTURAS? UNIDADES POR FACTURA? ju nous)
--VOY A ASUMIR QUE EL PROMEDIO DE VENTAS ES LA CANTIDAD DE FACTURAS DONDE FIGURA EL PRODUCTO Y FUE
--y que se refiere a la cantidad de ventas del 2012
use GD2015C1
SELECT clie_codigo, 
	--total de unidades compradas en el 2012
	(SELECT SUM(CASE WHEN comp_producto IS NULL THEN item_cantidad ELSE item_cantidad*comp_cantidad END)
	FROM Factura JOIN Item_Factura ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
				 LEFT JOIN Composicion ON item_producto=comp_producto
	WHERE fact_cliente=clie_codigo AND YEAR(fact_fecha)=2012) 
	unidades_totales_compradas,
	--producto mas comprado en el año
	(SELECT TOP 1 item_producto
	FROM Item_Factura i JOIN Factura ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
				 LEFT JOIN Composicion c ON item_producto=comp_componente
	WHERE YEAR (fact_fecha)=2012 AND fact_cliente=clie_codigo
	GROUP BY item_producto, comp_componente,comp_producto,comp_cantidad
	ORDER BY SUM(item_cantidad)
					+
				(CASE WHEN comp_componente is not null THEN 
							(SELECT SUM(item_cantidad)*c.comp_cantidad 
							 FROM Factura f2 JOIN Item_Factura ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
							 WHERE YEAR(fact_fecha)=2012 AND item_producto=c.comp_producto AND f2.fact_cliente=clie_codigo) ELSE 0 END) DESC,
			 item_producto ASC) 
	producto_mas_comprado

FROM Cliente c JOIN Factura f ON clie_codigo=fact_cliente
GROUP BY clie_codigo, clie_domicilio
HAVING COUNT(*)<1.00/3*(
	SELECT TOP 1 COUNT(*)--todas las facturas de un determinado producto vendido el 2012
	FROM Factura JOIN Item_Factura ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
	WHERE YEAR(fact_fecha)=2012
	GROUP BY item_producto
	ORDER BY COUNT(*) DESC)
ORDER BY clie_domicilio ASC
/*
17. Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del
periodo pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar
ordenada por periodo y código de producto.
*/
SELECT 
	(CONCAT(YEAR(fact_fecha),RIGHT(CONCAT('0',MONTH(fact_fecha)),2))) AS PERIODO, 
	
	(prod_codigo) AS PROD, 
	
	(prod_detalle) AS DETALLE,
	
	(SUM(item_cantidad)) AS CANTIDAD_VENDIDA, 
	
	(SELECT isnull(SUM(item_cantidad),0)
	 FROM Item_Factura i1 JOIN Factura f1 ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
	 WHERE i1.item_producto=p.prod_codigo AND YEAR(f1.fact_fecha)=YEAR(f.fact_fecha)-1 AND MONTH(f1.fact_fecha)=MONTH(f.fact_fecha))
		AS VENTAS_AÑO_ANT, 
	
	(COUNT(*)) AS CANT_FACTURAS
FROM Producto p JOIN  
	 (Item_Factura JOIN Factura f ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo)
	 ON prod_codigo=item_producto
GROUP BY prod_codigo, prod_detalle, YEAR(fact_fecha), MONTH(fact_fecha)
ORDER BY PERIODO,PROD
/*
18. Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos
30 días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar
ordenada por cantidad de productos diferentes vendidos del rubro
*/
--no se si hay que modificar los valores nulos a uno por default o no mostrar las filas con valores nulos
--me juego por la primera
SELECT
	isnull(rubr_detalle,'sin nombre') AS DETALLE_RUBRO,
	
	isnull(SUM(item_cantidad*item_precio),0) AS VENTAS,
	
	isnull((SELECT TOP 1 p1.prod_codigo 
	 FROM Producto p1 JOIN Item_Factura i1 ON p1.prod_codigo=i1.item_producto
	 WHERE p1.prod_rubro=rubr_id
	 GROUP BY p1.prod_codigo
	 ORDER BY SUM(i1.item_cantidad) DESC)
	 ,'-')
		AS PROD1,
	
	isnull(
	(SELECT TOP 1 p2.prod_codigo 
	 FROM Producto p2 JOIN Item_Factura i2 ON p2.prod_codigo=i2.item_producto
	 WHERE p2.prod_rubro=rubr_id AND p2.prod_codigo!=
					(SELECT TOP 1 p1.prod_codigo 
					 FROM Producto p1 JOIN Item_Factura i1 ON p1.prod_codigo=i1.item_producto
					 WHERE p1.prod_rubro=rubr_id
					 GROUP BY p1.prod_codigo
					 ORDER BY SUM(i1.item_cantidad) DESC) 
	 GROUP BY p2.prod_codigo
	 ORDER BY SUM(i2.item_cantidad) DESC)
	 ,'-')
		AS PROD2,

	isnull(
	(SELECT TOP 1 clie_codigo
	FROM Cliente c JOIN Factura fc ON c.clie_codigo=fc.fact_cliente
		 JOIN Item_Factura ic ON fc.fact_sucursal=ic.item_sucursal AND fc.fact_numero=ic.item_numero AND fc.fact_tipo=ic.item_tipo
		 JOIN Producto pc ON ic.item_producto=pc.prod_codigo
	WHERE pc.prod_rubro=rubr_id AND fc.fact_fecha>DATEADD(day,-30,(SELECT MAX(fact_fecha) FROM Factura))--podriamos usar getdate pero para obtener un resultado no nulo voy a usar la fecha de la ultima factura como parametro en vez de la actual
	GROUP BY c.clie_codigo
	ORDER BY SUM(ic.item_cantidad) DESC
	)
	,'nadie') AS CLIENTE
FROM Rubro JOIN Producto ON prod_rubro=rubr_id
		   JOIN Item_Factura ON prod_codigo=item_producto
		   JOIN Factura ON fact_sucursal=item_sucursal AND fact_numero=item_numero AND fact_tipo=item_tipo
GROUP BY rubr_id, rubr_detalle
ORDER BY COUNT(DISTINCT prod_codigo) DESC
  /*******************************************************/
 /*                        T-SQL                        */
/*******************************************************/
/*
1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es menor
al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de
ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.
*/
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name='estado_deposito' AND type in ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION estado_deposito
GO
CREATE FUNCTION estado_deposito
(  @prod_codigo char(8), @depo_codigo char(2) )
RETURNS Nvarchar(200)
BEGIN
	DECLARE @cant_stock int
	DECLARE @max_stock int
	DECLARE @RESPUESTA varchar(200)

	SELECT TOP 1 @cant_stock=isnull(stoc_cantidad,0), @max_stock=isnull(stoc_stock_maximo,0)
	FROM STOCK
	WHERE stoc_deposito=@depo_codigo AND stoc_producto=@prod_codigo
	

	if (@cant_stock>=@max_stock)
		SET @RESPUESTA= 'DEPOSITO COMPLETO'
	else 
	BEGIN
		DECLARE @porcentaje int
		SET @porcentaje = case when @max_stock=0 then 0 else @cant_stock*100/@max_stock end
		SET @RESPUESTA= convert(varchar,CONCAT('OCUPACION DEL DEPOSITO ',@porcentaje, '%'))
	END
RETURN @RESPUESTA
END
GO

select dbo.estado_deposito(stoc_producto, stoc_deposito) as funcion, isnull(stoc_cantidad,0) cant, isnull(stoc_stock_maximo,0) limit
FROM STOCK 

/*2. Realizar una función que dado un artículo y una fecha, retorne el stock que existía a
esa fecha
*/
GO
CREATE FUNCTION stock_fecha
(@prod_codigo char(8), @fecha smalldatetime)
returns int
BEGIN --ni idea como funciona lo de reposicion, si tuviera una fecha de cuando se repuso 
	  --por ultima vez (en lugar hay de la prox que se va a reponer podria hacer algo mas
	DECLARE @Vendidos_Desde_Entonces int
	DECLARE @Stock_Actual int
	
	SELECT @Vendidos_Desde_Entonces=
			SUM(case when @prod_codigo=item_producto then item_cantidad
		   else case when @prod_codigo=c1.comp_componente then item_cantidad*c1.comp_cantidad
		   else case when @prod_codigo=c2.comp_componente then item_cantidad*c1.comp_cantidad*c2.comp_cantidad end end end)
	FROM Item_Factura JOIN Factura ON (item_numero=fact_numero AND item_sucursal=fact_sucursal AND item_tipo=fact_tipo)
					  LEFT JOIN Composicion c1 ON (c1.comp_componente=item_producto)
					  LEFT JOIN Composicion c2 ON (c2.comp_componente=c1.comp_producto)
	WHERE convert(DATE,fact_fecha) BETWEEN convert(DATE,@fecha) AND convert(DATE,GETDATE())
		  AND @prod_codigo in (item_producto,c1.comp_componente,c2.comp_componente)

	SELECT @Stock_Actual=SUM(stoc_cantidad)
	FROM STOCK
	WHERE stoc_producto=@prod_codigo

	RETURN @Stock_Actual+@Vendidos_Desde_Entonces
END 
GO

DROP FUNCTION stock_fecha

/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en
caso que sea necesario. Se sabe que debería existir un único gerente general (debería
ser el único empleado sin jefe). Si detecta que hay más de un empleado sin jefe
deberá elegir entre ellos el gerente general, el cual será seleccionado por mayor
salario. Si hay más de uno se seleccionara el de mayor antigüedad en la empresa.
Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla de un único
empleado sin jefe (el gerente general) y deberá retornar la cantidad de empleados
que había sin jefe antes de la ejecución.
*/
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name='arreglar_gerente' AND type='p')
	DROP PROCEDURE arreglar_gerente
GO
CREATE PROC arreglar_gerente
(@cant_emps_sin_jefe int OUTPUT)
AS
BEGIN
	DECLARE @jefe_codigo numeric(6,0)
	DECLARE @emps_sin_jefe TABLE(
		empl_codigo numeric(6,0)
	)
	INSERT INTO @emps_sin_jefe
	SELECT empl_codigo 
	FROM Empleado
	WHERE empl_jefe IS NULL
	ORDER BY empl_salario DESC, empl_ingreso ASC
	
	set @cant_emps_sin_jefe =(SELECT  COUNT (*) FROM @emps_sin_jefe)
	
	IF (@cant_emps_sin_jefe>1)
		BEGIN
			SELECT TOP 1 @jefe_codigo=empl_codigo
			FROM @emps_sin_jefe
			
			UPDATE Empleado
			SET empl_jefe=@jefe_codigo
			WHERE empl_jefe is null AND empl_codigo!=@jefe_codigo

		END
	RETURN @cant_emps_sin_jefe
END
GO

	
/*4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese empleado
a lo largo del último año. Se deberá retornar el código del vendedor que más vendió
(en monto) a lo largo del último año.
*/
--SE INTERPRETA ULTIMO AÑO COMO EL AÑO ANTERIOR A ESTE
--EL MONTO SE CALCULA SIN fact_total_impuestos
GO
IF OBJECT_ID('actualizar_comision_empleados','P') IS NOT NULL
	DROP PROCEDURE actualizar_comision_empleados
GO
CREATE PROCEDURE actualizar_comision_empleados
(@mayor_vendedor numeric(6) OUTPUT)
AS
BEGIN
	
	UPDATE Empleado
	SET empl_comision = isnull(
					   (SELECT SUM(f1.fact_total)
						FROM Factura AS f1
						WHERE f1.fact_vendedor=empl_codigo AND YEAR(f1.fact_fecha)=YEAR(GETDATE())-1)
						,0)
	
	set @mayor_vendedor = (SELECT TOP 1 empl_codigo
						   FROM Empleado
						   ORDER BY empl_comision DESC)
END
GO
/*5. Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)
*/

if OBJECT_ID('Fact_table','U') IS NOT NULL 
DROP TABLE Fact_table
GO
Create table Fact_table
(
anio char(4) NOT NULL, --YEAR(fact_fecha)
mes char(2) NOT NULL, --RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
familia char(3) NOT NULL,--prod_familia
rubro char(4) NOT NULL,--prod_rubro
zona char(3) NOT NULL,--depa_zona
cliente char(6) NOT NULL,--fact_cliente
producto char(8) NOT NULL,--item_producto
cantidad decimal(12,2) NOT NULL,--item_cantidad
monto decimal(12,2)--asumo que es item_precio debido a que es por cada producto, 
				   --asumo tambien que el precio ya esta determinado por total y no por unidad (no debe multiplicarse por cantidad)
)
Alter table Fact_table
Add constraint pk_Fact_table_ID primary key(anio,mes,familia,rubro,zona,cliente,producto)
GO

if OBJECT_ID('llenar_fact_table','P') IS NOT NULL
DROP PROCEDURE llenar_fact_table
GO

CREATE PROCEDURE llenar_fact_table
AS
BEGIN
	INSERT INTO Fact_table 
	SELECT YEAR(fact_fecha)
		  ,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
		  ,prod_familia
		  ,prod_rubro
		  ,depa_zona
		  ,fact_cliente
		  ,item_producto
		  ,sum(item_cantidad)
		  ,sum(item_precio)
	FROM Factura
		 JOIN Item_Factura
			ON fact_sucursal = item_sucursal
			AND fact_tipo = item_tipo
			AND fact_numero=item_numero
		 JOIN Producto ON item_producto=prod_codigo
		 JOIN Empleado ON fact_vendedor=empl_codigo
		 JOIN Departamento ON empl_departamento=depa_codigo
	GROUP BY  YEAR(fact_fecha)
			  ,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
			  ,prod_familia
			  ,prod_rubro
			  ,depa_zona
			  ,fact_cliente
			  ,item_producto
END
GO

EXECUTE llenar_fact_table
GO 
/*6. Realizar un procedimiento que si en alguna factura se facturaron componentes que
conforman un combo determinado (o sea que juntos componen otro producto de
mayor nivel), en cuyo caso deberá reemplazar las filas correspondientes a dichos
productos por una sola fila con el producto que componen con la cantidad de dicho
producto que corresponda.
*/
GO
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'compuesto_en_factura')
                  AND type IN ( 'P' ))
  DROP PROCEDURE compuesto_en_factura
GO

CREATE PROCEDURE compuesto_en_factura (@Prod_codigo char(8),@Fact_tipo char(1), @Fact_sucursal char(4), @Fact_numero char(8))
AS
BEGIN
	--si el producto no esta ya en la factura
	if (@Prod_codigo not in (SELECT item_producto FROM Item_Factura WHERE  @Fact_sucursal = item_sucursal AND @Fact_tipo = item_tipo AND @Fact_numero=item_numero))
	--si estan todos los componentes
	if (SELECT count(comp_componente) FROM Composicion WHERE comp_producto=@Prod_codigo)
	  =(SELECT count(distinct item_producto) FROM Item_Factura WHERE @Fact_sucursal = item_sucursal AND @Fact_tipo = item_tipo AND @Fact_numero=item_numero)
	
	BEGIN
		DECLARE @cantidad int
		DECLARE @precio decimal(12,2)
		
		--se busca la cantidad de unidades a partir del componente limitante
		SELECT @cantidad = min(item_cantidad/comp_cantidad)
		FROM Item_Factura JOIN Composicion ON item_producto=comp_componente
		WHERE @Prod_codigo=comp_producto AND @Fact_sucursal = item_sucursal AND @Fact_tipo = item_tipo AND @Fact_numero=item_numero
		
		SELECT @precio=prod_precio*@cantidad FROM Producto WHERE prod_codigo=@Prod_codigo

		--si el limitante es mayor a 0 (si se puede formar al menos un ejemplar de producto)
		IF @cantidad>0
		BEGIN
			DELETE FROM Item_Factura
			WHERE  @Fact_sucursal = item_sucursal AND @Fact_tipo = item_tipo AND @Fact_numero=item_numero 
			AND item_producto in (SELECT comp_componente FROM Composicion WHERE comp_producto=@Prod_codigo)
		
			INSERT INTO Item_Factura (item_numero,  item_tipo,  item_sucursal,  item_producto, item_cantidad, item_precio)
							  values (@Fact_numero, @Fact_tipo, @Fact_sucursal, @Prod_codigo,  @cantidad,     @precio)
		END
	END
END
GO 
--FALTA APLICARLO A TODAS LAS FACTURAS Y TODOS LOS PRODUCTOS

/*7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock realizados entre
esas fechas. La tabla se encuentra creada y vacía.
VENTAS 
| Código  | Detalle | Cant. Mov. | Precio de Venta | Renglón  | Ganancia |
  Código    Detalle  (suma Item	   Precio promedio   Nro Linea  Cantidad*
  del       del       facturas)			             de la      Costo 
  articulo  articulo								 tabla      Actual
*/
if OBJECT_ID('Ventas','U') IS NOT NULL 
DROP TABLE Ventas
GO
Create table Ventas
(
vent_codigo char(8) NULL,
vent_detalle char(50) NULL,
vent_cant_mov int NULL,
vent_precio decimal(12,2) NULL,
vent_renglon int PRIMARY KEY,
vent_ganancia decimal (12,2) NULL
)
if OBJECT_ID('llenar_ventas','P') is not null
DROP PROCEDURE llenar_ventas
GO

CREATE PROCEDURE llenar_ventas
(@A date,@B date)
AS 
BEGIN
	if @A>@B
	BEGIN
		DECLARE @aux datetime
		set @aux = @A
		set @A = @B
		set @B = @aux
	END
	BEGIN
		DECLARE @Codigo char(8), @Detalle char(50), @Cant_Mov int, @Precio_de_venta decimal(12,2), @Renglon int, @Ganancia decimal(12,2)
		DECLARE cursor_articulos CURSOR LOCAL FAST_FORWARD   
		FOR SELECT prod_codigo, prod_detalle, SUM(item_cantidad), AVG(item_precio), SUM(item_cantidad*item_precio)
			FROM Producto LEFT JOIN 
								(Item_Factura JOIN Factura ON fact_sucursal=item_sucursal AND fact_tipo=item_tipo AND fact_numero=item_numero)
								ON item_producto=prod_codigo
			WHERE fact_fecha between @A and @B
			GROUP BY prod_codigo,prod_detalle
		OPEN cursor_articulos
		set @Renglon=0
		-- Perform the first fetch.
		FETCH NEXT FROM cursor_articulos
		INTO @Codigo, @Detalle, @Cant_Mov, @Precio_de_venta, @Ganancia
		-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- This is executed as long as the previous fetch succeeds.
			set @Renglon=@Renglon+1
			INSERT INTO Ventas VALUES (@Codigo, @Detalle, @Cant_Mov, @Precio_de_venta, @Renglon, @Ganancia)
			FETCH NEXT FROM cursor_articulos
			INTO @Codigo, @Detalle, @Cant_Mov, @Precio_de_venta, @Ganancia
		END
		CLOSE cursor_articulos
		DEALLOCATE cursor_articulos
		
	END
END
GO
/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por cantidad
de sus componentes, se aclara que un producto que compone a otro, también puede
estar compuesto por otros y así sucesivamente, la tabla se debe crear y está formada
por las siguientes columnas:
DIFERENCIAS
Código Detalle Cantidad Precio_generado Precio_facturado
(prod) (prod)   (comp)
*/
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name='precio_compuesto'  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION precio_compuesto 
GO

CREATE FUNCTION precio_compuesto (@Producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @Precio decimal(12,2)
		SELECT @Precio=SUM(comp_cantidad * dbo.precio_compuesto(comp_componente))
		FROM Composicion
		WHERE comp_producto=@Producto
	--si el select falló es porque no hay composicion, en cuyo caso se devuelve el precio original
	if @Precio is null
	set @Precio = (SELECT prod_precio FROM Producto WHERE prod_codigo=@Producto)
	RETURN @Precio
END

GO
IF EXISTS (SELECT name FROM sysobjects WHERE name='Diferencias' AND type='U')
DROP TABLE Diferencias 
GO
CREATE TABLE Diferencias (
							Codigo char(8) PRIMARY KEY,
							Detalle char(50),
							Cantidad int,
							Precio_generado decimal(12,2),
							Precio_facturado decimal(12,2)
						)
INSERT INTO Diferencias SELECT prod_codigo, prod_detalle, count(*), dbo.precio_compuesto(prod_codigo), prod_precio
FROM Producto JOIN Composicion ON prod_codigo=comp_producto
GROUP BY prod_codigo, prod_detalle, prod_precio

SELECT * FROM Diferencias

/*9. Hacer un trigger que ante alguna modificación de un ítem de factura de un artículo
con composición realice el movimiento de sus correspondientes componentes.
*/
/*
NO LO PUEDO RESOLVER
EL MOVIMIENTO DE SUS COMPONENTES LO INTERPRETO COMO QUE SI UN ITEM SE BORRA
O SU CANTIDAD SE ALTERA TENGO QUE ACTUALIZAR EL STOCK DE SUS COMPONENTES,
PERO EL MISMO DEPENDE DEL DEPOSITO, QUE NO TENGO FORMA (HASTA DONDE SE) DE CONOCER

*/
/*
10. Hacer un trigger que ante el intento de borrar un artículo verifique que no exista
stock y si es así lo borre en caso contrario que emita un mensaje de error.
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name='trigger_borrar_compuesto')
DROP TRIGGER trigger_borrar_compuesto
GO
CREATE TRIGGER trigger_borrar_compuesto ON Producto INSTEAD OF DELETE
AS
BEGIN
	DECLARE borrados CURSOR FOR
	SELECT prod_codigo
	FROM deleted

	DECLARE @borrado char(8)
	
	OPEN borrados
	FETCH NEXT FROM borrados into @borrado
	WHILE @@FETCH_STATUS=0
	BEGIN
	--si hay stock positivo
		IF isnull((SELECT SUM(isnull (stoc_cantidad,0)) 
				   FROM STOCK 
				   WHERE stoc_producto in (SELECT prod_codigo FROM deleted))
				  ,0) <= 0
			DELETE FROM Producto WHERE prod_codigo=@borrado
		ELSE
			RAISERROR('Error al intentar borrar producto %s, aun hay stock del producto.',1,1,@borrado)
		FETCH NEXT FROM borrados into @borrado
	END
	DEALLOCATE borrados
	
END
GO
--PRUEBA QUE FUNCAA
--DELETE FROM Producto WHERE prod_codigo = '00000000' 
--SELECT * FROM Producto WHERE prod_codigo = '00000000'
/*
11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que sean
menores que su jefe directo.
*/
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name='empleados_menores_a_cargo' and type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION empleados_menores_a_cargo
GO

GO
CREATE FUNCTION empleados_menores_a_cargo
(@Jefe numeric(6))
returns int
AS
BEGIN
	DECLARE @cant int
	DECLARE @jefe_nacimiento smalldatetime
	SELECT @jefe_nacimiento=empl_nacimiento FROM Empleado WHERE empl_codigo=@Jefe
	--sumamos los empleados a cargo del man con sus empleados a cargo
	SELECT @cant = isnull(sum(dbo.empleados_menores_a_cargo(empl_codigo)+1),0) FROM Empleado WHERE empl_jefe=@Jefe AND empl_nacimiento>@jefe_nacimiento
	RETURN @cant
END
GO--FUNCA BIEN PILLO
--SELECT dbo.empleados_menores_a_cargo

/*12. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener a su cargo más de 50 empleados en total (directos +
indirectos)”. Se sabe que en la actualidad dicha regla se cumple y que la base de
datos es accedida por n aplicaciones de diferentes tipos y tecnologías.
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name='empleados_a_cargo' and type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION empleados_a_cargo
GO

GO
CREATE FUNCTION empleados_a_cargo
(@Jefe numeric(6))
returns int
AS
BEGIN
	DECLARE @cant int
	--sumamos los empleados a cargo del man con sus empleados a cargo
	SELECT @cant = isnull(sum(dbo.empleados_a_cargo(empl_codigo)+1),0) FROM Empleado WHERE empl_jefe=@Jefe
	RETURN @cant
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name='jefe_mayor' and type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION jefe_mayor
GO
CREATE FUNCTION jefe_mayor
(@empleado numeric(6))
returns numeric(6)
AS
BEGIN
	DECLARE @jefe numeric(6)
	SELECT @jefe = (case when empl_jefe is null then @empleado else dbo.jefe_mayor(empl_jefe) end) FROM Empleado WHERE empl_codigo=@empleado
	RETURN @jefe
END
GO

IF EXISTS(SELECT name FROM sysobjects WHERE name='trigger_50_empleados')
DROP TRIGGER trigger_50_empleados
GO

CREATE TRIGGER trigger_50_empleados ON Empleado FOR UPDATE, INSERT
AS
BEGIN
--agarramos los jefes "supremos"(sin jefe) de los empleados modificados y si el que tiene mas empleados tiene mas de 50 rompe
	if (SELECT MAX(dbo.empleados_a_cargo(dbo.jefe_mayor(empl_codigo))) FROM inserted)>50
	BEGIN
		RAISERROR('DALE GILAZO NO PUEDE HABER MAS DE 50 EMPLEADOS POR JEFE',1,1)
		ROLLBACK TRANSACTION
		RETURN
	END
END
GO

--INSERT INTO Empleado (empl_codigo, empl_jefe) values (19, 1),(87, 2)


--SELECT dbo.empleados_a_cargo(1)

/*13. Cree el/los objetos de base de datos necesarios para que nunca un producto pueda
ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se cumple y
que la base de datos es accedida por n aplicaciones de diferentes tipos y tecnologías.
No se conoce la cantidad de niveles de composición existentes.
*/
/*
ACLARACIÓN: SI EXISTÍA UNA FORMA SENCILLA DE RESOLVER ESTE PUNTO, MURIÓ EN EL CAMINO

BUENO EN ESENCIA ESTE PUNTO CONSISTE EN RECORRER UN GRAFO DIRIGIDO CON
LA TABLA COMPOSICION COMO TABLA DE ARISTAS Y LOS PRODUCTOS COMO NODOS
DONDE HAY QUE EVITAR TODO POSIBLE BUCLE, PARA ESO HAY QUE TENER EN CUENTA LO SIGUIENTE
-UN PRODUCTO 'A' COMPONE A OTRO 'B' SI HAY UN "CAMINO" ENTRE LAS RELACIONES DE COMPOSICION QUE VA DE 'A' A 'B'
-CON LOGRAR LLEGAR DESDE UN PRODUCTO A SI MISMO RECORRIENDO EL GRAFO ALCANZA PARA DEMOSTRAR QUE SE COMPONE POR SI MISMO
-DEMOSTRAR QUE EL COMPUESTO DE LA COMPOSICION QUE SE QUIERE INSERTAR SE COMPONE POR SI MISMO ES NECESARIO Y SUFICIENTE PARA DEMOSTRAR QUE LA
COMPOSICION AGREGADA CAGA TODO (LO QUE IMPLICA QUE SI NO HAY BUCLE EN NINGUN COMPUESTO DE LA INSERCION FUNCA TODO)
-EL PROGRAMA TIENE QUE EVITAR RECORRER BUCLES ETERNAMENTE (por ejemplo, supongamos que queremos ver si un producto A
se compone por sí mismo, pero en su recorrido pasa por un bucle ida y vuelta entre B y C del cual A no forma parte,
esto quiere decir que si bien se encontraron dos productos que se componen por sí mismos (B y C), A no es uno de ellos,
y por lo tanto no le interesa al programa, que va a seguir recorriendo el bucle sin parar), ESTO SE LOGRA LLEVANDO CUENTA DE LOS NODOS YA VISITADOS
*/

--declaro un tipo de tabla para poder pasarlo por parametro, va a llevar cuenta de los nodos visitados
GO
--descomentar en primera ejecucion y comentarlo luego
--CREATE TYPE tipo_tabla_componentes AS TABLE (codigo char(8))
GO

--esta funcion se va a encargar de recorrer el grafo desde un nodo dado
IF EXISTS( SELECT name FROM sysobjects WHERE name='get_componentes' AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION get_componentes
GO
CREATE FUNCTION get_componentes (@Nodo char(8),@ya_visitados tipo_tabla_componentes READONLY)
RETURNS @visitados_ret TABLE (nombre char(8))
AS
BEGIN
--ESTO ES PORQUE LOS PARAMETROS TABLA SI O SI SON READONLY
	DECLARE @visitados tipo_tabla_componentes
	INSERT INTO @visitados
	SELECT * FROM @ya_visitados
	
	
	DECLARE @adyacentes_sin_visitar tipo_tabla_componentes
	INSERT INTO @adyacentes_sin_visitar
	SELECT comp_componente FROM Composicion
	WHERE comp_producto=@Nodo AND comp_componente not in (SELECT * FROM @visitados)
	
	INSERT INTO @visitados
	SELECT * FROM @adyacentes_sin_visitar

	--STATIC para que en sus filas no aparezcan las inserciones que se van a realizar en la tabla
	DECLARE cursor_adyacentes_sin_visitar CURSOR STATIC FOR
	SELECT * FROM @adyacentes_sin_visitar
	DECLARE @adyacente char(8)

	OPEN cursor_adyacentes_sin_visitar
	FETCH NEXT FROM cursor_adyacentes_sin_visitar into @adyacente
	WHILE @@FETCH_STATUS=0
	BEGIN
		INSERT INTO @visitados
		SELECT * FROM get_componentes(@adyacente,@visitados)

		FETCH NEXT FROM cursor_adyacentes_sin_visitar into @adyacente
	END
	INSERT INTO @visitados_ret
	SELECT * FROM @visitados
	RETURN
END
GO

IF EXISTS( SELECT name FROM sysobjects WHERE name='trigger_composicion_objetos')
DROP TRIGGER trigger_composicion_objetos
GO
CREATE TRIGGER trigger_composicion_objetos ON  Composicion FOR UPDATE, INSERT
AS
BEGIN
	--declaramos una tabla vacia para pasarle al get_componentes
	DECLARE @visitados tipo_tabla_componentes
	--SI EXISTE UN PRODUCTO COMPUESTO POR SI MISMO
	IF EXISTS(SELECT * FROM inserted WHERE comp_producto in (SELECT * FROM get_componentes(comp_producto,@visitados)))
	BEGIN
		RAISERROR('SI UN PRODUCTO SE COMPONE POR SI MISMO EXPLOTA EL MUNDO PAPU',1,1)
		ROLLBACK TRANSACTION
	END
END
GO
--codigo de prueba
BEGIN	
	DECLARE @A char(8), @B char(8), @C char(8)
	SELECT TOP 1 @A=prod_codigo FROM Producto
	SELECT TOP 1 @B=prod_codigo FROM Producto WHERE prod_codigo not in (@A)
	SELECT TOP 1 @C=prod_codigo FROM Producto WHERE prod_codigo not in (@A, @B)
	
	-- bucle de 1 nodo (reflexividad) SALTA EL TRIGGER
	--INSERT INTO Composicion values (1,@A,@A)

	-- bucle de 2 nodos (simetría) SALTA EL TRIGGER
	--SELECT TOP 1 @producto=comp_componente, @componente=comp_producto FROM Composicion
	--INSERT INTO Composicion values (1,@A,@B),(1,@B,@A)

	-- bucle de 3 nodos (composicion indirecta) SALTA EL TRIGGER
	--INSERT INTO Composicion values (1,@A,@B),(1,@B,@C),(1,@C,@A)

	--prueba que no deberia tirar trigger NO HAY TRIGGER CARAJO
	--INSERT INTO Composicion values (1,@A,@B)
	--DELETE FROM Composicion WHERE comp_producto=@A AND comp_componente=@B
	
END
GO
/*14. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de sus
empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha regla
se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y
tecnologías*/

/*
aclaro que actuo ignorando funciones hechas con anterioridad

Primero que nada, esta regla se puede ver afectada cuando se insertan empleados o se modifican
sus sueldos, pero tambien puede ocurrir cuando se borran empleados, ya que la suma de los sueldos cambia

Nuevamente si vemos la red de empleado/jefe como un grafo dirigido, lo que hay que evitar es que,
al recorrer todos los nodos desde un supuesto jefe, no haya camino que salga de su nodo (no es jefe de nadie)
o el sueldo de este no sea mayor que el 20% la suma de sueldos de dichos nodos

los casos que se pueden dar son:
-aumenta el sueldo de un jefe:
	-un jefe aumenta su sueldo, superando su limite, rompiendo la regla
-disminuye el limite de un jefe:
	-un empleado reduce su sueldo, disminuyendo el límite de su jefe, rompiendo la regla
	-se reducen los empleados a cargo de un jefe, lo que reduce su limite, rompiendo la regla
-un empleado se vuelve jefe de alguien, lo que le da un limite que se supera de entrada, rompiendo la regla

Una forma seria:
Para los empleados insertados, se observa si cumplen la regla él y sus jefes (los jefes porque por ahí antes no tenían empleados).
Para los empleados borrados, se observa si cumplen la regla sus jefes, cuyos límites se redujeron.

La otra seria fijarse si todos los jefes cumplen y se van todos a lA CON- (aca puse esa porque me dio fiaca)
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name='get_empleados' and type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION get_empleados 
GO
CREATE FUNCTION get_empleados (@jefe numeric(6,0))
RETURNS @EMPLEADOS TABLE (empleado numeric (6,0))
AS--SE PRESUPONE QUE NO PUEDE HABER RECURSIVIDAD (nadie es simultaneamente jefe y empleado de otro)
BEGIN
	DECLARE cursor_empleados CURSOR FOR
	SELECT empl_codigo FROM Empleado WHERE empl_jefe=@jefe
	DECLARE @codigo numeric(6,0)
	OPEN cursor_empleados
	FETCH NEXT FROM cursor_empleados INTO @codigo
	WHILE @@FETCH_STATUS = 0
	--para cada empleado directo
	BEGIN
		--se inserta al empleado directo
		INSERT INTO @EMPLEADOS VALUES (@codigo)
		--se insertan los empleados indirectos a cargo de dicho empleado directo
		INSERT INTO @EMPLEADOS
		SELECT * FROM get_empleados(@codigo)
		
		FETCH NEXT FROM cursor_empleados INTO @codigo
	END
	RETURN
END
GO


--la hice al pedo esta, aunque a partir de una funcion get_empleados se puede hacer get_jefes y viceversa, mepa que
--get_jefes es mas performante
IF EXISTS (SELECT name FROM sysobjects WHERE name='get_jefes' and type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
DROP FUNCTION get_jefes
GO
CREATE FUNCTION get_jefes (@empleado numeric(6,0))
RETURNS @JEFES TABLE (jefe numeric (6,0))
AS--SE PRESUPONE QUE NO PUEDE HABER RECURSIVIDAD (nadie es simultaneamente jefe y empleado de otro)
BEGIN
	DECLARE @Jefe numeric (6,0)
	SELECT @Jefe=empl_jefe FROM Empleado WHERE empl_codigo=@empleado
	
	
	--se inserta al empleado directo
	INSERT INTO @JEFES VALUES (@Jefe)
	--se insertan los empleados indirectos a cargo de dicho empleado directo
	INSERT INTO @JEFES
	SELECT * FROM get_jefes(@Jefe)
		
	RETURN
END
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name='trigger_jefe_sueldo_sarpado')
DROP TRIGGER trigger_jefe_sueldo_sarpado
GO
CREATE TRIGGER trigger_jefe_sueldo_sarpado ON Empleado FOR UPDATE, DELETE, INSERT
AS
BEGIN
	IF EXISTS(
	SELECT * 
	FROM Empleado jefe
	WHERE
		--tiene empleados...
		EXISTS(SELECT * FROM dbo.get_empleados(empl_codigo))
		--... y rompe la regla
		AND empl_salario > 0.20*(
			SELECT SUM(empleado.empl_salario)
			FROM Empleado empleado
			WHERE empleado.empl_codigo IN (SELECT * FROM dbo.get_empleados(jefe.empl_codigo))
			)
	)
	BEGIN
		RAISERROR('man no te quiero decir nada pero hay un jefe que gana UNA BANDA',1,1)
		ROLLBACK TRANSACTION
		
	END
END
go