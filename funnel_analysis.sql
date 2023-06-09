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
         	WHEN event_type = '2' AND  HighestPageCalled = '13'
         	THEN product_id
         END ) AS Purchased
FROM preproc
GROUP BY product_id
ORDER BY product_id;