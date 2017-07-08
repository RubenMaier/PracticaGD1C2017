--1. Hacer una función que dado un artículo y un deposito devuelva un string que indique el estado del depósito según el artículo. 
--Si la cantidad almacenada es menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de ocupación. 
--Si la cantidad almacenada es mayor o igual al límite retornar “DEPOSITO COMPLETO”.

create function ejer1 (@articulo varchar(8), @deposito varchar(2))
returns varchar(50)
as
begin 
declare @actual int;
declare @maximo int;
declare @mensaje varchar(50);

select @actual=stoc_cantidad from [GD2015C1].[dbo].stock where stoc_deposito=@deposito and stoc_producto=@articulo;
select @maximo=stoc_stock_maximo from [GD2015C1].[dbo].stock	where stoc_deposito=@deposito and stoc_producto=@articulo;
		
	if(@actual>=@maximo)
		select @mensaje='DEPOSITO COMPLETO';
	else 
		select @mensaje='OCUPACION DEL DEPOSITO ' +  CONVERT(varchar(10), @actual*100/@maximo) + '%';
return @mensaje;	
end
go

DECLARE @ret varchar(50);
EXEC @ret = ejer1 @articulo='00000030', @deposito='00';
select @ret;
go

--2. Realizar una función que dado un artículo y una fecha, retorne el stock que existía a esa fecha

create function ejer2 (@articulo int, @fecha date)
returns int
as
begin
declare @suma as int;

select @suma=sum(item_cantidad)
from Item_Factura
	join  Factura on item_tipo=fact_tipo and item_numero=fact_numero and item_sucursal=fact_sucursal
	 where item_producto = @articulo
			and fact_fecha < @fecha

return @suma;
end
go

DECLARE @ret int;
EXEC @ret = @rolNombreejer2 @articulo=00001415, @fecha='2012-01-16 00:00:00';
select @ret;
go

--3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en caso que sea necesario. 
--Se sabe que debería existir un único gerente general (debería ser el único empleado sin jefe). 
--Si detecta que hay más de un empleado sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por mayor salario. 
--Si hay más de uno se seleccionara el de mayor antigüedad en la empresa.
--Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla de un único empleado sin jefe (el gerente general) y 
--deberá retornar la cantidad de empleados que había sin jefe antes de la ejecución.

create procedure ejer3 
as
begin
	declare @gerente int;
	declare @cant_null int;
	-- empleado con salario mas alto y jefe null
	select @gerente = (select top 1 empl_codigo from Empleado where empl_jefe is null order by empl_salario desc, datediff(day, getdate(), empl_ingreso) desc);
	select @cant_null =(select count(empl_codigo) from Empleado where empl_jefe is null) - 1;
	-- START CURSOR
	declare @emp_codigo int, @emp_ingreso date, @emp_salario decimal, @emp_jefe int;
	declare empleado_cursor cursor
		for select empl_codigo, empl_ingreso, empl_salario, empl_jefe
		from Empleado
		where empl_codigo<>@gerente and (empl_jefe is null)
		for update of empl_jefe

	open empleado_cursor;

	fetch next from empleado_cursor
	into @emp_codigo, @emp_ingreso, @emp_salario, @emp_jefe;

	while @@FETCH_STATUS=0
	begin
	 -------------------------------------------------------------------------
		update Empleado set empl_jefe=@gerente where current of empleado_cursor;

	 -------------------------------------------------------------------------
	 fetch next from empleado_cursor
		into @emp_codigo, @emp_ingreso, @emp_salario, @emp_jefe; 
	end

	close empleado_cursor;
	deallocate empleado_cursor;
	-- END CURSOR
	
	select @cant_null;
end
go

EXEC @rolNombreejer3
go

--4. Cree el/los objetos de base de datos necesarios para actualizar la columna de empleado empl_comision 
--con la sumatoria del total de lo vendido por ese empleado a lo largo del último año. 
--Se deberá retornar el código del vendedor que más vendió (en monto) a lo largo del último año.

create procedure ejer4
as
begin
	declare @max_vendedor_codigo int;
	declare @max_vendedor_monto int;
	select @max_vendedor_monto=0;
	-- START CURSOR
	declare @emp_codigo int, @emp_comision int;
	declare empleado_cursor cursor
		for select empl_codigo, empl_comision
		from Empleado		
		for update of empl_comision

	open empleado_cursor;

	fetch next from empleado_cursor
	into @emp_codigo, @emp_comision;

	while @@FETCH_STATUS=0
	begin
	 -------------------------------------------------------------------------
		 declare @monto_emp int;
		 
		 select  @monto_emp=sum(item_cantidad*item_precio) 
		 from item_factura 
			join factura on item_tipo=fact_tipo and item_sucursal=fact_sucursal and item_numero=fact_numero
			where fact_vendedor=@emp_codigo;
		
		 if @monto_emp>@max_vendedor_monto
		 begin
			select @max_vendedor_monto=@monto_emp;
			select @max_vendedor_codigo=@emp_codigo;
		 end 		 
		 
		 update Empleado set empl_comision=@monto_emp where current of empleado_cursor;

	 -------------------------------------------------------------------------
	 fetch next from empleado_cursor
		into @emp_codigo, @emp_comision;
	end

	close empleado_cursor;
	deallocate empleado_cursor;
	-- END CURSOR
	
	select @max_vendedor_codigo;
end
go

EXEC @rolNombreejer4
go

--5. Realizar un procedimiento que complete con los datos existentes en el modelo provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
--Create table Fact_table
--(
--anio char(4) not null,
--mes char(2) not null,
--familia char(3) not null,
--rubro char(4) not null,
--zona char(3) not null,
--cliente char(6) not null,
--producto char(8) not null,
--cantidad decimal(12,2),
--monto decimal(12,2)
--)
--Alter table Fact_table Add primary key(anio,mes,familia,rubro,zona,cliente,producto)


create procedure ejer5
as

begin transaction
insert into Fact_table
select year(fact_fecha), month(fact_fecha), prod_familia, prod_rubro, isnull(depo_zona, 'nul'), fact_cliente, item_producto, sum(item_cantidad), sum(item_precio)
	from Item_Factura 
	join Factura on item_tipo=fact_tipo and item_numero=fact_numero and item_sucursal=fact_sucursal
	join Producto on item_producto=prod_codigo
	join Stock on prod_codigo=stoc_producto
	join Deposito on stoc_deposito=depo_codigo
group by year(fact_fecha), month(fact_fecha), prod_familia, prod_rubro, depo_zona, fact_cliente, item_producto	


commit
	
EXEC @rolNombreejer5
go

--TERMINAR--6. Realizar un procedimiento que si en alguna factura se facturaron componentes que conforman un combo determinado 
--(o sea que juntos componen otro producto de mayor nivel), 
--en cuyo caso deberá reemplazar las filas correspondientes a dichos productos por una sola fila 
--con el producto que componen con la cantidad de dicho producto que corresponda.

-- hacer una función que me retorne un posible combo y ahi actualizar, borro las filas e inserto 
-- la nueva de combo. 
-- en el select de la funcion tengo que joinear item_factura con composicion tomando en cuenta las cantidades para
-- ver si me alcanza para un combo.


declare @tipo as char(1);
declare @sucursal as char(4);
declare @numero as char(8);
declare @producto as char(8);
declare @index as int;
select @index=count(*)
	from Item_Factura
	join Composicion C1 on item_producto=C1.comp_componente
	and item_cantidad >= C1.comp_cantidad and item_numero=99999999
	group by item_tipo, item_sucursal, item_numero, C1.comp_producto
	having count(*) = (select count(*) from Composicion C2
						where C2.comp_producto=C1.comp_producto);

WHILE (@index!=0)  
BEGIN  
	
	select @tipo=item_tipo, @sucursal=item_sucursal, @numero=item_numero, @producto=C1.comp_producto
	from Item_Factura
	join Composicion C1 on item_producto=C1.comp_componente
	and item_cantidad >= C1.comp_cantidad --and item_numero=99999999
	group by item_tipo, item_sucursal, item_numero, C1.comp_producto
	having count(*) = (select count(*) from Composicion C2
						where C2.comp_producto=C1.comp_producto);						
	
	declare @comp_producto as char(8);
	declare comp_cursor cursor
		for select comp_componente from Composicion

	open comp_cursor;

	fetch next from comp_cursor
	into @comp_producto;

	while @@FETCH_STATUS=0
	begin
	 ---------------------------------------
		delete Item_Factura where item_tipo=@tipo and item_sucursal=@sucursal and item_numero=@numero and item_producto=@comp_producto;		
	 ---------------------------------------
	 fetch next from comp_cursor
		into @comp_producto;
	end

	close comp_cursor;
	deallocate comp_cursor;
	
	insert into Item_Factura values (@tipo, @sucursal, @numero, @producto, 1, (select prod_precio from Producto where prod_codigo=@producto));
	set @index	= @index -1;
END  

--TERMINAR--7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. 
--Debe insertar una línea por cada artículo con los movimientos de stock realizados entre esas fechas.
--Código del articulo
--Detalle del articulo
--cant mov=Cantidad de movimientos de ventas (Item factura)
--Precio de venta=Precio promedio de venta
--renglón=Nro. de línea de la tabla
--ganancia=Precio de Venta – Cantidad * Costo Actual

select ROW_NUMBER() OVER (ORDER BY prod_codigo) AS Row,
	prod_codigo, 
	prod_detalle, 
	count(*), 
	avg(item_cantidad*item_precio),
	(prod_precio - item_precio)*item_cantidad
from Producto
join Item_factura on prod_codigo=item_producto
group by prod_codigo, prod_detalle, prod_precio, item_precio,item_cantidad

--HACER--8
--8. Realizar un procedimiento que complete la tabla Diferencias de precios, 
--para los productos facturados que tengan composición y 
--en los cuales el precio de facturación sea diferente al precio del cálculo de los precios unitarios por cantidad de sus componentes, 
--se aclara que un producto que compone a otro, también puede estar compuesto por otros y así sucesivamente, 
--la tabla se debe crear y está formada por las siguientes columnas:

--9. Hacer un trigger que ante alguna modificación de un ítem de factura de un artículo <<con composición>> 
--realice el movimiento de sus correspondientes componentes.
use GD2015C1;
go
alter trigger tr_ejer9 on Item_factura
For update
as
Begin tran
-----------------------------------------------------

declare @item_codigo as char(8);
declare @item_cantidad as decimal;

declare item_cursor cursor for
	select item_producto, item_cantidad from inserted 

open item_cursor;

fetch next from item_cursor
into @item_codigo, @item_cantidad;

while @@FETCH_STATUS = 0
begin
	-------------------------------------------------------	
	declare @cant_deleted as decimal;
	select @cant_deleted=D.item_cantidad from deleted D where D.item_producto=@item_codigo;
	declare @deposito as char(2);
	
		-- tomo el depósito que menos tiene ---
		select top 1 @deposito=S2.stoc_deposito from Stock S2 where S2.stoc_producto = @item_codigo order by S2.stoc_cantidad desc;				
		-- actualizo el producto padre sea o no compuesto
		update Stock set stoc_cantidad= (stoc_cantidad + @cant_deleted - @item_cantidad)  
			where stoc_producto=@item_codigo and stoc_deposito = @deposito;

		-- actualizo si es compuesto, si no es compuesto el cursos no hace nada
		declare @comp_producto as char(8), @comp_comp as char(8), @comp_cantidad as decimal(12,2);
		declare comp_cursor cursor for
			select comp_producto, comp_componente, comp_cantidad from Composicion where comp_producto=@item_codigo;

		open comp_cursor;

		fetch next from comp_cursor
		into @comp_producto, @comp_comp, @comp_cantidad;

		while @@FETCH_STATUS = 0
		begin
			-----------------------------				
			-- actualizo
			update Stock set stoc_cantidad= (stoc_cantidad + @cant_deleted*@comp_cantidad - @item_cantidad*@comp_cantidad)  
			where stoc_producto=@comp_comp and stoc_deposito = @deposito;											
			---------------------------------
			fetch next from comp_cursor
			into @comp_producto, @comp_comp, @comp_cantidad;
		end
		close comp_cursor;
		deallocate comp_cursor;

	-------------------------------------------------------
	fetch next from item_cursor
	into @item_codigo, @item_cantidad;
end
close item_cursor;
deallocate item_cursor;

-----------------------------------------------------
commit

--10. Hacer un trigger que ante el intento de borrar un artículo verifique que no exista stock y 
--si es así lo borre en caso contrario que emita un mensaje de error.
use GD2015C1;
go
create trigger tr_ejer10 on Producto
instead of delete
as
Begin tran
		declare @prod_codigo as char(8);
		declare prod_cursor cursor for
			select prod_codigo from deleted;

		open prod_cursor;

		fetch next from prod_cursor
		into @prod_codigo;

		while @@FETCH_STATUS = 0
		begin
			-----------------------------				
			if exists (select * from stock where stoc_producto=@prod_codigo)
			begin
				select 'El producto no se puede borrar ya que posee stock';
			end
			else
			begin
				delete Producto where prod_codigo=@prod_codigo;
			end
			-----------------------------
			fetch next from prod_cursor
			into @prod_codigo;
		end
		close prod_cursor;
		deallocate prod_cursor;
Commit

--11. TERMINAR -- Cree el/los objetos de base de datos necesarios para que dado un código de empleado se retorne 
--la cantidad de empleados que este tiene a su cargo (directa o indirectamente). 
--Solo contar aquellos empleados (directos o indirectos) <<que sean errores>> que su jefe directo.

use GD2015C1;
go
alter function ObtenerCantEmpleadosDe(@jefe numeric(6))
returns int 
as
begin
	declare @cantEmpl as int;
	select @cantEmpl=isnull(count(*),0) from Empleado where empl_jefe=@jefe;
	if @cantEmpl = 0
	begin
		return 0;
	end
		
	declare @emp_codigo int;
	declare empleado_cursor cursor
		for select empl_codigo from Empleado where empl_jefe=@jefe;

	open empleado_cursor;

	fetch next from empleado_cursor
	into @emp_codigo;

	while @@FETCH_STATUS=0
	begin
	 ---------------------------------------
		set @cantEmpl = @cantEmpl + ObtenerCantEmpleadosDe(@emp_codigo);
	 ---------------------------------------
	 fetch next from empleado_cursor
		into @emp_codigo;
	end

	close empleado_cursor;
	deallocate empleado_cursor;
	
	return @cantEmpl;
end

--select ObtenerCantEmpleadosDe(1)

--12. TERMINAR -- Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
--“Ningún jefe puede tener a su cargo más de 50 empleados en total (directos + indirectos)”. 
--Se sabe que en la actualidad dicha regla se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y tecnologías.

--TRIGGER FOR INSTEAD OF A TABLA EMPLEADOS (en vez de insertar directamente, chequeo la regla y luego inserto)


use GD2015C1;
go
alter trigger tr_ejer12 on Empleado
INSTEAD OF insert, update
as
Begin tran

declare @empl_codigo as numeric(6);
select top 1 @empl_codigo=empl_codigo from INSERTED;

update Empleado set empl_nombre=(empl_nombre + '1')

commit

--13. HACER Cree el/los objetos de base de datos necesarios para que nunca un producto pueda ser compuesto por sí mismo. 
--Se sabe que en la actualidad dicha regla se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y tecnologías.
--No se conoce la cantidad de niveles de composición existentes.

-- trigger insted of sobre composicion, si comp_producto = comp_componente tirar error


--14. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
--“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de sus empleados totales (directos + indirectos)”. 
--Se sabe que en la actualidad dicha regla se cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos y tecnologías

use GD2015C1;
go
create trigger tr_ejer14 on Empleado
instead of update --insert no porq si estuviese insertando no tendría aún ningún empleado asignado
as
Begin tran
		declare @empl_codigo as char(6);
		declare @empl_jefe as char(6);
		declare @empl_salario as decimal(12,2);
		declare @salario_max as decimal(12,2);
		
		declare empl_cursor cursor for
			select empl_codigo, empl_jefe, empl_salario from inserted

		open empl_cursor;

		fetch next from empl_cursor
		into @empl_codigo, @empl_jefe, @empl_salario;
		
		while @@FETCH_STATUS = 0
		begin
			-----------------------------				
			--calculo 20% salario emplados -- VER LO DE DIRECTOS E INDIRECTOS
			select @salario_max=(sum(E2.empl_salario)*20/100) from Empleado E2 where E2.empl_jefe=@empl_codigo;
			if @empl_salario>@salario_max
			begin
				select 'No se puede actualizar el salario del Jefe ' + @empl_codigo + ' porque supera el 20% de sus empleados.'
			end
			else			
			begin
				update Empleado set empl_salario=@empl_salario where empl_codigo=@empl_codigo;
			end			
			-----------------------------
			fetch next from empl_cursor
			into @empl_codigo, @empl_jefe, @empl_salario;			
		end
		close empl_cursor;
		deallocate empl_cursor;
Commit