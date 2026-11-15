# 📏 Naming Conventions

This document outlines the naming conventions used for schemas, tables, views, columns, and stored procedures across the Data Warehouse.

## 1. General Principles
* **Naming Style:** Use `snake_case` (lowercase letters with underscores `_` separating words) for database objects and columns.
* **Language:** Use clear, descriptive English names; avoid reserved SQL keywords.

## 2. Table & View Naming Conventions
* **Bronze Rules:** `<sourcesystem>_<entity>` (e.g., `bronze.crm_cust_info`, `bronze.erp_loc_a101`). Table names must match the original source system table/CSV name without renaming.
* **Silver Rules:** `<sourcesystem>_<entity>` (e.g., `silver.crm_cust_info`, `silver.erp_loc_a101`). Preserves source lineage while applying data cleansing.
* **Gold Rules:** `<category>_<entity>` using business-aligned entity names:
  * **Dimension Views:** `dim_<entity>` (e.g., `gold.dim_customers`, `gold.dim_products`)
  * **Fact Views:** `fact_<entity>` (e.g., `gold.fact_sales`)

## 3. Column Naming Conventions
* **Surrogate Keys:** All primary keys in dimension views use the suffix `_key` (e.g., `customer_key`, `product_key`).
* **Technical Metadata Columns:** All audit/metadata columns added by the data warehouse use the prefix `dwh_` (e.g., `dwh_create_date`).

## 4. Stored Procedures
* All ETL load stored procedures follow the pattern: `<layer>.load_<layer>` (e.g., `bronze.load_bronze`, `silver.load_silver`).
