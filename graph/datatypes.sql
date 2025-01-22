CREATE TYPE vertex_type AS ENUM(
    'player',
    'team', 
    'game'
)

CREATE TYPE edge_type AS ENUM(
    'plays_against',
    'shares_team',
    'plays_in',
    'plays_on'
)
