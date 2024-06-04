drop database if exists erasmus;
create database erasmus charset utf8mb4 collate utf8mb4_0900_as_cs;
use erasmus;

CREATE TABLE ciclos (
    idCiclo INT AUTO_INCREMENT PRIMARY KEY,
    Denominacion VARCHAR(45) NOT NULL,
    FamiliaProfesional VARCHAR(45) NOT NULL,
    Grado ENUM('Medio', 'Superior') NOT NULL
);
CREATE TABLE CodigoPostal (
    Localidad VARCHAR(25) PRIMARY KEY,
    CodigoPostal CHAR(5) NOT NULL,
    CHECK (CodigoPostal BETWEEN 10000 AND 99999),
    Provincia VARCHAR(25) NOT NULL
);
CREATE TABLE alumnos (
    DNI CHAR(9) PRIMARY KEY,
    Ciclo INT NOT NULL,
    Nombre VARCHAR(15) NOT NULL,
    Apellidos VARCHAR(45) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Direccion VARCHAR(45),
    Telefono CHAR(9),
    Localidad CHAR(25),
    FOREIGN KEY (Ciclo)
        REFERENCES Ciclos (idCiclo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Localidad)
        REFERENCES CodigoPostal (Localidad)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE EmailAlumno (
    IdAlumno CHAR(9),
    Email VARCHAR(45) NOT NULL UNIQUE,
    PRIMARY KEY (IdAlumno , Email),
    FOREIGN KEY (IdAlumno)
        REFERENCES alumnos (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE historicoAlumnos (
    DNI CHAR(9),
    nombreCompleto VARCHAR(50),
    telefono CHAR(9),
    promocion year
);

CREATE TABLE historicoEmailAlumnos (
    emails LONGTEXT,
    promocion YEAR
);

CREATE TABLE PruebaIdiomas (
    FechaHora DATETIME PRIMARY KEY,
    Idioma VARCHAR(15) NOT NULL,
    Nivel ENUM('Bajo', 'Medio', 'Alto') NOT NULL,
    NumPreguntas TINYINT NOT NULL DEFAULT 20
);
CREATE TABLE UsuarioOLS (
    login VARCHAR(20) PRIMARY KEY,
    pass VARCHAR(45) NOT NULL,
    CHECK (pass RLIKE '[A-Za-z0-9]*'),
    IdiomaAsignado VARCHAR(15),
    CorreoAlumno VARCHAR(45)
);
CREATE TABLE AlmNoErasmus (
    IdAlmNoErasmus CHAR(9) PRIMARY KEY,
    FOREIGN KEY (IdAlmNoErasmus)
        REFERENCES alumnos (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE AlmErasmus (
    IdAlmErasmus CHAR(9) PRIMARY KEY,
    FOREIGN KEY (IdAlmErasmus)
        REFERENCES alumnos (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE realizaPrueba (
    IdAlumno CHAR(9) PRIMARY KEY,
    IdPrueba DATETIME,
    Calificacion TINYINT,
    CHECK (Calificacion BETWEEN 0 AND 10),
    FOREIGN KEY (IdAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdPrueba)
        REFERENCES PruebaIdiomas (FechaHora)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ReunionInformativa (
    FechaHora DATETIME PRIMARY KEY
);
CREATE TABLE ayudaA (
    IdAlumnoAyuda CHAR(9),
    IdAlumnoAyudado CHAR(9),
    FOREIGN KEY (IdAlumnoAyuda)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (IdAlumnoAyudado)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY (IdAlumnoAyuda , IdAlumnoAyudado)
);
CREATE TABLE asiste (
    IdReunion DATETIME,
    IdAlumno CHAR(9),
    PRIMARY KEY (IdReunion , IdAlumno),
    FOREIGN KEY (IdReunion)
        REFERENCES ReunionInformativa (FechaHora)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE movilidad (
    idMovilidad INT AUTO_INCREMENT PRIMARY KEY,
    DuracionDias TINYINT UNSIGNED NOT NULL,
    Plazas TINYINT UNSIGNED NOT NULL,
    tipo ENUM('KA103', 'KA116') NOT NULL
);
CREATE TABLE PaisesParticipantes (
    IdMovilidad INT AUTO_INCREMENT PRIMARY KEY,
    NombrePais VARCHAR(15) NOT NULL,
    FOREIGN KEY (IdMovilidad)
        REFERENCES movilidad (idMovilidad)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CursaMovilidad (
    idMovilidad INT,
    idAlumno CHAR(9),
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    FechaAdmision DATE NOT NULL,
    PaisDestino VARCHAR(15) NOT NULL,
    PRIMARY KEY (idMovilidad , idAlumno),
    FOREIGN KEY (idMovilidad)
        REFERENCES movilidad (IdMovilidad)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE Profesores (
    DNI CHAR(9) PRIMARY KEY,
    Nombre VARCHAR(45) NOT NULL
);
CREATE TABLE EmailsProfesores (
    IdProfesor CHAR(9) PRIMARY KEY,
    Email VARCHAR(45) NOT NULL UNIQUE,
    FOREIGN KEY (IdProfesor)
        REFERENCES Profesores (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE TelefonosProfesores (
    IdProfesor CHAR(9),
    Telefono CHAR(9) NOT NULL,
    PRIMARY KEY (IdProfesor , Telefono),
    FOREIGN KEY (IdProfesor)
        REFERENCES Profesores (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ProfNoErasmus (
    IdProfNoErasmus CHAR(9) PRIMARY KEY,
    HorasSemanales TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (IdProfNoErasmus)
        REFERENCES Profesores (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ProfErasmus (
    IdProfErasmus CHAR(9) PRIMARY KEY,
    AñosExperienciaErasmus TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (IdProfErasmus)
        REFERENCES Profesores (DNI)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ClasesIdiomas (
    IdClases INT AUTO_INCREMENT PRIMARY KEY,
    Idioma VARCHAR(15) NOT NULL,
    Nivel ENUM('Básico', 'Intermedio', 'Avanzado') NOT NULL,
    horario TIME NOT NULL
);
CREATE TABLE ImparteIdiomas (
    IdClases INT,
    IdProfesor CHAR(9),
    IdAlmErasmus CHAR(9),
    ParticipacionActiva TINYINT UNSIGNED NOT NULL,
    CHECK (ParticipacionActiva BETWEEN 0 AND 10),
    PRIMARY KEY (IdClases , IdAlmErasmus),
    FOREIGN KEY (IdClases)
        REFERENCES ClasesIdiomas (IdClases)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdProfesor)
        REFERENCES Profesores (DNI)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (IdAlmErasmus)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE EntregaDocumentacion (
    idDocumentacion INT AUTO_INCREMENT PRIMARY KEY,
    idAlumno CHAR(9),
    idTutor CHAR(9),
    TipoDocumento ENUM('Carta de presentación', 'CV Español', 'CV Inglés', 'DNI', 'Tarjeta sanitaria') NOT NULL,
    Entregado TINYINT NOT NULL,
    CHECK (Entregado BETWEEN 0 AND 1),
    FechaEntrega DATETIME,
    FOREIGN KEY (idTutor)
        REFERENCES ProfNoErasmus (IdProfNoErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (idAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE OrganizaReunion (
    IdProfesor CHAR(9),
    IdReunion DATETIME,
    PRIMARY KEY (IdProfesor , IdReunion),
    FOREIGN KEY (IdProfesor)
        REFERENCES ProfErasmus (IdProfErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (IdReunion)
        REFERENCES ReunionInformativa (FechaHora)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Entrevista (
    IdEntrevista INT AUTO_INCREMENT PRIMARY KEY,
    DestrezasValoradas VARCHAR(45),
    Fecha DATETIME NOT NULL,
    Puntuacion TINYINT NOT NULL,
    CHECK (Puntuacion BETWEEN 0 AND 10)
);
CREATE TABLE RealizaEntrevista (
    IdProfesor CHAR(9),
    IdAlumno CHAR(9),
    IdEntrevista INT,
    PRIMARY KEY (IdProfesor , IdAlumno),
    FOREIGN KEY (IdProfesor)
        REFERENCES ProfErasmus (IdProfErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (IdAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdEntrevista)
        REFERENCES Entrevista (IdEntrevista)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE InscribeUsuarioOLS (
    IdAlumno CHAR(9) PRIMARY KEY,
    IdProfesor CHAR(9),
    IdUsuario VARCHAR(20),
    DiaRegistro DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (IdAlumno)
        REFERENCES AlmErasmus (IdAlmErasmus)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdProfesor)
        REFERENCES ProfErasmus (IdProfErasmus)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (IdUsuario)
        REFERENCES usuarioOLS (login)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE PruebaOLS (
    FechaHora DATETIME PRIMARY KEY,
    TipoPrueba ENUM('Primera Prueba', 'Segunda Prueba') NOT NULL,
    Idioma VARCHAR(15) NOT NULL
);
CREATE TABLE RealizaPruebaOLS (
    IdPrueba DATETIME,
    IdUsuario VARCHAR(20),
    RespuestasCorrectas TINYINT UNSIGNED NOT NULL,
    NivelObtenido ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
    PRIMARY KEY (IdPrueba , IdUsuario),
    FOREIGN KEY (IdPrueba)
        REFERENCES PruebaOLS (FechaHora)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdUsuario)
        REFERENCES usuarioOLS (login)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE CursoOLS (
    IdCurso INT AUTO_INCREMENT PRIMARY KEY,
    Nivel ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2') NOT NULL,
    DuracionSemanas TINYINT UNSIGNED NOT NULL,
    CHECK (DuracionSemanas BETWEEN 8 AND 12)
);
CREATE TABLE AsisteCursoOLS (
    IdCurso INT,
    IdUsuario VARCHAR(20) PRIMARY KEY,
    FOREIGN KEY (IdCurso)
        REFERENCES CursoOLS (IdCurso)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdUsuario)
        REFERENCES usuarioOLS (login)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE FechasCursoOLS (
    IdCurso INT,
    IdUsuario VARCHAR(20),
    Fecha DATE NOT NULL,
    Asistencia ENUM('Asiste', 'Retraso', 'Falta injustificada', 'Falta justificada'),
    PRIMARY KEY (IdUsuario , Fecha),
    FOREIGN KEY (IdCurso)
        REFERENCES AsisteCursoOLS (IdCurso)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (IdUsuario)
        REFERENCES AsisteCursoOLS (IdUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO ciclos (Denominacion, FamiliaProfesional, Grado) VALUES
    ('Desarrollo de Aplicaciones Web', 'Informática', 'Superior'),
    ('Actividades comerciales', 'Comercio y Marketing', 'Medio');
INSERT INTO alumnos (DNI, Ciclo, Nombre, Apellidos, FechaNacimiento, Direccion, Telefono) VALUES
    ('65481521F', '1', 'Juan', 'Pérez Gómez', '1995-05-15', 'Dulcinea 123', '654987654'),
    ('95865487U', '2', 'Juana', 'García Santana', '1998-08-22', 'León y Castillo 181', '687954354');
INSERT INTO codigopostal (CodigoPostal, Localidad, Provincia) VALUES
    ('35640', 'Puerto del Rosario', 'Las Palmas'),
    ('38320', 'La Laguna', 'Santa Cruz de Tenerife');
INSERT INTO emailalumno (IdAlumno, Email) VALUES
    ('65481521F', 'juannn@gmail.com'),
    ('95865487U', 'juanagarsan@hotmail.com');
INSERT INTO pruebaidiomas (FechaHora, Idioma) VALUES
    ('2024-02-03 12:00:00', 'Inglés'),
    ('2024-02-04 14:30:00', 'Francés');
/*INSERT INTO realizaprueba (IdAlumno, IdPrueba, Calificacion) VALUES
    ('65481521F', '2024-02-03 12:00:00', 8),
    ('95865487U', '2024-02-04 14:30:00', 5);*/
INSERT INTO reunioninformativa (FechaHora) VALUES
    ('2024-02-05 10:00:00'),
    ('2024-02-06 15:00:00');
INSERT INTO almnoerasmus (IdAlmNoErasmus) VALUES
    ('65481521F'),
    ('95865487U');
INSERT INTO almerasmus (IdAlmErasmus) VALUES
    ('65481521F'),
    ('95865487U');
INSERT INTO ayudaa (IdAlumnoAyuda, IdAlumnoAyudado) VALUES
    ('65481521F', '95865487U'),
    ('95865487U', '65481521F');
INSERT INTO asiste (IdReunion, IdAlumno) VALUES
    ('2024-02-05 10:00:00', '65481521F'),
    ('2024-02-06 15:00:00', '95865487U');
INSERT INTO movilidad (DuracionDias, Plazas, Tipo) VALUES
    (15, 20, 'KA103'),
    (20, 15, 'KA116');
INSERT INTO paisesparticipantes (IdMovilidad, NombrePais) VALUES
    (1, 'Alemania'),
    (2, 'Francia');
INSERT INTO cursamovilidad (IdMovilidad, IdAlumno, FechaInicio, FechaFin, FechaAdmision, PaisDestino) VALUES
    (1, '65481521F', '2024-03-01', '2024-03-15', '2024-02-15', 'Alemania'),
    (2, '95865487U', '2024-04-01', '2024-04-20', '2024-03-20', 'Francia');
INSERT INTO profesores (DNI, Nombre) VALUES
    ('45678125I', 'Fernando'),
    ('95865874T', 'Jonathan');
INSERT INTO emailsprofesores (IdProfesor, Email) VALUES
    ('45678125I', 'fernandoprogramacion@gmail.com'),
    ('95865874T', 'jonathanlenguajedemarcas@hotmail.com');
INSERT INTO telefonosprofesores (IdProfesor, Telefono) VALUES
    ('45678125I', '956874525'),
    ('95865874T', '987456321');
INSERT INTO profnoerasmus (IdProfNoErasmus, HorasSemanales) VALUES
    ('45678125I', 20),
    ('95865874T', 15);
INSERT INTO proferasmus (IdProfErasmus, AñosExperienciaErasmus) VALUES
    ('45678125I', 5),
    ('95865874T', 3);
INSERT INTO clasesidiomas (Idioma, Nivel, Horario) VALUES
    ('Inglés', 'Intermedio', '10:00:00'),
    ('Francés', 'Avanzado', '14:30:00');
INSERT INTO imparteidiomas (IdClases, IdProfesor, IdAlumno, ParticipacionActiva) VALUES
    (1, '45678125I', '65481521F', 8),
    (2, '95865874T', '95865487U', 9);
INSERT INTO entregadocumentacion (idAlumno, IdTutor, TipoDocumento, Entregado) VALUES
    ('65481521F', '45678125I', 'Tarjeta sanitaria', 1),
    ('95865487U', '95865874T', 'DNI', 0);
INSERT INTO organizareunion (IdProfesor, IdReunion) VALUES
    ('45678125I', '2024-02-05 10:00:00'),
    ('95865874T', '2024-02-06 15:00:00');
INSERT INTO entrevista (DestrezasValoradas, Fecha, Puntuacion) VALUES
    ('Comunicación', '2024-02-08 12:00:00', 9),
    ('Programación', '2024-02-09 14:30:00', 8);
INSERT INTO realizaentrevista (IdProfesor, IdAlumno, IdEntrevista) VALUES
    ('45678125I', '65481521F', 1),
    ('95865874T', '95865487U', 2);
INSERT INTO usuariools (login, pass, IdiomaAsignado, CorreoAlumno) VALUES
    ('juanuser', 'a98s4da41', 'Inglés', 'juannnnn@gmail.com'),
    ('juanauser', 'ge8r7Evr91', 'Francés', 'juanaaa@hotmail.com');
INSERT INTO inscribeusuariools (IdAlumno, IdProfesor, IdUsuario) VALUES
    ('65481521F', '45678125I', 'juanuser'),
    ('95865487U', '95865874T', 'juanauser');
INSERT INTO pruebaols (FechaHora, TipoPrueba, Idioma) VALUES
    ('2024-02-10 10:00:00', 'Primera Prueba', 'Inglés'),
    ('2024-02-11 14:30:00', 'Primera Prueba', 'Francés');
INSERT INTO realizapruebaols (IdPrueba, IdUsuario, RespuestasCorrectas, NivelObtenido) VALUES
    ('2024-02-10 10:00:00', 'juanuser', 20, 'B2'),
    ('2024-02-11 14:30:00', 'juanauser', 18, 'B1');
INSERT INTO cursools (Nivel, DuracionSemanas) VALUES
    ('A2', 10),
    ('B1', 12);
INSERT INTO asistecursools (IdCurso, IdUsuario) VALUES
    (1, 'juanuser'),
    (2, 'juanauser');
INSERT INTO fechascursools (IdCurso, IdUsuario, Fecha, Asistencia) VALUES
    (1, 'juanuser', '2024-02-12', 'Asiste'),
    (2, 'juanauser', '2024-02-13', 'Retraso');