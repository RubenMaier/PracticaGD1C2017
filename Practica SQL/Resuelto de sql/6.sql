SELECT  rubr_id 'Código de Rubro',
		rubr_detalle 'Detalle Rubro',
		COUNT(DISTINCT prod_codigo) 'Cantidad de Artículos del Rubro',
		SUM(stoc_cantidad) 'Stock Total'
FROM Rubro LEFT JOIN Producto ON rubr_id = prod_rubro JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY rubr_id, rubr_detalle
HAVING SUM(stoc_cantidad) >
	(SELECT stoc_cantidad FROM STOCK WHERE stoc_producto = '00000000' AND stoc_deposito = '00')
ORDER BY 1