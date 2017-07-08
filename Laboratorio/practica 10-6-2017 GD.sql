USE GD2015C1;
	GO

-- VOLVER LA BASE A LA NORMALIDAD

IF OBJECT_ID('EmpleadosInsertados','U') IS NOT NULL
BEGIN
   DROP TABLE EmpleadosInsertados;
END;

IF OBJECT_ID('EmpleadosEliminados','U') IS NOT NULL
BEGIN
   DROP TABLE EmpleadosEliminados;
END;

ALTER TABLE DEPOSITO DROP COLUMN baja_logica; -- deberia poder borrar pero no funca
GO

-- GENERAR CAMBIOS EN LA BASE

/* EJERCICO 1
Queremos que se guarde en una tabla EmpleadosInsertados (debe creaerse previamente) el historial de
inserciones de registros realizados en la tabla Empleado, ademas de los datos del empleado se debera gaurdar
en la tabla el usuario que realizo la insercion del empelado y la fecha/hora de la operacion.
Para hacerlo aplciaremos el trigger en el FOR INSERT */

CREATE TABLE EmpleadosInsertados (
	empl_codigo NUMERIC(6) IDENTITY PRIMARY KEY,
	usuario NVARCHAR(255) NOT NULL,
	fecha DATETIME NOT NULL
);
GO

CREATE TRIGGER tr_historialEmpleados 
	ON EMPLEADO
	AFTER INSERT
	AS
		BEGIN TRANSACTION
			INSERT INTO EmpleadosInsertados(empl_codigo, usuario, fecha)
				SELECT i.empl_codigo, SUSER_SNAME(), GETDATE() -- usuario del sql y horario de la maquina
					FROM inserted i
			COMMIT -- ojo en este caso como hay un commit no tengo que poner un end
GO

/* EJERCICIO 2
Queremos que no se puedan eliminar fisicamente los depositos, y en vez de eliminarlo, se den una baja
logica. Para ello debemos añadir a la tabla de deposito un campo baja que contendra un cero o un uno, no
podra contener ningun otro valor. En un prinicpio esta a cero, y cuando se intente borrar el deposito,
en verz de borrar el deposito se marcada este campo a 1 */

ALTER TABLE DEPOSITO ADD baja_logica BIT NOT NULL default 0;
GO

UPDATE DEPOSITO 
	SET baja_logica = 0 
	FROM DEPOSITO;
GO
			
CREATE TRIGGER tr_bajaLogicaStock
	ON DEPOSITO
	INSTEAD OF DELETE
	AS
		BEGIN TRANSACTION
			UPDATE DEPOSITO 
				SET d.baja_logica = 1
				FROM DEPOSITO d
					JOIN deleted del
						ON del.depo_codigo = d.depo_codigo
			COMMIT
GO

/* EJERCICIO 3
Eliminar fisicamente el registro de la tabla empleados pero guardar una copia del registro eliminado
en una tabla EmpleadosEliminados, guardando tambien en esa tabla la fecha de eliminacion. Para hacerlo
aplicaremos el trigger en el FOR DELETE */

CREATE TABLE EmpleadosEliminados (
	empl_codigo NUMERIC(6,0) IDENTITY PRIMARY KEY,
	empl_nombre CHAR(50),
	empl_apellido CHAR(50),
	empl_nacimiento DATETIME,
	empl_ingreso DATETIME,
	empl_tareas CHAR(100),
	empl_salario DECIMAL(12,2),
	empl_comision DECIMAL(12,2),
	empl_jefe NUMERIC(6,0),
	empl_departamento NUMERIC(6,0),
	fecha_eliminacion DATETIME NOT NULL
);
GO

CREATE TRIGGER tr_eliminacionEmpleado 
	ON EMPLEADO
	AFTER DELETE
	AS
		BEGIN TRANSACTION
			INSERT INTO EmpleadosEliminados(empl_codigo, fecha_eliminacion)
				SELECT d.empl_codigo,  GETDATE()
					FROM deleted d -- ojo al hacer un delete la tabla inserted no tiene nada...
			COMMIT
GO

