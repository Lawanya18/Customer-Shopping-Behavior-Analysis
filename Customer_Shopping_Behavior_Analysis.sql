-- KPIs

-- 1. Which product categories generate the most revenue?
SELECT
    category,
    SUM(purchase_amount) AS Total_Revenue
FROM customer
GROUP BY category
ORDER BY total_revenue DESC;

-- 2. Which customers used a discount but still spent more than the average purchase amount ?
SELECT 
    customer_id, purchase_amount
FROM
    customer
WHERE
    discount_applied = 'Yes'
        AND purchase_amount >= (SELECT 
            AVG(purchase_amount)
        FROM
            customer);
            
-- 3. Which are the top 5 products with the highest average review rating ?
SELECT 
    item_purchased,
    ROUND(AVG(review_rating), 2) AS Average_Product_Rating
FROM
    customer
GROUP BY item_purchased
ORDER BY Average_Product_Rating DESC
LIMIT 5;

-- 4. Compare the average purchase amounts between standard and express shipping.
SELECT 
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS Avg_Purchase_Amount
FROM
    customer
WHERE
    shipping_type IN ('Standard' , 'Express')
GROUP BY shipping_type;

-- 5. Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non-subscribers.
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    SUM(purchase_amount) AS total_revenue
FROM
    customer
GROUP BY subscription_status
ORDER BY total_revenue , avg_spend;

-- 6. Which 5 products have the highest percentage of purchases with discounts applied?
SELECT 
    item_purchased,
    ROUND(SUM(CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS discount_rate
FROM
    customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- 7. Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each 
-- segment.
WITH customer_category as (
SELECT
     customer_id, previous_purchases, 
     CASE 
         WHEN previous_purchases = 1 THEN 'New' 
		 WHEN previous_purchases  between 2 and 10 THEN 'Returning' 
         ELSE 'Loyal' 
         END AS customer_segment 
from customer
)
SELECT 
    customer_segment, COUNT(*) AS Number_of_Customers
FROM
    customer_category
GROUP BY customer_segment;

-- 8. What are the top 3 most purchased products within each category?
WITH item_counts AS (
SELECT
      category, item_purchased, 
      COUNT(customer_id) AS Total_orders, 
      ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS Product_rank
FROM 
	customer
GROUP BY category, item_purchased
) 
SELECT
      product_rank, item_purchased, category, Total_orders
FROM 
     item_counts 
WHERE Product_rank <= 3
ORDER BY category, product_rank;

-- 9. Does repeat-purchase behaviour relate to subscription adoption?
SELECT
    CASE
        WHEN previous_purchases > 5 THEN 'Repeat Buyer'
        ELSE 'Occasional Buyer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    SUM(
        CASE
            WHEN subscription_status = 'Yes' THEN 1
            ELSE 0
        END
    ) AS subscribers,
	ROUND(
        100.0 * SUM(
            CASE
                WHEN subscription_status = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS subscription_rate
FROM customer
GROUP BY customer_type
ORDER BY subscription_rate DESC;

-- 10. Which age group contributes the most revenue?
SELECT 
    age_group, SUM(purchase_amount) AS total_revenue
FROM
    customer
GROUP BY age_group
ORDER BY total_revenue DESC;
