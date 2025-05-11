# 🚴‍♂️ BikeStores Data Engineering Project — PySpark + dbt + Snowflake

This project implements a modular and scalable data platform that:

- Ingests CSV files from the BikeStores dataset into Snowflake using PySpark
- Transforms data into business-friendly models using dbt's bronze → silver → gold layering
---

## 📁 Project Structure

```
bikestores-project/
│
├── python/ # Data ingestion pipeline using PySpark
│ ├── config/
│ │ └── pipeline_config.py # Configuration for staging and Snowflake
│ │
│ ├── staging/
│ │ └── csv_files/ # Raw BikeStores CSV files
│ │
│ ├── src/
│ │ ├── process_pipeline.py # Main ETL pipeline: load CSV to Snowflake
│ │ ├── conn.py # Snowflake connection test and setup
│ │ └── utils.py # Helper functions: config parsing, data load
│ │
│ ├── requirements.txt # Python dependencies
│ ├── LICENSE # Project license (MIT)
│ └── README.md # This file
│
├── dbt/ # dbt project for Snowflake modeling
│ ├── macros/
│ │ └── generate_schema_name.sql
│ │
│ └── models/
│ ├── bronze/ # Raw tables from Snowflake ingestion
│ ├── silver/ # Cleaned and joined datasets
│ └── gold/ # Business-ready fact/dimension models
```
---

## 🔧 Features

### ✅ PySpark Pipeline (under python/)
- 🔐 Secure Snowflake auth using PKCS8 private key
- 📦 Modular ETL logic using config-driven setup
- 🧮 Automatic table inference from filenames (e.g., prod_orders.csv → orders)
- ❄️ Optimized integration with Snowflake Spark connector
  * Uses `net.snowflake.spark.snowflake` Spark connector.
  * Supports overwrite mode for clean data reloads.

### ✅ dbt Transformations (under dbt/)
- 🥉 Bronze layer for raw ingestion copies
- 🥈 Silver layer for cleaned and modeled views
- 🥇 Gold layer for metrics, summaries, and business logic
- 🧠 Includes custom macro for schema naming

---

## 🧹 Dataset

Download the BikeStores sample dataset or generate your own CSVs.
Place the data files inside:

```
staging/csv_files/
```

Each file should follow the naming convention:

```
<environment>_<table>.csv
# Example: production_brands.csv → loads into "brands" table
```

---

## ⚙️ Configuration (`pipeline_config.py`)

Example structure:

```ini
[STAGING]
input_dataset_path = <path-to-dataset-dir>

[SNOWFLAKE]
private_key_file_path = <path-to-snowflake-key-pkcs8.pem>
raw_database = SQLSERVER_DB
raw_schema = BRONZE_SCH
warehouse = ETL_WH
account = "<your_account_locator>",
role = DATA_LOADER
user = SNOWFLAKE_ETL
```

---

## 🔗 Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/neeluvickey/bikestores-project.git
   cd bikestores-project
   ```
2. Create a virtual environment and activate it:
   ```sh
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```

---

## 🚀 How to Run

1. **Run the Pipeline**:

   ```bash
   python src/process_pipeline.py
   ```

   This will:

   * Read all CSVs under `staging/csv_files/`
   * Infer schema and load into appropriate Snowflake tables

---

## 🧠 Key Functions

### `parse_config(config_path)`

Loads the Python-based config dictionary.

### `data_load(spark, file_path, config)`

Reads a single CSV and writes it to Snowflake using the Spark Snowflake connector.

---

## 📌 Notes

* Ensure your private key is in **PKCS8 format** for Snowflake Spark connector compatibility.
* Pipeline currently supports `.csv` files only (JSON extensions could be added).
* Snowflake connector must be properly referenced in your Spark setup.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).
---
