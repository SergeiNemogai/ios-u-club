--9 Вариант

-- setting console output parameters
set colsep '|'
set linesize 300
set pagesize 30
set pagesize 1000

--TASK
--Определить, сколькими арендаторами и сколько объектов было осмотрено в течение года.
SELECT COUNT(DISTINCT rno), COUNT(DISTINCT pno) FROM Viewing WHERE date_o BETWEEN '01-jan-06' and '01-jan-07';
SELECT COUNT(DISTINCT rno), COUNT(DISTINCT pno) FROM Viewing WHERE TO_CHAR(date_o, 'YYYY') BETWEEN (EXTRACT(YEAR FROM sysdate)-19) AND EXTRACT(YEAR FROM sysdate);
--в течении года указывать как год,

--Создать список сотрудников, предлагающих объекты недвижимости в Минске.
SELECT DISTINCT fname, lname FROM Staff INNER JOIN Property_for_rent ON Property_for_rent.sno = Staff.sno WHERE city='Minsk';

--Определить суммарную рентную стоимость объектов в Минске и объектов в Гродно. Вывести город и сумму.
SELECT SUM(rent), Property_for_rent.city FROM Property_for_rent WHERE city = 'Minsk' OR city = 'Grodno';

--*Вывести информацию о владельцах квартир, стоимость которых больше чем стоимость любой квартиры одного конкретно указанного владельца.
SELECT fname, lname FROM Owner INNER JOIN Property_for_rent ON Property_for_rent.ono = Owner.ono WHERE rent> ANY (SELECT rent FROM Property_for_rent INNER JOIN Owner ON Owner.ono = Property_for_rent.ono where fname = 'Igor');
SELECT fname, lname FROM Owner INNER JOIN Property_for_rent ON Property_for_rent.ono = Owner.ono WHERE rent > (SELECT rent FROM Property_for_rent where fname = 'Igor');

--запрос на множественную проверку(any-all)