# 🏗️ SQL Data Warehouse Project

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Data Warehouse](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%20%7C%20Silver%20%7C%20Gold)-FFB900?style=for-the-badge)
![ETL](https://img.shields.io/badge/Pipeline-ETL%20%26%20Data%20Modeling-2EA44F?style=for-the-badge)

Welcome to the **SQL Data Warehouse Project** repository!  
This project demonstrates a complete, end-to-end **Data Warehousing and Analytics solution** built using **Microsoft SQL Server**[cite: 3, 8]. It follows the industry-standard **Medallion Architecture (Bronze, Silver, and Gold layers)** to transform raw ERP and CRM datasets into clean, standardized, business-ready **Star Schema** data models for BI reporting, Ad-Hoc SQL queries, and Machine Learning[cite: 8].

---

## 🏛️ High-Level Data Architecture

The data warehouse is designed using the **Medallion Architecture**, separating data processing into three distinct layers[cite: 8]:

![High Level Architecture](docs/Data%20Architecture.png)

1. **🟫 Bronze Layer (Raw Data):**
   * **Source Systems:** Ingests raw data from two primary enterprise systems (`CRM` and `ERP`) provided as flat `CSV` files[cite: 1, 2, 8].
   * **Object Type:** Physical SQL Server Tables[cite: 8].
   * **Load Strategy:** Batch Processing using **Full Load (`TRUNCATE` & `BULK INSERT`)** encapsulated inside a Stored Procedure (`Load Bronze Layer.sql`)[cite: 4, 8].
   * **Transformations:** None (stores data as-is to preserve historical and source fidelity)[cite: 8].

2. **⬜ Silver Layer (Cleaned & Standardized Data):**
   * **Object Type:** Physical SQL Server Tables[cite: 8].
   * **Load Strategy:** Batch Processing via Stored Procedure (`Load Silver Layer.sql`) using `TRUNCATE` and `INSERT`[cite: 5, 8].
   * **Transformations Applied:**
     * **Data Cleansing:** Removing unwanted leading/trailing spaces, handling `NULL` values, and deduplicating primary keys[cite: 8].
     * **Data Standardization & Normalization:** Mapping coded values (e.g., gender, marital status, product lines, and country names) into user-friendly, consistent terms[cite: 8].
     * **Derived Columns:** Extracting substrings (such as `cat_id` and `prd_key`) and calculating accurate date intervals (`prd_end_dt`)[cite: 8].
     * **Data Enrichment & Business Rules:** Recalculating invalid or missing sales figures and validating chronological date integrity[cite: 8].

3. **🟨 Gold Layer (Business-Ready Data):**
   * **Object Type:** SQL Server `Views`[cite: 8].
   * **Load Strategy:** Virtualized (`No Load` required — dynamically queries the cleaned Silver layer)[cite: 8].
   * **Transformations:** Data Integration across CRM and ERP entities, Surrogate Key generation, Aggregations, and Business Logic alignment[cite: 8].
   * **Data Model:** **Star Schema** consisting of Dimension views (`dim_customers`, `dim_products`) and a central Fact view (`fact_sales`)[cite: 8].

---

## 🔗 Data Integration & Source Systems

The project integrates 6 core datasets originating from **CRM (Customer Relationship Management)** and **ERP (Enterprise Resource Planning)** systems[cite: 1, 2, 7]:

![Data Integration](docs/Data%20Integration.png)

| Source System | File Name | Description | Key Identifiers |
| :--- | :--- | :--- | :--- |
| **CRM** | `cust_info.csv` | Customer demographics and profile records | `cst_id`, `cst_key` |
| **CRM** | `prd_info.csv` | Product catalog, cost, and lifecycle dates | `prd_key` |
| **CRM** | `sales_details.csv` | Transactional records about sales and orders | `prd_key`, `cst_id` |
| **ERP** | `CUST_AZ12.csv` | Additional customer attributes (birth dates) | `cid` |
| **ERP** | `LOC_A101.csv` | Customer geographical location data | `cid` |
| **ERP** | `PX_CAT_G1V2.csv` | Product categories and hierarchy | `id` |

---

## 🔄 Data Flow & Lineage

The diagram below illustrates how individual tables flow from the raw source CSV folders through the **Bronze** and **Silver** layers, ultimately merging into the **Gold** analytical views[cite: 9]:

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
├── docs/                               # Architecture & Data Modeling Diagrams (.png & .drawio)
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
* **Microsoft SQL Server** (Express, Developer, or Enterprise Edition)[cite: 3, 8]
* **SQL Server Management Studio (SSMS)** or **Azure Data Studio**

### Execution Steps
1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/Abobaida/sql-data-warehouse-project.git](https://github.com/Abobaida/sql-data-warehouse-project.git)
   ```
2. **Initialize the Database & Schemas:**
   * Open `Scripts/Initalize_DataBase.sql` in SSMS and execute it to create the `DataWarehouse` database and the `bronze`, `silver`, and `gold` schemas[cite: 3, 8].
3. **Build and Load the Bronze Layer:**
   * Run `Scripts/Bronze/DDL_Bronze.sql` to create the 6 raw tables[cite: 4, 9].
   * Open `Scripts/Bronze/Load Bronze Layer.sql`, update the local file paths in the `BULK INSERT` statements to match where you cloned the `Data Sets/` folder, and execute the script to run the `bronze.load_bronze` stored procedure[cite: 1, 2, 4, 8].
4. **Build and Load the Silver Layer:**
   * Run `Scripts/Silver/DDL_Silver.sql` to create the cleaned tables[cite: 5, 8].
   * Run `Scripts/Silver/Load Silver Layer.sql` and execute `silver.load_silver` to perform all data transformations and load the Silver tables[cite: 5, 8].
5. **Create the Gold Layer Views:**
   * Run `Scripts/Gold/DDL_Gold.sql` to generate the final Star Schema views (`gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`)[cite: 6, 8].

---

## 👨‍💻 Author

**Eng. Abo Obaida Nabil Mohamed**  
*Communications & Electronics Engineering Student | Data Engineering Enthusiast*

[![LinkedIn](https://img.shields.io/badge/Abo%20Obaida%20Nabil%20Mohamed-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/abo-obaida-nabil-mohamed/)
[![GitHub](https://img.shields.io/badge/Abobaida-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Abobaida)

* <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linkedin/linkedin-original.svg" width="18" height="18" align="absmiddle" /> **LinkedIn:** [Abo Obaida Nabil Mohamed](https://www.linkedin.com/in/abo-obaida-nabil-mohamed/)
* <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="18" height="18" align="absmiddle" /> **GitHub:** [Abobaida (Abo Obaida Nabil Mohamed)](https://github.com/Abobaida)
