--24 Вариант


-- setting console output parameters
set colsep '|'
set linesize 300
set pagesize 30
set pagesize 1000

--Task
--Создайте запросы: «Материалы заказов малых объемов» (условная выборка);
SELECT order_id FROM Order_information INNER JOIN Product ON Product.product_id = Order_information.product_id WHERE circulation < 10000 ;
--«Общее количество заказов» (итоговый запрос);
SELECT COUNT(product_id) FROM Order_information INNER JOIN Orders ON Orders.order_id = Order_information.order_id;
--«Заказы на заданную сумму» (параметрический запрос);
SELECT * FROM *;
--«Общий список материалов и техники с количеством использумых в заказах» (запрос на объединение), «Количество заказчиков по кварталам» (запрос по полю с типом дата).
SELECT * FROM *;