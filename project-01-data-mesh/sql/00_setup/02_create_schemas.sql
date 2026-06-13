/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: 02_create_schemas.sql
  Purpose: Create medallion architecture schemas
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;

-- Bronze: Raw data mirrored from source via Dynamic Tables
CREATE SCHEMA IF NOT EXISTS BRONZE
  COMMENT = 'Raw layer — Dynamic Tables pulling from SNOWFLAKE_PUBLIC_DATA_FREE';

-- Silver: Cleaned, typed, enriched, deduplicated
CREATE SCHEMA IF NOT EXISTS SILVER
  COMMENT = 'Cleansed layer — typed columns, nulls handled, enriched joins';

-- Gold: Dimensional model (star schema) for analytics consumption
CREATE SCHEMA IF NOT EXISTS GOLD
  COMMENT = 'Presentation layer — Star schema (facts + dimensions) for BI and ML';

-- Orchestration: Streams, Tasks, Alerts
CREATE SCHEMA IF NOT EXISTS ORCHESTRATION
  COMMENT = 'Pipeline management — streams, tasks, monitoring alerts';
