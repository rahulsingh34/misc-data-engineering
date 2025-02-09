INSERT INTO host_activity_reduced
WITH daily_aggregate AS (
	SELECT
		host,
		DATE(event_time)           AS date,
		COUNT(1)                   AS hits,
		COUNT(DISTINCT user_id)    AS unique_visitors
	FROM
		events
	WHERE
		DATE(event_time) = DATE('2023-01-02')
		AND user_id IS NOT NULL
	GROUP BY 
		host,
		DATE(event_time)
), yesterday_array AS (
	SELECT
		*
	FROM
		host_activity_reduced
	WHERE
		month_start = DATE('2023-01-01')
)
SELECT
	COALESCE(DATE_TRUNC('MONTH', da.date), ya.month_start) AS month_start,
	COALESCE(da.host, ya.host)							   AS host,
	CASE
		WHEN ya.hit_array IS NOT NULL 
			THEN ya.hit_array || ARRAY[COALESCE(da.hits, 0)] 
		WHEN ya.hit_array IS NULL
			THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('MONTH', date)), 0)]) || ARRAY[COALESCE(da.hits, 0)] 			
	END AS hit_array,
	CASE
		WHEN ya.unique_visitors IS NOT NULL 
			THEN ya.unique_visitors || ARRAY[COALESCE(da.unique_visitors, 0)] 
		WHEN ya.unique_visitors IS NULL
			THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('MONTH', date)), 0)]) || ARRAY[COALESCE(da.unique_visitors, 0)] 			
	END AS unique_visitors
FROM
	daily_aggregate 				AS da
	FULL OUTER JOIN yesterday_array AS ya ON da.host = ya.host
ON CONFLICT (host, month_start)
DO UPDATE SET hit_array = EXCLUDED.hit_array, unique_visitors = EXCLUDED.unique_visitors