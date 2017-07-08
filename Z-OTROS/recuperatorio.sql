use GD2015C1
go

/* --- EJERCICIO 1 ---
Una desventaja es que necesita de estructuras adicionales lo que ocupa mas espacio, ademas estas tienen que ser mantenidas
por lo que tambien ocupa procesamiento a medida que se generan operaciones que modifiquen alguna fila de dicha tabla

*/

/* --- EJERCICIO 2 ---
Un esenario donde sería util aplicar una vista es en aquellos donde se quiere suministrar un nivel adicional
de seguridad restringiendo el acceso a un cojunto predterminado de filas o columnas de una tabla

Por ejemplo cuando un administrador de bases de datos interactua con un programador que necesita ciertos requisitos,
lo recomendable seria que este administrador cree una vista para que el programador solo interactue con lo que necesita,
y así mantener una capa de seguridad extra

*/



/* --- EJERCICIO 4 ---

considero que con "en pesos" se refiere a monto total facturado en el año para ese cliente

*/


CREATE TABLE clientes_candidatos_a_descuento(
	clie_codigo CHAR(6) PRIMARY KEY
);
GO

CREATE FUNCTION compro_mas_que_anio_anterior (@cliente CHAR(6), @fecha1 DATETIME) RETURNS BIT
BEGIN

	DECLARE @respuesta BIT
	DECLARE @volumenAnio DECIMAL(12,2)
	DECLARE @volumenAnioAnterior DECIMAL(12,2)

	SET @volumenAnio = (
						SELECT SUM(fact_total) 
							FROM Factura 
							WHERE fact_cliente = @cliente 
								AND YEAR(fact_fecha) = YEAR(@fecha1)
						)

	SET @volumenAnioAnterior = (
								SELECT SUM(fact_total) 
									FROM Factura 
									WHERE fact_cliente = @cliente 
										AND YEAR(fact_fecha) = (YEAR(@fecha1)-1)
							)

	DECLARE @25porcientoDelVolumenAnterior DECIMAL(12,2)

	SET @25porcientoDelVolumenAnterior = ((25*@volumenAnioAnterior)/100)
	
	IF (@volumenAnio > (@volumenAnioAnterior + @25porcientoDelVolumenAnterior))
		SET @respuesta = 1
	ELSE
		SET @respuesta = 0
	
	RETURN @respuesta
END
GO


CREATE PROC actualizar_clientes_con_descuento_del_anio
AS
BEGIN


	SELECT c.clie_codigo, YEAR(f.fact_fecha)
		FROM Cliente c
			JOIN Factura f
				ON f.fact_cliente = c.clie_codigo
		GROUP BY c.clie_codigo, YEAR(f.fact_fecha)
		ORDER BY c.clie_codigo, YEAR(f.fact_fecha)

		CREATE CURSOR
END
GO

	