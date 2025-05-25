SET search_path = snowflake;

DROP TABLE IF EXISTS staging_raw;

CREATE TABLE staging_raw (
  id                       INTEGER,
  customer_first_name      TEXT,
  customer_last_name       TEXT,
  customer_age             INTEGER,
  customer_email           TEXT,
  customer_country         TEXT,
  customer_postal_code     TEXT,
  customer_pet_type        TEXT,
  customer_pet_name        TEXT,
  customer_pet_breed       TEXT,
  seller_first_name        TEXT,
  seller_last_name         TEXT,
  seller_email             TEXT,
  seller_country           TEXT,
  seller_postal_code       TEXT,
  product_name             TEXT,
  product_category         TEXT,
  product_price            NUMERIC,
  product_quantity         INTEGER,
  sale_date                TIMESTAMP,
  sale_customer_id         INTEGER,
  sale_seller_id           INTEGER,
  sale_product_id          INTEGER,
  sale_quantity            INTEGER,
  sale_total_price         NUMERIC,
  store_name               TEXT,
  store_location           TEXT,
  store_city               TEXT,
  store_state              TEXT,
  store_country            TEXT,
  store_phone              TEXT,
  store_email              TEXT,
  pet_category             TEXT,
  product_weight           NUMERIC,
  product_color            TEXT,
  product_size             TEXT,
  product_brand            TEXT,
  product_material         TEXT,
  product_description      TEXT,
  product_rating           NUMERIC,
  product_reviews          INTEGER,
  product_release_date     DATE,
  product_expiry_date      DATE,
  supplier_name            TEXT,
  supplier_contact         TEXT,
  supplier_email           TEXT,
  supplier_phone           TEXT,
  supplier_address         TEXT,
  supplier_city            TEXT,
  supplier_country         TEXT
);

\copy staging_raw FROM './Data/MOCK_DATA_0.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_1.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_2.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_3.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_4.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_5.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_6.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_7.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_8.csv' CSV HEADER;
\copy staging_raw FROM './Data/MOCK_DATA_9.csv' CSV HEADER;

INSERT INTO dim_customer(source_id, name, email)
SELECT DISTINCT
  sale_customer_id,
  customer_first_name || ' ' || customer_last_name,
  customer_email
FROM staging_raw
ON CONFLICT (source_id) DO NOTHING;

INSERT INTO dim_seller(source_id, name, region)
SELECT DISTINCT
  sale_seller_id,
  seller_first_name || ' ' || seller_last_name,
  seller_country
FROM staging_raw
ON CONFLICT (source_id) DO NOTHING;

ALTER TABLE dim_supplier
  ADD CONSTRAINT dim_supplier_name_key UNIQUE (name);

INSERT INTO dim_supplier(source_id, name, country)
SELECT DISTINCT
  ROW_NUMBER() OVER (ORDER BY supplier_name) + 100000 AS source_id,
  supplier_name,
  supplier_country
FROM staging_raw
ON CONFLICT (name) DO NOTHING;

ALTER TABLE dim_store
  ADD CONSTRAINT dim_store_name_key UNIQUE (name);

INSERT INTO dim_store(source_id, name, location)
SELECT DISTINCT
  ROW_NUMBER() OVER (ORDER BY store_name) + 200000 AS source_id,
  store_name,
  store_city || ', ' || store_state || ', ' || store_country
FROM staging_raw
ON CONFLICT (name) DO NOTHING;

INSERT INTO dim_product(source_id, name, category, price)
SELECT DISTINCT
  sale_product_id,
  product_name,
  product_category,
  product_price
FROM staging_raw
ON CONFLICT (source_id) DO NOTHING;

INSERT INTO fact_sales(
  customer_id,
  seller_id,
  supplier_id,
  store_id,
  product_id,
  sale_date,
  quantity,
  total_amount
)
SELECT
  c.customer_id,
  s.seller_id,
  sp.supplier_id,
  st.store_id,
  p.product_id,
  sr.sale_date,
  sr.sale_quantity,
  sr.sale_total_price
FROM staging_raw sr
  JOIN dim_customer c ON c.source_id = sr.sale_customer_id
  JOIN dim_seller   s ON s.source_id = sr.sale_seller_id
  JOIN dim_supplier sp ON sp.name = sr.supplier_name
  JOIN dim_store    st ON st.name = sr.store_name
  JOIN dim_product p ON p.source_id = sr.sale_product_id;

SELECT
  (SELECT COUNT(*) FROM staging_raw) AS staging_rows,
  (SELECT COUNT(*) FROM fact_sales)   AS fact_rows;
