/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Data_Ware_House' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Data_Ware_House')
BEGIN
    ALTER DATABASE Data_Ware_House SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Data_Ware_House;
END;
GO

-- Create the 'Data_Ware_House' database
CREATE DATABASE Data_Ware_House;
GO

USE Data_Ware_House;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
