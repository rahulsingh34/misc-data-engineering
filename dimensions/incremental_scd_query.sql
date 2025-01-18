WITH last_year_scd AS (
	SELECT
		*
	FROM
		actors_history_scd
	WHERE
		year = 1973
		AND end_year = 1973
		-- Latest data that I backfilled - 1
), historical_scd AS (
	SELECT
		actorid,
		quality_class,
		is_active,
		start_year,
		end_year
	FROM
		actors_history_scd
	WHERE
		end_year < 1973
), this_year_scd AS (
	SELECT
		*
	FROM
		actors
	WHERE
		year = 1974
), unchanged_records AS (
	SELECT
		t.actorid,
		t.quality_class,
		t.is_active,
		l.start_year,
		t.year AS end_year
	FROM
		this_year_scd               AS t
		INNER JOIN last_year_scd    AS l ON t.actorid = l.actorid
	WHERE
		t.quality_class = l.quality_class
		AND t.is_active = l.is_active
), changed_records AS (
	SELECT
		t.actorid,
		UNNEST(ARRAY[
			ROW(
				l.quality_class,
				l.is_active,
				l.start_year,
				l.end_year
			)::actors_scd_type,
			ROW(
				t.quality_class,
				t.is_active,
				t.year,
				t.year
			)::actors_scd_type		
		]) AS records
	FROM
		this_year_scd		       AS t
		LEFT JOIN last_year_scd    AS l ON t.actorid = l.actorid
	WHERE
		t.quality_class != l.quality_class
		OR t.is_active != l.is_active
), unnested_changed_records AS (
	SELECT
		actorid,
		(records::actors_scd_type).*
	FROM
		changed_records
), new_records AS (
	SELECT
		t.actorid,
		t.quality_class,
		t.is_active,
		t.year AS start_year,
		t.year AS end_year
	FROM
		this_year_scd 			   AS t
		LEFT JOIN last_year_scd    AS l ON t.actorid = l.actorid	
	WHERE
		l.actorid IS NULL
)
SELECT * FROM historical_scd
UNION ALL
SELECT * FROM unchanged_records
UNION ALL
SELECT * FROM unnested_changed_records
UNION ALL
SELECT * FROM new_records