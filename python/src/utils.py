"""
--------------------------------------------------------------
File: utils.py                       Author: Neelakanteswara
Created Date: 03-05-2025             Modified Date: 99-99-9999
--------------------------------------------------------------
Description:
    This file contains core utility functions used in the Bikestores
    Data Pipeline for configuration parsing, data preprocessing,
    and Snowflake data loading using Spark.

    The key functionality includes:
    1. parse_config: Reads and parses values from the pipeline
       configuration file
    2. data_load: Loads CSV data from the staging directory into
       Snowflake using Spark
--------------------------------------------------------------
"""

import re
import os
import configparser
from pyspark.sql import SparkSession, DataFrame
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization


def parse_config(config_path: str) -> dict:
    """
    Parses the configuration file using RawConfigParser and returns a dictionary with all config values.

    Params:
        config_path (str): Path to the configuration file.

    Returns:
        dict: A dictionary containing configuration values.
    """
    config = configparser.RawConfigParser()
    config.read(config_path)

    parsed_config = {
        "staging": {
            "input_dataset_path": config.get("STAGING", "input_dataset_path")
        },
        "snowflake": {
            "private_key_file_path": config.get("SNOWFLAKE", "private_key_file_path"),
            "raw_database": config.get("SNOWFLAKE", "raw_database"),
            "raw_schema": config.get("SNOWFLAKE", "raw_schema"),
            "warehouse": config.get("SNOWFLAKE", "warehouse"),
            "account": config.get("SNOWFLAKE", "account"),
            "role": config.get("SNOWFLAKE", "role"),
            "user": config.get("SNOWFLAKE", "user")
        }
    }

    return parsed_config


def data_load(spark: SparkSession, file_path: str, config: dict) -> None:
    """
    Loads CSV data from the given file into Snowflake using Spark.

    Params:
        spark: SparkSession object
        file_path (str): Path to the CSV file.
        config (dict): Configuration dictionary containing Snowflake and staging details.

    Returns:
        None
    """
    # Read CSV data into a DataFrame
    df: DataFrame = spark.read.csv(file_path, header=True, inferSchema=True)

    # Show the first few rows for debugging purposes
    df.show(5)

    # Extract table name from the file path
    file_name = os.path.basename(file_path)  # e.g., "production_brands.csv"
    table_name = file_name.split('_')[1]     # Extracts "brands.csv"
    table_name = table_name.split('.')[0]    # Extracts "brands"

    # Load and convert the private key
    with open(config['snowflake']['private_key_file_path'], "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None,
            backend=default_backend()
        )
    pem_private_key = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

    pem_private_key = pem_private_key.decode("UTF-8")
    pem_private_key = re.sub("-*(BEGIN|END) PRIVATE KEY-*\n",
                             "", pem_private_key).replace("\n", "")

    # Snowflake connection options for Spark
    snowflake_options = {
        "sfURL": f"{config['snowflake']['account']}.snowflakecomputing.com",
        "sfDatabase": config['snowflake']['raw_database'],
        "sfSchema": config['snowflake']['raw_schema'],
        "sfWarehouse": config['snowflake']['warehouse'],
        "sfRole": config['snowflake']['role'],
        "sfUser": config['snowflake']['user'],
        "pem_private_key": pem_private_key
    }

    # Use fully qualified table name
    qualified_table_name = (f"{config['snowflake']['raw_database'].upper()}."
                            f"{config['snowflake']['raw_schema'].upper()}.{table_name.upper()}")

    # Write the DataFrame to Snowflake
    df.write \
        .format("net.snowflake.spark.snowflake") \
        .options(**snowflake_options) \
        .option("dbtable", qualified_table_name) \
        .mode("overwrite") \
        .save()

    print(f"Data from {file_path} successfully loaded into Snowflake table '{table_name}'.")
