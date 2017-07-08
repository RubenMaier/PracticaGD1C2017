--1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o igual a $ 1000 ordenado por código de cliente.

SELECT [clie_codigo]
      ,[clie_razon_social]
      ,[clie_limite_credito]      
  FROM [GD2015C1].[dbo].[Cliente]
	WHERE clie_limite_credito > = 1000
	ORDER BY 1
	
--2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por cantidad vendida.

Select prod_codigo, prod_detalle
From [GD2015C1].dbo.Producto 
	join [GD2015C1].dbo.Item_Factura on prod_codigo=item_producto 
	join [GD2015C1].dbo.Factura on item_tipo= fact_tipo and item_sucursal=fact_sucursal and item_numero=fact_numero
Where YEAR(fact_fecha) = 2012
Group by prod_codigo, prod_detalle
Order by sum(item_cantidad)desc
	
--3. Realizar una consulta que muestre código de producto, nombre de producto y el stock total, 
--sin importar en que deposito se encuentre, los datos deben ser ordenados por 
--nombre del artículo de menor a mayor.
select prod_codigo, prod_detalle, 
		isnull((select sum(stoc_cantidad) from [GD2015C1].[dbo].Stock where stoc_producto=prod_codigo),0) as cantidad
from [GD2015C1].[dbo].Producto 
order by 2 asc

--otra forma
select prod_codigo, prod_detalle, isnull(sum(stoc_cantidad),0)
from [GD2015C1].[dbo].Producto 
left join [GD2015C1].[dbo].Stock on prod_codigo = stoc_producto 
group by prod_codigo, prod_detalle
order by 2 asc

--4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad
--de artículos que lo componen. Mostrar solo aquellos artículos para los cuales el
--stock promedio por depósito sea mayor a 100.
--Como no está claro suponemos: que todos los depósitos tienen que tener mas de 100 unidades
select P.prod_codigo, P.prod_detalle, count(*) cant_comps
From [GD2015C1].[dbo].Producto P 
	left join [GD2015C1].[dbo].Composicion C on C.comp_producto = P.prod_codigo 
Where ( select avg(stoc_cantidad)from [GD2015C1].[dbo].stock
		where stoc_producto=P.prod_codigo) > 100
Group by P.prod_codigo, P.prod_detalle	
order by 3 desc
--otra forma
select P.prod_codigo, P.prod_detalle, count(*) cant_comps
From [GD2015C1].[dbo].Producto P 
	left join [GD2015C1].[dbo].Composicion C on C.comp_producto = P.prod_codigo 
Group by P.prod_codigo, P.prod_detalle	
Having ( select avg(stoc_cantidad)from [GD2015C1].[dbo].stock
		where stoc_producto=P.prod_codigo) > 100
order by 3 desc
-- tomando la aclaración
select P.prod_codigo, P.prod_detalle, count(*) cant_comps
From [GD2015C1].[dbo].Producto P 
	left join [GD2015C1].[dbo].Composicion C on C.comp_producto = P.prod_codigo 
Group by P.prod_codigo, P.prod_detalle	
Having not exists  ( select 1 from [GD2015C1].[dbo].stock
		where stoc_producto=P.prod_codigo 
		group by stoc_producto, stoc_deposito
		having avg(stoc_cantidad) > 100)
order by 3 desc

--5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de stock 
--que se realizaron para ese artículo en el año 2012 (egresan los productos que fueron vendidos). 
--Mostrar solo aquellos que hayan tenido más egresos que en el 2011.

select prod_codigo, prod_detalle, 
	(select count(*)
	from [GD2015C1].[dbo].Item_Factura join [GD2015C1].[dbo].Factura on fact_tipo=item_tipo and	fact_sucursal=item_sucursal and fact_sucursal=item_sucursal and fact_numero=item_numero
	where item_producto=prod_codigo and year(fact_fecha)=2012) egresos
	
From [GD2015C1].[dbo].Producto

Where (select count(*)
		from [GD2015C1].[dbo].Item_Factura join [GD2015C1].[dbo].Factura on fact_tipo=item_tipo and fact_sucursal=item_sucursal and fact_sucursal=item_sucursal and fact_numero=item_numero
		where item_producto=prod_codigo and year(fact_fecha)=2012) >
		(select count(*)
		from [GD2015C1].[dbo].Item_Factura join [GD2015C1].[dbo].Factura on fact_tipo=item_tipo and fact_sucursal=item_sucursal and fact_sucursal=item_sucursal and fact_numero=item_numero
		where item_producto=prod_codigo and year(fact_fecha)=2011) 

--6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese rubro y 
--stock total de ese rubro de artículos. 
--Solo tener en cuenta aquellos artículos que tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.

select rubr_id, rubr_detalle, 
	(SELECT count(prod_codigo)
	FROM [GD2015C1].[dbo].[Producto] 
	WHERE prod_rubro = rubr_id) cant_art_rubr
from [GD2015C1].[dbo].Rubro
where (SELECT sum(stoc_cantidad)
		FROM [GD2015C1].[dbo].Stock
		JOIN [GD2015C1].[dbo].Producto on stoc_producto = prod_codigo
		WHERE stoc_producto = prod_codigo and prod_rubro = rubr_id)	> (select stoc_cantidad
												from [GD2015C1].[dbo].Stock 
												where stoc_producto='00000000' and stoc_deposito='00')
order by 1

--7. Generar una consulta que muestre para cada articulo código, detalle, mayor precio
--menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio= 10,
--mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean stock.
select prod_codigo, prod_detalle, 
		max(item_precio) as max_precio, 
		min(item_precio) as min_precio, 
		((max(item_precio)-min(item_precio))/min(item_precio))*100 as dif_porc
from [GD2015C1].[dbo].Producto
join [GD2015C1].[dbo].Item_Factura on prod_codigo = item_producto
where (select count(stoc_cantidad)
		from [GD2015C1].[dbo].Stock
		where stoc_producto=prod_codigo) > 0
group by prod_codigo, prod_detalle
--8. Mostrar para el o los artículos que tengan stock en todos los depósitos, 
--nombre del artículo, stock del depósito que más stock tiene.

select P1.prod_codigo,
	(select top 1 max(S2.stoc_cantidad)
	from [GD2015C1].[dbo].Producto P2
	join [GD2015C1].[dbo].Stock S2 on P2.prod_codigo = S2.stoc_producto
	join [GD2015C1].[dbo].Deposito D2 on S2.stoc_deposito = D2.depo_codigo
	where P2.prod_codigo=P1.prod_codigo
	group by P2.prod_codigo,S2.stoc_deposito
	order by  max(S2.stoc_cantidad) desc)
from [GD2015C1].[dbo].Producto P1
join [GD2015C1].[dbo].Stock S1 on P1.prod_codigo = S1.stoc_producto
join [GD2015C1].[dbo].Deposito D1 on S1.stoc_deposito = D1.depo_codigo
group by P1.prod_codigo, P1.prod_detalle
having sum(S1.stoc_cantidad)>0

--9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
--mismo y la cantidad de depósitos que ambos tienen asignados.
select E1.empl_codigo, E2.empl_codigo, E1.empl_nombre+' '+E1.empl_apellido,
		(select count(depo_codigo) from [GD2015C1].[dbo].Deposito
		  where depo_encargado=E1.empl_codigo or depo_encargado=E2.empl_codigo )
from [GD2015C1].[dbo].Empleado E1
	join [GD2015C1].[dbo].Empleado E2 on E2.empl_codigo = E1.empl_jefe

--10. Mostrar los 10 productos mas vendidos en la historia y también los 10 productos menos vendidos en la historia. 
--Además mostrar de esos productos, quien fue el cliente que mayor compra realizo. 
--(se resuelve con un IN)
select prod_codigo, prod_detalle,
	(select top 1 fact_cliente
	from [GD2015C1].[dbo].Factura join [GD2015C1].[dbo].Item_Factura on fact_tipo=item_tipo and
																		fact_sucursal=item_sucursal and
																		fact_numero=item_numero
	where item_producto=prod_codigo
	group by fact_cliente
	order by sum(item_cantidad) desc)	as cod_cliente	
From [GD2015C1].[dbo].Producto
Where prod_codigo IN (select top 10 item_producto from  [GD2015C1].[dbo].Item_Factura
						group by item_producto order by sum(item_cantidad)) or 
	  prod_codigo IN (select top 10 item_producto from  [GD2015C1].[dbo].Item_Factura
						group by item_producto order by sum(item_cantidad) desc)

--11. Realizar una consulta que retorne el detalle de la familia, 
--la cantidad diferentes de productos vendidos y 
--el monto de dichas ventas sin impuestos. 
--Los datos se deberán ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga, 
--solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para el año 2012.

select fami_id, fami_detalle,
	(select count(distinct(item_producto)) 
	from [GD2015C1].[dbo].item_factura
	join [GD2015C1].[dbo].producto on item_producto=prod_codigo
	where prod_familia=fami_id) as Cant_dif_prod_vend,
	(select sum(fact_total) 
	from [GD2015C1].[dbo].item_factura
	join [GD2015C1].[dbo].producto on item_producto=prod_codigo
	join [GD2015C1].[dbo].factura on fact_tipo=item_tipo and
									fact_sucursal=item_sucursal and
									fact_numero=item_numero
	where prod_familia=fami_id) as Monto_ventas
from [GD2015C1].[dbo].Familia
where (select sum(fact_total)
	from [GD2015C1].[dbo].item_factura
	join [GD2015C1].[dbo].producto on item_producto=prod_codigo
	join [GD2015C1].[dbo].factura on fact_tipo=item_tipo and
									fact_sucursal=item_sucursal and
									fact_numero=item_numero
	where year(fact_fecha)='2012' and prod_familia=fami_id) > 20000 
	order by 2 desc

--12. Mostrar nombre de producto, 
--cantidad de clientes distintos que lo compraron, 
--importe promedio pagado por el producto, 
--cantidad de depósitos en lo cuales hay stock del producto y 
--stock actual del producto en todos los depósitos. 
--Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2012 y 
--los datos deberán ordenarse de mayor a menor por monto vendido del producto.
select prod_detalle, 
		(select count(distinct(clie_codigo))
			from [GD2015C1].[dbo].Cliente 
			join [GD2015C1].[dbo].Factura on clie_codigo=fact_cliente
			join [GD2015C1].[dbo].Item_Factura on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero and
													item_producto=prod_codigo) as cant_cli,
		(select avg(fact_total)
			from [GD2015C1].[dbo].Cliente 
			join [GD2015C1].[dbo].Factura on clie_codigo=fact_cliente
			join [GD2015C1].[dbo].Item_Factura on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero and
													item_producto=prod_codigo) as avg_imp,
		(select count(stoc_deposito) 
			from  [GD2015C1].[dbo].stock 
			where prod_codigo = stoc_producto and stoc_cantidad>0) as cant_dep_stock,														
		(select sum(stoc_cantidad) 
			from  [GD2015C1].[dbo].stock 
			where prod_codigo = stoc_producto 
			group by stoc_producto) as stock																						
from [GD2015C1].[dbo].Producto
where (select count(*)
			from [GD2015C1].[dbo].Cliente 
			join [GD2015C1].[dbo].Factura on clie_codigo=fact_cliente
			join [GD2015C1].[dbo].Item_Factura on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero and
													item_producto=prod_codigo
			where year(fact_fecha) = '2012')>0
order by (select sum(fact_total)
			from [GD2015C1].[dbo].Cliente 
			join [GD2015C1].[dbo].Factura on clie_codigo=fact_cliente
			join [GD2015C1].[dbo].Item_Factura on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero and
													item_producto=prod_codigo) desc

--13. Realizar una consulta que retorne para cada producto que posea composición. nombre del producto, 
--precio del producto, precio de la sumatoria de los precios por la cantidad de los productos que lo componen. 
--Solo se deberán mostrar los productos que estén compuestos por más de 2 productos y deben ser ordenados de
--mayor a menor por cantidad de productos que lo componen.
SELECT P1.prod_detalle, P1.prod_precio, comp_componente, comp_cantidad * P2.prod_precio as precio_cant_comp, 
(select count(comp_producto) from dbo.Composicion where comp_producto=P1.prod_codigo) as cant_prod_comp
  FROM dbo.Producto P1
  join dbo.Composicion on prod_codigo=comp_producto
  join dbo.Producto P2 on comp_componente=P2.prod_codigo
  where (select count(comp_producto) from dbo.Composicion
			where comp_producto=P1.prod_codigo)>=2
order by 5 desc

--14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que debe retornar son:
--Código del cliente
--Cantidad de veces que compro en el último año
--Promedio por compra en el último año
--Cantidad de productos diferentes que compro en el último año
--Monto de la mayor compra que realizo en el último año
--Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en el último año.
--No se deberán visualizar NULLs en ninguna columna
select clie_codigo,
(select count(*) from dbo.Factura
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012') as cant_comp,
isnull((select sum(fact_total) from dbo.Factura
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012')/
	(select count(*) from dbo.Factura
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012'),0) as prom_comp,
(select count(distinct item_producto) from dbo.Factura
	join dbo.Item_Factura on item_tipo=fact_tipo and item_sucursal=fact_sucursal and item_numero=fact_numero
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012') as cant_prod_dif,
isnull((select max(fact_total) from dbo.Factura
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012'),0) as max_comp
from dbo.Cliente
order by (select count(*) from dbo.Factura
	where clie_codigo=fact_cliente and YEAR(fact_fecha)='2012') desc
	
*--15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos
--juntos (en la misma factura) más de 500 veces. El resultado debe mostrar el código
--y descripción de cada uno de los productos y la cantidad de veces que fueron
--vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se
--vendieron juntos dichos productos. Los distintos pares no deben retornarse más de una vez.

select P1.prod_codigo, P1.prod_detalle, P2.prod_codigo, P2.prod_detalle		
From [GD2015C1].[dbo].Producto P1 
		join [GD2015C1].[dbo].Item_Factura I1 on P1.prod_codigo=I1.item_producto 
		join [GD2015C1].[dbo].Factura F on I1.item_tipo=F.fact_tipo and I1.item_sucursal=F.fact_sucursal and I1.item_numero=F.fact_numero
		join [GD2015C1].[dbo].Item_Factura I2 on I2.item_tipo=F.fact_tipo and I2.item_sucursal=F.fact_sucursal and I2.item_numero=F.fact_numero
		join [GD2015C1].[dbo].Producto P2 on P2.prod_codigo=I2.item_producto 
Where P1.prod_codigo > P2.prod_codigo -- con el ">" elimino los duplicados
group by P1.prod_codigo, P1.prod_detalle, P2.prod_codigo, P2.prod_detalle
Having count (distinct F.fact_tipo + F.fact_sucursal  +F.fact_numero) > 500
		
--16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos
--compran en la empresa, se pide una consulta SQL que retorne aquellos clientes
--cuyas ventas son inferiores a 1/3 del promedio de ventas del/los producto/s que más se vendieron en el 2012.
-- sacar el promedio del producto que mas se vendió
--Además mostrar
--1. Nombre del Cliente
--2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
--3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,mostrar solamente el de menor código) para ese cliente.
--Aclaraciones:
--CONSULTAR--La composición es de 2 niveles, es decir, un producto compuesto solo se compone de productos no compuestos.
--Los clientes deben ser ordenados por código de provincia ascendente.
select clie_razon_social, 
isnull((select sum(item_cantidad)
			from [GD2015C1].[dbo].Factura
			join [GD2015C1].[dbo].Item_Factura on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero															
			where clie_codigo=fact_cliente and year(fact_fecha) = '2012'),0) as uni_vend,
(select max(prod_codigo)
	from [GD2015C1].[dbo].Producto 
	join [GD2015C1].[dbo].Item_Factura	on item_producto = prod_codigo
	join [GD2015C1].[dbo].Factura		  on	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero	
	where fact_cliente=clie_codigo and year(fact_fecha) = '2012') as prod_may_ven					
from [GD2015C1].[dbo].Cliente 

where (select sum(item_precio*item_cantidad)
			from [GD2015C1].[dbo].Factura 
			join [GD2015C1].[dbo].Item_Factura	on 	fact_tipo=item_tipo and
													fact_sucursal=item_sucursal and
													fact_numero=item_numero							
			where year(fact_fecha) = '2012' and  fact_cliente= clie_codigo)
						 < (select top 1 avg(item_precio*item_cantidad)
							from [GD2015C1].[dbo].Cliente 
							join [GD2015C1].[dbo].Factura on clie_codigo=clie_codigo
							join [GD2015C1].[dbo].Item_Factura	on 	fact_tipo=item_tipo and
																	fact_sucursal=item_sucursal and
																	fact_numero=item_numero							
							where year(fact_fecha) = '2012'
							group by item_producto 
							order by sum(item_precio*item_cantidad) desc)/3
order by 2 desc			
	   
--17. Escriba una consulta que retorne una estadística de ventas por año y mes para cada producto. La consulta debe retornar:
--PERIODO: Año y mes de la estadística con el formato YYYYMM
--PROD: Código de producto
--DETALLE: Detalle del producto
--CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
--VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo pero del año anterior
--CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el periodo
--La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada por periodo y código de producto.

select CAST(year(F.fact_fecha) AS VARCHAR) +'-'+ CAST(month(F.fact_fecha) AS VARCHAR) as Período, 		
		P1.prod_codigo,
		sum(I1.item_cantidad) as Cantidad,
		isnull((select sum(I2.item_cantidad) 
			From [GD2015C1].[dbo].Producto P2 
					join [GD2015C1].[dbo].Item_Factura I2 on P2.prod_codigo=I2.item_producto 
					join [GD2015C1].[dbo].Factura F2 on I2.item_tipo=F2.fact_tipo and I2.item_sucursal=F2.fact_sucursal and I2.item_numero=F2.fact_numero
			where P1.prod_codigo = P2.prod_codigo and
				year(F2.fact_fecha) = year(F.fact_fecha)-1 and 
				month(F2.fact_fecha) = month(F.fact_fecha)
				),0) as Cantidad_año_ant,
		(select count(*)
			From [GD2015C1].[dbo].Producto P3 
					join [GD2015C1].[dbo].Item_Factura I3 on P3.prod_codigo=I3.item_producto 
					join [GD2015C1].[dbo].Factura F3 on I3.item_tipo=F3.fact_tipo and I3.item_sucursal=F3.fact_sucursal and I3.item_numero=F3.fact_numero
			where	P1.prod_codigo = P3.prod_codigo and 
					year(F.fact_fecha) = year(F3.fact_fecha) and 
					month(F.fact_fecha) = month(F3.fact_fecha)) as Cant_Facturas
From [GD2015C1].[dbo].Producto P1 
		join [GD2015C1].[dbo].Item_Factura I1 on P1.prod_codigo=I1.item_producto 
		join [GD2015C1].[dbo].Factura F on I1.item_tipo=F.fact_tipo and I1.item_sucursal=F.fact_sucursal and I1.item_numero=F.fact_numero
where P1.prod_codigo = 	'00000102'	
group by P1.prod_codigo,year(F.fact_fecha),month(F.fact_fecha)
order by 1 asc, 2

--18. Escriba una consulta que retorne una estadística de ventas para todos los rubros. La consulta debe retornar:
--DETALLE_RUBRO: Detalle del rubro
--VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
--PROD1: Código del producto más vendido de dicho rubro
--PROD2: Código del segundo producto más vendido de dicho rubro
--CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30 días
--La consulta no puede mostrar NULL en ninguna de sus columnas y 
--debe estar ordenada por cantidad de productos diferentes vendidos del rubro

select rubr_detalle, 
	isnull((select sum(item_precio*item_cantidad) 
		from [GD2015C1].[dbo].producto
		join [GD2015C1].[dbo].item_factura on item_producto=prod_codigo
		where prod_rubro=rubr_id
		group by prod_rubro),0) VENTAS,
	isnull((select top 1 P2.prod_codigo 
		from [GD2015C1].[dbo].producto P2 
		join [GD2015C1].[dbo].item_factura on item_producto=P2.prod_codigo
		where rubr_id = P2.prod_rubro
		group by  P2.prod_codigo, P2.prod_rubro
		order by sum(item_precio*item_cantidad) desc),0) PROD1,
	isnull((select top 1 P2.prod_codigo 
		from [GD2015C1].[dbo].producto P2 
		join [GD2015C1].[dbo].item_factura on item_producto=P2.prod_codigo
		where rubr_id = P2.prod_rubro and P2.prod_codigo <>
				(select top 1 P3.prod_codigo from [GD2015C1].[dbo].producto P3 
				join [GD2015C1].[dbo].item_factura I2 on I2.item_producto=P3.prod_codigo where rubr_id = P3.prod_rubro
				group by  P3.prod_codigo, P3.prod_rubro order by sum(I2.item_precio*I2.item_cantidad) desc)
		group by  P2.prod_codigo, P2.prod_rubro
		order by sum(item_precio*item_cantidad) desc),0) PROD2,
	isnull((select top 1 clie_codigo
		from [GD2015C1].[dbo].cliente
		join [GD2015C1].[dbo].factura on clie_codigo=fact_cliente
		join [GD2015C1].[dbo].item_factura on fact_tipo = item_tipo and fact_sucursal = item_sucursal and fact_numero = item_numero
		join [GD2015C1].[dbo].producto on item_producto = prod_codigo
		where prod_rubro = rubr_id
		group by clie_codigo
		order by sum(item_cantidad)),'') CLIENTE
from [GD2015C1].[dbo].rubro
order by (select count(distinct prod_codigo)
		from [GD2015C1].[dbo].producto
		join [GD2015C1].[dbo].item_factura on item_producto=prod_codigo
		where prod_rubro= rubr_id)
