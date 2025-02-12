from pyspark.sql import SparkSession

query = """
    WITH teams_deduped AS (
        SELECT
            *,
            ROW_NUMBER() OVER(PARTITION BY team_id) AS row_num
        FROM
            teams
    )
    SELECT
        team_id AS identifier,
        'team' AS `type`,
        map(
            'abbreviation', abbreviation,
            'nickname', nickname,
            'city', city,
            'arena', arena,
            'year_founded', yearfounded
        ) AS properties
    FROM
        teams_deduped
    WHERE
        row_num = 1
"""

def do_team_vertex_transformation(spark, df):
    df.createOrReplaceTempView("teams")
    return spark.sql(query)

def main():
    spark = SparkSession.builder \
        .master("local") \
        .appName("players_scd") \
        .getOrCreate()
    output_df = do_team_vertex_transformation(spark, spark.table("players"))
    output_df.write.mode("overwrite").insertInto("players_scd")
