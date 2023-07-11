/*Задание 1.1 Добавить в таблицу «Грузовик» 2 новых столбца: Фамилия водителя (LastName) и Имя водителя (FirstName).*/

ALTER TABLE Car ADD COLUMN LastName varchar(50);
ALTER TABLE Car ADD COLUMN FirstName varchar(50);

/*Задание 1.2 Убрать ограничение NOT NULL из столбца «DriverFullName».*/

ALTER TABLE Car ALTER COLUMN DriverFullName DROP NOT NULL;

/* Задание 1.3 Заполнить 2 новых созданных столбца таблицы «Грузовик» на основе данных столбца «DriverFullName»
(используя команду UPDATE и команды разбора поля на составные части из предыдущих лабораторных работ).*/

UPDATE Car
    SET LastName = (trim(SUBSTRING(Car.DriverFullName FROM (POSITION (' ' IN DriverFullName)))));
UPDATE Car
     SET FirstName = (trim(SUBSTRING(Car.DriverFullName FROM 1 FOR (POSITION (' ' IN DriverFullName)))));
SELECT * FROM Car


/*Задание 2.1 Написать хранимую процедуру, которая предназначена для добавления в таблицу «Грузовик» новых строк.
Процедура должна заполнять только поля CarID, LastName и FirstName (использовать входящие параметры и конструкцию INSERT).*/

CREATE OR REPLACE PROCEDURE INSERT_Car (
_carid integer,
_lastname varchar(50),
_firstname varchar(50)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO Car(CarID, LastName,FirstName)
    VALUES (_carid, _lastname, _firstname);
END
$$;

CALL INSERT_Car (555, 'Давыдов', 'Дмитрий');
 SELECT * FROM Car
 
/* Задание 2.2 Изменить хранимую процедуру, созданную в задании 1, добавив в неё после команды INSERT
команду обновления столбца DriverFullName на основе введённых фамилии и имени (с использованием конструкции UPDATE).*/

CREATE OR REPLACE PROCEDURE INSERT_Car2 (
_carid integer,
_lastname varchar(50),
_firstname varchar(50)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO Car(CarID, LastName,FirstName)
    VALUES (_carid, _lastname, _firstname);
    
    UPDATE Car
    SET DriverFullName = CONCAT (firstname, ' ', lastname);
END
$$;

CALL INSERT_Car2 (5555, 'Давыдов', 'Дмитрий');
 SELECT * FROM Car

/*Задание 2.3 Изменить хранимую процедуру, созданную в задании 2,
таким образом, чтобы параметр CarID не передавался в процедуру,
а рассчитывался автоматически с учётом значения максимального
из существующих идентификаторов в таблице.*/

CREATE OR REPLACE PROCEDURE INSERT_Car3 (
_lastname varchar(50),
_firstname varchar(50)
)
LANGUAGE plpgsql
AS
$$
DECLARE Car_ID_MAX integer;
BEGIN
    SELECT MAX(CarID) FROM Car INTO Car_ID_MAX;
    INSERT INTO Car(CarID, LastName,FirstName)
    VALUES ( Car_ID_MAX + 1, _lastname, _firstname);
    
    UPDATE Car
    SET DriverFullName = CONCAT (firstname, ' ', lastname);
END
$$;

CALL INSERT_Car3 ('Иванов', 'Серёга');
 SELECT * FROM Car

/* Задание 2.4. Изменить хранимую процедуру, созданную в задании 3, 
таким образом, чтобы в процедуру передавалось только полное имя водителя (DriverFullName).
В процедуре должен осуществляться разбор переданного параметра на составные части,
генерация нового кода автомобиля, а затем – вставка всех полученных данных в таблицу.*/

CREATE OR REPLACE PROCEDURE INSERT_Car4 (
_driverfullname varchar(50)
)
LANGUAGE plpgsql
AS
$$
DECLARE Car_ID_MAX integer;
BEGIN
    SELECT MAX(CarID) FROM Car INTO Car_ID_MAX;
    INSERT INTO Car(CarID, DriverFullName)
    VALUES ( Car_ID_MAX + 1, _driverfullname);
    
    UPDATE Car
    SET LastName = split_part (Car.DriverFullName, ' ', 1),
    FirstName =  split_part (Car.DriverFullName, ' ', 2);
END
$$;

CALL INSERT_Car4 ('Иванов Иван');
 SELECT * FROM Car

/*
Задание 2.5:
Изменить хранимую процедуру, созданную в задании 4, таким образом, чтобы сгенерированный код автомобиля возвращался из процедуры при её вызове и отображался в окне результатов.
*/
CREATE OR REPLACE PROCEDURE car_insert5 (full_name varchar (100))
LANGUAGE 'plpgsql'
AS
$$
DECLARE max_id integer;
BEGIN
    SELECT MAX(carid)
    FROM car
    INTO max_id;
    
    INSERT INTO car (carid, driverfullname, lastname, firstname)
    VALUES (max_id + 1, full_name, split_part (full_name, ' ', 2), split_part (full_name, ' ', 1));
    RAISE NOTICE '%', max_id + 2;
    
END
$$;
CALL car_insert5 ('Сергеев Серёга')

/* Задание 2.5. Изменить хранимую процедуру, созданную в задании 4, таким образом,
чтобы сгенерированный код автомобиля возвращался из процедуры при её вызове и отображался в окне результатов.
*/

CREATE OR REPLACE PROCEDURE INSERT_Car5 (
_driverfullname varchar(50)
)
LANGUAGE plpgsql
AS
$$
DECLARE Car_ID_MAX integer;
BEGIN
    SELECT MAX(CarID) FROM Car INTO Car_ID_MAX;
    INSERT INTO Car(CarID, DriverFullName)
    VALUES ( Car_ID_MAX + 1, _driverfullname);
    
    UPDATE Car
    SET LastName = split_part (Car.DriverFullName, ' ', 1),
    FirstName =  split_part (Car.DriverFullName, ' ', 2);
    RAISE NOTICE '%', Car_ID_MAX + 1;
END
$$;

CALL INSERT_Car5 ('Алексеев Лёша');

/* Задани 2.6. Изменить хранимую процедуру, созданную в задании 5, таким образом, чтобы
генерируемый идентификатор автомобиля всегда состоял из 5 символов (для
этого необходимо реализовать проверку полученного значения и его
последующую корректировку при необходимости).*/

DROP PROCEDURE IF EXISTS INSERT_Car5;
CREATE OR REPLACE PROCEDURE INSERT_Car5
        (DriverFullName varchar(50)
         )
LANGUAGE plpgsql
AS
$$
DECLARE i integer;
BEGIN
    SELECT MAX(CarID) FROM Car
    INTO i;
IF char_length (i :: text) > 5 
THEN i = right (i, 5);
ELSEIF char_length (i :: text) < 5 
THEN i = i + 10000;
END IF;
INSERT INTO Car (CarID, DriverFullName)
    VALUES (i + 1, DriverFullName);
UPDATE Car
SET FirstName = split_part (Car.DriverFullName, ' ',1),
    LastName = split_part (Car.DriverFullName, ' ',2);
    RAISE NOTICE 'CarID=%', i +1;
END
$$;
CALL INSERT_Car5 ('Алексеев Алехан');