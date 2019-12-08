--24 Вариант


-- setting console output parameters
set colsep '|'
set linesize 300
set pagesize 30
set pagesize 1000

-- Task
-- «Материалы заказов малых объемов» (условная выборка);
SELECT Material.material_id, Material.material_type, Material.manufacturer, Material.price
FROM Order_information 
INNER JOIN Product ON Product.product_id = Order_information.product_id
INNER JOIN Material ON Material.material_id = Product.material_id
WHERE circulation = (
    SELECT MIN(circulation)
    FROM Product
);


-- «Общее количество заказов по каждому клиету» (итоговый запрос);
SELECT Customer.customer_id, Customer.last_name, COUNT(*) AS Num_of_orders
FROM Orders
INNER JOIN Customer ON Customer.customer_id = Orders.customer_id
GROUP BY Customer.customer_id,  Customer.last_name;


-- «Заказы на заданную сумму» (параметрический запрос);
SELECT Customer.last_name, Customer.first_name, Customer.telephone_number, Orders.order_cost, Orders.order_date
FROM Orders
INNER JOIN Customer ON Customer.customer_id = Orders.customer_id
WHERE order_cost BETWEEN &min_cost AND &max_cost ;


-- «Общий список материалов и техники с количеством использумых в заказах» (запрос на объединение)
SELECT Material.material_type AS List, COUNT(Product.material_id) AS Num
FROM Material
INNER JOIN Product ON Product.material_id = Material.material_id
INNER JOIN Order_information ON Order_information.product_id = Product.product_id
GROUP BY Product.material_id, Material.material_type
UNION
SELECT Equipment.equipment_type, COUNT(Product.equipment_id)
FROM Equipment
INNER JOIN Product ON Product.equipment_id = Equipment.equipment_id
INNER JOIN Order_information ON Order_information.product_id = Product.product_id
GROUP BY Product.equipment_id, Equipment.equipment_type

-- «Количество заказчиков по кварталам» (запрос по полю с типом дата)
SELECT COUNT(customer_id) AS Num_of_customers, TO_CHAR(order_date, 'q') AS Quarter
FROM Orders
GROUP BY TO_CHAR(order_date, 'q')



-- «Вывести фамилию покупателя и сделанные им заказы, включающие номер продукта» (JOIN ... USING)
SELECT last_name,order_id,product_id
FROM Customer
JOIN Orders USING (customer_id)
JOIN Order_information USING (order_id);

-- «Фамилии и номера соответствующих заказов»(LEFT JOIN)
SELECT Customer.last_name, Orders.order_id
FROM Customer
LEFT JOIN Orders ON Customer.customer_id = Orders.customer_id
ORDER BY Customer.last_name;

-- «Информация  о продуктах, оборудование которого произведено в Японии» (IN)
UPDATE Equipment SET production_country='USA' WHERE equipment_id=3;

SELECT *
FROM Product
WHERE equipment_id IN (
    SELECT equipment_id
    FROM Equipment
    WHERE production_country = 'Japan'
);

-- «Иформация об оборудовании, цена которого больше чем цена любого оборудования произведенного указанной компанией» (ANY)
SELECT *
FROM Equipment
WHERE price > ANY (
    SELECT price
    FROM Equipment
    WHERE manufacturer = 'Sakurai'
) AND  manufacturer <> 'Sakurai';


-- «Продукты которые не были заказаны» (NOT EXISTS)
SELECT *
FROM Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Order_information
    WHERE Order_information.product_id = Product.product_id
);
