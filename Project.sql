/*The database contains 8 tables, customers, employees, offices, orders, orderdetails, payments, products, productLine. 
In this project, we use SQL to extract critical insights from a rich dataset, focusing on three key business areas. 
We'll examine product and order details to optimize inventory, analyze customer behaviors to refine marketing strategies, 
and assess existing customer profitability to guide acquisition spending. 
This investigation demonstrates SQL's capabilities in transforming complex data into valuable, actionable business intelligence.
*/
SELECT 'Customers' AS table_name, 13 AS number_of_attributes ,COUNT(*) AS number_of_rows
FROM Customers
UNION ALL
SELECT 'Product' , 9 ,COUNT(*)
FROM Products
UNION ALL
SELECT 'productLines' , 4 ,COUNT(*)
FROM productlines
UNION ALL 
SELECT 'Orders' , 7 ,COUNT(*)
FROM orders
UNION ALL 
SELECT 'orderdetails' , 5 ,COUNT(*)
FROM orderdetails
UNION ALL 
SELECT 'payments' , 4 ,COUNT(*)
FROM payments
UNION ALL 
SELECT 'employees' , 8 ,COUNT(*)
FROM employees
UNION ALl 
SELECT 'Offices', 9, count(*) 
From offices;

-- Question 1: Which Products Should We Order More of or Less of?

-- This Query compute the low stock index for each product.

SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                             FROM products p
                                            WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10;
 
 -- This Query compute the Product performance index for each product.
SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS prod_perf
  FROM orderdetails od
 GROUP BY productCode 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
 -- Priority Products for restocking
WITH 
 
low_stock_table AS (
SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
                                           FROM products p
                                          WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10
)
SELECT p.productName,
		p.productLine,
       od.productCode, 
       SUM(od.quantityOrdered * od.priceEach) AS prod_perf
  FROM orderdetails od
  JOIN products p ON od.productCode = p.productCode
 WHERE od.productCode IN (SELECT productCode
                         FROM low_stock_table)
 GROUP BY od.productCode, p.productName 
 ORDER BY prod_perf DESC
 LIMIT 10;
 
 -- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
  
 -- Revenue By customer 
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue 
FROM products p 
JOIN orderdetails od 
ON p.productCode = od.productCode
JOIN orders o
ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber;

--TOP 5 most engaged customer 

WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue DESC
 LIMIT 5;
 
 -- TOP 5 less engaging customer
 WITH 
 
money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)
 
 SELECT contactLastName, contactFirstName, city, country, mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 ORDER BY mc.revenue
 LIMIT 5;
 
 --Question 3: How Much Can We Spend on Acquiring New Customers?
 -- We compute the customer Lifetime Value (LTV) to determine the average amount money a customer generate
 
 WITH 

money_in_by_customer_table AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber
)

SELECT AVG(mc.revenue) AS ltv
  FROM money_in_by_customer_table mc;
  
/* Conclusion
Q1: Which products should we order more of or less of?
According to the result that we conducted, 

productName	             productLine	productCode	prod_perf
1968 Ford Mustang	    Classic Cars	S12_1099	161531.48
1928 Mercedes-Benz SSK	Vintage Cars	S18_2795	132275.98
1997 BMW F650 ST	    Motorcycles	    S32_1374	89364.89
F/A 18 Hornet 1/72	    Planes	        S700_3167	76618.4
2002 Yamaha YZR M1	   Motorcycles	    S50_4713	73670.64
The Mayflower	        Ships	        S700_1938	69531.61
1960 BSA Gold Star      Motorcycles	    S24_2000	67193.49
1928 Ford Phaeton Deluxe Vintage Cars	S32_4289	60493.33
Pont Yacht	             Ships	        S72_3212	47550.4
1911 Ford Town Car	    Vintage Cars	S18_2248	45306.77

These are the product that are priority for restocking. 

Q2: How should we match marketing and communication strategies to customer behaviors?

-Most engaged customers

contactLastName	contactFirstName	city	 country	    revenue
Freyre	         Diego 	           Madrid	 Spain	        326519.66
Nelson	         Susan	         San Rafael	 USA	        236769.39
Young	         Jeff	            NYC	     USA	        72370.09
Ferguson	     Peter	         Melbourne	 Australia	    70311.07
Labrune	         Janine 	      Nantes	 France	        60875.3

- Least engaged customers 

contactLastName	contactFirstName	city	 country	  revenue
Young	        Mary	          Glendale	 USA	      2610.87
Taylor	        Leslie	          Brickhave  USA	      6586.02
Ricotti	        Franco	            Milan	 Italy	      9532.93
Schmitt	        Carine 	           Nantes	 France	      10063.8
Smith	        Thomas 	           London	  UK	      10868.04

Q3: How much can we spend on acquiring new customers?

ltv
39039.5943877551

The index tells us how much profit an average customer generates during their lifetime with our store.
We can use it to predict our future profit. 
We can decide based on this prediction how much we can spend on acquiring new customers.






  
  
  
  
 
 
 


 








