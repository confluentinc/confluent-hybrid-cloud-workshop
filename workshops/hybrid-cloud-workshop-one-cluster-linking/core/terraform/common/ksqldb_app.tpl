-- Lab 7: Creating a ksqlDB Application - ksqlDB Streams

CREATE STREAM sales_orders WITH (KAFKA_TOPIC='${dc}_sales_orders', VALUE_FORMAT='AVRO');
CREATE STREAM sales_order_details WITH (KAFKA_TOPIC='${dc}_sales_order_details', VALUE_FORMAT='AVRO'); 
CREATE STREAM purchase_orders WITH (KAFKA_TOPIC='${dc}_purchase_orders', VALUE_FORMAT='AVRO');
CREATE STREAM purchase_order_details WITH (KAFKA_TOPIC='${dc}_purchase_order_details', VALUE_FORMAT='AVRO'); 
CREATE STREAM products WITH (KAFKA_TOPIC='${dc}_products', VALUE_FORMAT='AVRO');
CREATE STREAM customers WITH (KAFKA_TOPIC='${dc}_customers', VALUE_FORMAT='AVRO'); 
CREATE STREAM suppliers WITH (KAFKA_TOPIC='${dc}_suppliers', VALUE_FORMAT='AVRO');

-- Lab 9: Creating ksqlDB Tables - Creating Tables

CREATE TABLE customers_tbl (
  ROWKEY      INT PRIMARY KEY,
  FIRST_NAME  VARCHAR,
  LAST_NAME   VARCHAR,
  EMAIL       VARCHAR,
  CITY        VARCHAR,
  COUNTRY     VARCHAR,
  SOURCEDC    VARCHAR
)
WITH (
  KAFKA_TOPIC='${dc}_customers',
  VALUE_FORMAT='AVRO'
);

CREATE TABLE suppliers_tbl (
  ROWKEY      INT PRIMARY KEY,
  NAME        VARCHAR,
  EMAIL       VARCHAR,
  CITY        VARCHAR,
  COUNTRY     VARCHAR,
  SOURCEDC    VARCHAR
)
WITH (
  KAFKA_TOPIC='${dc}_suppliers',
  VALUE_FORMAT='AVRO'
);

CREATE TABLE products_tbl (
  ROWKEY      INT PRIMARY KEY,
  NAME        VARCHAR,
  DESCRIPTION VARCHAR,
  PRICE       DECIMAL(10,2),
  COST        DECIMAL(10,2),
  SOURCEDC    VARCHAR
)
WITH (
  KAFKA_TOPIC='${dc}_products',
  VALUE_FORMAT='AVRO'
);

-- Lab 10: Joining Streams & Tables with ksqlDB

SET 'auto.offset.reset'='earliest';
CREATE STREAM sales_enriched WITH (PARTITIONS = 1, KAFKA_TOPIC = '${dc}_sales_enriched') AS SELECT
    o.id order_id,
    od.id order_details_id,
    o.order_date,
    od.product_id product_id,
    pt.name product_name,
    pt.description product_desc,
    od.price product_price,
    od.quantity product_qty,
    o.customer_id customer_id,
    ct.first_name customer_fname,
    ct.last_name customer_lname,
    ct.email customer_email,
    ct.city customer_city,
    ct.country customer_country
FROM sales_orders o
INNER JOIN sales_order_details od WITHIN 1 SECONDS GRACE PERIOD 1 SECONDS ON (o.id = od.sales_order_id)
INNER JOIN customers_tbl ct ON (o.customer_id = ct.rowkey)
INNER JOIN products_tbl pt ON (od.product_id = pt.rowkey);

SET 'auto.offset.reset'='earliest';
CREATE STREAM purchases_enriched WITH (PARTITIONS = 1, KAFKA_TOPIC = '${dc}_purchases_enriched') AS SELECT
    o.id order_id,
    od.id order_details_id,
    o.order_date,
    od.product_id product_id,
    pt.name product_name,
    pt.description product_desc,
    od.cost product_cost,
    od.quantity product_qty,
    o.supplier_id supplier_id,
    st.name supplier_name,
    st.email supplier_email,
    st.city supplier_city,
    st.country supplier_country
FROM purchase_orders o
INNER JOIN purchase_order_details od WITHIN 1 SECONDS GRACE PERIOD 1 SECONDS ON (o.id = od.purchase_order_id)
INNER JOIN suppliers_tbl st ON (o.supplier_id = st.rowkey)
INNER JOIN products_tbl pt ON (od.product_id = pt.rowkey);

-- Lab 11: Streaming Current Stock Levels

SET 'auto.offset.reset'='earliest';
CREATE STREAM product_supply_and_demand WITH (PARTITIONS=1, KAFKA_TOPIC='${dc}_product_supply_and_demand') AS SELECT
  product_id,
  product_qty * -1 "QUANTITY"
FROM sales_enriched;

INSERT INTO product_supply_and_demand
  SELECT  product_id,
          product_qty "QUANTITY"
  FROM    purchases_enriched;

SET 'auto.offset.reset'='earliest';
CREATE TABLE current_stock WITH (PARTITIONS = 1, KAFKA_TOPIC = '${dc}_current_stock') AS SELECT
      product_id
    , SUM(quantity) "STOCK_LEVEL"
FROM product_supply_and_demand
GROUP BY product_id;

-- Lab 13: Streaming Recent Product Demand

SET 'auto.offset.reset'='earliest';
CREATE TABLE product_demand_last_3mins_tbl WITH (PARTITIONS = 1, KAFKA_TOPIC = '${dc}_product_demand_last_3mins')
AS SELECT
      timestamptostring(windowStart,'HH:mm:ss') "WINDOW_START_TIME"
    , timestamptostring(windowEnd,'HH:mm:ss') "WINDOW_END_TIME"
    , product_id AS product_id_key
    , AS_VALUE(product_id) AS product_id
    , SUM(product_qty) "DEMAND_LAST_3MINS"
FROM sales_enriched
WINDOW HOPPING (SIZE 3 MINUTES, ADVANCE BY 1 MINUTE)
GROUP BY product_id EMIT CHANGES;

CREATE STREAM product_demand_last_3mins WITH (KAFKA_TOPIC='${dc}_product_demand_last_3mins', VALUE_FORMAT='AVRO');

-- Lab 14: Streaming "Out of Stock" Events
SET 'auto.offset.reset' = 'latest';
CREATE STREAM out_of_stock_events WITH (PARTITIONS = 1, KAFKA_TOPIC = '${dc}_out_of_stock_events')
AS SELECT
  cs.product_id "PRODUCT_ID_KEY",
  AS_VALUE(cs.product_id) AS product_id,
  pd.window_start_time,
  pd.window_end_time,
  cs.stock_level,
  pd.demand_last_3mins,
  (cs.stock_level * -1) + pd.DEMAND_LAST_3MINS "QUANTITY_TO_PURCHASE"
FROM product_demand_last_3mins pd
INNER JOIN current_stock cs ON pd.product_id = cs.product_id
WHERE stock_level <= 0;