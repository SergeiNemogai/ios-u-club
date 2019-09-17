CREATE TABLE Branch (
	bno INTEGER NOT NULL PRIMARY KEY,
	street VARCHAR2(30) NOT NULL,
	city VARCHAR2(30) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL UNIQUE);

CREATE TABLE Staff (
	sno INTEGER NOT NULL PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL UNIQUE,
	position VARCHAR2(20) NOT NULL,
	sex char(6) check (sex IN ('male','female')),
	dob date NOT NULL,
	salary INTEGER NOT NULL,
	bno INTEGER NOT NULL,
	CONSTRAINT fk_bno1 FOREIGN KEY (bno) REFERENCES Branch(bno));

CREATE TABLE Property_for_rent (
	pno INTEGER NOT NULL PRIMARY KEY,
	street VARCHAR2(30) NOT NULL,
	city VARCHAR2(30) NOT NULL,
	type char(1) check (type IN('h','f')),
    rooms INTEGER NOT NULL,
	rent INTEGER NOT NULL,
	ono INTEGER NOT NULL,
	sno INTEGER NOT NULL,
	bno INTEGER NOT NULL,
	CONSTRAINT fk_ono FOREIGN KEY (ono) REFERENCES Owner(ono),
	CONSTRAINT fk_sno FOREIGN KEY (sno) REFERENCES Staff(sno),
	CONSTRAINT fk_bno2 FOREIGN KEY (bno) REFERENCES Branch(bno)); 
       
CREATE TABLE Renter(
	rno INTEGER NOT NULL PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
    tel_no VARCHAR2(15) NOT NULL,
    pref_type char(1) check (pref_type IN('h','f')),
	max_rent INTEGER NOT NULL,
	bno INTEGER NOT NULL,
	CONSTRAINT fk_bno3 FOREIGN KEY (bno) REFERENCES Branch(bno));

CREATE TABLE Owner(
	ono INTEGER NOT NULL PRIMARY KEY,
	fname VARCHAR2(20) NOT NULL,
	lname VARCHAR2(20) NOT NULL,
	adress VARCHAR2(20) NOT NULL,
	tel_no VARCHAR2(15) NOT NULL);

CREATE TABLE Viewig(
	rno INTEGER NOT NULL,
	pno INTEGER NOT NULL,
	date_o date NOT NULL,
	comment_o VARCHAR2(100) NOT NULL,
	CONSTRAINT fk_rno FOREIGN KEY (rno) REFERENCES Renter(rno),
	CONSTRAINT fk_pno FOREIGN KEY (pno) REFERENCES Property_for_rent(pno),
	PRIMARY KEY (rno,pno));


INSERT INTO Branch VALUES(1,'Plekhnova','MINsk','345678');
INSERT INTO Branch VALUES(2,'Ordi','MINsk','728443');
INSERT INTO Branch VALUES(3,'Yakubova','MINsk','421532');

INSERT INTO Staff VALUES(1,'Alexander','KokorIN','PushkINa 33','345621', 'worker','male','31-may-93',250,1);
