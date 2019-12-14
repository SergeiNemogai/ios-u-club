-- 1.Написать DML-триггер, регистрирующий изменение данных (вставку,
-- обновление, удаление) в одной из таблиц БД. Во вспомогательную таблицу
-- LOG1 записывать, кто, когда (дата и время) и какое именно изменение
-- произвел, для одного из столбцов сохранять старые и новые значения.
CREATE TABLE LOG1 (
    table_name VARCHAR2(30),
    oper_name CHAR(1),
    pk_key VARCHAR2(200),
    column_name VARCHAR2(30),
    old_value VARCHAR2(200),
    new_value VARCHAR2(200),
    username VARCHAR2(20),
    dateoper DATE);


CREATE OR REPLACE PROCEDURE SAVE_LOGS (
    vtable_name IN VARCHAR2,
    voper_name IN CHAR,
    vpk_key IN VARCHAR2,
    vcolumn_name IN VARCHAR2,
    vold_value IN VARCHAR2,
    vnew_value IN VARCHAR2
)
IS

BEGIN 
   IF vold_value <> vnew_value or vOper_name in ('I','D')
   THEN
        INSERT INTO LOG1 (
            table_name, oper_name, pk_key,
            column_name, old_value, new_value,
            username, dateoper
        ) VALUES (
            vtable_name, voper_name,
            vpk_key, vcolumn_name, vold_value,
            vnew_value, USER, SYSDATE);
    
    END IF;
END;
/



CREATE OR REPLACE TRIGGER TRIGGER_DML
AFTER INSERT OR UPDATE OR DELETE
ON Material
FOR EACH ROW

DECLARE

op CHAR(1) := 'I';

BEGIN
    CASE
        WHEN INSERTING
        THEN
            op := 'I';
            SAVE_LOGS('Material', op, :NEW.material_id, 'material_type', NULL, :NEW.material_type);
            SAVE_LOGS('Material', op, :NEW.material_id, 'manufacturer', NULL, :NEW.manufacturer);
            SAVE_LOGS('Material', op, :NEW.material_id, 'price', NULL, :NEW.price);


        WHEN UPDATING('material_type') or UPDATING('manufacturer') or  UPDATING('price')
        THEN
            op := 'U';
            SAVE_LOGS('Material', op, :NEW.material_id, 'material_type', :OLD.material_type, :NEW.material_type);
            SAVE_LOGS('Material', op, :NEW.material_id, 'manufacturer', :OLD.manufacturer, :NEW.manufacturer);
            SAVE_LOGS('Material', op, :NEW.material_id, 'price', :OLD.price, :NEW.price);


        WHEN DELETING
        THEN
            op := 'D';
            SAVE_LOGS('Material', op, :old.material_id, 'material_type', :OLD.material_type, NULL);
            SAVE_LOGS('Material', op, :old.material_id, 'manufacturer', :OLD.manufacturer, NULL);
            SAVE_LOGS('Material', op, :old.material_id, 'price', :OLD.price, NULL);

    ELSE
        NULL;

    END CASE;

END TRIGGER_DML;
/
-- setting console output parameters
set colsep '|'
set linesize 1000
set pagesize 60
set pagesize 2000

INSERT INTO Material (material_type,manufacturer,price) VALUES ('TEST_NAME','TEST_MANUF',4440);
UPDATE Material SET material_type='test2' WHERE material_id=44;
DELETE FROM Material WHERE material_id=44;



-- 2.Написать DDL-триггер, протоколирующий действия пользователей по
-- созданию, изменению и удалению таблиц в схеме во вспомогательную таблицу
-- LOG2 в определенное время и запрещающий эти действия в другое время

CREATE TABLE LOG2(
    table_name VARCHAR2(30),
    oper_name VARCHAR(10),
    username VARCHAR2(20),
    dateoper DATE);


CREATE OR REPLACE TRIGGER CRT_ALR_DRP_TRIGGER
BEFORE CREATE OR ALTER OR DROP ON SCHEMA

BEGIN
IF TO_NUMBER(TO_CHAR(SYSDATE,'HH24')) >= 8 AND TO_NUMBER(TO_CHAR(SYSDATE,'HH24')) <= 18 THEN
    INSERT INTO LOG2(table_name, oper_name, username, dateoper)
    VALUES (ora_dict_obj_name, ora_sysevent, USER, SYSDATE);
ELSE
    RAISE_APPLICATION_ERROR(
        num => -20000,
        msg => 'You can`t create, drop or alter tables since 6pm till 8am!');
END IF;

END;
/


CREATE TABLE human(id INTEGER, age INTEGER);
DROP TABLE human;
ALTER TABLE human ADD fname VARCHAR2(30);

-- 3.Написать системный триггер, добавляющий запись во вспомогательную
-- таблицу LOG3, когда пользователь подключается или отключается. В таблицу
-- логов записывается имя пользователя (USER), тип активности (LOGON или
-- LOGOFF), дата (SYSDATE), количество записей в основной таблице БД.

CREATE TABLE LOG3(
    username VARCHAR2(20),
    action_type VARCHAR(10),
    date_of_action DATE);


CREATE OR REPLACE TRIGGER LOGON_TRIGGER AFTER LOGON ON SCHEMA
BEGIN
    INSERT INTO LOG3(username, action_type, date_of_action)
    VALUES (USER, 'LOGON', SYSDATE);
END;
/
  
CREATE OR REPLACE TRIGGER LOGOFF_TRIGER BEFORE LOGOFF ON SCHEMA
BEGIN
    INSERT INTO LOG3(username, action_type, date_of_action)
    VALUES (USER, 'LOGOFF', SYSDATE);
END;
/



-- 4.Написать триггеры, реализующие бизнес-логику (ограничения) в
-- заданной вариантом предметной области. Три задания приведены в прил. 6.
-- Количество и тип триггеров (строковый или операторный, выполняется AFTER
-- или BEFORE) определять самостоятельно исходя из сути заданий и имеющейся
-- схемы БД; учесть, что в некоторых вариантах первые два задания могут быть
-- выполнены в рамках одного триггера, а также возможно возникновение
-- мутации, что приведет к совмещению данного пункта лабораторной работы со
-- следующим. Третий пункт задания предполагает использование планировщика
-- задач, который обязательно должен быть настроен на многократный запуск с
-- использованием частоты, интервала и спецификаторов

-- Определенный материал подходит для определенной техники.

-- Клиентам, у которых больше 5 заказов, предоставляется скидка.

-- Клиент одновременно не может иметь более 3 заказов.

-- 1)При изменении цен на материалы пересчитывать стоимость услуг, для
-- которых они необходимы.

-- 2) Не заключать в месяц более определенного количества контрактов,
-- делать скидку заказчику при повторном обращении, рассчитывать автоматически
-- общую стоимость контракта.

-- 3) Вести в дополнительной таблице учет занятости оборудования по дням недели



-- 5.Самостоятельно или при помощи преподавателя составить задание на
-- триггер, который будет вызывать мутацию таблиц, и решить эту проблему
-- одним из двух способов (при помощи переменных пакета и двух триггеров или
-- при помощи COMPAUND-триггера)

-- 6.Написать триггер INSTEAD OF для работы с необновляемым
-- представлением, созданным после выполнения п. 2 задания к лабораторной
-- работе №3, проверить DML-командами возможность обновления
-- представления до и после включения триггера