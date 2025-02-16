WITH lebron AS (
	SELECT
		gd.game_id,
		g.game_date_est,
		gd.pts,
		SUM(CASE WHEN pts < 10 OR pts IS NULL THEN 1 ELSE 0 END) OVER (ORDER BY game_date_est) AS grp
	FROM
		game_details AS gd
		INNER JOIN games AS g ON gd.game_id = g.game_id
	WHERE
		player_name = 'LeBron James'
)
SELECT 
	grp,
	COUNT(grp) - CASE WHEN grp > 0 THEN 1 ELSE 0 END AS games_in_a_row_scoring_over_ten_pts
FROM 
	lebron
GROUP BY
	grp
ORDER BY
	games_in_a_row_scoring_over_ten_pts DESC
LIMIT 1