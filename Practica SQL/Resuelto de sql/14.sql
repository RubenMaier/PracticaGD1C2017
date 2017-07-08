SELECT fact_cliente	'C�digo Cliente',
	   COUNT(DISTINCT fact_tipo + fact_sucursal + fact_numero) 'Compras ultimo a�o',
	   AVG(fact_total) 'Promedio por Compra',
	   COUNT(DISTINCT item_producto) 'Cantidad de Art�culos Diferentes',
	   MAX(fact_total) 'Compra M�xima'
FROM Factura JOIN Item_Factura
		ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero			
WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
GROUP BY fact_cliente
ORDER BY 2 DESC