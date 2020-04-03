import sys
import MySQLdb
from datetime import datetime
import time
import random

tick_seconds = 5
o, od, p, pd = 0, 0, 0, 0

most_frequent_product  = 15 #random.randint(1, 30)
most_frequent_customer = 15 #random.randint(1, 30)
most_frequent_supplier = 15 #random.randint(1, 30)

db = MySQLdb.connect(host="mysql",
                     user="mysqluser",
                     passwd="mysqlpw",
                     db="orders")

cursor = db.cursor()

cursor.execute("SELECT MAX(id) FROM sales_orders" )
sales_order_id = cursor.fetchone()[0]
if sales_order_id is None:
  sales_order_id = 0

cursor.execute("SELECT MAX(id) FROM sales_order_details" )
sales_order_details_id = cursor.fetchone()[0]
if sales_order_details_id is None:
  sales_order_details_id = 0

cursor.execute("SELECT MAX(id) FROM purchase_orders" )
purchase_order_id = cursor.fetchone()[0]
if purchase_order_id is None:
  purchase_order_id = 0

cursor.execute("SELECT MAX(id) FROM purchase_order_details" )
purchase_order_details_id = cursor.fetchone()[0]
if purchase_order_details_id is None:
  purchase_order_details_id = 0

while True:
  o += 1

  #
  # Insert into sales_orders 
  #

  # select a random customer
  now = datetime.now()
  sql = "INSERT INTO sales_orders (id, order_date, customer_id) VALUES (%s, %s, %s)"
  val = (sales_order_id + o, now, int(random.triangular(1, 31, most_frequent_customer)) )
  cursor.execute(sql, val)

  print "Sales Order " + str(sales_order_id + o) + " Created"

  #
  # insert into sales_order_details
  #

  # select some random products
  product_ids = []
  for i in range(1,6):
    n = random.triangular(1, 31, most_frequent_product)
    product_ids.append(int(n))
  product_ids_str = ','.join(['%s'] * len(product_ids))
  cursor.execute("SELECT id, price FROM products WHERE id IN (%s)" % product_ids_str, tuple(product_ids))
  random_products = cursor.fetchall()

  # add each product to sale order details
  for product in random_products:
    od += 1
    product_id = product[0]
    price = product[1]
    quantity = random.randint(1,10)

    sql = "insert into sales_order_details(id, sales_order_id, product_id, quantity, price) values (%s, %s, %s, %s, %s)"
    val = (sales_order_details_id + od, sales_order_id + o, product_id, quantity, price)
    cursor.execute(sql, val)
 
  #
  # Raise some purchase orders to meet demand
  #
  sql = "select count(distinct product_id) from dcxx_out_of_stock_events"
  cursor.execute(sql)
  out_of_stock_product_count = cursor.fetchone()[0]

  if out_of_stock_product_count > 0:

    p += 1
    
    #
    # Insert into purchase_orders 
    #

    # select a random supplier
    now = datetime.now()
    sql = "INSERT INTO purchase_orders (id, order_date, supplier_id) VALUES (%s, %s, %s)"
    val = (purchase_order_id + p, now, int(random.triangular(1, 31, most_frequent_supplier)) )
    cursor.execute(sql, val)
    
    print "Purchase Order " + str(purchase_order_id + p) + " Created"

    #
    # insert into purchase_order_details
    #
    sql = "select product_id,cost, max(quantity_to_purchase) from dcxx_out_of_stock_events oos, products p where p.id = oos.product_id group by product_id"
    cursor.execute(sql)
    out_of_stock_products = cursor.fetchall()

    for product in out_of_stock_products:
      pd += 1
      product_id = product[0]
      cost = product[1]
      quantity = product[2]

      # Check to make sure product wasn't on the previous PO, this is a hack!
      sql = "select count(*) from purchase_order_details where purchase_order_id = %s and product_id = %s and quantity != 100"
      val = ((purchase_order_id + p) -1, product_id )
      cursor.execute(sql, val)
      is_duplicate = cursor.fetchone()[0]
      if is_duplicate == 0:

        sql = "insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (%s, %s, %s, %s, %s)"
        val = (purchase_order_details_id + pd, purchase_order_id + p, product_id, quantity, cost)
        cursor.execute(sql, val)
 
    # Delete processed out of stock events
    sql = "DELETE FROM dcxx_out_of_stock_events"
    cursor.execute(sql)

  db.commit()
  
  time.sleep(tick_seconds)

db.close()
