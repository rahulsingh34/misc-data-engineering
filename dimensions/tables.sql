CREATE TABLE actors (
	actorid TEXT,
	actor TEXT,
	films film_year[],
	quality_class quality_class,
	is_active BOOLEAN,
	year INTEGER,
	PRIMARY KEY (actorid, year)
)

CREATE TABLE actors_history_scd (
	actorid TEXT,
	quality_class quality_class,
	is_active BOOLEAN,
	start_year INTEGER,
	end_year INTEGER,
	year INTEGER,
	PRIMARY KEY(actorid, start_year)
)