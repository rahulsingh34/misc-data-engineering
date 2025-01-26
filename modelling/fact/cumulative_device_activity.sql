INSERT INTO user_devices_cumulated
WITH yesterday AS (
	SELECT
		*
	FROM
		user_devices_cumulated
	WHERE
		date = '2023-01-01'
), today AS (
	SELECT
		e.user_id,
		d.browser_type,
		DATE(e.event_time)    AS date_active
	FROM
		events 			     AS e
		LEFT JOIN devices    AS d ON e.device_id = d.device_id 
	WHERE 
		e.user_id IS NOT NULL
		AND d.browser_type IS NOT NULL
		AND DATE(e.event_time) = '2023-01-02'
	GROUP BY
		user_id,
		d.browser_type,
		DATE(e.event_time)
)
SELECT
	COALESCE(t.user_id, y.user_id) 						           AS user_id,
	COALESCE(t.browser_type, y.browser_type)    		           AS browser_type,
	CASE
		WHEN y.device_activity_datelist IS NULL
			THEN ARRAY[t.date_active]
		WHEN t.date_active IS NULL
			THEN y.device_activity_datelist
		ELSE ARRAY[t.date_active] || y.device_activity_datelist
	END													           AS device_activity_dateliest,
	DATE(COALESCE(t.date_active, y.date + INTERVAL '1 DAY'))       AS date
FROM 
	today 					     AS t
	FULL OUTER JOIN yesterday    AS y ON t.user_id = y.user_id AND t.browser_type = y.browser_type