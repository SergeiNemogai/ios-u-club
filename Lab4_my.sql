UPDATE Orders SET order_cost=2000.56 WHERE order_id=1;
UPDATE Orders SET order_cost=1990.899 WHERE order_id=3;

-- 1. Написать процедуру, которая выводит информацию о контрактах,
-- в которых сумма заказа лежит в диапазоне +/- 50$ от введенного значения.
-- Если контрактов с такой суммой не имеется, должно выводиться
-- соответствующее сообщение.

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE INFO (COST IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;
CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-50 AND CONTRACT_LIST.order_cost <= COST+50 THEN
            DBMS_OUTPUT.PUT_LINE('Customer id=' || CONTRACT_LIST.customer_id || '; ' ||'Order cost=' || CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost must be not null and positive number.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no orders with such cost.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('EEEEEEEEEERROR.');
        END IF;
END;
/


BEGIN
INFO(0);
END;
/

BEGIN
INFO(3000);
END;
/

BEGIN
INFO(1000);
END;
/



-- 2. Создать функцию, подсчитывающую количество заключенных контрактов
-- за текущий год. В вызывающую среду возвращать общую сумму этих
-- контрактов в параметре OUT.

CREATE OR REPLACE FUNCTION NUM_OF_CONTRACTS
RETURN NUMBER IS
RESULT NUMBER;
NO_ORDERS_ERROR EXCEPTION;
CURSOR CONTRACT IS SELECT count(order_id) AS num, SUM(order_cost) AS sum FROM Orders WHERE TO_CHAR(order_date, 'yyyy') = (SELECT (TO_CHAR(sysdate,'yyyy')-2) FROM dual);
CONTRACT_INFO CONTRACT%ROWTYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    select order_id into RESULT FROM Orders WHERE TO_CHAR(order_date, 'yyyy') = (SELECT (TO_CHAR(sysdate,'yyyy')-2) FROM dual) and rownum = 1;
    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_INFO;

    IF CONTRACT%FOUND THEN
        IF  CONTRACT_INFO.num > 0 THEN
            DBMS_OUTPUT.PUT_LINE('The total num of orders: ' ||CONTRACT_INFO.num);
            RESULT := CONTRACT_INFO.sum;
        END IF;
    END IF;
    CLOSE CONTRACT;

    RETURN RESULT;
    exception
      when no_data_found then
        DBMS_OUTPUT.PUT_LINE('There is no orders in this year!');
        return -1;

END;
/


DECLARE
RES NUMBER;
BEGIN
RES := NUM_OF_CONTRACTS();
IF RES IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('The total sum of orders: ' ||RES);
END IF;
END;
/

-- 3. Создать локальную программу, изменив код ранее написанной
-- процедуры или функции.
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE INFO_LOCAL (COST IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;
CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

PROCEDURE PRINT_INFO (CUSTOMER_ID IN INTEGER, ORDER_COST IN NUMBER) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Customer id=' || CUSTOMER_ID || '; ' ||'Order cost=' || ORDER_COST);
END PRINT_INFO;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-50 AND CONTRACT_LIST.order_cost <= COST+50 THEN
            PRINT_INFO(CONTRACT_LIST.customer_id, CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost must be not null and positive number.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR.');

END;
/


BEGIN
INFO_LOCAL(2000);
END;
/

-- 4. Написать перегруженные программы, используя для этого ранее
-- созданную процедуру или функцию

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE INFO (COST IN NUMBER, STEP IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;
CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    IF STEP IS NULL OR STEP <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-STEP AND CONTRACT_LIST.order_cost <= COST+STEP THEN
            DBMS_OUTPUT.PUT_LINE('Customer id=' || CONTRACT_LIST.customer_id || '; ' ||'Order cost=' || CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost and step must be not null and positive numbers.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR.');

END;
/


BEGIN
INFO(3000,50);
END;
/


BEGIN
INFO(3000,10);
END;
/


-- 5. Объединить все процедуры и функции, в том числе перегруженные, в пакет

CREATE OR REPLACE PACKAGE LAB4_PACKAGE IS
PROCEDURE INFO (COST IN NUMBER);
PROCEDURE INFO_LOCAL (COST IN NUMBER);
PROCEDURE INFO (COST IN NUMBER, STEP IN NUMBER);
FUNCTION NUM_OF_CONTRACTS RETURN NUMBER;
END LAB4_PACKAGE;
/

CREATE OR REPLACE PACKAGE BODY LAB4_PACKAGE IS

-- the first procedure
PROCEDURE INFO (COST IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;

CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-50 AND CONTRACT_LIST.order_cost <= COST+50 THEN
            DBMS_OUTPUT.PUT_LINE('Customer id=' || CONTRACT_LIST.customer_id || '; ' ||'Order cost=' || CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost must be not null and positive number.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');

        WHEN OTHERS THEN
            IF SQLCODE = '-06502' OR SQLCODE = '-06512' THEN
                DBMS_OUTPUT.PUT_LINE('ERROR.BLABLABLA');
            END IF;
END INFO;

-- the second procedure

PROCEDURE INFO_LOCAL (COST IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;
CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

PROCEDURE PRINT_INFO (CUSTOMER_ID IN INTEGER, ORDER_COST IN NUMBER) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Customer id=' || CUSTOMER_ID || '; ' ||'Order cost=' || ORDER_COST);
END PRINT_INFO;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-50 AND CONTRACT_LIST.order_cost <= COST+50 THEN
            PRINT_INFO(CONTRACT_LIST.customer_id, CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost must be not null and positive number.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR');

END INFO_LOCAL;

-- the third procedure

PROCEDURE INFO (COST IN NUMBER, STEP IN NUMBER) IS
CURSOR CONTRACT IS SELECT customer_id, order_cost FROM Orders;
INPUT_ERROR EXCEPTION;
COST_ERROR EXCEPTION;
CONTRACT_LIST CONTRACT%ROWTYPE;
COUNTER INTEGER := 0;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    IF COST IS NULL OR COST <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    IF STEP IS NULL OR STEP <= 0 THEN
        RAISE INPUT_ERROR;
    END IF;

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_LIST;

    WHILE CONTRACT%FOUND
    LOOP
        IF CONTRACT_LIST.order_cost >= COST-STEP AND CONTRACT_LIST.order_cost <= COST+STEP THEN
            DBMS_OUTPUT.PUT_LINE('Customer id=' || CONTRACT_LIST.customer_id || '; ' ||'Order cost=' || CONTRACT_LIST.order_cost);
            COUNTER := COUNTER + 1;
        END IF;

        FETCH CONTRACT INTO CONTRACT_LIST;
    END LOOP;
    
    IF COUNTER = 0 THEN
        RAISE COST_ERROR;
    END IF;

    CLOSE CONTRACT;


    EXCEPTION
        WHEN INPUT_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Check the input data. Cost and step must be not null and positive numbers.');
        WHEN COST_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR.');

END INFO;

-- the function


CREATE OR REPLACE FUNCTION NUM_OF_CONTRACTS
RETURN NUMBER IS
RESULT NUMBER;
NO_ORDERS_ERROR EXCEPTION;
CURSOR CONTRACT IS SELECT count(order_id) AS num, SUM(order_cost) AS sum FROM Orders WHERE TO_CHAR(order_date, 'yyyy') = (SELECT (TO_CHAR(sysdate,'yyyy')-2) FROM dual);
CONTRACT_INFO CONTRACT%ROWTYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');
    select order_id into RESULT FROM Orders WHERE TO_CHAR(order_date, 'yyyy') = (SELECT (TO_CHAR(sysdate,'yyyy')-2) FROM dual) and rownum = 1;
    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_INFO;

    IF CONTRACT%FOUND THEN
        IF  CONTRACT_INFO.num > 0 THEN
            DBMS_OUTPUT.PUT_LINE('The total num of orders: ' ||CONTRACT_INFO.num);
            RESULT := CONTRACT_INFO.sum;
        END IF;
    END IF;
    CLOSE CONTRACT;

    RETURN RESULT;
    exception
      when no_data_found then
        DBMS_OUTPUT.PUT_LINE('There is no orders in this year!');
        return -1;

END NUM_OF_CONTRACTS;




END LAB4_PACKAGE;
/





-- 6. Написать анонимный PL/SQL-блок, в котором будут вызовы
-- реализованных функций и процедур пакета с различными характерными
-- значениями параметров для проверки правильности работы основных задач и
-- обработки исключительных ситуаций.


BEGIN
LAB4_PACKAGE.INFO(3000);
LAB4_PACKAGE.INFO(2000);
LAB4_PACKAGE.INFO(0);
LAB4_PACKAGE.INFO(-13424);
LAB4_PACKAGE.INFO('dsgdsg');

DBMS_OUTPUT.PUT_LINE('-------------------------------');
LAB4_PACKAGE.INFO_LOCAL(3000);
LAB4_PACKAGE.INFO_LOCAL(2000);
LAB4_PACKAGE.INFO_LOCAL(0);
LAB4_PACKAGE.INFO_LOCAL(-13424);
DBMS_OUTPUT.PUT_LINE('-----------------------------');
LAB4_PACKAGE.INFO(3000,10);
LAB4_PACKAGE.INFO(2000, 0);
LAB4_PACKAGE.INFO(0, 0);
LAB4_PACKAGE.INFO(-13424, -1);
END;
/

DECLARE
RES NUMBER;
BEGIN
RES := LAB4_PACKAGE.NUM_OF_CONTRACTS();
DBMS_OUTPUT.PUT_LINE('The total sum of orders: ' ||RES);
END;
/