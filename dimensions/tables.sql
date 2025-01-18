CREATE TABLE actors (
	actorid TEXT,
	actor TEXT,
	films film_year[],
	quality_class quality_class,
	is_active BOOLEAN,
	year INTEGER,
	PRIMARY KEY (actorid, year)
)