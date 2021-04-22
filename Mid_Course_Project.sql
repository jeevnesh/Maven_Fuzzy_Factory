USE mavenfuzzyfactory;

/*
1. Gsearch seems to be the biggest driver to our business. could you pull monthly
   trends for gsearch session and orders so that we can showcase the growth there ? 
*/

SELECT 
    MONTHNAME(website_sessions.created_at) AS months,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) as conversion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
        AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at);

/*
2. Next,it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand
   and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 
*/

SELECT 
    MONTHNAME(website_sessions.created_at) AS months,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)/COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_conv_rt,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)/COUNT(CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
        AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at);

/*
3. While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type?
  I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/

SELECT 
    MONTHNAME(website_sessions.created_at) AS months,
    COUNT(CASE WHEN device_type = 'desktop' then website_sessions.website_session_id ELSE NULL END) AS Desktop_sessions,
    COUNT(CASE WHEN device_type = 'desktop' then orders.order_id ELSE NULL END) AS Desktop_orders,
    COUNT(CASE WHEN device_type = 'desktop' then orders.order_id ELSE NULL END) / COUNT(CASE WHEN device_type = 'desktop' then website_sessions.website_session_id ELSE NULL END) AS Desktop_conv_rt,
	COUNT(CASE WHEN device_type = 'mobile' then website_sessions.website_session_id ELSE NULL END) AS Mobile_sessions,
    COUNT(CASE WHEN device_type = 'mobile' then orders.order_id ELSE NULL END) AS Mobile_orders,
    COUNT(CASE WHEN device_type = 'mobile' then orders.order_id ELSE NULL END) / COUNT(CASE WHEN device_type = 'mobile' then website_sessions.website_session_id ELSE NULL END) AS Mobile_conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY MONTH(website_sessions.created_at);

/*
4. I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch.
   Can you pull monthly trend for Gsearch, alongside monthly trend for each of our other channels?
*/

-- first finding the various utm source and referers to see the traffic we are getting 

SELECT DISTINCT
    utm_source, utm_campaign, http_referer
FROM
    website_sessions
WHERE
    created_at < '2012-11-27';
    
    
SELECT
	MONTHNAME(website_sessions.created_at) AS months,
    COUNT(CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) as gsearch_paid_session,
    COUNT(CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) as bsearch_paid_session,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) as organic_search_session,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) as direct_type_in_session
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
GROUP BY month(website_sessions.created_at);

/*
5. I'd like to tell the story of our website performance improvement over the course of the first 8 months.
   Could you pull session to order conversion rates, by month? 
*/

SELECT 
    MONTHNAME(website_sessions.created_at) AS months,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
GROUP BY MONTH(website_sessions.created_at);

/*
6. For the Gsearch lander test, please estimate the revenue that test earned us.
(Hint: Look at the increase in CVR from the test (Jun 19 - Jul 28), and use 
nonbrand sessions and revenue since then to calculate incremental value)
*/
-- First date at which lander-1 is live

SELECT 
    MIN(DATE(created_at)) AS first_created_at
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1';
    
-- 2012-06-19

-- Now we will find the first Pageview id for relevent sessions

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.website_session_id
ORDER BY website_sessions.website_session_id;

-- Now we will bring the landing page of each session but restrict it to /home and /lander-1 page.analyze

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT 
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_test_pageviews
        LEFT JOIN
    website_pageviews ON first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE
    website_pageviews.pageview_url IN ('/home' , '/lander-1');
    
-- Now we make table to bring in Orders 
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT 
    nonbrand_test_sessions_w_landing_pages.website_session_id,
    nonbrand_test_sessions_w_landing_pages.landing_page,
    orders.order_id
FROM
    nonbrand_test_sessions_w_landing_pages
        LEFT JOIN
    orders ON nonbrand_test_sessions_w_landing_pages.website_session_id = orders.website_session_id;
    
-- find the difference between conversion rates

SELECT 
    landing_page,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(website_session_id) AS conv_rate
FROM
    nonbrand_test_sessions_w_orders
GROUP BY landing_page;

-- 0.0318 for /home  vs  0.0406 for /lander-1.
-- 0.0088 additional orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to home

SELECT 
    MAX(website_sessions.website_session_id) as most_recent_gsearch_nonbrand_home_pageview 
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND pageview_url = '/home'
        AND website_sessions.created_at < '2012-11-27';
        
-- Max website_session_id = 17145

-- Now

SELECT 
    COUNT(website_sessions.website_session_id) AS total_sessions_since_test
FROM
    website_sessions
WHERE
    created_at < '2012-11-27'
        AND website_session_id > 17145
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';
        
-- 22972 since test 
-- 22972 * 0.0088 incremental conversation = 202.1536 incremental order since july 29
	-- roughly 4 months, so 50 extra orders per month 
    
/*
7. For the landing page test you analyzed previously, it would be great to show a Full conversion funnel
   from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 - Jul 28)
*/

CREATE TEMPORARY TABLE session_level_made_it_flag
SELECT 
    website_session_id,
    MAX(homepage) AS saw_homepage,
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT 
    website_sessions.website_session_id,
    CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
) as pageview_level
GROUP BY 
	website_session_id;
    
-- Final Output 1

SELECT 
    CASE
        WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic'
    END AS segment,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
    session_level_made_it_flag
GROUP BY 
	segment;
    
-- Final output - clicked rate

SELECT 
    CASE
        WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic'
    END AS segment,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS lander_click_rt,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_click_rt,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM
    session_level_made_it_flag
GROUP BY 
	segment;

/*
8. I'd love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
   (Sep 10 - Nov 10), in term of revenue per billing session, and then pull the number of billing page sessions for the 
   past months to understand montly impact.
*/

SELECT 
    billing_version_seen,
    COUNT(website_session_id) AS sessions,
    SUM(price_usd) / COUNT(website_session_id) AS revenue_per_billing_page_seen
FROM
    (SELECT 
        website_pageviews.website_session_id,
            website_pageviews.pageview_url AS billing_version_seen,
            orders.order_id,
            orders.price_usd
    FROM
        website_pageviews
    LEFT JOIN orders ON website_pageviews.website_session_id = orders.website_session_id
    WHERE
        website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-10-10'
            AND website_pageviews.pageview_url IN ('/billing' , '/billing-2')) AS billing_pageviews_and_order_data
GROUP BY billing_version_seen; 

-- $23.25 revenue per billing page seen for the old version
-- $30.20 for the new version 
-- Lift : $6.95 per billing page view

SELECT 
    COUNT(website_session_id) AS billing_session_past_month
FROM
    website_pageviews
WHERE
    website_pageviews.pageview_url IN ('/billing' , '/billing-2')
        AND website_pageviews.created_at BETWEEN '2012-10-27' AND '2012-11-27'
        
        
-- 1193 billing session last month
-- lift : $6.95 per billing page view
-- value of billing test : 6.95*1,193 = $8,291.35 over the past month 