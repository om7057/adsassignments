BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Fact_Order CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Customer CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Store CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Item CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Time CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Stored_Items CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Stores CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE Headquarters CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE Dim_Customer (
    Customer_id NUMBER PRIMARY KEY,
    Customer_name VARCHAR2(255),
    City_id NUMBER,
    First_order_date DATE
);

CREATE TABLE Dim_Store (
    Store_id NUMBER PRIMARY KEY,
    City_id NUMBER,
    Phone VARCHAR2(20)
);

CREATE TABLE Dim_Item (
    Item_id NUMBER PRIMARY KEY,
    Description VARCHAR2(255),
    Item_Size VARCHAR2(50),
    Weight NUMBER(10,2),
    Unit_price NUMBER(10,2)
);

CREATE TABLE Dim_Time (
    Time_id NUMBER PRIMARY KEY,
    Order_date DATE
);

CREATE TABLE Fact_Order (
    Order_no NUMBER PRIMARY KEY,
    Customer_id NUMBER,
    Store_id NUMBER,
    Item_id NUMBER,
    Quantity_ordered NUMBER,
    Ordered_price NUMBER(10,2),
    Time_id NUMBER,
    FOREIGN KEY (Customer_id) REFERENCES Dim_Customer(Customer_id),
    FOREIGN KEY (Store_id) REFERENCES Dim_Store(Store_id),
    FOREIGN KEY (Item_id) REFERENCES Dim_Item(Item_id),
    FOREIGN KEY (Time_id) REFERENCES Dim_Time(Time_id)
);

CREATE TABLE Stores (
    Store_id NUMBER PRIMARY KEY,
    City_id NUMBER,
    Phone VARCHAR2(20)
);

CREATE TABLE Stored_Items (
    Store_id NUMBER,
    Item_id NUMBER,
    Quantity_held NUMBER,
    PRIMARY KEY (Store_id, Item_id),
    FOREIGN KEY (Store_id) REFERENCES Stores(Store_id),
    FOREIGN KEY (Item_id) REFERENCES Dim_Item(Item_id)
);

CREATE TABLE Headquarters (
    City_id NUMBER PRIMARY KEY,
    City_name VARCHAR2(255),
    Headquarter_addr VARCHAR2(255),
    State VARCHAR2(100)
);

INSERT INTO Dim_Customer VALUES (1, 'Rajesh Sharma', 1, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO Dim_Customer VALUES (2, 'Priya Patel', 2, TO_DATE('2023-02-20', 'YYYY-MM-DD'));

INSERT INTO Dim_Store VALUES (1, 1, '123-456-7890');
INSERT INTO Dim_Store VALUES (2, 2, '234-567-8901');

INSERT INTO Dim_Item VALUES (1, 'Saree', 'Free size', 0.5, 499.99);
INSERT INTO Dim_Item VALUES (2, 'Kurta', 'Large', 0.4, 399.99);

INSERT INTO Dim_Time VALUES (1, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO Dim_Time VALUES (2, TO_DATE('2023-02-20', 'YYYY-MM-DD'));

INSERT INTO Fact_Order VALUES (1, 1, 1, 1, 2, 999.98, 1);
INSERT INTO Fact_Order VALUES (2, 2, 2, 2, 1, 399.99, 2);

INSERT INTO Stores VALUES (1, 1, '123-456-7890');
INSERT INTO Stores VALUES (2, 2, '234-567-8901');

INSERT INTO Stored_Items VALUES (1, 1, 100);
INSERT INTO Stored_Items VALUES (2, 2, 30);

INSERT INTO Headquarters VALUES (1, 'Mumbai', 'HQ Road, Mumbai', 'Maharashtra');
INSERT INTO Headquarters VALUES (2, 'Delhi', 'HQ Street, Delhi', 'Delhi');

COMMIT;

CREATE TABLE Order_Aggregate AS
SELECT 
    c.Customer_id, 
    c.City_id AS Customer_City, 
    s.Store_id, 
    s.City_id AS Store_City,
    i.Item_id, 
    t.Time_id, 
    SUM(f.Ordered_price) AS Total_Sales, 
    SUM(f.Quantity_ordered) AS Total_Quantity
FROM Fact_Order f
JOIN Dim_Customer c ON f.Customer_id = c.Customer_id
JOIN Dim_Store s ON f.Store_id = s.Store_id
JOIN Dim_Item i ON f.Item_id = i.Item_id
JOIN Dim_Time t ON f.Time_id = t.Time_id
GROUP BY c.Customer_id, c.City_id, s.Store_id, s.City_id, i.Item_id, t.Time_id;

SELECT s.Store_id, s.City_id, s.Phone, i.Description, i.Item_Size, i.Weight, i.Unit_price
FROM Dim_Store s
JOIN Fact_Order f ON s.Store_id = f.Store_id
JOIN Dim_Item i ON f.Item_id = i.Item_id
WHERE i.Description = 'Saree';

SELECT o.Order_no, c.Customer_name, t.Order_date
FROM Fact_Order o
JOIN Dim_Customer c ON o.Customer_id = c.Customer_id
JOIN Dim_Time t ON o.Time_id = t.Time_id
WHERE o.Store_id = 1;

SELECT DISTINCT s.Store_id, h.City_name, s.Phone
FROM Fact_Order f
JOIN Dim_Store s ON f.Store_id = s.Store_id
JOIN Headquarters h ON s.City_id = h.City_id
WHERE f.Customer_id = 1;

SELECT h.Headquarter_addr, h.City_name, h.State
FROM Stored_Items si
JOIN Stores s ON si.Store_id = s.Store_id
JOIN Headquarters h ON s.City_id = h.City_id
WHERE si.Quantity_held > 50;

SELECT f.Order_no, i.Description, f.Store_id, h.City_name
FROM Fact_Order f
JOIN Dim_Item i ON f.Item_id = i.Item_id
JOIN Stores s ON f.Store_id = s.Store_id
JOIN Headquarters h ON s.City_id = h.City_id;

SELECT 
    s.Store_id, 
    h.City_name, 
    si.Quantity_held
FROM Stored_Items si
JOIN Stores s ON si.Store_id = s.Store_id
JOIN Headquarters h ON s.City_id = h.City_id
WHERE si.Item_id = 1 AND h.City_name = 'Mumbai'; 


SELECT 
    f.Order_no, 
    i.Description, 
    f.Quantity_ordered, 
    c.Customer_name, 
    s.Store_id, 
    h.City_name
FROM Fact_Order f
JOIN Dim_Customer c ON f.Customer_id = c.Customer_id
JOIN Dim_Item i ON f.Item_id = i.Item_id
JOIN Stores s ON f.Store_id = s.Store_id
JOIN Headquarters h ON s.City_id = h.City_id;

SELECT 
    c.Customer_id, 
    c.Customer_name, 
    CASE 
        WHEN w.Customer_id IS NOT NULL AND m.Customer_id IS NOT NULL THEN 'Dual Customer'
        WHEN w.Customer_id IS NOT NULL THEN 'Walk-in Customer'
        WHEN m.Customer_id IS NOT NULL THEN 'Mail-order Customer'
        ELSE 'Unknown'
    END AS Customer_Type
FROM Dim_Customer c
LEFT JOIN Walk_in_customers w ON c.Customer_id = w.Customer_id
LEFT JOIN Mail_order_customers m ON c.Customer_id = m.Customer_id;



SET PAGESIZE 500;
COLUMN Store_id FORMAT 9999;
COLUMN Description FORMAT A20;
COLUMN Total_Sales FORMAT 999999.99;

SELECT * FROM Order_Aggregate;

EXPLAIN PLAN FOR 
SELECT * FROM Order_Aggregate;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT * FROM USER_INDEXES;
