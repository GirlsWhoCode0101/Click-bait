--  Product Funnel Analysis
/* Using a single SQL query - create a new output table which has the -following details:

How many times was each product viewed?
How many times was each product added to cart?
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased? */

WITH preproc AS (  
  	SELECT 	product_id, 
  			page_name,
  			event_type,
      		MAX(page_id) OVER (PARTITION BY cookie_id) AS HighestPageCalled
  	FROM clique_bait.events
  	JOIN clique_bait.event_identifier
      USING (event_type)
  	JOIN clique_bait.page_hierarchy
      USING (page_id)
	)
SELECT MAX(page_name) AS Product,
       SUM ( 
         CASE 
           	WHEN event_type = '1' 
         	THEN 1 ELSE 0 
         END ) AS Views,
       SUM ( 
         CASE 
            WHEN event_type = '2' 
         	THEN 1 ELSE 0
       END ) AS AddedToCart,
        COUNT (
         CASE 
         	WHEN event_type = '2' AND HighestPageCalled < '13'
         	THEN product_id
         END ) AS Abandoned,
       COUNT (
         CASE 
         	WHEN event_type = '2' AND  HighestPageCalled = '13' -- count only purchased products which have been added to cart
         	THEN product_id
         END ) AS Purchased
FROM preproc
GROUP BY product_id
ORDER BY product_id;

-- for each product category
WITH preproc AS (  
  	SELECT 	product_category,
  			page_name,
  			event_type,
      		MAX(page_id) OVER (PARTITION BY cookie_id) AS HighestPageCalled
  	FROM clique_bait.events
  	JOIN clique_bait.event_identifier
      USING (event_type)
  	JOIN clique_bait.page_hierarchy
      USING (page_id)
	)
SELECT MAX(page_name) AS Product,
       SUM ( 
         CASE 
           	WHEN event_type = '1' 
         	THEN 1 ELSE 0 
         END ) AS Views,
       SUM ( 
         CASE 
            WHEN event_type = '2' 
         	THEN 1 ELSE 0
       END ) AS AddedToCart,
        COUNT (
         CASE 
         	WHEN event_type = '2' AND HighestPageCalled < '13'
         	THEN product_category
         END ) AS Abandoned,
       COUNT (
         CASE 
         	WHEN event_type = '2' AND  HighestPageCalled = '13'
         	THEN product_category
         END ) AS Purchased
FROM preproc
GROUP BY product_category
ORDER BY product_category;

/*
Use your 2 new output tables - answer the following questions:

Which product had the most views, cart adds and purchases?
Which product was most likely to be abandoned?
Which product had the highest view to purchase percentage?
What is the average conversion rate from view to cart add?
What is the average conversion rate from cart add to purchase?
*/

-- 1. Which product had the most views, cart adds and purchases?

WITH preproc AS (  
  	SELECT 	product_id,
  			page_name,
  			event_type,
      		MAX(page_id) OVER (PARTITION BY cookie_id) AS HighestPageCalled
  	FROM clique_bait.events
  	JOIN clique_bait.event_identifier
      USING (event_type)
  	JOIN clique_bait.page_hierarchy
      USING (page_id)
	),
    product_summary AS (SELECT MAX(page_name) AS Product,
       SUM ( 
         CASE 
           	WHEN event_type = '1' 
         	THEN 1 ELSE 0 
         END ) AS Views,
       SUM ( 
         CASE 
            WHEN event_type = '2' 
         	THEN 1 ELSE 0
       END ) AS AddedToCart,
        COUNT (
         CASE 
         	WHEN event_type = '2' AND HighestPageCalled < '13'
         	THEN product_id
         END ) AS Abandoned,
       COUNT (
         CASE 
         	WHEN event_type = '2' AND  HighestPageCalled = '13'
         	THEN product_id
         END ) AS Purchased
	FROM preproc
	GROUP BY product_id
	ORDER BY product_id
    )
SELECT 	MAX(Views) AS mx_view,
	 	MAX(AddedToCart) AS mx_add,
        MAX(Purchased) AS mx_pur
FROM product_summary
WHERE product != 'Home Page'
;
-- max view: Oyster
-- max cart adds: Lobster
-- max purchased: Lobster
-- max abandoned: Russion Cavier

-- 3. Which product had the highest view to purchase percentage?

WITH preproc AS (  
  	SELECT 	product_id,
  			page_name,
  			event_type,
      		MAX(page_id) OVER (PARTITION BY cookie_id) AS HighestPageCalled
  	FROM clique_bait.events
  	JOIN clique_bait.event_identifier
      USING (event_type)
  	JOIN clique_bait.page_hierarchy
      USING (page_id)
	),
    product_summary AS (SELECT MAX(page_name) AS Product,
       SUM ( 
         CASE 
           	WHEN event_type = '1' 
         	THEN 1 ELSE 0 
         END ) AS Views,
       SUM ( 
         CASE 
            WHEN event_type = '2' 
         	THEN 1 ELSE 0
       END ) AS AddedToCart,
        COUNT (
         CASE 
         	WHEN event_type = '2' AND HighestPageCalled < '13'
         	THEN product_id
         END ) AS Abandoned,
       COUNT (
         CASE 
         	WHEN event_type = '2' AND  HighestPageCalled = '13'
         	THEN product_id
         END ) AS Purchased
	FROM preproc
	GROUP BY product_id
	ORDER BY product_id
    )
SELECT 	Product, 
		ROUND ( CAST(Purchased AS decimal) / CAST(Views AS decimal) * 100, 2 ) AS viewToPct
FROM product_summary
WHERE product != 'Home Page'
ORDER BY viewToPct DESC
;

-- Black truffle has the highest view to purchase percentage with 55.28%

-- 4. What is the average conversion rate from view to cart add?

-- ...
SELECT ROUND ( AVG ( CAST(AddedToCart AS decimal) / CAST(Views AS decimal) * 100) , 2 ) AS viewToCartAddPct
FROM product_summary
WHERE product != 'Home Page'
ORDER BY viewToCartAddPct DESC
;
-- The average view to cart add percentage is 60.95%

-- 5. What is the average conversion rate from cart add to purchase?

-- ...
SELECT ROUND ( AVG ( CAST( Purchased AS decimal) / CAST(AddedToCart AS decimal) * 100) , 2 ) AS PurchasedToCartAddPct
FROM product_summary
WHERE product != 'Home Page'
ORDER BY PurchasedToCartAddPct DESC
;

-- From products added to cart, 86.58 % have been actually purchased