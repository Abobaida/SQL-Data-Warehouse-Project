# 📚 Data Catalog for Gold Layer

## Overview
The **Gold Layer** is the business-level data representation, structured as a **Star Schema** to support BI reporting, ad-hoc SQL queries, and analytics. It consists of two dimension views (`gold.dim_customers`, `gold.dim_products`) and one central fact view (`gold.fact_sales`).

---

### 1. `gold.dim_customers`
* **Purpose:** Stores customer profile details enriched with demographic and geographic data from CRM and ERP sources.
* **Grain:** One row per unique customer (`customer_key`).

| Column Name | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `customer_key` | INT | **PK** (Surrogate) | Surrogate key uniquely identifying each customer record in the dimension view. |
| `customer_id` | INT | Natural Key | Unique numerical identifier assigned to each customer (`cst_id`). |
| `customer_number` | NVARCHAR(50) | Business Key | Alphanumeric identifier representing the customer (`cst_key`), used for ERP integration. |
| `first_name` | NVARCHAR(50) | — | The customer's first name, trimmed of whitespace. |
| `last_name` | NVARCHAR(50) | — | The customer's last name or family name, trimmed of whitespace. |
| `country` | NVARCHAR(50) | — | Standardized country of residence from ERP (`erp_loc_a101.cntry`). |
| `marital_status` | NVARCHAR(50) | — | Normalized marital status (`Married`, `Single`, or `n/a`). |
| `gender` | NVARCHAR(50) | — | Standardized gender (`Male`, `Female`, or `n/a`), prioritizing CRM with ERP fallback. |
| `birthdate` | DATE | — | Validated date of birth from ERP (`erp_cust_az12.bdate`). |
| `create_date` | DATE | — | Date when the customer record was created in the CRM system. |

---

### 2. `gold.dim_products`
* **Purpose:** Provides information about active products and their attributes (`WHERE prd_end_dt IS NULL`).
* **Grain:** One row per active product (`product_key`).

| Column Name | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `product_key` | INT | **PK** (Surrogate) | Surrogate key uniquely identifying each active product record. |
| `product_id` | INT | Natural Key | Internal numerical identifier assigned to the product (`prd_id`). |
| `product_number` | NVARCHAR(50) | Business Key | Clean alphanumeric product code (`prd_key`) used to join with sales transactions. |
| `product_name` | NVARCHAR(50) | — | Descriptive name of the product, including model, color, and size. |
| `category_id` | NVARCHAR(50) | — | Extracted 5-character category code (`cat_id`) linking to ERP categories. |
| `category` | NVARCHAR(50) | — | High-level classification (`Bikes`, `Components`, `Clothing`, `Accessories`). |
| `subcategory` | NVARCHAR(50) | — | Detailed product classification within the category (`Road Bikes`, `Mountain Bikes`, etc.). |
| `maintenance` | NVARCHAR(50) | — | Indicates whether the product requires maintenance (`Yes`, `No`). |
| `cost` | INT | — | Base cost of the product in whole currency units (nulls defaulted to `0`). |
| `product_line` | NVARCHAR(50) | — | Standardized product line (`Mountain`, `Road`, `Touring`, `Other Sales`, or `n/a`). |
| `start_date` | DATE | — | Date when the current product record became active. |

---

### 3. `gold.fact_sales`
* **Purpose:** Stores transactional sales order line items linked to customer and product dimensions.
* **Grain:** One row per sales order line item (`order_number` + `product_key`).

| Column Name | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `order_number` | NVARCHAR(50) | Degenerate Dim | Alphanumeric sales order identifier (e.g., `SO43697`). |
| `product_key` | INT | **FK1** | Surrogate foreign key referencing `gold.dim_products(product_key)`. |
| `customer_key` | INT | **FK2** | Surrogate foreign key referencing `gold.dim_customers(customer_key)`. |
| `order_date` | DATE | — | Date when the sales order was placed. |
| `shipping_date` | DATE | — | Date when the order was shipped to the customer. |
| `due_date` | DATE | — | Date when the order payment was due. |
| `sales_amount` | INT | Measure | Total monetary value of the line item (`quantity * ABS(price)`). |
| `quantity` | INT | Measure | Number of product units ordered. |
| `price` | INT | Measure | Unit price of the product. |
