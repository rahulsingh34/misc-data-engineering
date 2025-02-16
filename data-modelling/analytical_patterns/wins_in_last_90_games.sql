WITH teams AS (
	SELECT
		gd.game_id,
		gd.team_city,
		g.game_date_est,
		MAX(CASE 
				WHEN gd.team_id = g.team_id_home AND home_team_wins = 0 THEN 0
				WHEN gd.team_id = g.team_id_away AND home_team_wins = 1 THEN 0
				ELSE 1
			END
		) AS game_won
	FROM
		game_details AS gd
		INNER JOIN games AS g ON gd.game_id = g.game_id
	GROUP BY
		gd.game_id,
		gd.team_city,
		g.game_date_est
), games_won_tally AS (
	SELECT
		*,
		SUM(game_won) OVER(PARTITION BY team_city ORDER BY game_date_est ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS wins_in_last_90_games
	FROM
		teams
)
SELECT
	*
FROM
	games_won_tally
ORDER BY
	wins_in_last_90_games DESC
LIMIT 1
