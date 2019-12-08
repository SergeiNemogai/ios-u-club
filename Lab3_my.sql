-- setting console output parameters
set colsep '|'
set linesize 167
set pagesize 30
set pagesize 1000

-- tables
SELECT * FROM Customer;
SELECT * FROM Orders;
SELECT * FROM Order_information;
SELECT * FROM Product;
SELECT * FROM Material;
SELECT * FROM Equipment;


-- Создать представление, показывающее информацию о заказах,
-- тип продукта которого является Флексографической печатной машиной.
-- (горизонтальное обновляемое представление)
CREATE OR REPLACE VIEW orders AS
SELECT * FROM Order_information
WHERE product_id IN (
    SELECT product_id
    FROM Product
    INNER JOIN Equipment ON Equipment.equipment_id = Product.equipment_id
    WHERE Equipment.equipment_type = 'Flexographic printing machines'
);

SELECT * FROM orders;


--необновляемое
-- вертикальное представление
CREATE OR REPLACE VIEW products AS
SELECT Product.title, Product.price, Product.production_time,
Product.circulation, Equipment.equipment_type, Material.material_type
FROM Product
INNER JOIN Equipment ON Equipment.equipment_id = Product.equipment_id
INNER JOIN Material ON Material.material_id = Product.material_id;

CREATE OR REPLACE VIEW products AS
SELECT Equipment.equipment_type, Material.material_type
FROM Product
INNER JOIN Equipment ON Equipment.equipment_id = Product.equipment_id
INNER JOIN Material ON Material.material_id = Product.material_id;

INSERT INTO products (title,price,production_time,circulation,equipment_type,material_type) VALUES ('avc',101,2,1001,'dsgs','gjfjgf');

-- UPDATE products SET price = 3000;
UPDATE Product SET price = 1000 WHERE product_id = 1;   
UPDATE Product SET price = 3000 WHERE product_id = 2;
UPDATE Product SET price = 1500 WHERE product_id = 3;
UPDATE Product SET price = 1400 WHERE product_id = 4;
UPDATE products SET equipment_type = 'test' WHERE material_type ='Offset paper';

SELECT * FROM products;

--  Проверить обновляемость горизонтального представления
-- с фразой WITH CHECK OPTION при помощи инструкций UPDATE,
-- DELETE или INSERT (привести пример правильной и неправильной инструкции)
UPDATE Equipment SET production_country='USA' WHERE equipment_id=3;

CREATE OR REPLACE VIEW upd_view AS
SELECT * FROM Equipment WHERE production_country = 'USA'
WITH CHECK OPTION CONSTRAINT production_usa;

INSERT INTO upd_view (equipment_type,equipment_model,manufacturer,production_country,price,production_date) VALUES ('test machine 1','model1','company1','USA',15001,5);
INSERT INTO upd_view (equipment_type,equipment_model,manufacturer,production_country,price,production_date) VALUES ('test machine 2','model2','company2','Russia',15002,6);

SELECT * FROM upd_view;

-- Создать обновляемое представление для работы с одной из
-- родитель-ских таблиц индивидуальной БД и через него
-- разрешить работу с данными только в рабочие дни
-- (с понедельника по пятницу) и в рабочие часы (с 9:00 до 18:00)
CREATE OR REPLACE VIEW work_time AS
SELECT * FROM Customer
WHERE (SELECT TO_CHAR(sysdate,'d') FROM dual) BETWEEN 2 AND 6 
AND (SELECT TO_CHAR(sysdate, 'hh24:mi:ss') FROM dual) BETWEEN TO_CHAR('09:00:00') AND TO_CHAR('18:00:00');

SELECT * FROM work_time; 