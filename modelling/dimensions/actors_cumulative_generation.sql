INSERT INTO actors
WITH last_year AS (
	SELECT
		*
	FROM
		actors
	WHERE
		year = 1969
), this_year AS (
	SELECT
		actorid,
		actor,
		year,
		avg(rating) 										  AS average_rating,
		ARRAY_AGG(ROW(film, votes, rating, filmid)::films)    AS films
	FROM
		actor_films
	WHERE
		year = 1970
	GROUP BY
        actorid, actor, year
)
SELECT
	COALESCE(l.actorid, t.actorid)    					  AS actorid,
	COALESCE(l.actor, t.actor)        					  AS actor,
	CASE 
		WHEN l.films IS NULL THEN
			ARRAY[ROW(
                COALESCE(t.year, l.year + 1),
                t.films
            )::film_year]
		WHEN t.year	IS NOT NULL THEN 
			l.films || ARRAY[ROW(
                COALESCE(t.year, l.year + 1),
                t.films
            )::film_year]
		ELSE
			l.films
	END  						       					  AS films,
	CASE
		WHEN t.year IS NOT NULL THEN
			(CASE
				WHEN average_rating > 8 THEN 'star'
				WHEN average_rating > 7 THEN 'good'
				WHEN average_rating > 6 THEN 'average'
				ELSE 'bad'
			END::quality_class)
		ELSE
			l.quality_class	
	END 							   				      AS quality_class,
	CASE
		WHEN t.year IS NOT NULL THEN TRUE
		ELSE FALSE
	END 							   				      AS is_active,
	COALESCE(t.year, l.year + 1)      					  AS year
FROM
	last_year 					 AS l
	FULL OUTER JOIN this_year    AS t ON l.actorid = t.actorid