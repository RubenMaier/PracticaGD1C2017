SELECT TOP 3 empl_codigo 'Código',
			 empl_nombre 'Nombre',
			 empl_apellido 'Apellido',
			 YEAR(empl_ingreso) 'Año Ingreso', 
			 CASE WHEN (SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2011) >= 50 THEN
				(SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2011 AND fact_total > 100)
			 ELSE CASE WHEN (SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2011) < 10 THEN
					(SELECT COUNT(*) * 0.5 FROM Factura
					 WHERE fact_vendedor IN (SELECT empl_codigo FROM Empleado WHERE empl_jefe = E.empl_codigo) AND YEAR(fact_fecha) = 2011)
				  END
			 END 'Puntaje 2011',
			 CASE WHEN (SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2012) >= 50 THEN
					(SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2012 AND fact_total > 100)
			 ELSE CASE WHEN (SELECT COUNT(*) FROM Factura WHERE empl_codigo = fact_vendedor AND YEAR(fact_fecha) = 2011) < 10 THEN
					(SELECT COUNT(*) * 0.5 FROM Factura 
					 WHERE fact_vendedor IN (SELECT empl_codigo FROM Empleado WHERE empl_jefe = E.empl_codigo) AND YEAR(fact_fecha) = 2012)
				  END
			 END 'Puntaje 2012'
FROM Empleado E
ORDER BY 6 DESC