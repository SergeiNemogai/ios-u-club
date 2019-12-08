-- setting console output parameters
set colsep '|'
set linesize 167
set pagesize 30
set pagesize 1000

-- tables
SELECT * FROM Branch;
SELECT * FROM Staff;
SELECT * FROM Owner;
SELECT * FROM Property_for_rent;
SELECT * FROM Renter;
SELECT * FROM Viewing;

-- updates
ALTER TABLE Renter MODIFY adress VARCHAR2(30);
UPDATE Renter SET adress='Minsk,Bedi_35' WHERE rno=1;
UPDATE Renter SET adress='Minsk,Moskovsaya_3' WHERE rno=2;
UPDATE Renter SET adress='Brest,Pobedi_83' WHERE rno=3;
UPDATE Renter SET adress='Minsk,Lenina_78' WHERE rno=4;
UPDATE Renter SET adress='Minsk,Rokosovskaya_96' WHERE rno=5;
UPDATE Renter SET adress='Grodno,Chernyakhovskogo_22' WHERE rno=6;
 
-- views
-- с информацией об офисах в Бресте;
CREATE OR REPLACE VIEW branches AS
SELECT * FROM Branch
WHERE city = 'Minsk';

SELECT * FROM branches;

--***** с информацией об объектах недвижимости минимальной стоимости;
CREATE OR REPLACE VIEW min_cost AS
SELECT *
FROM (
    SELECT *
    FROM Property_for_rent
    ORDER BY rent
)
WHERE rownum <=3;

SELECT * FROM min_cost;

-- с информацией о количестве сделанных осмотров с комментариями;
CREATE OR REPLACE VIEW num_views AS
SELECT COUNT(comment_o) AS Num_Views
FROM Viewing;

SELECT * FROM num_views;

-- со сведениями об арендаторах, желающих арендовать 3-х комнатные квартиры в тех же городах, где они проживают;
CREATE OR REPLACE VIEW renter_info AS
SELECT fname, lname, tel_no, adress FROM Renter
INNER JOIN Viewing ON Viewing.rno = Renter.rno
INNER JOIN Property_for_rent ON Property_for_rent.pno = Viewing.pno
WHERE Property_for_rent.rooms = 3 AND Property_for_rent.city = SUBSTR(Renter.adress,1,INSTR(Renter.adress,',')-1);

SELECT * FROM renter_info;

-- со сведениями об отделении с максимальным количеством работающих сотрудников;
CREATE OR REPLACE VIEW max_staff_in_branch AS
SELECT * FROM Branch WHERE bno IN (
    SELECT bno
    FROM Staff
    GROUP BY bno
    HAVING COUNT(bno) = (
        SELECT MAX(COUNT(bno))
        FROM Staff GROUP BY bno
    )
);

SELECT * FROM max_staff_in_branch;

-- с информацией о сотрудниках и объектах, которые они предлагают в аренду в текущем квартале;
CREATE OR REPLACE VIEW staff_info AS
SELECT Staff.fname, Staff.lname, Property_for_rent.street, Property_for_rent.city
FROM Staff
INNER JOIN Property_for_rent ON Property_for_rent.sno = Staff.sno
INNER JOIN Viewing ON Viewing.pno = Property_for_rent.pno
WHERE TO_CHAR(date_o, 'q') IN (SELECT TO_CHAR(SYSDATE,'q') FROM DUAL);

SELECT * FROM staff_info;

-- с информацией о владельцах, чьи дома или квартиры осматривались потенциальными арендаторами более двух раз.
CREATE OR REPLACE VIEW owners_info AS
SELECT * FROM Owner
WHERE ono IN (
    SELECT ono
    FROM Property_for_rent
    WHERE pno IN (
        SELECT pno
        FROM Property_for_rent
        WHERE pno IN (
            SELECT pno
            FROM Viewing
            GROUP BY pno
            HAVING count(pno) >= 2
        )
    )
);

SELECT * FROM owners_info;

-- с информацией о собственниках с одинаковыми именами
CREATE OR REPLACE VIEW owners_names AS
SELECT * FROM Owner
WHERE fname LIKE (
    SELECT fname
    FROM Owner
    GROUP BY fname
    HAVING COUNT(fname)>1
);

SELECT * FROM owners_names;




-- deleting views
DROP VIEW branches;
DROP VIEW min_cost;
DROP VIEW num_views;
DROP VIEW renter_info;
DROP VIEW max_staff_in_branch;
DROP VIEW staff_info;
DROP VIEW owners_info;
DROP VIEW owners_names;