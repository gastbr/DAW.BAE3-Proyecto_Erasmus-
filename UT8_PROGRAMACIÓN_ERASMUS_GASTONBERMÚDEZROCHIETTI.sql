use erasmus;

-- Una rutina almacenada, trigger o evento que permita crear una tabla de histórico de alumnado, por cada curso escolar una vez finalizado éste, y en el que se registren únicamente los campos que consideres que sean relevantes para contactar con el alumnado que ha realizado la movilidad.

delimiter $$
drop event if exists erasmus.insertHistorico$$
create event erasmus.insertHistorico
on schedule every 10 second starts '2024-06-04 18:30:00' enable do
begin
	insert into historicoAlumnos select DNI, concat_ws(nombre, apellidos), telefono, year(curdate()) from alumnos;
    truncate table alumnos;
end$$

delimiter ;

show tables;
select * from emailalumno;
select * from historicoEmailAlumnos;

-- Una rutina almacenada, trigger o evento que permita registrar, en una tabla creada previamente, la lista de correo de los alumnos que han participado en una movilidad, por cada curso escolar y una vez ha finalizado éste.

delimiter $$

drop event if exists erasmus.insertHistoricoEmailAlumnos$$
create event erasmus.insertHistoricoEmailAlumnos
on schedule every 5 second starts '2024-06-04 18:30:00' enable do
begin
    declare correo varchar(255);
    declare listaCorreos longtext;
	declare flag boolean default false;

	declare cur cursor for select email from emailAlumno;
    declare continue handler for not found set flag = true;

    bucle: LOOP
		fetch cur into correo;
        set listaCorreos = concat_ws(listaCorreos, correo, ", ");
        if flag then
			leave bucle;
		end if;
	end loop;
    
    set listaCorreos = trim(trailing ', ' from listaCorreos);

	insert into historicoEmailAlumnos values (listaCorreos, year(curdate()));
end$$

-- Una rutina almacenada, trigger o evento que permita automatizar la decisión de APTO o NO APTO en la participación del proyecto. De manera que una vez un alumno ha superado las pruebas de inglés y entrevista, se indique con un campo si el alumno es apto o no lo es.

-- Una rutina almacenada, trigger o evento que permita automatizar el estado de la documentación solicitada (resuelto o pendiente) de manera que cuando un alumno ha entregado toda la documentación solicitada, se indique mediante un campo, con estado Resuelto y en caso contrario se mostrará Pendiente

-- Una rutina almacenada, trigger o evento original con funcionalidades que se consideren útiles para el proyecto de ERASMUS+. Explicar claramente el objetivo del ejercicio.
