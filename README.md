# 🏗️ SQL Data Warehouse Project

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Data Warehouse](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%20%7C%20Silver%20%7C%20Gold)-FFB900?style=for-the-badge)
![ETL](https://img.shields.io/badge/Pipeline-ETL%20%26%20Data%20Modeling-2EA44F?style=for-the-badge)

Welcome to the **SQL Data Warehouse Project** repository!  
This project demonstrates a complete, end-to-end **Data Warehousing and Analytics solution** built using **Microsoft SQL Server**. It follows the industry-standard **Medallion Architecture (Bronze, Silver, and Gold layers)** to transform raw ERP and CRM datasets into clean, standardized, business-ready **Star Schema** data models for BI reporting, Ad-Hoc SQL queries, and Machine Learning.

---

## 🏛️ High-Level Data Architecture

The data warehouse is designed using the **Medallion Architecture**, separating data processing into three distinct layers:

![High Level Architecture](docs/Data%20Architecture_2.png)

1. **🟫 Bronze Layer (Raw Data):**
   * **Source Systems:** Ingests raw data from two primary enterprise systems (`CRM` and `ERP`) provided as flat `CSV` files.
   * **Object Type:** Physical SQL Server Tables (`bronze` schema).
   * **Load Strategy:** Batch Processing using **Full Load (`TRUNCATE` & `BULK INSERT`)** encapsulated inside a Stored Procedure (`bronze.load_bronze`).
   * **Transformations:** None (stores data as-is to preserve historical and source fidelity).

2. **⬜ Silver Layer (Cleaned & Standardized Data):**
   * **Object Type:** Physical SQL Server Tables (`silver` schema) with metadata audit columns (`dwh_create_date`).
   * **Load Strategy:** Batch Processing via Stored Procedure (`silver.load_silver`) using `TRUNCATE` and `INSERT`.
   * **Transformations Applied:**
     * **Data Cleansing:** Removing unwanted leading/trailing spaces (`TRIM`), handling `NULL` values, and deduplicating primary keys using `ROW_NUMBER()`.
     * **Data Standardization & Normalization:** Mapping coded values (e.g., gender, marital status, product lines, and country names) into user-friendly, consistent terms.
     * **Derived Columns:** Extracting substrings (such as `cat_id` and `prd_key`) and calculating accurate historical end dates (`prd_end_dt`) using `LEAD()`.
     * **Data Enrichment & Business Rules:** Recalculating invalid or missing sales figures (`sls_quantity * ABS(sls_price)`) and validating chronological date integrity.

3. **🟨 Gold Layer (Business-Ready Data):**
   * **Object Type:** SQL Server `Views` (`gold` schema).
   * **Load Strategy:** Virtualized (`No Load` required — dynamically queries the cleaned Silver layer).
   * **Transformations:** Data Integration across CRM and ERP entities, Surrogate Key generation (`ROW_NUMBER()`), and Business Logic alignment.
   * **Data Model:** **Star Schema** consisting of Dimension views (`dim_customers`, `dim_products`) and a central Fact view (`fact_sales`).

---

## 🔗 Data Integration & Source Systems

The project integrates 6 core datasets originating from **CRM (Customer Relationship Management)** and **ERP (Enterprise Resource Planning)** systems:

![Data Integration](docs/Data%20Integration_2.png)

| Source System | File Name | Bronze Table | Description | Key Identifiers |
| :--- | :--- | :--- | :--- | :--- |
| **CRM** | `cust_info.csv` | `bronze.crm_cust_info` | Customer demographics and profile records | `cst_id`, `cst_key` |
| **CRM** | `prd_info.csv` | `bronze.crm_prd_info` | Product catalog, cost, and lifecycle dates | `prd_id`, `prd_key` |
| **CRM** | `sales_details.csv` | `bronze.crm_sales_details` | Transactional records about sales and orders | `sls_ord_num`, `sls_prd_key`, `sls_cust_id` |
| **ERP** | `CUST_AZ12.csv` | `bronze.erp_cust_az12` | Additional customer attributes (birth dates & gender) | `cid` |
| **ERP** | `LOC_A101.csv` | `bronze.erp_loc_a101` | Customer geographical location data | `cid` |
| **ERP** | `PX_CAT_G1V2.csv` | `bronze.erp_px_cat_g1v2` | Product categories, subcategories, and maintenance | `id` |

---

## 🔄 Data Flow & Lineage

The diagram below illustrates how individual tables flow from the raw source CSV folders through the **Bronze** and **Silver** layers, ultimately merging into the **Gold** analytical views:

![Data Flow](docs/Data%20Flow_2.png)

---

## ⭐ Sales Data Mart (Gold Layer Star Schema)

The Gold layer models the integrated data into a **Star Schema** optimized for BI reporting and analytical queries:

![Sales Data Mart](docs/Sales%20Datamart.png)

* **`gold.dim_customers`**: Stores customer master details enriched with demographic (`bdate`, `gen`) and geographic (`cntry`) data from CRM and ERP sources.
* **`gold.dim_products`**: Provides active product catalog details (`WHERE prd_end_dt IS NULL`) enriched with ERP category, subcategory, and maintenance attributes.
* **`gold.fact_sales`**: Stores transactional sales line items linking to `product_key` and `customer_key` alongside order/shipping/due dates and sales metrics (`sales_amount`, `quantity`, `price`).

---

## 📂 Repository Folder Structure

```text
SQL-Data-Warehouse-Project/
│
├── Data Sets/                          # Raw source CSV files
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/                               # Architecture & Data Modeling Diagrams (.png & .drawio)
│   ├── Data Architecture_2.drawio
│   ├── Data Architecture_2.png
│   ├── Data Flow_2.drawio
│   ├── Data Flow_2.png
│   ├── Data Integration_2.drawio
│   ├── Data Integration_2.png
│   ├── Sales Datamart_2.drawio
│   ├── Sales Datamart.png
│   └── data_catalog.md
│
├── Scripts/                            # T-SQL DDL and ETL Scripts
│   ├── Initialize_DataBase.sql         # Creates 'Data_Ware_House' DB and Bronze/Silver/Gold schemas
│   ├── Bronze/
│   │   ├── DDL_Bronze.sql              # Creates raw Bronze tables
│   │   └── Load Bronze Layer.sql       # Stored Procedure (bronze.load_bronze) for BULK INSERT
│   ├── Silver/
│   │   ├── DDL_Silver.sql              # Creates Silver tables with metadata audit columns
│   │   └── Load Silver Layer.sql       # Stored Procedure (silver.load_silver) for data cleansing & ETL
│   └── Gold/
│       └── DDL_Gold.sql                # Creates Star Schema views (dim_customers, dim_products, fact_sales)
│
├── tests/                              # Data Quality & Integrity Checks
│   └── quality_checks_gold.sql
│
└── README.md                           # Project Documentation
