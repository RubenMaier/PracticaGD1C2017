/* Ejercicio del parcial resuelto
Implemente el/los objetos necesarios para registrar en una tabla cuales son los clientes 
candidatos a obtener un descuento del 50% en su proxima compra.
Este beneficio se otorga año a año en funcion del volumen, en pesos, de las compras realizadas. 
Si el cliente realizo compras por un 25% mas comparado con el año pasado, entonces se deberá 
registrar como  candidato a obtener ese descuento.
*/

if OBJECT_ID('clientesConDescuento','U') IS NOT NULL 
	DROP TABLE clientesConDescuento
GO

CREATE TABLE clientesConDescuento
(
	clie_codigo char(6) PRIMARY KEY
)
GO

IF OBJECT_ID('actualizarClientesConDescuento','P') is not null
	DROP PROCEDURE actualizarClientesConDescuento
GO

CREATE PROCEDURE actualizarClientesConDescuento (@fecha AS DATETIME)
AS BEGIN

	truncate table clientesConDescuento

	-- declaro un cursor con lo que necesito almacenar en la tabla
	declare cursorConClientes cursor scroll
	for
		-- cargo la tabla con los clientes aptos para recibir el descuento en el cursor
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
			isnull(sum(CASE WHEN year(fact_fecha) = 2012 THEN item_cantidad * item_precio else 0 END), 0) * 1.25 >
			isnull(sum(CASE WHEN year(fact_fecha) = 2012-1 THEN item_cantidad * item_precio else 0 END), 0)
		order by 
			clie_codigo

	open cursorConClientes -- abro el cursor
	
	declare @clie_codigo char(6)
	fetch next from cursorConClientes -- le digo que valla al siguiente registro que se encuentre en el cursor (hago avanzar el puntero)
		into @clie_codigo

	while @@FETCH_STATUS = 0
	begin
		insert into clientesConDescuento 
			(clie_codigo)
		values 
			(@clie_codigo)

		fetch next from cursorConClientes -- le digo que valla al siguiente registro que se encuentre en el cursor (hago avanzar el puntero)
			into @clie_codigo
	end

	close cursorConClientes -- cierro el cursor
	deallocate cursorConClientes -- libero espacio  de memoria RAM
END
GO

EXEC actualizarClientesConDescuento 2012