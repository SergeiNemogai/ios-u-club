UPDATE Orders SET order_cost=2000.56 WHERE order_id=1;
UPDATE Orders SET order_cost=1990.899 WHERE order_id=3;

-- Написать процедуру, которая выводит информацию о контрактах,
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
        DBMS_OUTPUT.PUT_LINE('There is no order with such cost.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR.');

END;
/


BEGIN
INFO(3000);
END;
/

BEGIN
INFO(2000);
END;
/

BEGIN
INFO('sss');
END;
/


-- Создать функцию, подсчитывающую количество заключенных контрактов
-- за текущий год. В вызывающую среду возвращать общую сумму этих
-- контрактов в параметре OUT.

CREATE OR REPLACE FUNCTION NUM_OF_CONTRACTS
RETURN NUMBER IS
RESULT NUMBER;
CURSOR CONTRACT IS SELECT count(order_id) AS num, SUM(order_cost) AS sum FROM Orders WHERE TO_CHAR(order_date, 'yyyy') = (SELECT TO_CHAR(sysdate,'yyyy') FROM dual);
CONTRACT_INFO CONTRACT%ROWTYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE(' ');

    OPEN CONTRACT;
    FETCH CONTRACT INTO CONTRACT_INFO;

    IF CONTRACT%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('The total num of orders: ' ||CONTRACT_INFO.num);
        RESULT := CONTRACT_INFO.sum;
    END IF;
    CLOSE CONTRACT;

    RETURN RESULT;
END;
/


DECLARE
RES NUMBER;
BEGIN
RES := NUM_OF_CONTRACTS();
DBMS_OUTPUT.PUT_LINE('The total sum of orders: ' ||RES);
END;
/


