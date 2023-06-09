-- 1. How many users are there?
SELECT COUNT( DISTINCT user_id) AS Number_of_Users
FROM clique_bait.users;

-- 2. How many cookies does each user have on average?
WITH num_users AS (
  	SELECT COUNT(cookie_id) AS num_cookies
	FROM clique_bait.users
	GROUP BY user_id
  	)
SELECT ROUND(AVG(num_cookies), 0)
FROM num_users;

-- 3. What is the unique number of visits by all users per month?
SELECT DATE_PART('MONTH', event_time) AS Month, COUNT( DISTINCT visit_id) AS Number_of_visits
FROM clique_bait.events
WHERE event_time IS NOT NULL
GROUP BY DATE_PART('MONTH', event_time);

-- 4. What is the number of events for each event type?

SELECT event_type, COUNT(event_type) AS count
FROM clique_bait.events
GROUP BY event_type
ORDER BY event_type;

-- 5. What is the percentage of visits which have a purchase event?

SELECT 
    (CAST(COUNT(DISTINCT 
                CASE 
                	WHEN event_type = '3' 
                	THEN visit_id 
                END) AS decimal) 
     	/ COUNT(DISTINCT visit_id)) * 100 AS percentage_of_visits
FROM clique_bait.events
WHERE visit_id IS NOT NULL;

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH max_page_viewed AS (
     SELECT visit_id, cookie_id, event_type, page_name, MAX(page_id) OVER (PARTITION BY cookie_id) AS max_page
     FROM clique_bait.event_identifier
     JOIN clique_bait.events
          USING (event_type)
     JOIN clique_bait.page_hierarchy
          USING (page_id)
  	  )
SELECT CAST ( COUNT ( DISTINCT (
  		CASE 
  			WHEN  max_page = '12'
  			THEN visit_id
  		END ) ) AS decimal )
        / COUNT (DISTINCT ( visit_id )) * 100 
        AS percentage_checkout_but_no_purchase
FROM max_page_viewed;

-- 7. What are the top 3 pages by number of views?
SELECT 
    SUM(CASE WHEN event_type = '1' THEN 1 ELSE 0 END) AS count_of_views, page_name
FROM clique_bait.events
JOIN clique_bait.page_hierarchy
    USING (page_id)
GROUP BY page_name
ORDER BY count_of_views DESC
LIMIT 3;

-- 8. What is the number of views and cart adds for each product category?

SELECT product_category,
		SUM(CASE WHEN event_type = '2' THEN 1 ELSE 0 END) AS cnt_addToCart,
        SUM(CASE WHEN event_type = '1' THEN 1 ELSE 0 END) AS cnt_views
FROM clique_bait.events
JOIN clique_bait.page_hierarchy
	USING (page_id)
WHERE product_category IS NOT NULL
GROUP BY product_category
ORDER BY cnt_addToCart;

-- 9. What are the top 3 products by purchases?

WITH max_page_viewed AS (
     SELECT product_id, cookie_id, event_type, page_name, 
     MAX(page_id) OVER (PARTITION BY cookie_id) AS max_page
     FROM clique_bait.event_identifier
     JOIN clique_bait.events
          USING (event_type)
     JOIN clique_bait.page_hierarchy
          USING (page_id)
	 )
SELECT 
	COUNT(product_id) AS num_products_purchased, 
    product_id,
    MAX(page_name)
FROM max_page_viewed
WHERE max_page = '13'
AND event_type = '2'
GROUP BY product_id
ORDER BY num_products_purchased DESC
LIMIT 3;


--- nice query to remember
WITH max_page_viewed AS (
     SELECT product_id, cookie_id, event_type, page_name, 
     MAX(page_id) OVER (PARTITION BY cookie_id) AS max_page,
     LAG(event_type) OVER (ORDER BY cookie_id) AS previous_event_type
     FROM clique_bait.event_identifier
     JOIN clique_bait.events
          USING (event_type)
     JOIN clique_bait.page_hierarchy
          USING (page_id)
	 )
SELECT 
	product_id, 
    cookie_id,
	event_type,
	previous_event_type,
    max_page
FROM max_page_viewed
WHERE max_page = '13';