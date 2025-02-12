from chispa.dataframe_comparer import *
from spark.testing.job import do_team_vertex_transformation
from collections import namedtuple

TeamVertex = namedtuple(
    'TeamVertex',
    "identifier type properties"
)

Team = namedtuple(
    'Team',
    "team_id abbreviation nickname city arena year_founded"
)

def test_vertex_generation(spark):
    # Input data to check deduping + transformation
    input_data = [
        Team(1, "GSW", "Warriors", "San Francisco", "Chase Center", 1900),
        Team(1, "GSW", "Bad Warriors", "San Francisco", "Chase Center", 1900),
    ]

    input_df = spark.createDataFrame(input_data)
    
    # Run the transformation
    actual_df = do_team_vertex_transformation(spark, input_df)

    # Expected output
    expected_output = [
        TeamVertex(
            identifier=1,
            type='team',
            properties={
                'abbreviation': 'GSW',
                'nickname': 'Warriors',
                'city': 'San Francisco',
                'arena': 'Chase Center',
                'year_founded': 1900
            }
        )
    ]

    expected_df = spark.createDataFrame(expected_output)

    # Check results/equality
    assert_df_equality(actual_df, expected_df, ignore_nullable=True)