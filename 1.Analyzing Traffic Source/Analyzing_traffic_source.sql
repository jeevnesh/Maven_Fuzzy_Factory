USE mavenfuzzyfactory;

-- Analyzing advertisement traffic

SELECT 
    website_sessions.utm_content,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS session_to_order_conv_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000                   -- Arbitrary range
GROUP BY website_sessions.utm_content
ORDER BY sessions DESC;   

/*
utm_content  sessions	 orders 	 session_to_order_conv_rate
g_ad_1			975			35			0.0359
NULL			18			0			0.0000
g_ad_2			6			0			0.0000
b_ad_2			2			0			0.0000
*/

-- ASSIGNMENT-1 (2012-04-12)

/*
1. We've been live for almost a month now and we're starting to generate sales.
   Can you help me understand where the bulk of our website sessions coming from,through yesterday?
   I'd like to see breakdown by UTM source, campaign and referring domain if possible.
*/

SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY utm_source , utm_campaign , http_referer
ORDER BY sessions DESC;

/*
utm_source  utm_campaign    http_referer				sessions
gsearch		nonbrand		https://www.gsearch.com		3613
NULL		NULL			NULL						28
NULL		NULL			https://www.gsearch.com		27
gsearch		brand			https://www.gsearch.com		26
bsearch		brand			https://www.bsearch.com		7
NULL		NULL			https://www.bsearch.com		7
*/

-- ASSIGNMENT-2 (2012-04-14)

/*
2. Sounds like gsearch nonbrand is our major traffic source, but we need to understand
   if those sessions are driving sales.
   Could you please calculate the conversion rate(CVR) from session to order? Based on
   what we're paying for clicks, we'll need a CVR of at least 4% to make th numbers work.
   If we're much lower, we'll need to reduce the bids. If we're higher, we can increase
   bids to drive more volume.
*/

SELECT 
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-04-14'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand';
        
/*
sessions	 orders  	 session_to_order_conversion_rate
3895			112			0.0288
*/

-- BID OPTIMIZATION
-- ASSIGNMENT-3 (2012-05-10)

/*
3. Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012-04-15.
   Can you pull gsearch nonbrand trended session volume, by week, to see if bid changes
   caused volume to drop at all?
*/

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-10'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);     

/*
week_start_date   sessions
2012-03-19			896
2012-03-25			956
2012-04-01			1152
2012-04-08			983
2012-04-15			621
2012-04-22			594
2012-04-29			681
2012-05-06			399
*/ 

-- ASSIGNMENT-4 (2012-05-11)

/*
4. I was trying to use our site on my mobile device the other day, and the experience
   was not great.
   Could you pull conversion rates from session to order, by device type?
   If desktop performance is better than on my mobile we may be able to bid up for 
   desktop specifically to get more volume?
 */
 
 SELECT 
    website_sessions.device_type,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS session_to_order_conersion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-05-11'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type;

/*
device_type    sessions   orders   session_to_order_conersion_rate
mobile			2492		24			0.0096
desktop			3911		146			0.0373
*/

-- ASSIGNMENT-5 (2012-06-09)

/*
5. After your device-level analysis of conversion rates, we realized desktop was doing well,
   so we bid our gsearch nonbrand desktop campaigns up on 2012-05-19.
   Could you pull weekly trends for both desktop and mobile so we can see the impact on volume?
   You can use 2012-04-15 until the bid change as a baseline.
*/

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_session,
    COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_session
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

/*
week_start_date    dtop_session    mobile_session
2012-04-15			383				238
2012-04-22			360				234
2012-04-29			425				256
2012-05-06			430				282
2012-05-13			403				214
2012-05-20			661				190
2012-05-27			585				183
2012-06-03			582				157
*/