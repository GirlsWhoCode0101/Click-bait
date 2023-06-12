DROP TABLE IF EXISTS campaign_analysis;
CREATE TABLE campaign_analysis AS (
  WITH events_per_visit AS ( 
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
    )
   SELECT visit_id, visit_start_time,
      CASE 
          WHEN  e.visit_start_time BETWEEN c.start_date AND c.end_date
          THEN  c.campaign_name
      END AS campaign,
      page_views,
      cart_adds,
      Purchase,
      impressions,
      clicks
   FROM events_per_visit AS e, clique_bait.campaign_identifier AS c
 );


SELECT campaign, SUM(page_views) AS viewed,
				 SUM(Purchase) AS purchased,
                 SUM(impressions) AS impr,
                 SUM(clicks) AS clicked 
FROM campaign_analysis
WHERE campaign IS NOT NULL
GROUP BY campaign;