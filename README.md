# 🏗️ SQL Data Warehouse Project

Welcome to the **SQL Data Warehouse Project** repository!  
This project demonstrates a complete, end-to-end **Data Warehousing and Analytics solution** built using **Microsoft SQL Server**. It follows the industry-standard **Medallion Architecture (Bronze, Silver, and Gold layers)** to transform raw ERP and CRM datasets into clean, standardized, business-ready **Star Schema** data models for BI reporting, Ad-Hoc SQL queries, and Machine Learning.

---

## 🏛️ High-Level Data Architecture

The data warehouse is designed using the **Medallion Architecture**, separating data processing into three distinct layers:

![High Level Architecture](docs/Data%20Architecture.png)

1. **🟫 Bronze Layer (Raw Data):**
   * **Source Systems:** Ingests raw data from two primary enterprise systems (`CRM` and `ERP`) provided as flat `CSV` files.
   * **Object Type:** Physical SQL Server Tables.
   * **Load Strategy:** Batch Processing using **Full Load (`TRUNCATE` & `BULK INSERT`)** encapsulated inside a Stored Procedure (`Load Bronze Layer.sql`).
   * **Transformations:** None (stores data as-is to preserve historical/source fidelity).

2. **⬜ Silver Layer (Cleaned & Standardized Data):**
   * **Object Type:** Physical SQL Server Tables.
   * **Load Strategy:** Batch Processing via Stored Procedure (`Load Silver Layer.sql`) using `TRUNCATE` and `INSERT`.
   * **Transformations Applied:**
     * **Data Cleansing:** Removing unwanted leading/trailing spaces, handling `NULL` values, and deduplicating primary keys using window functions (`ROW_NUMBER()`).
     * **Data Standardization & Normalization:** Mapping coded values (e.g., gender, marital status, product lines, and country names) into user-friendly, consistent terms.
     * **Derived Columns:** Extracting substrings (such as `cat_id` and `prd_key`) and calculating accurate date intervals (`prd_end_dt`) using `LEAD()`.
     * **Data Enrichment & Business Rules:** Recalculating invalid or missing sales figures (`sls_sales = sls_quantity * ABS(sls_price)`) and validating chronological date integrity.

3. **🟨 Gold Layer (Business-Ready Data):**
   * **Object Type:** SQL Server `Views`.
   * **Load Strategy:** Virtualized (`No Load` required — dynamically queries the cleaned Silver layer).
   * **Transformations:** Data Integration across CRM and ERP entities, Surrogate Key generation (`ROW_NUMBER()`), and business logic alignment.
   * **Data Model:** **Star Schema** consisting of Dimension views (`dim_customers`, `dim_products`) and a central Fact view (`fact_sales`).

---

## 🔗 Data Integration & Source Systems

The project integrates 6 core datasets originating from **CRM (Customer Relationship Management)** and **ERP (Enterprise Resource Planning)** systems:

![Data Integration](docs/Data%20Integration.png)

| Source System | File Name | Description | Key Identifiers |
| :--- | :--- | :--- | :--- |
| **CRM** | `cust_info.csv` | Customer demographics and profile records | `cst_id`, `cst_key` |
| **CRM** | `prd_info.csv` | Product catalog, cost, and lifecycle dates | `prd_id`, `prd_key` |
| **CRM** | `sales_details.csv` | Transactional sales and order records | `sls_ord_num`, `prd_key`, `cst_id` |
| **ERP** | `CUST_AZ12.csv` | Additional customer attributes (birth dates, gender) | `cid` |
| **ERP** | `LOC_A101.csv` | Customer geographical location data (country) | `cid` |
| **ERP** | `PX_CAT_G1V2.csv` | Product hierarchy, categories, and maintenance flags | `id` |

---

## 🔄 Data Flow & Lineage

The diagram below illustrates how individual tables flow from the raw source CSV folders through the **Bronze** and **Silver** layers, ultimately merging into the **Gold** analytical views:

![Data Flow](docs/Data%20Flow.png)

---

## 📂 Repository Folder Structure

```text
Data-Warehouse/
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
├── docs/                               # Architecture & Data Modeling Diagrams
│   ├── Data Architecture.png
│   ├── Data Integration.png
│   └── Data Flow.png
│
├── Scripts/                            # T-SQL DDL and ETL Scripts
│   ├── Initalize_DataBase.sql          # Creates 'DataWarehouse' DB and Bronze/Silver/Gold schemas
│   ├── Bronze/
│   │   ├── DDL_Bronze.sql              # Creates raw Bronze tables
│   │   └── Load Bronze Layer.sql       # Stored Procedure (bronze.load_bronze) for BULK INSERT
│   ├── Silver/
│   │   ├── DDL_Silver.sql              # Creates Silver tables with metadata audit columns
│   │   └── Load Silver Layer.sql       # Stored Procedure (silver.load_silver) for data cleansing & ETL
│   └── Gold/
│       └── DDL_Gold.sql                # Creates Star Schema views (dim_customers, dim_products, fact_sales)
│
└── README.md                           # Project Documentation
```

---

## 🚀 How to Run This Project

### Prerequisites
* **Microsoft SQL Server** (Express, Developer, or Enterprise Edition)
* **SQL Server Management Studio (SSMS)** or **Azure Data Studio**

### Execution Steps
1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/sql-data-warehouse-project.git
   ```
2. **Initialize the Database & Schemas:**
   * Open `Scripts/Initalize_DataBase.sql` in SSMS and execute it to create the `DataWarehouse` database and the `bronze`, `silver`, and `gold` schemas.
3. **Build and Load the Bronze Layer:**
   * Run `Scripts/Bronze/DDL_Bronze.sql` to create the 6 raw tables.
   * Open `Scripts/Bronze/Load Bronze Layer.sql`, update the local file paths in the `BULK INSERT` statements to match where you cloned the `Data Sets/` folder, and execute the script to create and run the `EXEC bronze.load_bronze;` stored procedure.
4. **Build and Load the Silver Layer:**
   * Run `Scripts/Silver/DDL_Silver.sql` to create the cleaned tables.
   * Run `Scripts/Silver/Load Silver Layer.sql` and execute `EXEC silver.load_silver;` to perform all data transformations and load the Silver tables.
5. **Create the Gold Layer Views:**
   * Run `Scripts/Gold/DDL_Gold.sql` to generate the final Star Schema views (`gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`).

---

## 👨‍💻 Author

**Eng. Abo Obaida Nabil Mohamed**  
*Communications & Electronics Engineering Student | Data Engineering Enthusiast*

[![LinkedIn](https://img.shields.io/badge/Abo%20Obaida%20Nabil%20Mohamed-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/abo-obaida-nabil-mohamed/)
[![GitHub](https://img.shields.io/badge/Abobaida-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Abobaida)
