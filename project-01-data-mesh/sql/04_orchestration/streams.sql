/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: streams.sql
  Purpose: Create streams on bronze tables to capture CDC changes
  Note: Streams on Dynamic Tables capture insert/update/delete changes
        that flow through the medallion layers.
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA ORCHESTRATION;

-- Stream on bronze stock prices to detect new price data
CREATE OR REPLACE STREAM stream_bronze_stock_prices
  ON DYNAMIC TABLE BRONZE.BRONZE_STOCK_PRICES
  SHOW_INITIAL_ROWS = FALSE
  COMMENT = 'Captures new/changed stock price records flowing into bronze';

-- Stream on bronze company index to detect company master changes
CREATE OR REPLACE STREAM stream_bronze_company_index
  ON DYNAMIC TABLE BRONZE.BRONZE_COMPANY_INDEX
  SHOW_INITIAL_ROWS = FALSE
  COMMENT = 'Captures new/changed company records in bronze';

-- Stream on bronze federal reserve for economic data updates
CREATE OR REPLACE STREAM stream_bronze_federal_reserve
  ON DYNAMIC TABLE BRONZE.BRONZE_FEDERAL_RESERVE
  SHOW_INITIAL_ROWS = FALSE
  COMMENT = 'Captures new economic indicator readings in bronze';
