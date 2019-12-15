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
-- использованием частоты, интервала и спецификаторов.

-- 1)При изменении цен на материалы пересчитывать стоимость услуг, для
-- которых они необходимы.

CREATE OR REPLACE TRIGGER update_material_cost
AFTER UPDATE OF price ON Material
FOR EACH ROW

DECLARE
old_material_cost NUMBER := :OLD.price;
new_material_cost NUMBER := :NEW.price;
current_material NUMBER := :NEW.material_id;
old_product_price NUMBER;
counter INTEGER;

BEGIN
SELECT product_id
INTO counter
FROM Product
WHERE material_id = current_material AND ROWNUM = 1;

IF old_material_cost <> new_material_cost THEN
    SELECT price
    INTO old_product_price
    FROM Product
    WHERE material_id = current_material;

    UPDATE Product
    SET price = old_product_price + (new_material_cost-old_material_cost)*0.3
    WHERE material_id = current_material;

    DBMS_OUTPUT.PUT_LINE('Material`s price and product`s price updated');

END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Product`s price hasn`t changed, because there is no products with this materials');

END;
/


UPDATE Material SET price = 1700 WHERE material_id = 7;
UPDATE Material SET price = 1600 WHERE material_id = 7;

UPDATE Material SET price = 300 WHERE material_id = 4;
UPDATE Material SET price = 200 WHERE material_id = 4;




-- 2) Не заключать в месяц более определенного количества контрактов,
-- делать скидку заказчику при повторном обращении, рассчитывать автоматически
-- общую стоимость контракта.

CREATE OR REPLACE TRIGGER orders_num
FOR INSERT ON Orders
COMPOUND TRIGGER
 
orders_counter INTEGER;
discount INTEGER :=10;
max_num_of_orders INTEGER := 3;
current_customer INTEGER := :NEW.customer_id;
current_order INTEGER := :NEW.order_id;
current_order_cost NUMBER := :NEW.order_cost;
num_of_customers_orders INTEGER;

BEFORE EACH ROW IS

BEGIN
SELECT COUNT(1)
INTO orders_counter
FROM Orders
WHERE TO_CHAR(order_date, 'MM.YYYY') = TO_CHAR(sysdate, 'MM.YYYY');


IF orders_counter >= max_num_of_orders THEN
    RAISE_APPLICATION_ERROR(
        num => -20000,
        msg => 'You can`t have more than 3 orders in one month!');

END IF;

END BEFORE EACH ROW;


AFTER STATEMENT IS
BEGIN
SELECT COUNT(1)
INTO num_of_customers_orders
FROM Orders
WHERE customer_id = current_customer;

DBMS_OUTPUT.PUT_LINE(current_customer);

IF num_of_customers_orders >=1 THEN
    UPDATE Orders
    SET order_cost = current_order_cost*0.01*(100-discount)
    WHERE order_id = current_order;
END IF;
END AFTER STATEMENT;



END;
/

insert into Orders (customer_id,order_cost,order_date,status) values(2,2500,'13-december-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(3,2000,'14-december-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(1,5000,'14-december-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(1,4000,'14-december-2019','y');
delete from Orders where order_id = 82;
insert into Orders (customer_id,order_cost,order_date,status) values(4,4000,'14-december-2019','y');


-- 3) Раз в год повышать стоимость продукта на 15%

BEGIN
DBMS_SCHEDULER.CREATE_JOB(
JOB_NAME => 'update_product_price_once_a_year',
JOB_TYPE => 'PLSQL_BLOCK',
JOB_ACTION => 'UPDATE Product SET price=price+price*0.15;',
START_DATE => '01-JAN-19 01.00.00 AM ',
REPEAT_INTERVAL => 'FREQ=YEARLY; BYYEARDAY=1',
END_DATE => '01-JAN-23 01.00.00 AM ',
COMMENTS => 'Update product`s price once a year (1 jan at 1 am) ',
ENABLED => TRUE);
END;
/



-- 5.Самостоятельно или при помощи преподавателя составить задание на
-- триггер, который будет вызывать мутацию таблиц, и решить эту проблему
-- одним из двух способов (при помощи переменных пакета и двух триггеров или
-- при помощи COMPAUND-триггера)

-- 6.Написать триггер INSTEAD OF для работы с необновляемым
-- представлением, созданным после выполнения п. 2 задания к лабораторной
-- работе №3, проверить DML-командами возможность обновления
-- представления до и после включения триггера

CREATE OR REPLACE VIEW num_ord AS
SELECT c.customer_id, c.last_name, COUNT(*) AS Num_of_orders
FROM Orders o
INNER JOIN Customer c ON c.customer_id = o.customer_id
GROUP BY c.customer_id,  c.last_name;


CREATE OR REPLACE TRIGGER update_vertical_view
INSTEAD OF UPDATE ON num_ord
FOR EACH ROW
BEGIN
UPDATE Customer SET
last_name = :NEW.last_name
WHERE customer_id = :OLD.customer_id;
END;
/

update num_ord set last_name='Kokoko' where customer_id=1;
update num_ord set last_name='Kokorin' where customer_id=1;

drop trigger update_vertical_view;