SELECT J.empl_codigo 'Código Jefe',
	   E.empl_codigo 'Código Empleado',
	   E.empl_nombre 'Nombre Empleado',
	   E.empl_apellido 'Apellido Empleado',
	   (SELECT COUNT(*) FROM DEPOSITO
		WHERE depo_encargado = J.empl_codigo) 'Depositos Encargado',
	   (SELECT COUNT(*) FROM DEPOSITO
		WHERE depo_encargado = E.empl_codigo) 'Depositos Empleado'
FROM Empleado J JOIN Empleado E ON J.empl_codigo = E.empl_jefe