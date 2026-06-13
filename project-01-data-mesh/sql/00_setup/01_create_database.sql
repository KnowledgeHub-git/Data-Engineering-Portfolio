/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: 01_create_database.sql
  Purpose: Create the PORTFOLIO_DATA_MESH database and warehouse
=============================================================================
*/

USE ROLE ACCOUNTADMIN;

-- Create a dedicated warehouse for portfolio work
CREATE WAREHOUSE IF NOT EXISTS PORTFOLIO_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse for Snowflake Portfolio projects';

-- Create the main database for Project 1
CREATE DATABASE IF NOT EXISTS PORTFOLIO_DATA_MESH
  COMMENT = 'Multi-Domain Data Mesh — Project 01: Bronze/Silver/Gold medallion architecture';

USE DATABASE PORTFOLIO_DATA_MESH;
USE WAREHOUSE PORTFOLIO_WH;
