SELECT prod_codigo 'Código',
		prod_detalle 'Detalle',
		MAX(item_precio) 'Mayor Precio',
		MIN(item_precio) 'Menor Precio',
		((MAX(item_precio) - MIN(item_precio))*100/MIN(item_precio)) 'Dif. Porcentual'
FROM Producto JOIN Stock ON prod_codigo = stoc_producto JOIN Item_Factura ON item_producto = prod_codigo
WHERE stoc_cantidad > 0
GROUP BY prod_codigo, prod_detalle