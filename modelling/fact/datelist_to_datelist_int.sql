WITH user_devices AS (
	SELECT
		*
	FROM
		user_devices_cumulated 
	WHERE
		date = '2023-01-31'
), series AS (
	SELECT
		*
	FROM
		generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 DAY') AS series_date
), placeholder_ints AS (
	SELECT
		*,
		CASE 
			WHEN device_activity_datelist @> ARRAY[DATE(series_date)] 
				THEN POW(2, 32 - (date - DATE(series_date)))
			ELSE 0
		END AS placeholder_int_value
	FROM
		user_devices
		CROSS JOIN series
)
SELECT
	user_id,
	browser_type,
	CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32)),
	BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0    AS dim_is_monthly_active,
	BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) &
		CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0          AS dim_is_weekly_active,
	BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) &
	CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0              AS dim_is_daily_active
FROM
	placeholder_ints
GROUP BY
	user_id, browser_type