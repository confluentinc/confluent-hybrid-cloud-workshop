-- Lab 6: Getting Started with KSQL - KSQL Streams

CREATE STREAM sales_orders WITH (KAFKA_TOPIC='dc01_sales_orders', VALUE_FORMAT='AVRO');
CREATE STREAM sales_order_details WITH (KAFKA_TOPIC='dc01_sales_order_details', VALUE_FORMAT='AVRO'); CREATE STREAM purchase_orders WITH (KAFKA_TOPIC='dc01_purchase_orders', VALUE_FORMAT='AVRO');
CREATE STREAM purchase_order_details WITH (KAFKA_TOPIC='dc01_purchase_order_details', VALUE_FORMAT='AVRO'); 
CREATE STREAM products WITH (KAFKA_TOPIC='dc01_products', VALUE_FORMAT='AVRO');
CREATE STREAM customers WITH (KAFKA_TOPIC='dc01_customers', VALUE_FORMAT='AVRO'); 
CREATE STREAM suppliers WITH (KAFKA_TOPIC='dc01_suppliers', VALUE_FORMAT='AVRO');

-- Lab 8: Creating KSQL Tables - Rekeying Streams

SET 'auto.offset.reset'='earliest';
CREATE STREAM customers_rekeyed WITH (KAFKA_TOPIC='dc01_customers_rekeyed', PARTITIONS=1) AS SELECT * FROM customers PARTITION BY id;
CREATE STREAM products_rekeyed WITH (KAFKA_TOPIC='dc01_products_rekeyed', PARTITIONS=1) AS SELECT * FROM products PARTITION BY id;
CREATE STREAM suppliers_rekeyed WITH (KAFKA_TOPIC='dc01_suppliers_rekeyed', PARTITIONS=1) AS SELECT * FROM suppliers PARTITION BY id;

-- Lab 8: Creating KSQL Tables - Creating Tables

CREATE TABLE customers_tbl WITH (KAFKA_TOPIC='dc01_customers_rekeyed', VALUE_FORMAT='AVRO', key='id'); 
CREATE TABLE products_tbl WITH (KAFKA_TOPIC='dc01_products_rekeyed', VALUE_FORMAT='AVRO', key='id'); 
CREATE TABLE suppliers_tbl WITH (KAFKA_TOPIC='dc01_suppliers_rekeyed', VALUE_FORMAT='AVRO', key='id');

-- Lab 9: KSQL Stream-to-Stream Joins

CREATE STREAM sales_enriched_01 WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_sales_enriched_01') AS SELECT o.id order_id,
    od.id order_details_id,
    o.order_date,
    o.customer_id,
    od.product_id,
    od.quantity,
od.price
FROM sales_orders o
INNER JOIN sales_order_details od WITHIN 1 SECONDS ON (o.id = od.sales_order_id);

-- Lab 10: KSQL Stream-to-Table Joins

CREATE STREAM sales_enriched_02 WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_sales_enriched_02') AS SELECT se.order_id,
    se.order_details_id,
    se.order_date,
    se.customer_id,
    se.product_id,
    se.quantity,
    se.price,
    ct.first_name,
    ct.last_name,
    ct.email,
    ct.city,
    ct.country
FROM sales_enriched_01 se
INNER JOIN customers_tbl ct ON (se.customer_id = ct.id);

CREATE STREAM sales_enriched WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_sales_enriched') AS SELECT se.order_id,
    se.order_details_id,
    se.order_date,
    se.product_id product_id,
    pt.name product_name,
    pt.description product_desc,
    se.price product_price,
    se.quantity product_qty,
    se.customer_id customer_id,
    se.first_name customer_fname,
    se.last_name customer_lname,
    se.email customer_email,
    se.city customer_city,
    se.country customer_country
FROM sales_enriched_02 se
INNER JOIN products_tbl pt ON (se.product_id = pt.id);

CREATE STREAM purchases_enriched_01 WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_purchases_enriched_01') AS SELECT o.id order_id,
    od.id order_details_id,
    o.order_date,
    o.supplier_id,
    od.product_id,
    od.quantity,
od.cost
FROM purchase_orders o
INNER JOIN purchase_order_details od WITHIN 1 SECONDS ON (o.id = od.purchase_order_id);

CREATE STREAM purchases_enriched_02 WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_purchases_enriched_02') AS SELECT pe.order_id,
    pe.order_details_id,
    pe.order_date,
    pe.supplier_id,
    pe.product_id,
    pe.quantity,
    pe.cost,
    st.name,
    st.email,
    st.city,
    st.country
FROM purchases_enriched_01 pe
INNER JOIN suppliers_tbl st ON (pe.supplier_id = st.id);

CREATE STREAM purchases_enriched WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_purchases_enriched') AS SELECT pe.order_id,
    pe.order_details_id,
    pe.order_date,
    pe.product_id product_id,
    pt.name product_name,
    pt.description product_desc,
    pe.cost product_cost,
    pe.quantity product_qty,
    pe.supplier_id supplier_id,
    pe.name supplier_name,
    pe.email supplier_email,
    pe.city supplier_city,
    pe.country supplier_country
FROM purchases_enriched_02 pe
INNER JOIN products_tbl pt ON (pe.product_id = pt.id);

-- Lab 11: Streaming Stock Levels

CREATE STREAM product_supply_and_demand WITH (PARTITIONS=1, KAFKA_TOPIC='dc01_product_supply_and_demand') AS SELECT
product_id,
product_qty * -1 "QUANTITY" FROM sales_enriched;

INSERT INTO product_supply_and_demand SELECT product_id,
product_qty "QUANTITY" FROM purchases_enriched;

CREATE TABLE current_stock WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_current_stock') AS SELECT
    product_id,
    SUM(quantity) "STOCK_LEVEL"
FROM product_supply_and_demand GROUP BY product_id;

-- Lab 13: Streaming Recent Product Demand

CREATE TABLE product_demand_last_3mins_tbl WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_product_demand_last_3mins') AS SELECT
    timestamptostring(windowStart(),'HH:mm:ss') "WINDOW_START_TIME",
    timestamptostring(windowEnd(),'HH:mm:ss') "WINDOW_END_TIME",
    product_id,
    SUM(product_qty) "DEMAND_LAST_3MINS",
FROM sales_enriched
WINDOW HOPPING (SIZE 3 MINUTES, ADVANCE BY 1 MINUTE) GROUP BY product_id EMIT CHANGES;

CREATE STREAM product_demand_last_3mins WITH (KAFKA_TOPIC='dc01_product_demand_last_3mins', VALUE_FORMAT='AVRO');

-- Lab 14: Streaming "Out of Stock" Events

SET 'auto.offset.reset' = 'latest';
CREATE STREAM out_of_stock_events WITH (PARTITIONS = 1, KAFKA_TOPIC = 'dc01_out_of_stock_events') AS SELECT
  cs.product_id "PRODUCT_ID",
  pd.window_start_time,
  pd.window_end_time,
  cs.stock_level,
  pd.demand_last_3mins,
  (cs.stock_level * -1) + pd.DEMAND_LAST_3MINS "QUANTITY_TO_PURCHASE"
FROM product_demand_last_3mins pd
INNER JOIN current_stock cs ON pd.product_id = cs.product_id WHERE stock_level <= 0;