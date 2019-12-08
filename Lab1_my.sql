CREATE TABLE Customer (
	customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	last_name VARCHAR2(20) NOT NULL,
	first_name VARCHAR2(20) NOT NULL,
	telephone_number VARCHAR2(15) NOT NULL UNIQUE,
	--telephone_number VARCHAR2(15) CHECK(REGEXP_LIKE(telephone_number, '[0-9]{2}[-][0-9]{2}[0-9]{2}')),
	mail VARCHAR2(30) NOT NULL,
	discount INTEGER NOT NULL);


CREATE TABLE Orders (
	order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_id INTEGER,
	order_cost NUMBER(*,2) NOT NULL,
	order_date DATE NOT NULL,
	status CHAR(1) CHECK (status IN('y','n')),
	CONSTRAINT fk_cust_id FOREIGN KEY (customer_id) REFERENCES Customer(customer_id));

-- check regex(telephone number)
-- ordercost and price change type-done

CREATE TABLE Material (
	material_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	material_type VARCHAR2(40) NOT NULL,
	manufacturer VARCHAR2(40) NOT NULL,
	price NUMBER(*,2) NOT NULL);


CREATE TABLE Equipment (
	equipment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	equipment_type VARCHAR2(40) NOT NULL,
	equipment_model VARCHAR2(40) NOT NULL,
	manufacturer VARCHAR2(40) NOT NULL,
	production_country VARCHAR2(20) NOT NULL,
	price NUMBER(*,2) NOT NULL,
	production_date INTEGER NOT NULL);


CREATE TABLE Product (
	product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	title VARCHAR2(40) NOT NULL,
	price NUMBER(*,2) NOT NULL,
	production_time INTEGER NOT NULL,
    circulation INTEGER NOT NULL,
    equipment_id INTEGER,
	material_id INTEGER,
	CONSTRAINT fk_equipment FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
	CONSTRAINT fk_material FOREIGN KEY (material_id) REFERENCES Material(material_id));


CREATE TABLE Order_information (
	order_id INTEGER,
	product_id INTEGER,
	CONSTRAINT order_id FOREIGN KEY (order_id) REFERENCES Orders(order_id),
	CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES Product(product_id),
	PRIMARY KEY (order_id,product_id));

-- CREATE SEQUENCE Customer_seq START WITH 1 INCREMENT BY 1 NOCACHE;
-- CREATE SEQUENCE Order_seq START WITH 1 INCREMENT BY 1 NOCACHE;
-- CREATE SEQUENCE Material_seq START WITH 1 INCREMENT BY 1 NOCACHE;
-- CREATE SEQUENCE Equipment_seq START WITH 1 INCREMENT BY 1 NOCACHE;
-- CREATE SEQUENCE Product_seq START WITH 1 INCREMENT BY 1 NOCACHE;


-- synonyms
CREATE PUBLIC SYNONYM Ord FOR tkv4.Orders;

-- indexes
CREATE INDEX indx_for_product ON Product(title);



-- iserting into Customer
insert Into Customer (last_name,first_name,telephone_number,mail,discount) values('Kokorin','Alexander','46-43-88','butyrka@gmail.com',0);
insert Into Customer (last_name,first_name,telephone_number,mail,discount) values('Mamaev','Pavel','76-48-02','monako2016@mail.ru',0);
insert Into Customer (last_name,first_name,telephone_number,mail,discount) values('Berezuckiy','Vasya','36-43-18','vasyabereza@gmail.ru',0);
insert Into Customer (last_name,first_name,telephone_number,mail,discount) values('Zhirkov','Yuriy','76-45-21','yra_chelsea@mail.ru',0);
insert Into Customer (last_name,first_name,telephone_number,mail,discount) values('Arshavin','Andrey','86-54-64','poker@gmail.com',0);


-- iserting into Orders
insert into Orders (customer_id,order_cost,order_date,status) values(3,3000.354,'29-september-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(4,2000,'30-september-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(2,2000,'1-october-2019','y');
insert into Orders (customer_id,order_cost,order_date,status) values(1,3000.199,'19-november-2019','y');

-- iserting into Material
insert into Material (material_type,manufacturer,price) values('Offset paper','Lumiset',1000);
insert into Material (material_type,manufacturer,price) values('Digital Printing Paper','Xerox',1500);
insert into Material (material_type,manufacturer,price) values('Thermal transfer tape','Leonhard KURZ',5000);
insert into Material (material_type,manufacturer,price) values('T-shirt','Suzor`e',200);
insert into Material (material_type,manufacturer,price) values('Printing ink','Sun cemical',1100);
insert into Material (material_type,manufacturer,price) values('Offset ink','Sunlit Diamond',2000);
insert into Material (material_type,manufacturer,price) values('Lamination film','FSD',1600);


-- iserting into Equipment
insert into Equipment (equipment_type,equipment_model,manufacturer,production_country,price,production_date) values('Offset printing machines','SAKURAI OLIVER 266EZP','Sakurai','Japan',80000,2);
insert into Equipment (equipment_type,equipment_model,manufacturer,production_country,price,production_date) values('Flexographic printing machines','Taiyo STF-460-8F','Taiyo','Japan',230000,3);
insert into Equipment (equipment_type,equipment_model,manufacturer,production_country,price,production_date) values('Digital printing machines','RICOH PRO С5100S','Ricoh','Japan',30000,4);
insert into Equipment (equipment_type,equipment_model,manufacturer,production_country,price,production_date) values('Screen printing Machines','SAKURAI MS-72A','Sakurai','Japan',15000,1);



-- iserting into Product
insert into Product (title,price,production_time,circulation,equipment_id,material_id) values('Offset printing',1000,2,1000,1,1);
insert into Product (title,price,production_time,circulation,equipment_id,material_id) values('Flexographic printing',3000,3,10000,2,3);
insert into Product (title,price,production_time,circulation,equipment_id,material_id) values('Digital printing',1500,2,10000,3,2);
insert into Product (title,price,production_time,circulation,equipment_id,material_id) values('Silk screen printing',1400,2,1000,4,7);


-- iserting into Order_information
insert into Order_information values(1,1);
insert into Order_information values(2,2);
insert into Order_information values(3,2);




-- setting console output parameters
set colsep '|'
set linesize 300
set pagesize 30
set pagesize 1000

-- output
SELECT * FROM Customer;
SELECT * FROM Orders;
SELECT * FROM Order_information;
SELECT * FROM Product;
SELECT * FROM Material;
SELECT * FROM Equipment;



-- dropping tables and sequences
DROP TABLE tkv4.Customer CASCADE CONSTRAINTS;
DROP TABLE tkv4.Orders CASCADE CONSTRAINTS;
DROP TABLE tkv4.Order_information CASCADE CONSTRAINTS;
DROP TABLE tkv4.Product CASCADE CONSTRAINTS;
DROP TABLE tkv4.Material CASCADE CONSTRAINTS;
DROP TABLE tkv4.Equipment CASCADE CONSTRAINTS;
DROP PUBLIC SYNONYM Ord;
--DROP INDEX indx_for_product;

-- DROP SEQUENCE Customer_seq;
-- DROP SEQUENCE Order_seq;
-- DROP SEQUENCE Material_seq;
-- DROP SEQUENCE Equipment_seq;
-- DROP SEQUENCE Product_seq;

CREATE TABLE Tel (
	telephone_number VARCHAR2(15) CHECK(REGEXP_LIKE(telephone_number, '[0-9]{2,3}-[0-9]{2,3}-[0-9]{2,3}')));

DROP TABLE tkv4.Tel CASCADE CONSTRAINTS;