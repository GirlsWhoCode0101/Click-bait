SELECT 	visit_id,
		MIN(event_time) AS visit_start_time,
		COUNT( CASE 
              		WHEN event_type = '1' 
             		THEN visit_id
             	END ) AS page_views,
        COUNT ( CASE 
              		WHEN event_type = '2' 
             		THEN visit_id
             	END ) AS cart_adds,
        SUM ( CASE 
             	WHEN event_type = '3' 
             	THEN 1 ELSE 0 
        	END ) AS Purchase,
        COUNT ( CASE 
              		WHEN event_type = '4' 
             		THEN visit_id
             	END ) AS impressions,
        COUNT ( CASE 
              		WHEN event_type = '5' 
             		THEN visit_id
             	END ) AS clicks        
FROM clique_bait.event_identifier
JOIN clique_bait.events
	USING (event_type)
JOIN clique_bait.page_hierarchy
	USING (page_id)
GROUP BY visit_id
LIMIT 20;