SELECT * FROM walmart;
--
SELECT COUNT(*) FROM walmart;

SELECT
		payment_method, 
		COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT
		COUNT(DISTINCT branch)
FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- Find number of transactions, quantity sold for each payment method

SELECT 
		payment_method,
		COUNT(*) AS num_payments,
		SUM(quantity) AS num_qty_sold
FROM walmart
GROUP BY payment_method

-- Find the highest-rated category in from each Walmart branch
-- Display the branch, category, AVG rating

SELECT *
FROM
(SELECT 
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
WHERE rank = 1

-- Identify the busiest day for each branch based on
-- the number of transactions

WITH cte
AS
(		SELECT
			branch,
			TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
			COUNT(*) AS num_transactions,
			RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
		FROM walmart
		GROUP BY branch, day_name
)
SELECT *
FROM cte
WHERE rank = 1

-- Calculate the total quantity of items sold per payment method
-- List payment_method and total_quantity

SELECT * FROM walmart;

SELECT
		payment_method,
		SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method

-- Determine the average, minimum, and maximum rating of category
-- for each city
-- List the city, average_rating, min_rating, and max_rating

SELECT * FROM walmart;

SELECT
		city,
		category,
		MIN(rating) AS min_rating,
		MAX(rating) AS max_rating,
		AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category

-- Calculate the total profit for each category by considering
-- total_profit as (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

SELECT
		category,
		SUM(total) AS total_profit,
		SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category

-- Determine the most common payment method for each Branch
-- Display Branch and the preferred_payment_method

WITH cte
AS
(SELECT
		branch,
		payment_method,
		COUNT(*) AS total_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE rank = 1

-- Categorize sales into 3 groups Morning, Afternoon, Evening
-- Find number of invoices for each shift time at each branch

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END shift_time,
	COUNT(*) AS invoices
FROM walmart
GROUP BY branch, shift_time
ORDER BY branch, invoices DESC

-- Identify 5 branches with the highest descrease in revenue
-- compared to the previous year (2022->2023)

WITH revenue_2022
AS
(
	SELECT
			branch,
			SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY branch
),

revenue_2023
AS
(
	SELECT
			branch,
			SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY branch
)

SELECT 
		prev.branch,
		prev.revenue AS previous_year_revenue,
		curr.revenue AS current_year_revenue,
		ROUND(
				(prev.revenue - curr.revenue)::numeric/
				prev.revenue::numeric * 100, 2) as rev_dec_ratio
FROM revenue_2022 AS prev
JOIN
revenue_2023 AS curr
ON prev.branch = curr.branch
WHERE
		prev.revenue > curr.revenue
ORDER BY 4 DESC
LIMIT 5