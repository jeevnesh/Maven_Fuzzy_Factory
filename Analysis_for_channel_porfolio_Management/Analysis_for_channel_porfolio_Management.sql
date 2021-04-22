USE mavenfuzzyfactory;

-- Analyzing Channel Portfolios
SELECT 
    utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'  -- arbitrary range
GROUP BY utm_content
ORDER BY sessions DESC;

/*
utm_content|   sessions|   orders|   conversion_rate
g_ad_1	     	7500		543			0.0724
NULL		    2724		194			0.0712
social_ad_1		1618		17			0.0105
b_ad_1			1614		109			0.0675
g_ad_2			1107		91			0.0822
b_ad_2			262			29			0.1107
*/
-- ASSIGNMENT-1(2012-11-29)
/*
1. With gsearch doing well and the site performing better, we launched a second paid search channel,
   bsearch around August 22.
   Can you pull weekly trended session volume since then and compare to gsearch nonbrand so i can
   get a sense for how important this will be for the business?
*/

SELECT 
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_sessions
FROM
    website_sessions
WHERE
    website_sessions.created_at BETWEEN '2012-08-22' AND '2012-11-29'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY WEEK(website_sessions.created_at);

/*
week_start_date| gsearch_sessions| bsearch_sessions
2012-08-22	      590				197
2012-08-26	      1056				343
2012-09-02	      925  				290
2012-09-09	      951			    329
2012-09-16	      1151				365
2012-09-23	      1050				321
2012-09-30	      999			    316
2012-10-07	      1002				330
2012-10-14	      1257				420
2012-10-21	      1302				431
2012-10-28	      1211				384
2012-11-04	      1350				429
2012-11-11		  1246				438
2012-11-18		  3508				1093
2012-11-25		  2286			    774
*/

-- ASSIGNMENT-2 (2012-11-30)
/*
2. I'd like to learn more about the bsearch nonbrand campaign. could you please pull the 
   percentage of traffic coming on Mobile, and compare that to gsearch?
   Feel free to dig around and share everything else you find interesting. Aggregate data since 
   August 22nd is great, no need to show trending at this point. 
*/

SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS pct_mobile,
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) / COUNT(website_session_id) AS pct_desktop
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-08-22' AND '2012-11-30'
        AND utm_campaign = 'nonbrand'
GROUP BY
	utm_source;
    
/*
     utm_source| sessions| mobile_sessions| pct_mobile| desktop_sessions| pct_desktop
     bsearch	 6522	    562	            0.0862	     5960	           0.9138
     gsearch	 20073	    4921	        0.2452	     15152	           0.7548
*/    

-- ASSIGNMENT-3 (2012-12-01)
/*
3. I'm wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand conversion 
   rates from session to order for gsearch and bsearch, and slice the data by device type?
   Please analize data from August 22 to September 18; We ran a special pre-holiday campaign for gsearch
   starting on September 19, so data after that isn't fair game.
*/

SELECT 
    website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS conv_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type , website_sessions.utm_source
ORDER BY website_sessions.device_type;

/*
device_type| utm_source| sessions| orders| conv_rate
desktop	     bsearch	 1118	   43	    0.0385
desktop	     gsearch	 2850	   130	    0.0456
mobile	     bsearch	 125	   1	    0.0080
mobile	     gsearch	 962  	   11	    0.0114
*/

-- ASSIGNMENT-4 (2012-12-22)
/*
4. Based on your last analysis, we bid down bsearch nonbrand on December 2nd.
   Can you pull weekly session volume for gsearch and bsearch nonbrand,
   broken down by device, since November 4th?
   If you can include a comparision metric to show bsearch as a percent of
   gsearch for each device, that would be great too.
*/

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_dtop_session,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_dtop_session,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_percent_of_g_dtop,
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mob_session,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mob_session,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_percent_of_g_mob
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-11-04' AND '2012-12-22'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

/*
week_start_date|  g_dtop_session|  b_dtop_session| b_percent_of_g_dtop|  g_mob_session|  b_mob_session|  b_percent_of_g_mob       
2012-11-04			1027			400				0.3895				323					29				0.0898
2012-11-11			956				401				0.4195				290					37				0.1276
2012-11-18			2655			1008			0.3797				853					85				0.0996
2012-11-25			2058			843				0.4096				692					62				0.0896
2012-12-02			1326			517				0.3899				396					31				0.0783
2012-12-09			1277			293				0.2294				424					46				0.1085
2012-12-16			1270			348				0.2740				376					41				0.1090
*/

-- Analysing Direct, Brand-Driven Traffic
SELECT 
    CASE
        WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN http_referer = 'https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic'
        WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
    END AS traffic,
	COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN '100000' AND '115000'
GROUP BY traffic
ORDER BY sessions DESC; 

/*
traffic       		 sessions
NULL	       		 12760
direct_type_in		 1055
gsearch_organic		 966
bsearch_organic		 220
*/

-- ASSIGNMENT-5 (2012-12-23)

/*
5. A Potential investor is asking if we're building any momentum with our brand or if
   we'll need to keep relying on paid traffic.
   Could you pull organic search, direct type in, and paid brand search sessions by month,
   and show those sessions as a % of paid search nonbrand?
*/

SELECT 
    YEAR(created_at) AS yr,
    MONTHNAME(created_at) AS months,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS brand_perct_of_nonbrand,
    COUNT(CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
    COUNT(CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS direct_perc_of_nonbrand,
    COUNT(CASE WHEN http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com') AND utm_source IS NULL THEN website_session_id ELSE NULL END) AS organic,
    COUNT(CASE WHEN http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com') AND utm_source IS NULL THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_perc_of_nonbrand
FROM
    website_sessions
WHERE
    created_at < '2012-12-23'
GROUP BY YEAR(created_at) , MONTHNAME(created_at);

/*
yr|		months	   nonbrand    brand   brand_perct_of_nonbrand    direct   direct_perc_of_nonbrand     organic   organic_perc_of_nonbrand
2012	March	   1852			10		0.0054						9			0.0049					8			0.0043
2012	April	   3509			76		0.0217						71			0.0202					78			0.0222
2012	May		   3295			140		0.0425						151			0.0458					150			0.0455
2012	June	   3439			164		0.0477						170			0.0494					190			0.0552
2012	July	   3660			195		0.0533						187			0.0511					207			0.0566
2012	August	   5318			264		0.0496						250			0.0470					265			0.0498
2012	September  5591			339		0.0606						285			0.0510					331			0.0592
2012	October	   6883			432		0.0628						440			0.0639					428			0.0622
2012	November   12260		556		0.0454						571			0.0466					624			0.0509
2012	December   6643			464		0.0698						482			0.0726					492			0.0741
*/
