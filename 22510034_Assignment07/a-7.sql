BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE sales_fact CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE product CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE customer CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE store CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE date_dimension CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE time_dimension CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE sales_person CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE product (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(255),
    category VARCHAR2(255),
    brand VARCHAR2(255)
);

CREATE TABLE customer (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(255),
    address VARCHAR2(255),
    contact_info VARCHAR2(255)
);

CREATE TABLE store (
    store_id NUMBER PRIMARY KEY,
    store_name VARCHAR2(255),
    location VARCHAR2(255),
    manager VARCHAR2(255)
);

CREATE TABLE date_dimension (
    date_id NUMBER PRIMARY KEY,
    sales_date DATE,
    day_of_week VARCHAR2(10),
    month VARCHAR2(10),
    quarter VARCHAR2(10),
    year NUMBER,
    public_holidays VARCHAR2(255)
);

CREATE TABLE time_dimension (
    time_id NUMBER PRIMARY KEY,
    hour NUMBER,
    minute NUMBER,
    time_band VARCHAR2(20)
);

CREATE TABLE sales_person (
    sales_person_id NUMBER PRIMARY KEY,
    sales_person_name VARCHAR2(255),
    department VARCHAR2(255)
);

CREATE TABLE sales_fact (
    sales_id NUMBER PRIMARY KEY,
    sales_date_key NUMBER,
    sales_time_key NUMBER,
    invoice_number VARCHAR2(50),
    sales_person_id NUMBER,
    store_id NUMBER,
    customer_id NUMBER,
    product_id NUMBER,
    actual_cost NUMBER(10,2),
    total_sales NUMBER(10,2),
    quantity_sold NUMBER,
    fact_record_count NUMBER,
    FOREIGN KEY (sales_date_key) REFERENCES date_dimension(date_id),
    FOREIGN KEY (sales_time_key) REFERENCES time_dimension(time_id),
    FOREIGN KEY (sales_person_id) REFERENCES sales_person(sales_person_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO product VALUES (1, 'Laptop', 'Electronics', 'ABC');
INSERT INTO product VALUES (2, 'T-shirt', 'Apparel', 'XYZ');
INSERT INTO product VALUES (3, 'Smartphone', 'Electronics', 'PQR');

INSERT INTO customer VALUES (1, 'Rajesh Kumar', '123 Main St', '123-456-7890');
INSERT INTO customer VALUES (2, 'Priya Sharma', '456 Oak St', '456-789-0123');

INSERT INTO store VALUES (1, 'X-Mart Downtown', 'Downtown', 'Amit Patel');
INSERT INTO store VALUES (2, 'X-Mart Mall', 'Mall', 'Rahul Singh');

INSERT INTO date_dimension VALUES (1, TO_DATE('2024-03-01', 'YYYY-MM-DD'), 'Monday', 'March', 'Q1', 2024, 'None');
INSERT INTO date_dimension VALUES (2, TO_DATE('2024-03-02', 'YYYY-MM-DD'), 'Tuesday', 'March', 'Q1', 2024, 'None');

INSERT INTO time_dimension VALUES (1, 8, 0, 'Morning');
INSERT INTO time_dimension VALUES (2, 12, 0, 'Afternoon');

INSERT INTO sales_person VALUES (1, 'Aarav Kumar', 'Electronics');
INSERT INTO sales_person VALUES (2, 'Priya Sharma', 'Apparel');

INSERT INTO sales_fact VALUES (1, 1, 1, 'INV-001', 1, 1, 1, 1, 1000.00, 1500.00, 5, 1);
INSERT INTO sales_fact VALUES (2, 2, 2, 'INV-002', 2, 2, 2, 2, 500.00, 750.00, 3, 1);

CREATE MATERIALIZED VIEW Sales_Cube
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT 
    d.sales_date, 
    t.time_band, 
    p.category, 
    s.store_name,
    SUM(sf.total_sales) AS Total_Sales, 
    SUM(sf.actual_cost) AS Total_Cost, 
    SUM(sf.total_sales - sf.actual_cost) AS Total_Profit
FROM sales_fact sf
JOIN date_dimension d ON sf.sales_date_key = d.date_id
JOIN time_dimension t ON sf.sales_time_key = t.time_id
JOIN product p ON sf.product_id = p.product_id
JOIN store s ON sf.store_id = s.store_id
GROUP BY CUBE (d.sales_date, t.time_band, p.category, s.store_name);

SELECT d.sales_date, p.category, SUM(sf.total_sales) AS total_sales
FROM sales_fact sf
JOIN date_dimension d ON sf.sales_date_key = d.date_id
JOIN product p ON sf.product_id = p.product_id
WHERE d.sales_date = '2024-03-01' AND p.category = 'Electronics'
GROUP BY d.sales_date, p.category;

SELECT s.store_name, SUM(sf.total_sales) AS total_sales, SUM(sf.total_sales - sf.actual_cost) AS total_profit
FROM sales_fact sf
JOIN store s ON sf.store_id = s.store_id
GROUP BY s.store_name;

SELECT d.month, SUM(sf.total_sales) AS total_sales
FROM sales_fact sf
JOIN date_dimension d ON sf.sales_date_key = d.date_id
GROUP BY d.month;
