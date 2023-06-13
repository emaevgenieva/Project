set timing on;

ALTER TABLE customers ADD external_reference VARCHAR2(60);
SELECT * FROM customers;
-- update 36 sec.
UPDATE customers set external_reference = 'EXT'||customer_id WHERE external_reference is NULL;
/
ALTER TABLE customers 
MODIFY external_reference VARCHAR2(60) 
CONSTRAINT external_reference_unique UNIQUE 
CONSTRAINT external_reference_noNull NOT NULL;
/
SELECT * FROM payments;
ALTER TABLE payments add original_payment_id VARCHAR2(60);
ALTER TABLE payments ADD CONSTRAINT original_payment_id FOREIGN KEY (original_payment_id) REFERENCES payments(payment_ID);
SELECT * FROM invoices;
ALTER TABLE invoices add original_invoice_id VARCHAR2(60);
ALTER TABLE invoices ADD CONSTRAINT original_invoice_id FOREIGN KEY (original_invoice_id) REFERENCES invoices(inv_NO);
/
--ALTER TABLE customers ADD CONSTRAINT external_reference_unique UNIQUE (external_reference) NOT NULL;
ALTER TABLE customers 
MODIFY external_reference VARCHAR2(60) 
CONSTRAINT uk_employee_id UNIQUE 
CONSTRAINT nn_employee_id NOT NULL;
/
ALTER TABLE customers 
ADD CONSTRAINT external_reference_unique 
NOT NULL(external_reference) 
UNIQUE(external_reference);
/
create table over_payments (
       invoice_no      varchar2(50),
       payment_id      varchar2(60),
       payment_dt      date,
       amount          number(10,2),
       payment_method  varchar2(10),
       currency        varchar2(3),
       fg_processed    varchar2(1),
       iban            varchar2(60),
       bank_name       varchar2(100),
       created_by      varchar2(50),
       free_text       varchar2(1000),
       original_payment_id varchar2(60),
       constraint op_paym_no_pk primary key (payment_id) ,
       CONSTRAINT op_fk_inv FOREIGN KEY (invoice_no) REFERENCES invoices(inv_no)
);
/
alter table over_payments
   add constraint fk_over_pay_id_orig_paym_id
   foreign key (original_payment_id) references payments(payment_id)
   deferrable initially deferred;
/
commit;
/

--Triger 
CREATE SEQUENCE over_payments_seq
 START WITH     1
 INCREMENT BY   1
 CACHE          100
 NOCYCLE;
 /
CREATE OR REPLACE TRIGGER payments_trigger
BEFORE INSERT ON payments FOR EACH ROW

DECLARE 
overpayment_amount DECIMAL(10,2);
v_invoice_amount DECIMAL(10,2);

BEGIN
SELECT amount INTO v_invoice_amount
FROM invoices
WHERE inv_no = :NEW.invoice_no;

IF :NEW.amount > v_invoice_amount THEN
overpayment_amount := :NEW.amount - v_invoice_amount;
INSERT INTO over_payments (payment_id, payment_dt, amount, invoice_no, original_payment_id)
					   VALUES (over_payments_seq.nextval, SYSDATE,
								overpayment_amount, 
								NULL, :NEW.payment_id);
								
    UPDATE invoices SET amount_due = NULL WHERE inv_no = :NEW.invoice_no;
  ELSE
    UPDATE invoices SET amount_due = amount_due - :NEW.amount WHERE inv_no = :NEW.invoice_no;
  END IF;
END;
/
commit;
/

--Finalna procedura--
BEGIN
Due_Date_Set_Null;
END;
/
BEGIN
Due_Date;
END;
/
commit;
/
-- 14:30 min. / dolnata e 12:30
CREATE OR REPLACE PROCEDURE Due_Date AS
BEGIN
UPDATE INVOICES
SET DUE_DATE = (SELECT
                  CASE
                    WHEN Customers.Credit_Limit < 5000 THEN Invoices.Issue_date + 10
                    WHEN Customers.Credit_Limit > 8000 THEN Invoices.Issue_date + 20
                    ELSE Invoices.Issue_date + 15
                   END
                 FROM CUSTOMERS 
                WHERE Customers.Customer_ID = Invoices.Customer_ID)
WHERE Invoices.Due_date IS NULL;
END;
/
SELECT to_date(to_char(sysdate, 'j')+10, 'j') from dual;
SELECT to_char(sysdate, 'j') from dual;
SELECT to_date(2460019, 'j') from dual;
SELECT to_date(to_char(sysdate, 'j'), 'j') from dual;
/


--NOVA PROCEDURA
CREATE OR REPLACE PROCEDURE Due_Date AS
BEGIN
UPDATE 
(SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE I.Due_Date IS NULL) Proba
SET Proba.Due_Date = 
        CASE 
            WHEN Proba.Credit_Limit < 5000 THEN Proba.Issue_date + 10
            WHEN Proba.Credit_Limit >= 5000 AND Proba.Credit_Limit < 8000 THEN Proba.Issue_date + 15
            ELSE Proba.Issue_date + 20
        END; 
END;
/
CREATE OR REPLACE PROCEDURE Due_Date AS
CURSOR c_Rosen_Proba IS SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date 
FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE C.Customer_ID < 20 ;
r_Rosen_Proba c_Rosen_Proba%ROWTYPE;
BEGIN
OPEN c_Rosen_Proba;
LOOP
FETCH c_Rosen_Proba INTO r_Rosen_Proba;
EXIT WHEN c_Rosen_Proba%NOTFOUND;
UPDATE INVOICES 
SET DUE_DATE = CASE 
WHEN r_Rosen_Proba.Credit_Limit < 5000 THEN r_Rosen_Proba.Issue_date + 10
WHEN r_Rosen_Proba.Credit_Limit >= 5000 AND r_Rosen_Proba.Credit_Limit < 8000 THEN r_Rosen_Proba.Issue_date + 15
ELSE r_Rosen_Proba.Issue_date + 20
END WHERE Inv_NO = r_Rosen_Proba.Inv_NO;
END LOOP;
CLOSE c_Rosen_Proba;
END;
/
--Test za insurt in Customers
insert into CUSTOMERS (customer_id, 
                             first_name,
                             family_name,
                             sex,
                             adr_city, adr_country,
                            credit_limit, email,
                            external_reference)
    VALUES (customers_seq.nextval, 'Rosen', 'Karadzhov4', 'm', 'Sofia', 'Bulgaria', 500, 'testq@mail.bg', 'EXT'||customers_seq.nextval);
    /
select * from customers where First_Name = 'Rosen';
select * from customers 
ORDER BY customer_id DESC;
/
commit;
/
--Test za update DueDate
SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE C.Customer_ID = 8;
/
CREATE OR REPLACE PROCEDURE Due_Date AS
BEGIN
UPDATE INVOICES
SET DUE_DATE = (SELECT
                  CASE
                    WHEN Customers.Credit_Limit < 5000 THEN Invoices.Issue_date + 10
                    WHEN Customers.Credit_Limit > 8000 THEN Invoices.Issue_date + 20
                    ELSE Invoices.Issue_date + 15
                   END
                 FROM CUSTOMERS 
                WHERE Customers.Customer_ID = 6 AND Customers.Customer_ID = Invoices.Customer_ID)
WHERE Invoices.Due_date IS NULL;
END;
/

CREATE OR REPLACE PROCEDURE Due_Date AS
BEGIN
MERGE INTO INVOICES Inv
USING (SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE I.Due_Date IS NULL) Proba
--WHERE C.Customer_ID < 20 AND I.Due_Date IS NULL) Proba
ON (Inv.Inv_NO = Proba.Inv_NO)
WHEN MATCHED THEN
UPDATE SET Inv.Due_Date = 
CASE 
    WHEN Proba.Credit_Limit < 5000 THEN Inv.Issue_date + 10
    WHEN Proba.Credit_Limit >= 5000 AND Proba.Credit_Limit < 8000 THEN Inv.Issue_date + 15
    ELSE Inv.Issue_date + 20
END 
WHERE Inv.Inv_NO = Proba.Inv_NO; 
END;
/
BEGIN
Due_Date;
END;
/
-- SET NULL za DueDate
CREATE OR REPLACE PROCEDURE Due_Date_Set_Null AS
CURSOR c_Rosen_Proba IS SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE C.Customer_ID < 20 AND IDue_Date;
r_Rosen_Proba c_Rosen_Proba%ROWTYPE;
BEGIN
OPEN c_Rosen_Proba;
LOOP
FETCH c_Rosen_Proba INTO r_Rosen_Proba;
EXIT WHEN c_Rosen_Proba%NOTFOUND;
UPDATE INVOICES 
SET DUE_DATE = CASE 
WHEN r_Rosen_Proba.Credit_Limit > 0 THEN NULL
END WHERE Inv_NO = r_Rosen_Proba.Inv_NO;
END LOOP;
CLOSE c_Rosen_Proba;
END;
/
BEGIN
Due_Date_Set_Null;
END;
/
-- NA DOLU SA OPITNI FAILOVE ZA ARHIV KOJTO SI POLZVAM CHAT PAT :))))
SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE C.Customer_ID = 6;
WHERE C.Customer_ID = 6 AND I.Issue_date = '01-12-2022';

/
SELECT I.Customer_ID, I.Inv_NO, I.Issue_date FROM Invoices I
WHERE I.Customer_ID = 6;
/
CREATE OR REPLACE PROCEDURE Due_Date AS
BEGIN
UPDATE INVOICES 
SET DUE_DATE = CASE 
    WHEN Credit_Limit < 5000 THEN INVOICES.Issue_date + 10
    WHEN Credit_Limit >= 5000 AND Credit_Limit < 8000 THEN INVOICES.Issue_date + 15
    ELSE INVOICES.Issue_date + 20
END
WHERE INVOICES.Inv_NO IN (
    SELECT I.Inv_NO 
    FROM Customers C 
    INNER JOIN Invoices I ON C.Customer_ID = I.Customer_id 
    WHERE C.Customer_ID = 6 AND I.Due_date IS NULL);
END;

/
CREATE OR REPLACE PROCEDURE Due_Date AS
Credit_Limit_Rosen NUMBER;
BEGIN
SELECT Credit_Limit INTO Credit_Limit_Rosen FROM Customers WHERE Customer_ID = 6;
DBMS_OUTPUT.PUT_LINE(Credit_Limit_Rosen);
END;
/
BEGIN
Due_Date;
END;
/
CREATE OR REPLACE PROCEDURE Due_Date AS
First_Name1 customers.first_name%TYPE;
Credit_Limit1 customers.credit_limit%TYPE;
inv_no1 invoices.inv_no%TYPE;
issue_date1 invoices.issue_date%TYPE;
Due_Date1 invoice.Due_Date%TYPE;
BEGIN
SELECT first_name, credit_limit, Inv_NO, Issue_date, Due_Date
INTO First_Name1, Credit_Limit1, inv_no1, issue_date1, Due_Date1
FROM Customers 
INNER JOIN Invoices USING (Customer_id)
WHERE Due_Date IS NULL;
DBMS_OUTPUT.PUT_LINE(First_Name1||' '|| Credit_Limit1||' '||inv_no1||' '||issue_date1);
END;
/
BEGIN
Due_Date_Set_Null;
END;
/
SELECT C.Customer_ID, C.First_Name, C.Credit_Limit, I.Inv_NO, I.Issue_date, I.Due_Date FROM Customers C
INNER JOIN Invoices I
ON C.Customer_ID = I.Customer_id 
WHERE C.Customer_ID = 6;
/
set timing on;
/
commit;
/
select * from invoices 
where customer_id = 6;
select * from invoices 
where inv_no = '6_1_20221201';
select * from customers 
where customer_id = 6;
/
INSERT INTO payments ( /* 01*/ invoice_no,  
									/* 02*/ payment_id, 
									/* 03*/ payment_dt, 
									/* 04*/ amount, 
									/* 05*/ payment_method, 
									/* 06*/ currency )
									
							VALUES (/* 01*/ '6_1_20221201', 
									/* 02*/ payments_seq.nextval, 
									/* 03*/ SYSDATE,
									/* 04*/ 125, 
									/* 05*/ 'bank', 
									/* 06*/ 'BGN');
/
6_40_20230215
6_1_20221201
/
select * from over_payments;
SELECT i.amount, p.payment_id 
FROM invoices i, payments p
WHERE i.inv_no = '6_1_20221201';
/
-- Posledni testowe
select * from payments
where invoice_no = '6_1_20221201';
/

select * from invoices
ORDER BY ISSUE_DATE DESC;
select * from invoices
where customer_id = 6;

delete from over_payments where payment_id = 22;
select * from payments
where payment_id = 13034721;
select * from payments
where payment_id = 13034816;
/
UPDATE over_payments SET amount = 5 WHERE payment_id = 23;
/
select * from over_payments;
/
select * from invoices
where inv_no = '6_1_20221201';
/
update invoices set amount_due = 15 where inv_no = '6_1_20221201';
/
INSERT INTO invoices 	  ( /* 01*/ inv_no,  
													/* 02*/ amount, 
													/* 03*/ amount_due, 
													/* 04*/ currency, 
													/* 05*/ issue_date, 
													/* 06*/ due_date, 
													/* 07*/ customer_id, 
													/* 08*/ seq,
													/* 09*/ original_invoice_id
													)
							  VALUES (/* 01*/ 63||'_'||34||'_'||SYSDATE, 
									  /* 02*/ 0.90, 
									  /* 03*/ NULL, 
									  /* 04*/ 'BGN', 
									  /* 05*/ SYSDATE, 
									  /* 06*/ NULL, 
									  /* 07*/ 63, 
									  /* 08*/ 34,
									  /* 09*/ '63_31_20230101'
									  );
/

select * from customers 
where customer_id = 63;

select * from payments
where invoice_no = '64_28_20230101';
/
 SELECT inv_no, amount , currency, customer_id
				FROM invoices
			   WHERE amount_due IS NOT NULL  AND TRUNC(SYSDATE - due_date) > 5 AND original_invoice_id IS NULL AND customer_id = 63;	
/
SELECT TO_CHAR(TO_DATE('63_31_20230101', 'DDMMYYYY'), 'YYYYMMDD') from dual;
delete from invoices where customer_id = 63 and SEQ = 35;
select TO_CHAR(TO_DATE(SYSDATE, 'DD-MM-YYYY'), "MMDDYYYY') from dual;
select sysdate from dual;
/
SELECT TO_CHAR(TO_DATE(SYSDATE), 'MMDDYYYY') FROM dual;
/
SELECT ov.payment_id, ov.amount, i.inv_no, i.amount, i.amount_due
			  FROM over_payments ov, payments p, invoices i
			  WHERE p.payment_id = ov.original_payment_id and 
							 i.amount_due > 0 and 
							 i.customer_id = 6;
--							 p.invoice_no = NULL;
/
INSERT INTO payments ( /* 01*/ invoice_no,  
									/* 02*/ payment_id, 
									/* 03*/ payment_dt, 
									/* 04*/ amount, 
									/* 05*/ payment_method, 
									/* 06*/ currency )
									
							VALUES (/* 01*/ '6_1_20221201', 
									/* 02*/ payments_seq.nextval, 
									/* 03*/ SYSDATE,
									/* 04*/ 135, 
									/* 05*/ 'bank', 
									/* 06*/ 'BGN');
/
CREATE OR REPLACE TRIGGER payments_trigger
BEFORE INSERT ON payments FOR EACH ROW

DECLARE 
overpayment_amount DECIMAL(10,2);
v_invoice_amount_due DECIMAL(10,2);

BEGIN
SELECT amount_due INTO v_invoice_amount_due
FROM invoices
WHERE inv_no = :NEW.invoice_no;

IF :NEW.amount > v_invoice_amount_due THEN
overpayment_amount := :NEW.amount - v_invoice_amount_due;
INSERT INTO over_payments (payment_id, payment_dt, amount, invoice_no, original_payment_id)
					   VALUES (over_payments_seq.nextval, SYSDATE,
								overpayment_amount, 
								NULL, :NEW.payment_id);
								
    UPDATE invoices SET amount_due = NULL WHERE inv_no = :NEW.invoice_no;
  ELSE
    UPDATE invoices SET amount_due = amount_due - :NEW.amount WHERE inv_no = :NEW.invoice_no;
  END IF;
END;
/
DROP TRIGGER payments_trigger;
INSERT INTO payments(payment_id, invoice_no, amount) VALUES (payments_seq.nextval,'6_1_20221201' , 98);
/
SELECT ov.payment_id, ov.amount, i.inv_no, i.amount, i.amount_due
			  FROM over_payments ov, payments p, invoices i
			  WHERE p.payment_id = ov.original_payment_id and 
							 i.amount_due > 0
                             and i.customer_id = 6;
/
