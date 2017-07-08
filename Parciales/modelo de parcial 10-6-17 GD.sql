/*
1) realice una consulta sql que retorne el deposito y los rubros de los productos que este posee. Por cada rubro ademas necesitamos saber cual es el producto mas exitoso (es decir, con mas ventas). En caso de obtener mas de 1 producto exitoso, devolver el string "Mas de un producto exitoso".
Con esta informacion el area de marketing establecera un plan de publicidad de los productos menos vendidos
*/

select Distinct depo_detalle,rubr_detalle,
CASE WHEN 
(
select COUNT(DISTINCT prod_codigo)
from  Producto
JOIN Rubro r2 on rubr_id = prod_rubro
JOIN Item_Factura on item_producto = prod_codigo
where r2.rubr_id = r.rubr_id and 
prod_codigo in (
select prod_codigo
 from Item_Factura
 join Producto on prod_codigo = item_producto
 join Rubro r3 on rubr_id = prod_rubro
 where r3.rubr_id = r.rubr_id
 group by prod_codigo
 having SUM(item_cantidad) = 
 ( select top 1 SUM(item_cantidad) from Item_Factura
 join Producto on prod_codigo = item_producto
 join Rubro on rubr_id = prod_rubro
 where rubr_id = r.rubr_id
 group by prod_codigo
 order by SUM(item_cantidad) desc ))) > 1 then 'Mas de un producto exitoso' else 
 (
 select TOP 1 prod_detalle
 from Producto join Rubro on rubr_id = prod_rubro
 JOIN Item_Factura on item_producto = prod_codigo
 where rubr_id = r.rubr_id
 group by prod_detalle
 order by SUM(item_cantidad) desc
 
 ) end

from DEPOSITO 
join STOCK on depo_codigo = stoc_deposito
JOIN Producto on prod_codigo = stoc_producto
JOIN Rubro r on rubr_id = prod_rubro
 group by depo_detalle,rubr_id,rubr_detalle
 order by rubr_detalle;
