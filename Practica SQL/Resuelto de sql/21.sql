SELECT YEAR(fact_fecha) 'Año',
		COUNT(DISTINCT fact_cliente) 'Clientes mal facturados',
		COUNT(DISTINCT fact_tipo + fact_sucursal + fact_numero) 'Facturas mal realizadas'
FROM Factura
WHERE ((fact_total - fact_total_impuestos) -
		(SELECT SUM(item_cantidad * item_precio) FROM Item_Factura
		WHERE item_tipo + item_sucursal + item_numero = fact_tipo + fact_sucursal + fact_numero)) > 1
GROUP BY YEAR(fact_fecha)