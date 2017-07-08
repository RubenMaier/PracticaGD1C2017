SELECT  P1.prod_codigo 'Código Producto 1',
		P1.prod_detalle 'Detalle Producto 1',
		P2.prod_codigo 'Código Producto 2',
		P2.prod_detalle 'Detalle Producto 2',
		COUNT(*) 'Cantidad de veces'
FROM Producto P1 JOIN Item_Factura I1 ON P1.prod_codigo = I1.item_producto,
	 Producto P2 JOIN Item_Factura I2 ON P2.prod_codigo = I2.item_producto
WHERE I1.item_tipo + I1.item_sucursal + I1.item_numero = I2.item_tipo + I2.item_sucursal + I2.item_numero
	AND I1.item_producto < I2.item_producto
GROUP BY P1.prod_codigo, P1.prod_detalle, P2.prod_codigo, P2.prod_detalle
HAVING COUNT(*) > 500
ORDER BY 5 DESC