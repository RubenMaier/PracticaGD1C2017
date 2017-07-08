SELECT  rubr_id 'Código de Rubro',
		rubr_detalle 'Detalle Rubro',
		COUNT(DISTINCT prod_codigo) 'Cantidad de Artículos del Rubro',
		SUM(stoc_cantidad) 'Stock Total'
FROM Rubro
	LEFT JOIN Producto 
		ON prod_rubro = rubr_id
	JOIN STOCK
		ON prod_codigo = stoc_producto
WHERE
	  (SELECT SUM(stoc_cantidad)
	  FROM STOCK
	  WHERE stoc_producto = prod_codigo)
	  >
	  (SELECT stoc_cantidad
	  FROM STOCK
	  WHERE stoc_producto = '00000000'
		AND stoc_deposito = '00')
GROUP BY rubr_id, rubr_detalle
ORDER BY 1