USE mavenfuzzyfactory;

-- ASSIGNMENT-1 (2014-11-01)

/*
1. We've been thinking about customer value based solely on their first session conversion
   and revenue. but if customers have repeat sessions, they may be more valuable than we 
   thought. if that's the case, we might be able to spend a bit more to aquire them.
   Could you please pull data on how many of our website visitor come back for another 
   session? 2014 to date is good.
*/

-- Step 1: Identify the relevant new sessions
-- Step 2: Use the user_id value from step 1 to find any repeat season those users had
-- Step 3: Analyze the data at user level (how many seasons did each user have?)
-- Step 4: Aggregate the user-level analysis to generate your behavioral analysis

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT 
    new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    website_sessions.website_session_id AS repeat_sesiion_id
FROM
    (SELECT 
        user_id, website_session_id
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-01'
            AND is_repeat_session = 0) AS new_sessions
        LEFT JOIN
    website_sessions ON website_sessions.user_id = new_sessions.user_id
        AND website_sessions.website_session_id > new_sessions.website_session_id
        AND created_at BETWEEN '2014-01-01' AND '2014-11-01';
        

SELECT 
    repeat_sessions, COUNT(user_id) AS users
FROM
    (SELECT 
        user_id,
            COUNT(new_session_id) AS new_sessions,
            COUNT(repeat_sesiion_id) AS repeat_sessions
    FROM
        sessions_w_repeats
    GROUP BY user_id
    ORDER BY repeat_sessions DESC) AS user_level
GROUP BY repeat_sessions
ORDER BY repeat_sessions;

/*
repeat_sessions     users
0					126813
1					14086
2					315
3					4686
*/

-- ASSIGNMET 2 (2014-11-03)

/*
2. Ok, so the repeat session data was really interesting to see.
   Now you've got me curious to better understand the behaviour of these repeat customers.
   Could you help me understand the minimum,maximum and average time between the first and
   second sessions for customers who do come back? Again analyzing 2014 to date is probably
   the right time period.
*/

-- Step 1: Identify the relevent new sessions
-- Step 2: Use the user id values from step 1 to find any repeat season those users had
-- Step 3: find the created_at time for first and second sessins
-- Step 4: find the difference between first and second sessions at user level
-- Step 5: Aggregate the user level data to find the average, min, max

CREATE TEMPORARY TABLE user_date
SELECT 
    first_time.user_id,
    first_time.website_session_id as first_website_session_id,
    first_time.created_at AS initial_date,
    website_sessions.website_session_id as second_website_session_id,
    DATE(website_sessions.created_at) AS second_date
FROM
    (SELECT 
        DATE(created_at) AS created_at, website_session_id, user_id
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-03'
            AND is_repeat_session = 0) AS first_time
        LEFT JOIN
    website_sessions ON website_sessions.user_id = first_time.user_id
        AND website_sessions.website_session_id > first_time.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-01';


CREATE TEMPORARY TABLE users_first_to_second        
SELECT 
    user_id,
    DATEDIFF(min_second_date, initial_date) AS days_first_to_second_session
FROM
    (SELECT 
        user_id,
            first_website_session_id,
            initial_date,
            MIN(second_website_session_id) AS second_session_id,
            MIN(second_date) AS min_second_date
    FROM
        user_date
    WHERE
        second_website_session_id IS NOT NULL
            AND second_date IS NOT NULL
    GROUP BY user_id , first_website_session_id , initial_date) AS first_second;
        
SELECT 
    AVG(days_first_to_second_session) AS avg_days_first_to_second,
    MIN(days_first_to_second_session) AS min_days_first_to_second,
    MAX(days_first_to_second_session) AS max_days_first_to_second
FROM
    users_first_to_second;
    
/*
avg_days_first_to_second    min_days_first_to_second     max_days_first_to_second
33.2498							1							69
*/

-- ASSIGNMENT-3 (2014-11-05)

/*
3. Let's do a bit more digging into our repeated customers.
   Can you help me understand the channel they come back through? Curious if it's all direct 
   type-in, or if we're paying for these customers with paid search ads multiple times.
   Comparing new vs repeat sessions by channel would be really valuable, if you're able
   to pull it! 2014 to date is great.
*/


SELECT 
	CASE
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
	END AS channel_group,
   -- utm_source,
   -- utm_campaign,
   -- http_referer,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 
    channel_group
ORDER BY 
	repeat_sessions DESC;

/*
channel_group	 new_sessions	 repeat_sessions
organic_search		7139			11507
paid_brand			6432			11027
direct_type_in		6591			10564
paid_nonbrand		119950			0
paid_social			7652			0
*/

-- ASSIGNMENT-4 (2014-11-08)

/*
4. Sounds like we have learned lot about our repeat customers.
   Can i trouble you for one more thing?
   I'd love to do a comparison of conversion rates and revenue per 
   sesion for repeat sessions vs new sessions.
   Let's continue using data from 2014, year to date.
*/

SELECT 
    is_repeat_session,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd) / COUNT(website_sessions.website_session_id) AS rev_per_session
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY is_repeat_session;
    
/*
is_repeat_session  sessions	  orders  	 conv_rate	 rev_per_session
0					149787		10179		0.0680		4.343754
1					33577		2724		0.0811		5.168828
*/