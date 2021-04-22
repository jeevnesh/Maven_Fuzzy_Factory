USE mavenfuzzyfactory;

-- Using Time Functions

SELECT 
    website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday,
    CASE
        WHEN WEEKDAY(created_at) IN (5 , 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS weekdays,
    DATE(created_at) AS dates,
    WEEK(created_at) AS weeks,
    MONTH(created_at) AS months,
    QUARTER(created_at) AS qtr,
    YEAR(created_at) AS yr
FROM
    website_sessions
WHERE
    website_session_id < 1000;
    
-- ASSIGNMENT-1 (2013-01-02)
/*
1. 2012 was a great year for us. As we continue to grow, we should take a look at 2012's monthly and weekly volume
   patterns, to see if we can find any seasonal trends we should plan for 2013.
   If you can pull session volume and order volume, that would be excellent.
*/

SELECT 
    YEAR(website_sessions.created_at) AS years,
    MONTH(website_sessions.created_at) AS months,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2013-01-01'
GROUP BY YEAR(website_sessions.created_at) , MONTH(website_sessions.created_at);

/*
years  months sessions  orders
2012	3	   1879		 60
2012	4	   3734		 99
2012	5	   3736		 108
2012	6	   3963	 	 140
2012	7	   4249		 169
2012	8	   6097		 228
2012	9	   6546	 	 287
2012	10	   8183		 371
2012	11	   14011   	 618
2012	12     10072	 506
*/

SELECT 
    MIN(DATE(website_sessions.created_at)) AS Week_start_date,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at <= '2013-01-01'
GROUP BY WEEK(website_sessions.created_at);

/*
Week_start_date sessions orders
2012-03-19		896			25
2012-03-25		983			35
2012-04-01		1193		29
2012-04-08		1029		28
2012-04-15		679			22
2012-04-22		655			18
2012-04-29		770			19
2012-05-06		798			17
2012-05-13		706			23
2012-05-20		965			28
2012-05-27		875			31
2012-06-03		920			34
2012-06-10		994			29
2012-06-17		966			37
2012-06-24		883			32
2012-07-01		892			30
2012-07-08		925			36
2012-07-15		987			47
2012-07-22		954			41
2012-07-29		1172		55
2012-08-05		1235		48
2012-08-12		1181		39
2012-08-19		1522		55
2012-08-26		1593		52
2012-09-02		1418		56
2012-09-09		1488		72
2012-09-16		1776		76
2012-09-23		1624		70
2012-09-30		1553		67
2012-10-07		1632		73
2012-10-14		1955		93
2012-10-21		2042		95
2012-10-28		1923		82
2012-11-04		2086		91
2012-11-11		1973		101
2012-11-18		5130		223
2012-11-25		4172		179
2012-12-02		2727		145
2012-12-09		2489		123
2012-12-16		2718		135
2012-12-23		1682		74
2012-12-30		309	    	21
*/

-- ASSIGNMENT-2
/*
2. We're considering adding live chat support to the website to improve our customer experience.
   Could you analyze the average website session volume, by hour of day and by day week, so that 
   we can staff appropriately?
   Let's avoid the holiday time period and use a date range of Sep 15 - Nov 15 , 2012.
*/

SELECT 
	hr,
    AVG(CASE WHEN wkday = 0 THEN website_session_id ELSE NULL END) AS mon,
    AVG(CASE WHEN wkday = 1 THEN website_session_id ELSE NULL END) AS tue,
    AVG(CASE WHEN wkday = 2 THEN website_session_id ELSE NULL END) AS wed,
    AVG(CASE WHEN wkday = 3 THEN website_session_id ELSE NULL END) AS thu,
    AVG(CASE WHEN wkday = 4 THEN website_session_id ELSE NULL END) AS fri,
    AVG(CASE WHEN wkday = 5 THEN website_session_id ELSE NULL END) AS sat,
    AVG(CASE WHEN wkday = 6 THEN website_session_id ELSE NULL END) AS sun
FROM(
    SELECT
      DATE(created_at) AS created_at,
      WEEKDAY(created_at) AS wkday,
      HOUR(created_at) AS hr,
      COUNT(DISTINCT website_session_id) as website_session_id
    FROM  
    website_sessions
WHERE
    created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY DATE(created_at),
      WEEKDAY(created_at),
      HOUR(created_at)) AS daily_hourly_sessions
GROUP BY hr
ORDER BY hr;

/*
hr  mon     tue     wed     thu     fri     sat     sun
0	8.6667	7.6667	6.3333	7.3750	6.7500	5.0000	5.0000
1	6.5556	6.6667	5.3333	4.8750	7.1250	5.0000	3.0000
2	6.1111	4.4444	4.4444	6.1250	4.6250	3.6667	3.0000
3	5.6667	4.0000	4.6667	4.5714	3.6250	3.8889	3.3750
4	5.8750	6.3333	6.0000	4.0000	6.1429	2.7500	2.4444
5	5.0000	5.4444	5.1111	5.3750	4.6250	4.3333	3.8889
6	5.4444	5.5556	4.7778	6.0000	6.7500	4.0000	2.5556
7	7.3333	7.7778	7.4444	10.6250	7.0000	5.6667	4.7778
8	12.3333	12.2222	13.0000	16.5000	10.5000	4.2500	4.1111
9	17.5556	15.6667	19.5556	19.2500	17.5000	7.5556	6.0000
10	18.4444	17.6667	21.0000	18.3750	19.0000	8.3333	6.3333
11	18.0000	19.1111	24.8889	21.6250	20.8750	7.2222	7.6667
12	21.1111	23.3333	22.7778	24.1250	19.0000	8.5556	6.1111
13	17.7778	23.0000	20.7778	20.6250	21.6250	8.1111	8.4444
14	17.8889	21.5556	22.3333	18.5000	19.5000	8.6667	6.6667
15	21.5556	17.1111	25.3333	23.5000	21.2500	6.8889	7.1111
16	21.1111	23.6667	23.6667	19.6250	20.8750	7.6250	6.5556
17	19.4444	15.8889	20.2222	19.7500	12.8750	6.4444	7.5556
18	12.6667	15.0000	14.7778	15.2500	10.8750	5.3333	6.7778
19	12.4444	14.1111	13.3333	11.6250	14.2500	7.1111	6.4444
20	12.1111	12.4444	14.2222	10.6250	10.2500	5.6667	8.4444
21	9.1111	12.5556	11.4444	9.3750	7.2500	5.6667	10.2222
22	9.1111	10.0000	9.7778	12.1250	6.0000	5.6667	10.2222
23	8.7778	8.5556	9.5556	10.6250	7.6250	5.3333	8.3333
*/
