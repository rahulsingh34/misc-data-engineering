INSERT INTO actors_history_scd
WITH started AS (
	SELECT
		actorid,
		year,
		quality_class,
		is_active,
		LAG(quality_class, 1) OVER(PARTITION BY actorid ORDER BY year)    AS previous_quality_class,
		LAG(is_active, 1) OVER(PARTITION BY actorid ORDER BY year)        AS previous_is_active
	FROM
		actors
	WHERE
		year <=2020
), indicators AS (
	SELECT
		*,
		CASE
			WHEN quality_class != previous_quality_class THEN 1
			WHEN is_active != previous_is_active THEN 1
			ELSE 0
		END AS change_indicator
	FROM
		started
), streak AS (
	SELECT
		*,
		SUM(change_indicator) OVER(PARTITION BY actorid ORDER BY YEAR) AS streak_identifier
	FROM
		indicators
)
SELECT
	actorid,
	quality_class,
	is_active,
	MIN(year) AS start_year,
	MAX(year) AS end_year,
	2020 AS year
FROM
	streak
GROUP BY
	actorid,
	streak_identifier,
	quality_class,
	is_active
ORDER BY
	actorid,
	streak_identifier