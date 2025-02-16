-- PLAYER - GAME
INSERT INTO edges
WITH game_details_deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
	FROM
		game_details 
)
SELECT 
	player_id                AS subject_identifier,
	'player'::vertex_type    AS subject_type,
	game_id                  AS object_identifier,
	'game'::vertex_type      AS object_type,
	'plays_in'::edge_type    AS edge_type,
	json_build_object(
		'start_position', start_position,
		'pts', pts,
		'team_id', team_id,
		'team_abbreviation', team_abbreviation 
	) 
FROM
	game_details_deduped
WHERE 
	row_num = 1

-- PLAYER - PLAYER
INSERT INTO edges
WITH game_details_deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
	FROM
		game_details 
), filtered AS (
	SELECT
		*
	FROM
		game_details_deduped
	WHERE
		row_num = 1
), aggregated AS (
	SELECT
		f1.player_id                                            AS subject_player_id,
		MAX(f1.player_name)                                     AS subject_player_name,
		f2.player_id                                            AS object_player_id,
		MAX(f2.player_name)                                     AS object_player_name,
		CASE
			WHEN f1.team_abbreviation = f2.team_abbreviation 
                THEN 'shares_team'::edge_type
			ELSE 'plays_against'::edge_type
		END                                                     AS edge_type,
		COUNT(1)                                                AS num_games,
		SUM(f1.pts)                                             AS subject_points,
		SUM(f2.pts)                                             AS object_points
	FROM
		filtered AS f1
		JOIN filtered AS f2 ON f1.game_id = f2.game_id AND f1.player_name != f2.player_name
	WHERE
		f1.player_id > f2.player_id
	GROUP BY
		f1.player_id, f2.player_id, edge_type
)
SELECT
	subject_player_id        AS subject_identifier,
	'player'::vertex_type    AS subject_type,
	object_player_id         AS object_identifier,
	'player'::vertex_type    AS object_type,
	edge_type                AS edge_type,
	json_build_object(
		'num_games', num_games,
		'subject_points', subject_points,
		'object_points', object_points
	) 
FROM
	aggregated