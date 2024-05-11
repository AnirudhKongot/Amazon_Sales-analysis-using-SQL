-- What is the total revenue generated?
SELECT
	ROUND(SUM(sale)) total_rvenue 
FROM orders;

-- How many products do we have?
SELECT 
	COUNT(DISTINCT(product_id)) total_products
FROM orders;

-- Find  out top 5 order details by sales amount?
SELECT 
	order_id, sale 
FROM orders
ORDER BY 2 DESC 
LIMIT 5;

-- What is the total sale for GOA?
SELECT 
	SUM(sale) total_sale
FROM orders
WHERE state = 'Goa';

-- Find out the top 5 customers who made the highest profits.
SELECT 
	customer_id, 
	SUM(profit) highest_profits
FROM orders
GROUP BY customer_id
ORDER BY SUM(profit) DESC LIMIT 5;

-- Find out the average quantity ordered per category.
SELECT 
	category, 
	ROUND(AVG(quantity)) average_quantity
FROM orders
GROUP BY category;

-- Identify the top 5 products that have generated the highest revenue.
SELECT
	product_id, 
	SUM(sale) highest_revenue
FROM orders
GROUP BY product_id
ORDER BY highest_revenue DESC LIMIT 5;

-- Determine the top 5 products whose revenue has decreased compared to the previous year.
WITH CTE1
AS
(
	SELECT 
	product_id, order_date,
	SUM(sale) AS current_year_revenue
	FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2024
	GROUP BY 1, 2
),
CTE2
AS
(
	SELECT 
		product_id,
		order_date,
		SUM(sale) AS previous_year_revenue
	FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 2023
	GROUP BY 1, 2
)
SELECT 
	CTE1.Product_id,
	p.product_name, 
	CTE2.previous_year_revenue,
	CTE1.current_year_revenue
FROM CTE1
JOIN CTE2 
ON CTE1.product_id = CTE2.product_id
JOIN Products p
ON CTE1.product_id = p.product_id
WHERE CTE1.current_year_revenue < CTE2.previous_year_revenue
ORDER BY 1 DESC
LIMIT 5;

-- Identify the highest profitable sub-category.
SELECT
	sub_category,
	profit
FROM
(
	
	SELECT 
	sub_category,
	SUM(sale) profit,
	RANK() OVER (ORDER BY SUM(sale) DESC) AS RANK
	FROM 
	orders
	GROUP BY sub_category
	
)
WHERE RANK = 1;

-- Find out the states with the highest total orders.
SELECT 
	state,
	COUNT(order_id) highest_total_orders
FROM orders
GROUP BY state
ORDER BY highest_total_orders DESC
LIMIT 2;

-- using subquery
SELECT
	state, total_orders
FROM (
    SELECT state, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY state
) AS state_orders
WHERE total_orders = (
    SELECT MAX(total_orders)
    FROM (
        SELECT COUNT(order_id) AS total_orders
        FROM orders
        GROUP BY state
    ) AS max_orders
)

-- Determine the month with the highest number of orders.
SELECT 
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY
    month
ORDER BY
    total_orders DESC;

-- Calculate the profit margin percentage for each sale (Profit divided by Sales), handling negative profit values.
SELECT 
    order_id,
	sale,
	ABS(profit) profit,
    CASE
        WHEN profit <> 0 AND sale <> 0 THEN (ABS(profit) / sale) * 100
        ELSE 0 
    END AS profit_margin
FROM 
    orders;

-- Calculate the percentage contribution of each sub-category
SELECT
	sub_category,
	SUM(sale) total_sale,
	SUM(sale)/(SELECT(SUM(sale)) FROM orders) *100 as percentage_contribution
FROM orders
GROUP BY sub_category
ORDER BY percentage_contribution DESC;











