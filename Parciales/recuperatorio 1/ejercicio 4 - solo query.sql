-- MI CODIGO CHOTO
select c1.clie_codigo
from Cliente c1
	join Factura f1
		on f1.fact_cliente = c1.clie_codigo
	join Item_Factura
		on item_tipo = f1.fact_tipo
		and item_sucursal = f1.fact_sucursal
		and item_numero = f1.fact_numero	
where year(f1.fact_fecha) = 2012
group by c1.clie_codigo
having 
	(isnull(sum(item_precio*item_cantidad), 0) * 1.25) 
	>
	(
		select isnull(sum(item_cantidad*item_precio), 0)
		from Item_Factura
			join Factura f2
				on f2.fact_tipo = item_tipo
				and f2.fact_sucursal = item_sucursal
				and f2.fact_numero = item_numero
			join Cliente c2
				on c2.clie_codigo = f2.fact_cliente
				and c2.clie_codigo = c1.clie_codigo
		where year(f2.fact_fecha) = year(fact_fecha)-1
	)
order by 
	clie_codigo;

-- CODIGO MEDIO CHOTO DE SANTY Y NICO
select c.clie_codigo
from Factura 
join Item_Factura 
	on fact_numero = item_numero 
	and fact_sucursal = item_sucursal 
	and fact_tipo = item_tipo
join cliente c 
	on clie_codigo = fact_cliente
where 
	2012 = year(fact_fecha)
group by 
	clie_codigo
having 
	ISNULL(SUM(item_cantidad * item_precio),0) * 1.25 >
	(
		select 
			ISNULL(SUM(item_cantidad * item_precio), 0)
		from 
			Factura 
			join Item_Factura 
				on fact_numero = item_numero 
				and fact_sucursal = item_sucursal 
				and fact_tipo = item_tipo
			join cliente 
				on clie_codigo = fact_cliente
		where 
			2012 - 1 = year(fact_fecha) 
			and c.clie_codigo = clie_codigo 
	) 
order by 
	clie_codigo;

-- CODIGO PERFORMANTE DE SANTY
select 
	c.clie_codigo
from 
	Factura 
	join Item_Factura 
		on fact_numero = item_numero 
		and fact_sucursal = item_sucursal 
		and fact_tipo = item_tipo
	join cliente c 
		on clie_codigo = fact_cliente
group by 
	clie_codigo
having 
	ISNULL(SUM(CASE WHEN year(fact_fecha) = 2012 THEN item_cantidad * item_precio else 0 END ), 0) * 1.25 >
	ISNULL(SUM(CASE WHEN year(fact_fecha) = 2012-1 THEN item_cantidad * item_precio else 0 END ), 0)
order by 
	clie_codigo;