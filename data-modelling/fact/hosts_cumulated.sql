INSERT INTO hosts_cumulated
WITH yesterday AS (
SELECT
	*
FROM
	hosts_cumulated
WHERE
	date = '2023-01-01'
), today AS (
	SELECT
		host,
		user_id,
		DATE(event_time) AS date_active
	FROM
		events
	WHERE
		host IS NOT NULL
		AND user_id IS NOT NULL
		AND DATE(event_time) = '2023-01-02'
	GROUP BY
		host,
		user_id,
		DATE(event_time)
)
SELECT
	COALESCE(t.host, y.host) 								     AS host,
	COALESCE(t.user_id, y.user_id) 								 AS user_id,
	CASE
		WHEN y.host_activity_datelist IS NULL
			THEN ARRAY[t.date_active]
		WHEN t.date_active IS NULL
			THEN y.host_activity_datelist
		ELSE ARRAY[t.date_active] || y.host_activity_datelist
	END														     AS host_activity_datelist,
	DATE(COALESCE(t.date_active, y.date + INTERVAL '1 DAY'))     AS date
FROM
	today 						 AS t
	FULL OUTER JOIN yesterday    AS y ON t.host = y.host AND t.user_id = y.user_id
