SELECT fact_vendedor 'Código Empleado',
		(SELECT COUNT(DISTINCT depo_codigo) FROM DEPOSITO WHERE depo_encargado = fact_vendedor) 'Depositos a Cargo',
		SUM(ISNULL(fact_total, 0)) 'Monto total',
		(SELECT TOP 1 fact_cliente
		FROM Factura
		WHERE fact_vendedor = F.fact_vendedor AND YEAR(fact_fecha) = 2012
		GROUP BY fact_cliente
		ORDER BY SUM(ISNULL(fact_total, 0)) DESC) 'Cliente mas ventas',
		(SELECT TOP 1 item_producto
		FROM Factura JOIN Item_Factura
			ON fact_tipo + fact_sucursal + fact_numero = item_tipo + item_sucursal + item_numero
		WHERE fact_vendedor = F.fact_vendedor AND
			YEAR(fact_fecha) = 2012
		GROUP BY item_producto
		ORDER BY SUM(item_cantidad) DESC) 'Producto mas vendido',
		(SUM(ISNULL(fact_total, 0)) / 
			(SELECT SUM(ISNULL(fact_total, 0))
			FROM Factura
			WHERE YEAR(fact_fecha) = 2012)) * 100 'Porcentaje'
FROM Factura F
WHERE YEAR(fact_fecha) = 2012
GROUP BY fact_vendedor
ORDER BY 3 DESC