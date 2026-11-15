# 🏗️ Enterprise SQL Data Warehouse Project

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Data Warehouse](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%20%7C%20Silver%20%7C%20Gold)-FFB900?style=for-the-badge)
![ETL](https://img.shields.io/badge/Pipeline-ETL%20%26%20Star%20Schema-2EA44F?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

Welcome to the **SQL Data Warehouse Project** repository! 🚀  
This project showcases a production-style, end-to-end **Data Warehousing and Analytics solution** built from scratch using **Microsoft SQL Server**. Designed around the industry-standard **Medallion Architecture (Bronze, Silver, and Gold layers)**, it ingests raw enterprise datasets from **CRM** and **ERP** systems, executes automated ETL cleansing and standardization pipelines, and models the data into a business-ready **Star Schema** for BI reporting, Ad-Hoc SQL analytics, and Machine Learning.

---

## 📑 Table of Contents
1. [Project Scope & Objectives](#-project-scope--objectives)
2. [High-Level Data Architecture](#-high-level-data-architecture)
3. [Data Integration & Source Systems](#-data-integration--source-systems)
4. [Data Flow & Lineage](#-data-flow--lineage)
5. [Sales Data Mart (Gold Star Schema)](#-sales-data-mart-gold-star-schema)
6. [Data Quality & Validation](#-data-quality--validation)
7. [Repository Folder Structure](#-repository-folder-structure)
8. [How to Run This Project](#-how-to-run-this-project)
9. [Project Documentation](#-project-documentation)
10. [Author](#-author)

---

## 🎯 Project Scope & Objectives

* **Data Engineering & ETL Pipelines:** Build modular, error-handled T-SQL Stored Procedures (`bronze.load_bronze` and `silver.load_silver`) with execution-time logging and batch duration tracking.
* **Data Cleansing & Standardization:** Resolve real-world data quality issues including duplicate primary keys, unformatted strings, invalid `YYYYMMDD` integer dates, out-of-range birthdates, and inconsistent financial calculations.
* **Enterprise Data Integration:** Consolidate disparate **CRM** and **ERP** customer and product entities into unified master records with fallback resolution rules.
* **Dimensional Data Modeling:** Design an analytical **Star Schema** (`fact_sales`, `dim_customers`, `dim_products`) optimized for high-performance BI queries.

---

## 🏛️ High-Level Data Architecture

The data warehouse is structured using the **Medallion Architecture**, separating data processing into three distinct logical schemas (`Bronze`, `Silver`, and `Gold`):

![High Level Architecture](docs/Data%20Architecture.png)

### 1. 🟫 Bronze Layer (Raw Ingestion Layer)
* **Source Systems:** Ingests raw data from two enterprise systems (`CRM` and `ERP`) provided as flat `CSV` files.
* **Object Type:** Physical SQL Server Tables (`bronze` schema).
* **Load Strategy:** Automated Batch Processing using **Full Load (`TRUNCATE` & `BULK INSERT`)** encapsulated inside `bronze.load_bronze`.
* **Transformations:** None — preserves raw source fidelity for historical auditing and reprocessing.

### 2. ⬜ Silver Layer (Cleansed & Standardized Layer)
* **Object Type:** Physical SQL Server Tables (`silver` schema) enriched with DWH metadata audit columns (`dwh_create_date`).
* **Load Strategy:** Batch Processing via Stored Procedure (`silver.load_silver`) using `TRUNCATE` and `INSERT`.
* **Transformations Applied:**
  * **Data Cleansing:** Trimming leading/trailing whitespace (`TRIM`), handling `NULL` costs/keys, and deduplicating customer primary keys using `ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC)`.
  * **Data Standardization & Normalization:** Mapping coded abbreviations (`M`/`F`, `S`/`M`, `R`/`M`/`T`/`S`, and ISO country codes) into descriptive business terms.
  * **Derived Columns:** Extracting composite substrings (`cat_id` and clean `prd_key`) and calculating SCD Type-2 historical product end dates (`prd_end_dt`) using `LEAD()`.
  * **Business Rule Enforcement:** Recalculating missing or mismatched sales amounts (`sls_quantity * ABS(sls_price)`) and converting integer dates into native `DATE` types.

### 3. 🟨 Gold Layer (Business-Ready Analytical Layer)
* **Object Type:** SQL Server `Views` (`gold` schema).
* **Load Strategy:** Virtualized (`No Load` required — dynamically queries the cleansed Silver tables).
* **Transformations:** Cross-system entity integration, surrogate key generation (`ROW_NUMBER()`), active record filtering (`WHERE prd_end_dt IS NULL`), and master data fallback logic.
* **Data Model:** **Star Schema** consisting of Dimension views (`dim_customers`, `dim_products`) and a central Fact view (`fact_sales`).

---

## 🔗 Data Integration & Source Systems

The pipeline integrates **6 core datasets** across **CRM (Customer Relationship Management)** and **ERP (Enterprise Resource Planning)** domains:

![Data Integration](docs/Data%20Integration.png)

| Source System | File Name | Bronze Table | Record Count | Key Identifiers & Integration Logic |
| :--- | :--- | :--- | :--- | :--- |
| **CRM** | `cust_info.csv` | `bronze.crm_cust_info` | 18,494 | `cst_id` (joins to Sales), `cst_key` (joins to ERP Customer tables) |
| **CRM** | `prd_info.csv` | `bronze.crm_prd_info` | 397 | `prd_id`, `prd_key` (split into `cat_id` for ERP Category join & clean `prd_key` for Sales join) |
| **CRM** | `sales_details.csv` | `bronze.crm_sales_details` | 60,398 | `sls_ord_num`, `sls_prd_key`, `sls_cust_id` |
| **ERP** | `CUST_AZ12.csv` | `bronze.erp_CUST_AZ12` | 18,484 | `cid` (stripped of `NAS` prefix to match `crm_cust_info.cst_key`) |
| **ERP** | `LOC_A101.csv` | `bronze.erp_LOC_A101` | 18,484 | `cid` (hyphens removed to match `crm_cust_info.cst_key`) |
| **ERP** | `PX_CAT_G1V2.csv` | `bronze.erp_PX_CAT_G1V2` | 37 | `id` (joins to extracted `cat_id` in `crm_prd_info`) |

---

## 🔄 Data Flow & Lineage

The diagram below traces table-level lineage from the raw source CSV directories through the **Bronze** and **Silver** schemas into the **Gold** analytical views:

![Data Flow](docs/Data%20Flow.png)

---

## ⭐ Sales Data Mart (Gold Star Schema)

The Gold layer exposes a clean **Star Schema** designed for seamless connection to Power BI, Tableau, or analytical SQL workloads:

![Sales Data Mart](docs/Sales%20Datamart.png)

* **`gold.dim_customers`**: Unified customer dimension combining CRM profile attributes with ERP birthdates, countries, and gender fallback logic.
* **`gold.dim_products`**: Active product catalog enriched with ERP category, subcategory, product line, cost, and maintenance indicators.
* **`gold.fact_sales`**: Transactional sales fact view containing foreign surrogate keys (`product_key`, `customer_key`), order/shipping/due dates, and validated financial measures (`sales_amount`, `quantity`, `price`).

---

## ✅ Data Quality & Validation

Dedicated SQL test suites in the [`test/`](test/) directory verify pipeline integrity across both transformation layers:

* **[`test/quality_checks_silver.sql`](test/quality_checks_silver.sql):** Validates primary key uniqueness, zero leading/trailing spaces, chronological date ordering (`sls_order_dt <= sls_ship_dt`), valid birthdate bounds, and mathematical consistency (`sls_sales = sls_quantity * sls_price`).
* **[`test/quality_checks_gold.sql`](test/quality_checks_gold.sql):** Verifies surrogate key uniqueness in `gold.dim_customers` and `gold.dim_products` and checks for orphaned foreign keys in `gold.fact_sales`.

---

## 📂 Repository Folder Structure

~~~text
SQL-Data-Warehouse-Project/
│
├── Data Sets/                          # Raw source CSV datasets
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── Scripts/                            # T-SQL DDL and ETL Stored Procedures
│   ├── Bronze/
│   │   ├── DDL_Bronze.sql              # Creates raw Bronze tables
│   │   └── Load Bronze Layer.sql       # Stored Procedure (bronze.load_bronze) for BULK INSERT
│   ├── Silver/
│   │   ├── DDL_Silver.sql              # Creates Silver tables with metadata audit columns
│   │   └── Load Silver Layer.sql       # Stored Procedure (silver.load_silver) for data cleansing & ETL
│   ├── Gold/
│   │   └── DDL_Gold.sql                # Creates Star Schema views (dim_customers, dim_products, fact_sales)
│   └── Initialize_DataBase.sql         # Creates 'Data_Ware_House' DB and Bronze/Silver/Gold schemas
│
├── docs/                               # Architecture Diagrams & Technical Documentation
│   ├── Data Architecture.drawio
│   ├── Data Architecture.png
│   ├── Data Flow.drawio
│   ├── Data Flow.png
│   ├── Data Integration.drawio
│   ├── Data Integration.png
│   ├── Sales Datamart.drawio
│   ├── Sales Datamart.png
│   ├── data_catalog.md                 # Gold Layer Data Dictionary
│   └── naming_conventions.md           # DWH Naming Standards
│
├── test/                               # Data Quality & Referential Integrity Checks
│   ├── quality_checks_gold.sql
│   └── quality_checks_silver.sql
│
├── .gitattributes
├── LICENSE
└── README.md                           # Project Documentation
~~~

---

## 🚀 How to Run This Project

### Prerequisites
* **Microsoft SQL Server** (Express, Developer, or Enterprise Edition)
* **SQL Server Management Studio (SSMS)** or **Azure Data Studio**

### Step-by-Step Execution
1. **Clone the Repository:**
   ~~~bash
   git clone https://github.com/Abobaida/SQL-Data-Warehouse-Project.git
   ~~~
2. **Initialize the Database & Schemas:**
   * Open `Scripts/Initialize_DataBase.sql` in SSMS and execute it to create the `Data_Ware_House` database along with the `Bronze`, `Silver`, and `Gold` schemas.
3. **Build and Load the Bronze Layer:**
   * Execute `Scripts/Bronze/DDL_Bronze.sql` to create the 6 raw staging tables.
   * Open `Scripts/Bronze/Load Bronze Layer.sql`, update the local file paths in the `BULK INSERT` statements to point to your local `Data Sets/` directory, compile the procedure, and run:
     ~~~sql
     EXEC bronze.load_bronze;
     ~~~
4. **Build, Load, and Validate the Silver Layer:**
   * Execute `Scripts/Silver/DDL_Silver.sql` to create the cleansed Silver tables.
   * Compile `Scripts/Silver/Load Silver Layer.sql` and run the transformation pipeline:
     ~~~sql
     EXEC silver.load_silver;
     ~~~
   * Run `test/quality_checks_silver.sql` to confirm zero data quality discrepancies.
5. **Create and Validate the Gold Layer Views:**
   * Execute `Scripts/Gold/DDL_Gold.sql` to create `gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`.
   * Run `test/quality_checks_gold.sql` to verify Star Schema referential integrity.

---

## 📖 Project Documentation

For deeper technical specifications, refer to the documentation inside the [`docs/`](docs/) directory:
* 📘 **[Gold Layer Data Catalog (`docs/data_catalog.md`)](docs/data_catalog.md):** Full data dictionary detailing every view, column, data type, grain, and business rule.
* 📏 **[Naming Conventions (`docs/naming_conventions.md`)](docs/naming_conventions.md):** Standards governing schemas, tables, views, surrogate keys, and stored procedures.

---

## 👨‍💻 Author

**Abo Obaida Nabil Mohamed**  
*Communications & Electronics Engineering Student | Data Engineering Enthusiast*

[![LinkedIn](https://img.shields.io/badge/Abo%20Obaida%20Nabil%20Mohamed-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/abo-obaida-nabil-mohamed/)
[![GitHub](https://img.shields.io/badge/Abobaida-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Abobaida)
