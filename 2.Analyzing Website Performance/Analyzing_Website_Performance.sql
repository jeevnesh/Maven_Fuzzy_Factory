USE mavenfuzzyfactory;

-- Analyzing Top website pages

SELECT 
    pageview_url, COUNT(website_pageview_id) AS pvs
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000         -- Arbitrary
GROUP BY pageview_url;

/*
pageview_url				pvs
/home						523
/products					195
/the-original-mr-fuzzy		134
/cart						56
/shipping					39
/billing					34
/thank-you-for-your-order	18
*/

-- Top Entry Pages

CREATE TEMPORARY TABLE first_pageview
SELECT 
    website_session_id, MIN(website_pageview_id) AS min_pv_id
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000           -- Arbitrary
GROUP BY website_session_id;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(first_pageview.website_session_id) AS sessions_hitting_this_page
FROM
    first_pageview
        LEFT JOIN
    website_pageviews ON first_pageview.min_pv_id = website_pageviews.website_pageview_id;
    
/*
landing_page			 sessions_hitting_this_page
/home						523
*/

-- Assignment-1 (2012-06-09)

/*
1. Could you help me get my head around the site by pulling the most-viewed website pages,
   Ranked by session volume?	
*/

SELECT 
    pageview_url, COUNT(website_pageview_id) AS sessions
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

/*
pageview_url				   sessions
/home							10403
/products						4239
/the-original-mr-fuzzy			3037
/cart							1306
/shipping						869
/billing						716
/thank-you-for-your-order		306
*/

-- Assignment-2 (2012-06-12)

/*
2. Would you be able to pull a list of the top entry pages? 
   I want to confirm where our users are hitting the site.
   If you could pull all entry pages and rank them on entry volume,
   that would be great.
*/

-- STEP 1 : Find the first pageview for each session
-- STEP 2 : Find the url the customer saw on that first pageview
 
CREATE TEMPORARY TABLE first_pageviews
SELECT 
    website_session_id, MIN(website_pageview_id) AS pv
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(first_pageviews.website_session_id) AS session_hitting_this_lander
FROM
    first_pageviews
        LEFT JOIN
    website_pageviews ON first_pageviews.pv = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url;

/*
landing_page			 session_hitting_this_lander
/home						10714
*/

-- Analyzing bounce rates & Landing page performance

-- BUSINESS CONTEXT: we want to see landing page performance for a certain time period

-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify 'bounces'
-- STEP 4: summarizing total sessions and bounced sessions , by Landing page

-- finding the minimum website_pageview_id associate with each session we care about

CREATE TEMPORARY TABLE first_pageview_demo
SELECT 
    website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY website_session_id;

-- next, we'll bring in the landing page to each session

CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT 
    website_pageviews.pageview_url,
    first_pageview_demo.website_session_id
FROM
    first_pageview_demo
        LEFT JOIN
    website_pageviews ON first_pageview_demo.min_pageview_id = website_pageviews.website_pageview_id;
    
-- next, we'll see the bounced sessions 

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
    sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.pageview_url,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM
    sessions_w_landing_page_demo
        LEFT JOIN
    website_pageviews ON sessions_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
GROUP BY sessions_w_landing_page_demo.website_session_id , sessions_w_landing_page_demo.pageview_url
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

/* Better Approach then upper one
SELECT 
    website_session_id,
    COUNT(website_pageview_id) AS count_of_pages
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY website_session_id
HAVING COUNT(website_pageview_id) = 1;
*/

-- final output

SELECT 
    sessions_w_landing_page_demo.pageview_url AS landing_page,
    COUNT(sessions_w_landing_page_demo.website_session_id) AS total_sessions,
    COUNT(bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(bounced_sessions_only.website_session_id) / COUNT(sessions_w_landing_page_demo.website_session_id) AS bounced_rate
FROM
    sessions_w_landing_page_demo
        LEFT JOIN
    bounced_sessions_only ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY sessions_w_landing_page_demo.pageview_url;

/*
landing_page 	 total_sessions		bounced_sessions		bounced_rate
/lander-2			6500				2855					0.4392
/home				4093				1575					0.3848
/lander-3			4232				2606					0.6158
*/

-- Assignment-3 (2012-06-14)

/*
3. The other day you showed us that all our traffic is landing on the homepage right now.
   we should check how that landing page is performing.
   Can you pull bounce rates for traffic landing on the homepage? I would like to see three
   numbers Sessions, Bounced Sessions and Bounce rate.
*/

-- STEP 1: Calculating total website sessions before '2012-06-14'
 
CREATE TEMPORARY TABLE total_session
SELECT 
    website_session_id AS Total_Sessions
FROM
    website_pageviews
WHERE
    created_at < '2012-06-14'
GROUP BY website_session_id;

-- STEP 2: Calculating bounced website sessions before '2012-06-14'

CREATE TEMPORARY TABLE bounced_session
SELECT 
    website_session_id AS Bounced_Sessions
FROM
    website_pageviews
WHERE
    created_at < '2012-06-14'
GROUP BY website_session_id
HAVING COUNT(website_pageview_id) = 1;

-- STEP 3: Joining the tables to check bounce rate

SELECT 
    COUNT(total_session.Total_Sessions) AS Total_Sessions,
    COUNT(bounced_session.Bounced_Sessions) AS Bounced_Sessions,
    COUNT(bounced_session.Bounced_Sessions) / COUNT(total_session.Total_Sessions) AS Bounce_rate
FROM
    total_session
        LEFT JOIN
    bounced_session ON total_session.Total_Sessions = bounced_session.Bounced_Sessions;

/*
Total_Sessions			 Bounced_Sessions 			Bounce_rate
11048						6538						0.5918
*/

-- Assignment-4 (2012-07-28)

/*
4. Based on your bounced rate analysis, we ran a new custom landing page (/lander-1) in a 
   50/50 test against the homepage (/home) for our gsearch nonbrand traffic.
   Can you pull bounce rates for the two groups so we can evaluate the new page?
   Make sure to just look at the time period where /lander-1 was getting traffic, so that 
   it is a fair comparision
*/

-- STEP 0: find out when the new page /lander launched
-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by LP

-- finding the first instance of /lander-1 to set analysis timeframe

SELECT 
    MIN(DATE(created_at)) AS first_created_at
FROM
    website_pageviews
WHERE
    created_at < '2012-07-28'
        AND pageview_url = '/lander-1';
        
/*
first_created_at
'2012-06-19'
*/

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
        INNER JOIN
    website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
    website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- next, we'll bring in the landing page to each session

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_test_pageviews
        LEFT JOIN
    website_pageviews ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id;
    
-- next, we'll check for bounced sessions

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT 
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM
    nonbrand_test_sessions_w_landing_page
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY nonbrand_test_sessions_w_landing_page.website_session_id , nonbrand_test_sessions_w_landing_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- Final output

SELECT 
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(nonbrand_test_sessions_w_landing_page.website_session_id) AS total_sessions,
    COUNT(nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(nonbrand_test_bounced_sessions.website_session_id) / COUNT(nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM
    nonbrand_test_sessions_w_landing_page
        LEFT JOIN
    nonbrand_test_bounced_sessions ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY nonbrand_test_sessions_w_landing_page.landing_page
ORDER BY nonbrand_test_sessions_w_landing_page.website_session_id;

/*
landing_page	 total_sessions		 bounced_sessions		 bounce_rate
/lander-1			2316				1233					0.5324
/home				2261				1319					0.5834
*/

-- Assignment-5 (2012-08-31)

/*
5. Could you pull the volume of paid search nonbrand traffic landing on /home and /lander-1,
   trended weekly since june 1st? I want to confirm the traffic is all routed correctly.
   Could you also pull our overall paid search bounce rate trended weekly? I want to make 
   sure the lander chnage has improved the overall picture.
*/

-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by week (bounce rate, sessions to each lander)

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.website_session_id;

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT 
    sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM
    sessions_w_min_pv_id_and_view_count
        LEFT JOIN
    website_pageviews ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;
    
SELECT 
    MIN(DATE(session_created_at)) AS week_start_date,
    COUNT(CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS bouce_rate,
    COUNT(CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM
    sessions_w_counts_lander_and_created_at
GROUP BY WEEK(session_created_at);

/*
week_start_date		 bouce_rate		 home_sessions		 lander_sessions
2012-06-01				0.6057			175						0
2012-06-03				0.5871			792						0
2012-06-10				0.6160			875						0
2012-06-17				0.5582			492						350
2012-06-24				0.5828			369						386
2012-07-01				0.5821			392						388
2012-07-08				0.5668			390						411
2012-07-15				0.5424			429						421
2012-07-22				0.5138			402						394
2012-07-29				0.4971			33						995
2012-08-05				0.5382			0						1087
2012-08-12				0.5140			0						998
2012-08-19				0.5010			0						1012
2012-08-26				0.5378			0						833
*/


-- Building conversion funnels

-- Business Context
	-- we want to build a mini conversion funnel, from /lander-2 tp /cart
    -- we want to know how many people reach each step, and also dropoff rates
    -- for simplicity, we're looking at /lander-2 traffic only
    -- for simplicity, we're looking at customers who like Mr Fuzzy only 
    
-- STEP 1: select all pageviews for relevant sessions 
-- STEP 2: identify each relevant pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance 

CREATE TEMPORARY TABLE session_level_made_it_flag
SELECT 
	website_session_id,
	MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM(    
SELECT 
    website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
        AND website_pageviews.pageview_url IN ('/lander-2' , '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY website_sessions.website_session_id , website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id ;

-- the final output 

SELECT 
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS lander_clickthrough_rate,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_clickthrough_rate,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickthrough_rate
FROM
    session_level_made_it_flag;
    
/*
sessions	 lander_clickthrough_rate	 products_clickthrough_rate		 mrfuzzy_clickthrough_rate
10644			0.7318							0.6133							0.6048
*/    

-- Assignment-6 (2012-09-12)

/*
6. I'd like to understand where we lose our gsearch visitors between the new /lander-1 page and placing an order.
   Can you build us a full conversion funnel, analyzing how many customers make it to each step?
   Start with /lander-1 and build the funnel all the way to our thank you page. Please use data since August 5th.
*/

-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance

CREATE TEMPORARY TABLE sessions_level_made_it_flag
SELECT 
	website_session_id,
	MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
(
SELECT 
	website_sessions.website_session_id,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-12'
        AND website_pageviews.pageview_url IN ('/lander-1' , '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY website_sessions.website_session_id
) AS pageview_level
GROUP BY website_session_id ;

-- Final output

SELECT 
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS lander_click_rate,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_click_rate,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rate,
    COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM
    sessions_level_made_it_flag;
    
/*
lander_click_rate		 product_click_rate			mrfuzzy_click_rate		 cart_click_rate		 shipping_click_rate		 billing_click_rate
0.4714							0.7391					0.4337						0.6711				0.7604						0.4597
*/

-- Assignment-7 (2012-11-10)

/*
7. We tested an updated billing page based on your funnel analysis. can you take a look and see whether
   /billing-2 is doing any better than the original /billing page?
   We're wondering what % of sessions on those pages end up placing an order. FYI - we ran this test
   for all traffic, not just for our search visitors.
*/

-- finding the first instance of /billing-2 to set analysis timeframe

SELECT 
    MIN(DATE(created_at)) AS first_created_at
FROM
    website_pageviews
WHERE
    created_at < '2012-11-10'
        AND pageview_url = '/billing-2';
        
/*
first_created_at
'2012-09-10'
*/

SELECT 
    billing_version_seen,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(website_session_id) AS billing_to_order_rt
FROM
    (SELECT 
        website_pageviews.website_session_id,
            website_pageviews.pageview_url AS billing_version_seen,
            orders.order_id
    FROM
        website_pageviews
    LEFT JOIN orders ON orders.website_session_id = website_pageviews.website_session_id
    WHERE
        website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
            AND website_pageviews.pageview_url IN ('/billing' , '/billing-2')) AS billing_sessions_w_orders
GROUP BY billing_version_seen
;

/*
billing_version_seen	 sessions 	   orders 		billing_to_order_rt
/billing-2					654			410				0.6269
/billing					657			300				0.4566
*/