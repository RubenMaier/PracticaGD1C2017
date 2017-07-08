SELECT  prod_codigo  'Código',
		prod_detalle 'Detalle Artículo',
		prod_familia 'Familia',
		fami_detalle 'Familia Detalle',
		(SELECT TOP 1 prod_familia FROM Producto
		 WHERE SUBSTRING(prod_detalle, 1, 5) = SUBSTRING(P.prod_detalle, 1, 5)
		 GROUP BY prod_familia
		 ORDER BY COUNT(*) DESC, prod_familia) 'Familia Sugerida',
		(SELECT fami_detalle FROM Familia
		 WHERE fami_id = (SELECT TOP 1 prod_familia FROM Producto
						  WHERE SUBSTRING(prod_detalle, 1, 5) = SUBSTRING(P.prod_detalle, 1, 5)
						  GROUP BY prod_familia
						  ORDER BY COUNT(*) DESC, prod_familia)) 'Detalle Familia Sugerida'
FROM Producto P JOIN Familia ON prod_familia = fami_id
WHERE  (SELECT TOP 1 prod_familia FROM Producto
		WHERE SUBSTRING(prod_detalle, 1, 5) = SUBSTRING(P.prod_detalle, 1, 5)
		GROUP BY prod_familia
		ORDER BY COUNT(*) DESC, prod_familia) != fami_id  -- SOLO DEJA LAS QUE LA SUGERIDA ES DISTINTA A LA ACTUAL
ORDER BY 2