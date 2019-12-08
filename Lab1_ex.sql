-- connection
/*
Run console -> sqlplus -> / as sysdba -> connect login/password.
*/


-- creating tables
CREATE TABLE Branch (
	bno INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	street VARCHAR2(30) NOT NULL,
	city VARCHAR2(30) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL UNIQUE);

CREATE TABLE Staff (
	sno INTEGER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL UNIQUE,
	position VARCHAR2(20) NOT NULL,
	-- dobavit vmesto char varchar
	sex CHAR(6) CHECK (sex IN ('male','female')),
	dob DATE NOT NULL,
	salary INTEGER NOT NULL,
	bno INTEGER,
	CONSTRAINT fk_bno1 FOREIGN KEY (bno) REFERENCES Branch(bno));

CREATE TABLE Owner(
	ono INTEGER NOT NULL PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL);

CREATE TABLE Property_for_rent (
	pno INTEGER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	street VARCHAR2(30) NOT NULL,
	city VARCHAR2(30) NOT NULL,
	type CHAR(1) CHECK (type IN('h','f')),
    rooms INTEGER NOT NULL,
	rent INTEGER NOT NULL,
	bno INTEGER,
	sno INTEGER,
	ono INTEGER,
	CONSTRAINT fk_ono FOREIGN KEY (ono) REFERENCES Owner(ono),
	CONSTRAINT fk_sno FOREIGN KEY (sno) REFERENCES Staff(sno),
	CONSTRAINT fk_bno2 FOREIGN KEY (bno) REFERENCES Branch(bno));

CREATE TABLE Renter(
	rno INTEGER  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
    tel_no VARCHAR2(15) NOT NULL,
    pref_type CHAR(1) CHECK (pref_type IN('h','f')),
	max_rent INTEGER NOT NULL,
	bno INTEGER,
	CONSTRAINT fk_bno3 FOREIGN KEY (bno) REFERENCES Branch(bno));

CREATE TABLE Viewing(
	rno INTEGER,
	pno INTEGER,
	date_o date NOT NULL,
	comment_o VARCHAR2(100) NOT NULL,
	CONSTRAINT fk_rno FOREIGN KEY (rno) REFERENCES Renter(rno),
	CONSTRAINT fk_pno FOREIGN KEY (pno) REFERENCES Property_for_rent(pno),
	PRIMARY KEY (rno,pno));


--CREATE SEQUENCE Staff_seq START WITH 10 INCREMENT BY 5 NOCACHE;


-- iserting into Branch
INSERT INTO Branch (street,city,tel_no) VALUES('Plekhnova','Minsk','345678');
INSERT INTO Branch (street,city,tel_no) VALUES('Ordi','Minsk','728443');
INSERT INTO Branch (street,city,tel_no) VALUES('Yakubova','Minsk','421532');
INSERT INTO Branch (street,city,tel_no) VALUES('Bobruiskaya','Minsk','332829');
INSERT INTO Branch (street,city,tel_no) VALUES('Platonova','Minsk','982321');
INSERT INTO Branch (street,city,tel_no) VALUES('Kuprevicha','Minsk','543321');
INSERT INTO Branch (street,city,tel_no) VALUES('Pobedy','Grodno','523521');


-- iserting into Staff
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Alexander','Kokorin','Pushkina_33','345621', 'worker','male','1-may-93',250,1);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Igor','Akinfeev','Pushkina_34','345622', 'worker','male','2-june-94',251,2);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Pavel','Mamaev','Pushkina_35','345623', 'worker','male','3-july-95',252,3);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Yuriy','Zhirkov','Pushkina_36','345624', 'worker','male','4-august-96',253,4);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Andrey','Arshavin','Pushkina_37','345625', 'worker','male','5-september-97',254,5);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Valeriya','Lopyreva','Pushkina_38','345626', 'worker','female','6-october-98',255,6);
INSERT INTO Staff (fname,lname,adress,tel_no,position,sex,dob,salary,bno) VALUES('Tina','Kandelaki','Pushkina_39','345627', 'worker','female','6-october-95',256,6);

-- iserting into Owner
INSERT INTO Owner (ono, fname, lname, adress, tel_no) SELECT sno, fname, lname, adress, tel_no FROM Staff;
INSERT INTO Owner (ono,fname,lname,adress,tel_no) VALUES(7,'Alexander','Golovin','Pushkina_40','345628');


-- iserting into Property_for_rent
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Pobedy_21','Minsk','h',3,5,1,1,1);
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Moskovskiy_41','Vitebsk','f',4,6,2,2,2);
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Sovetskaya_9','Gomel','f',5,7,3,3,3);
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Zhukova_65','Moscow','h',6,8,4,4,4);
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Lenina_53','Brest','f',7,9,5,5,5);
INSERT INTO Property_for_rent (street,city,type,rooms,rent,bno,sno,ono) VALUES('Ligovskiy_16','Saint-Petersburg','h',8,10,6,6,6);


-- iserting into Renter
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Frenkie','De-Yong','Bedi_35','998877','h',1,1);
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Arthur','Melo','Moskovsaya_3','887766','h',2,2);
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Marc-Andre','Ter-Stegen','Pobedi_83','776655','f',3,3);
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Sergi','Roberto','Lenina_78','665544','h',4,4);
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Nelson','Semedo','Rokosovskaya_96','554433','f',5,5);
INSERT INTO Renter (fname,lname,adress,tel_no,pref_type,max_rent,bno) VALUES('Clement','Langlet','Chernyakhovskogo_22','443322','f',6,6);


-- iserting into Viewing
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(1,1,'1-may-01','Com1');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(2,2,'2-may-02','Com2');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(3,3,'3-may-03','Com3');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(4,4,'4-may-04','Com4');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(5,5,'5-may-05','Com5');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(3,4,'5-jan-05','Com5');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(6,6,'6-may-06','Com6');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(1,6,'4-nov-2019','Com6');
INSERT INTO Viewing (rno,pno,date_o,comment_o) VALUES(3,2,'5-nov-2019','Com7');



-- setting console output parameters
set colsep '|'
set linesize 167
set pagesize 30
set pagesize 1000

-- output
SELECT * FROM Branch;
SELECT * FROM Staff;
SELECT * FROM Owner;
SELECT * FROM Property_for_rent;
SELECT * FROM Renter;
SELECT * FROM Viewing;
 


-- dropping tables and sequences
DROP TABLE tramp4.Branch CASCADE CONSTRAINTS;
DROP TABLE tramp4.Staff CASCADE CONSTRAINTS;
DROP TABLE tramp4.Owner CASCADE CONSTRAINTS;
DROP TABLE tramp4.Property_for_rent CASCADE CONSTRAINTS;
DROP TABLE tramp4.Renter CASCADE CONSTRAINTS;
DROP TABLE tramp4.Viewing CASCADE CONSTRAINTS;
--DROP SEQUENCE Staff_seq;