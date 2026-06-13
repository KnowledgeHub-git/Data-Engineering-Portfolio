-- Project 03: Economic Data Vault 2.0
-- Step 00: Infrastructure

CREATE DATABASE IF NOT EXISTS ECON_VAULT
  COMMENT = 'Economic Data Vault 2.0 - hubs, links, satellites from Fed/BLS/Treasury/World Bank';

CREATE SCHEMA IF NOT EXISTS ECON_VAULT.STAGING
  COMMENT = 'Source views with hash keys for vault loading';
CREATE SCHEMA IF NOT EXISTS ECON_VAULT.RAW_VAULT
  COMMENT = 'Data Vault 2.0 - hubs, links, satellites';
CREATE SCHEMA IF NOT EXISTS ECON_VAULT.BUSINESS_VAULT
  COMMENT = 'Analyst-friendly PIT, bridges, and consumption views';

GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_PUBLIC_DATA_FREE TO ROLE ACCOUNTADMIN;
