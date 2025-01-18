CREATE TYPE films AS (
	film TEXT,
	votes INTEGER,
	rating REAL,
	filmid TEXT
)

CREATE TYPE quality_class AS ENUM (
	'star',
	'good',
	'average',
	'bad'
)

CREATE TYPE film_year AS (
	year INTEGER,
	films films[]
)

CREATE TYPE actors_scd_type AS (
	quality_class quality_class,
	is_active BOOLEAN,
	start_year INTEGER,
	end_year INTEGER
)