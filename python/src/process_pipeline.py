"""
--------------------------------------------------------------
File: process_pipeline.py           Author: Neelakanteswara
Created Date: 03-05-2025            Modified Date: 99-99-9999
--------------------------------------------------------------
Description:
    This script serves as the main orchestration engine for the
    Bikestores Data Pipeline. It automates the complete ETL
    process using the following steps:

    1. Reads configurations from a .cfg file to extract required
       parameters like file paths, Snowflake credentials, etc.
    2. Iterates through all CSV files located in the staging input directory.
    3. Loads each CSV file into Snowflake after applying necessary transformations.

    This file is the entry point of the data pipeline and is designed
    to be modular, readable, and scalable for large dataset processing.
--------------------------------------------------------------
"""

import os
from pyspark.sql import SparkSession
from utils import parse_config, data_load


def spark_conn() -> SparkSession:
    """
    Initializes a SparkSession and configures it with various settings.

    Params:
        None

    Returns:
        SparkSession: The initialized SparkSession.

    Raises:
        RuntimeError: If SparkSession initialization fails.
    """
    try:
        # Initialize Spark session
        spark_session = SparkSession \
            .builder \
            .master("local") \
            .appName("bikestores_project") \
            .config('spark.jars.packages', 'net.snowflake:snowflake-jdbc:3.13.30') \
            .getOrCreate()

        print("SparkSession created successfully.")

        # Check if SparkSession was created successfully
        if spark_session is None:
            print("SparkSession could not be created.")
            raise RuntimeError("SparkSession could not be created.")

        # Set log level to ERROR to reduce verbosity
        spark_session.sparkContext.setLogLevel("ERROR")

        return spark_session

    except Exception as e:
        # Raise the exception if Spark initialization fails
        print(f"Spark initialization failed: {e}")
        raise RuntimeError(f"Spark initialization failed: {e}")


def process_pipeline(config_path: str) -> None:
    """
    Main function to loop through CSV files in the staging directory
    and load them to Snowflake.

    Params:
        config_path (str): Path to the configuration file.

    Returns:
        None
    """
    spark = spark_conn()

    # Parse configuration
    config = parse_config(config_path)

    input_dir = config["staging"]["input_dataset_path"]

    # Loop through all CSV files in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith(".csv"):  # Process only CSV files
            input_file_path = os.path.join(input_dir, filename)
            print(f"Processing file: {filename}")

            # Assuming you have a function to load data from CSV to Snowflake
            data_load(spark, input_file_path, config)

    print("Pipeline processing completed!")

    # Stop the SparkSession if it was created
    if 'spark' in locals():
        spark.stop()
        print("Spark session stopped")


# Example usage:
if __name__ == "__main__":
    config_file_path = r"C:\Users\Neelkant\PycharmProjects\personal\bikestores_project\config\pipeline_config.cfg"
    process_pipeline(config_file_path)
