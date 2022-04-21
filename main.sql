ALTER SESSION SET "_ORACLE_SCRIPT" = true;

SET SERVEROUTPUT ON

---------------------------------------------------------------
-- 1)   GESTIÓN DE USUARIOS Y TABLAS --------------------------
---------------------------------------------------------------
CREATE USER ILERNA_PAC IDENTIFIED BY 1234; --Creamos el usuario ILERNA_PAC con contraseña 1234

GRANT ALL PRIVILEGES TO ILERNA_PAC; --Le asignamos todos los privilegios 

-- 1. Usuario "GESTOR"

alter session set "_ORACLE_SCRIPT"=true; 
CREATE USER GESTOR IDENTIFIED BY 1234; --creamos el usuario gestor y le asigamos una PASSWORD_GRACE_TIME
GRANT CREATE SESSION to GESTOR; --Permiso de conexión
GRANT  ALTER, UPDATE on ILERNA_PAC.alumnos_pac  to GESTOR; --Le damos los permisos solicituados con ALTER y UPDATE
GRANT ALTER, UPDATE on ILERNA_PAC.asignaturas_pac  to GESTOR;  --Le damos los permisos solicituados con ALTER y UPDATE
ALTER TABLE ILERNA_PAC.alumnos_pac add CIUDAD VARCHAR(30); --añadimos una tabla con alter table y de nombre ciudad del tipo varchar de 30 caracteres
ALTER TABLE ILERNA_PAC.asignaturas_pac MODIFY NOMBRE_PROFESOR VARCHAR(50); --Modificamos el campo profesor con MODIFY, su máximo ahora serán 50 caracteres
ALTER TABLE ILERNA_PAC.asignaturas_pac DROP COLUMN creditos; --Eliminamos la columna con DROP COLUMN
ALTER TABLE ILERNA_PAC.asignaturas_pac ADD CICLO VARCHAR (3); --Añadimos el campo con ADD
-- 2. Usuario "DIRECTOR"

alter session set "_ORACLE_SCRIPT"=true;
CREATE ROLE ROL_DIRECTOR; --Creamos el rol director
CREATE USER DIRECTOR IDENTIFIED BY 1234; --Creamos el usuario director con su clave
GRANT CREATE SESSION TO ROL_DIRECTOR; --Le asignamos el privilegio de poder conectarse
GRANT UPDATE, SELECT, INSERT on ILERNA_PAC.alumnos_pac to ROL_DIRECTOR; --Le asignamos privilegios al rol con la tabla alumnos
GRANT UPDATE, SELECT, INSERT on ILERNA_PAC.asignaturas_pac to ROL_DIRECTOR;--Le asignamos privilegios al rol con la tabla asignaturas_pac
GRANT ROL_DIRECTOR TO DIRECTOR; -- LE asignamos el rol al director para que consiga todos los privilegios asignados al rol
INSERT INTO ILERNA_PAC.ALUMNOS_PAC (id_alumno, nombre, apellidos, edad) VALUES ('DADEVE', 'Daniel', 'Deniz Vega', 20) --Insertamos los datos en la tabla con INSERT INTO
INSERT INTO ILERNA_PAC.asignaturas_pac (Id_asignatura, nombre_asignatura, nombre_profesor, ciclo) VALUES ('DAX_M02B', 'MP2.Bases de datos B', 'Guillem Mauri Jiménez', 'DAX'); --Insertamos los datos en la tabla con INSERT INTO
UPDATE ILERNA_PAC.asignaturas_pac set ciclo='DAW'; --Utilizamos UPDATE par actualizar el registro y set más el campo a actualizar con su nuevo valor

---------------------------------------------------------------
-- 2)	BLOQUES ANONIMOS -------------------------------------- 
---------------------------------------------------------------

--  %IRPF SALARIO BRUTO ANUAL

alter session set "_ORACLE_SCRIPT"=true; 
SET SERVEROUTPUT ON size 1000000; --Para mostrar en consola

DECLARE --Declaración de objetos

salario_mes CONSTANT NUMBER (10,2) := 1200; --Creamos la constante para almacenar el salario mensual
salario_anual CONSTANT NUMBER (10,2) := salario_mes*12; -- Creamos la constante de salario anual, será salario mensual por los meses del año
irpf_aplicado NUMBER(10,2); --Creamos la variable que almacenará el porcentaje de irpf que se aplicará
BEGIN -- Aqui dentro irá la parte ejecutable de nuestro código
 DBMS_OUTPUT.put_line ('el salario mensual es: ' ||salario_mes); --Mostramos por consola nuestra variable salario_mes con DBMS_OUTPUT.put_line y concatenando con ||
 DBMS_OUTPUT.put_line ('el salario anual es: ' ||salario_anual); --Mostramos por consola nuestra variable salario_anual con DBMS_OUTPUT.put_line y concatenando con ||
 SELECT PORCENTAJE INTO irpf_aplicado --Vamos a buscar el porcentaje de irpf adecuado para nuestro salario_anual, el valor de la columna porcentaje irá dentro de la variable irpf_aplicado
 FROM irpf_pac --seleccionamos la table
 WHERE valor_bajo <= salario_anual AND valor_alto >= salario_anual; --Le decimos que escogeremos el valor donde valor_bajo sea menor que salario_anual y donde valor_alto sea mayor que salario_anual, usaremos el operador AND para esto
 DBMS_OUTPUT.put_line ('el IRPF aplicado es: ' ||irpf_aplicado*100 || '%'); --Mostramos por consola el nuevo valor de irpf_aplicado, multiplicado por 100 para que pase de 0,24 a 24 y le concatenamos "%"
DBMS_OUTPUT.put_line ('el IRPF a pagar es: ' ||salario_anual*irpf_aplicado*100/100); --Mostramos por consola el irpf a pagar que sería el 24% de 14400, para ello usé el cálculo de salario_anual*irpf_aplicado*100/100
END; -- Indica el fin de nuestra sentencia en la consola de comandos

/


---------------------------------------------------------------
-- 3)	PROCEDIMIENTOS Y FUNCIONES SIMPLES -------------------- 
---------------------------------------------------------------

--  NUMERO MAYOR
alter session set "_ORACLE_SCRIPT"=true; 
SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE FUNCTION NUMERO_MAYOR(num1 number, num2 number, num3 number) --Creamos la función con los 3 párametros a introducir por el usuario
RETURN VARCHAR2 IS --Retornará lo siguiente
resultado NUMBER; --Retornará esta variable
error_iguales EXCEPTION;
BEGIN --Comienza el código ejecutable de la función

if num1=num2 OR num1=num2 OR num2=num3 THEN --si coincide algún numero 
RAISE error_iguales; --Se detendrá la ejecución y se la pasará a esta excepción
END IF;
if num1 > num2 AND num1>num3 THEN --si numero 1 es el mayor, resultado será igual a numero 1
resultado:= num1;
END IF;

if num2 > num1 AND num2>num3 THEN --si numero 2 es el mayor, resultado será igual a numero 2
resultado:= num2;
END IF;

if num3 > num1 AND num3>num2 THEN --si numero 3 es el mayor, resultado será igual a numero 3
resultado:= num3;
END IF;




return TO_NUMBER(resultado); --La función devolverá el valor de resultado, usamos TO_NUMBER para pasar el numero a NUMBER ya que al principio elegimos que nuestra función retornara un tipo VARCHAR2
EXCEPTION

WHEN error_iguales THEN --Bloque de excepción
return 'No se pueden repetir números en la secuencia'; --Retornará este texto
END numero_mayor; --Fin de la función
/


---------------------------------------------------------------
-- 4)	PROCEDIMIENTOS Y FUNCIONES COMPLEJAS ------------------ 
---------------------------------------------------------------

--  NUMERO DE EMPLEADOS POR TRAMO DE IRPF

ALTER SESSION SET "_ORACLE_SCRIPT" = true;
SET VERIFY OFF;
SET SERVEROUTPUT ON;
 CREATE OR REPLACE FUNCTION EMPLEADOS_TRAMOS_IRPF (tramo number) --Creamos la función que se nos pide con un argumento que será el número de tramo a introducir
RETURN NUMBER IS
total_empleados NUMBER; --retornará el total de empleados
CURSOR mi_cursor IS  --Creamos un cursor para ejecutar la sentencia sql que recorrerá las tablas
SELECT  salario --Selecciona la columna salario de empleados_pac
FROM empleados_pac;
registro mi_cursor%ROWTYPE; --Creo la variable registro del tipo mi_cursor
minimo_irpf NUMBER:= 0; --Variables para el funcionamiento de mi programa
maximo_irpf NUMBER:=0;
contador NUMBER :=0; 

BEGIN  
SELECT VALOR_BAJO into minimo_irpf --Introducimos en la variable minimo_irpf el valor de la columna VALOR_BAJO donde la columna TRAMO_IRPF sea igual a tramo(numero introducido por el usuario)
FROM IRPF_PAC
WHERE TRAMO_IRPF= tramo ;

SELECT VALOR_ALTO into maximo_irpf --Lo mismo pero con el VALOR_ALTO
FROM IRPF_PAC
WHERE TRAMO_IRPF= tramo;

OPEN mi_cursor; --Abrimos el cursor
FETCH mi_cursor INTO registro; --Esta sentencia coloca el cursor en la siguiente fila y lo guarda en nuestra variable registro
WHILE mi_cursor%FOUND --mientras nuestro cursor tenga filas se ejecutrá el código dentro del bucle
LOOP      
if registro.salario >= minimo_irpf AND registro.salario <= maximo_irpf THEN --Pequeño algoritmo, que lo que hace es que va acumulando en la variable contador si el salario de esa fila se encuentra entre los tramos irpf

contador:= contador + 1;

END IF;
FETCH mi_cursor INTO registro; --Pasa a la siguiente fila
END LOOP;  
CLOSE mi_cursor; --Cerramos cursor al salir del bucle
total_empleados:= contador; --Nuestra variable total_empleados tomará el valor de contador, que se ha ido acumulando en base a cada empleado que se encontraba en el tramo introducido
return (total_empleados); --La función retornará el valor de total_empleados
END EMPLEADOS_TRAMOS_IRPF; --Fin de la función
/

---------------------------------------------------------------
-- 5)	GESTIÓN DE TRIGGERS ----------------------------------- 
---------------------------------------------------------------


--  COMPENSACIÓN SALARIO POR CAMBIO TRAMO
ALTER SESSION SET "_ORACLE_SCRIPT" = true;
SET VERIFY OFF;
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER COMPENSA_TRAMO_IRPF --Creamos el trigger pedido en el enunciado
BEFORE UPDATE OF SALARIO ON EMPLEADOS_PAC --Le decimos que este trigger se disparará antes de que alguien haga un UPDATE de la columna salario en empleados_pac
FOR EACH ROW -- indicamos que el trigger se disparará por cada fila de la tabla sobre la cual se lleva a cabo  la operación SQL

DECLARE
minimo_irpf NUMBER:=0; --Declaramos las variables que usaré en el trigger
maximo_irpf NUMBER:=0;
tramo_old NUMBER:=0;
tramo_new NUMBER:= 0;
BEGIN
SELECT TRAMO_IRPF into tramo_old --Le digo que guarde el tramo_irpf en mi variable tramo_old, donde coincida que el antiguo salario era mayor que valor_bajo y menor que valor_alto, para así guardar en que tramo irpf se encontraba
FROM IRPF_PAC
WHERE VALOR_BAJO <= :old.SALARIO AND VALOR_ALTO >= :old.SALARIO;

SELECT TRAMO_IRPF into tramo_new  --Le digo que guarde el tramo_irpf en mi variable tramo_new, donde coincida que el nuevp salario es mayor que valor_bajo y menor que valor_alto, para así guardar en que tramo irpf se encuentra este nuevo salario
FROM IRPF_PAC
WHERE VALOR_BAJO <= :new.SALARIO AND VALOR_ALTO >= :new.SALARIO;

if tramo_new > tramo_old THEN --Condicional para saber si al cambiar el salario, este ha hecho que el nuevo salario suba de tramo, en ese caso el nuevo salario sumará 1000 euros como indica el enunciado
:new.SALARIO:= :new.SALARIO + 1000;
--dbms_output.put_line('se ha aumentado el salario en 1000 euros por cambio de tramo, nuevo salario: ' || :new.SALARIO);

END IF;

END;

/
---------------------------------------------------------------
-- 6)   BLOQUES ANÓNIMOS PARA PRUEBAS DE CÓDIGO --------------- 
---------------------------------------------------------------

-- 1.	COMPROBACIÓN REGISTROS DE TABLAS
/
EXECUTE dbms_output.put_line('-- 1.	COMPROBACIÓN REGISTROS DE TABLAS');
SELECT * FROM alumnos_pac;--Con un select * FROM sacamos todos los registros de las tablas
SELECT * FROM asignaturas_pac;

-- 2.	COMPROBACIÓN DE LA FUNCION “NUMERO_MAYOR”
/
EXECUTE dbms_output.put_line('-- 2.	COMPROBACIÓN DE LA FUNCION “NUMERO_MAYOR”');
DECLARE
numero1 NUMBER := 23; --Declaramos las variables que almacenarán los números para pasar a la función
numero2 NUMBER := 37;
numero3 NUMBER := 32;
BEGIN
dbms_output.put_line('El numero mayor entre (' || numero1 || ','|| numero2|| ',' ||numero3 || ') es: '|| numero_mayor(numero1,numero2,numero3)); --llamamos a la función y mostramos por consola su valor
END;
-- 3.	COMPROBACIÓN DE LA FUNCION “EMPLEADOS_TRAMOS_IRPF”
/
EXECUTE dbms_output.put_line('-- 3.	COMPROBACIÓN DE LA FUNCION “EMPLEADOS_TRAMOS_IRPF”');

DECLARE --Nuevo bloque donde llamaremos a la función y haremos introducir por consola el numero de tramo al usuario
tramo_parametro NUMBER := 5;

BEGIN 
dbms_output.put_line('en el tramo '||tramo_parametro || ' de IRP, tenemos a '|| EMPLEADOS_TRAMOS_IRPF( tramo_parametro) ||' empleados'); --Mostramos por consola el retorno de nuestra función luego de llamarla y pasarle como parámetro el tramo indicado, en este caso 5
END;
/

-- 4.	COMPROBACIÓN DE LOS TRIGGERS
/
EXECUTE dbms_output.put_line('-- 4.	COMPROBACIÓN DE LOS TRIGGERS');
ALTER SESSION SET  "_ORACLE_SCRIPT" = true;
ALTER SESSION SET nls_date_format = 'dd-mm-yyyy hh24:mi'; --modificamos el formato para que aparezca la hora también
SET VERIFY OFF;
SET SERVEROUTPUT ON;
DECLARE
numero_empleado NUMBER:= &numero_de_empleado; --Pedimos el id del empleado
salario_empleado NUMBER:= &salario; --El salario a modificar
nombre_empleado VARCHAR2(20);
salario_antiguo NUMBER:= 0;
salario_nuevo NUMBER := 0;

BEGIN
SELECT NOMBRE into nombre_empleado
FROM EMPLEADOS_PAC WHERE id_empleado= numero_empleado; --Guardamos el nombre del empleado para mostrarlo

SELECT SALARIO into salario_antiguo
FROM EMPLEADOS_PAC
WHERE nombre = nombre_empleado;
UPDATE EMPLEADOS_PAC SET SALARIO = salario_empleado WHERE nombre = nombre_empleado; --Sentencia con la que se disparará el trigger
SELECT SALARIO into salario_nuevo
FROM EMPLEADOS_PAC
WHERE nombre = nombre_empleado;
dbms_output.put_line('El salario del empleado ' || nombre_empleado || ' se ha modificado el día ' || SYSDATE() || ' Antes era de ' || salario_antiguo || '€' || ' y ahora es de ' || salario_nuevo || '€' );
END;


