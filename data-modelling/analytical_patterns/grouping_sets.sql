WITH joined_data AS (
	SELECT
		gd.game_id,
		gd.player_name,
		gd.team_city,
		g.season,
		gd.pts,
		CASE
			WHEN gd.team_id = g.team_id_home AND home_team_wins = 0 THEN NULL
			WHEN gd.team_id = g.team_id_away AND home_team_wins = 1 THEN NULL
			ELSE gd.game_id
		END AS game_id_won
	FROM
		game_details 	    AS gd
		INNER JOIN games    AS g ON gd.game_id = g.game_id
), grouping_sets AS (
	SELECT 
		CASE
			WHEN GROUPING(player_name) = 0 
				AND GROUPING(team_city) = 0 
				AND GROUPING(season) = 0 
				THEN 'player_name__team_city__season'
			WHEN GROUPING(player_name) = 0 AND GROUPING(team_city) = 0 
				THEN 'player_name__team_city'
			WHEN GROUPING(player_name) = 0 AND GROUPING(season) = 0 
				THEN 'player_name__season'
			WHEN GROUPING(team_city) = 0 
				THEN 'team_city'
		END 														      AS aggregation_level,
		COALESCE(player_name, '(OVERALL)')							      AS player_name,
		COALESCE(team_city, '(OVERALL)')  					   			  AS team_city,
		COALESCE(CAST(season AS TEXT), '(OVERALL)') 					  AS season,
		SUM(pts) 													      AS pts,
		COUNT(DISTINCT game_id_won) 									  AS games_won
	FROM
		joined_data
	GROUP BY GROUPING SETS (
		(player_name, team_city, season),
		(player_name, team_city),
		(player_name, season),
		(team_city)
	)
), most_points_on_one_team AS (
	SELECT
		*
	FROM
		grouping_sets
	WHERE
		aggregation_level = 'player_name__team_city'
	ORDER BY
		pts DESC NULLS LAST 
	LIMIT 1
), most_points_in_one_season AS (
	SELECT
		*
	FROM
		grouping_sets
	WHERE
		aggregation_level = 'player_name__season'
	ORDER BY
		pts DESC NULLS LAST 
	LIMIT 1
), most_winning_team AS (
	SELECT 
		*
	FROM
		grouping_sets
	WHERE
		aggregation_level = 'team_city'
	ORDER BY
		games_won DESC NULLS LAST
	LIMIT 1
)
SELECT * FROM grouping_sets