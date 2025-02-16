SELECT
	*,
	CASE
		WHEN MIN(current_season) OVER (PARTITION BY player_name) = current_season THEN 'New'
		WHEN LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) = TRUE AND years_since_last_season = 0 THEN 'Continued Playing'
		WHEN years_since_last_season = 1 THEN 'Retired'
		WHEN years_since_last_season > 1 THEN 'Stayed Retired'
		ELSE 'Returned from Retirement'
	END AS state
FROM
	players