\c petdb;

DROP SCHEMA IF EXISTS snowflake CASCADE;
CREATE SCHEMA snowflake;
SET search_path = snowflake;

CREATE TABLE dim_customer (
  customer_id   SERIAL PRIMARY KEY,
  source_id     INTEGER UNIQUE NOT NULL,
  name          TEXT,
  email         TEXT
);

CREATE TABLE dim_seller (
  seller_id     SERIAL PRIMARY KEY,
  source_id     INTEGER UNIQUE NOT NULL,
  name          TEXT,
  region        TEXT
);

CREATE TABLE dim_supplier (
  supplier_id   SERIAL PRIMARY KEY,
  source_id     INTEGER UNIQUE NOT NULL,
  name          TEXT,
  country       TEXT
);

CREATE TABLE dim_store (
  store_id      SERIAL PRIMARY KEY,
  source_id     INTEGER UNIQUE NOT NULL,
  name          TEXT,
  location      TEXT
);

CREATE TABLE dim_product (
  product_id    SERIAL PRIMARY KEY,
  source_id     INTEGER UNIQUE NOT NULL,
  name          TEXT,
  category      TEXT,
  price         NUMERIC
);

CREATE TABLE fact_sales (
  sale_id       SERIAL PRIMARY KEY,
  customer_id   INTEGER REFERENCES dim_customer(customer_id),
  seller_id     INTEGER REFERENCES dim_seller(seller_id),
  supplier_id   INTEGER REFERENCES dim_supplier(supplier_id),
  store_id      INTEGER REFERENCES dim_store(store_id),
  product_id    INTEGER REFERENCES dim_product(product_id),
  sale_date     TIMESTAMP,
  quantity      INTEGER,
  total_amount  NUMERIC
);