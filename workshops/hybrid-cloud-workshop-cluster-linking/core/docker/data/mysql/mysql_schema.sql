GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'mysqluser' IDENTIFIED BY 'mysqlpw';
DROP DATABASE IF EXISTS orders;
CREATE DATABASE orders;
GRANT ALL PRIVILEGES ON orders.* TO 'mysqluser'@'%';
USE orders;

/* Customers */
DROP TABLE IF EXISTS customers;
create table customers (
	id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(50),
	city VARCHAR(50),
	country VARCHAR(50),
  PRIMARY KEY (id)
);
insert into customers (id, first_name, last_name, email, city, country) values (1, 'Luce', 'Waring', 'lwaring0@theguardian.com', 'Manchester', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (2, 'Jermaine', 'Laxson', 'jlaxson1@sun.com', 'Craigavon', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (3, 'Deborah', 'Coxhead', 'dcoxhead2@bbc.co.uk', 'Kirkton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (4, 'Johannah', 'Kuhnt', 'jkuhnt3@tamu.edu', 'East End', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (5, 'Skippy', 'Pieroni', 'spieroni4@twitter.com', 'Milton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (6, 'Abey', 'Dangerfield', 'adangerfield5@about.me', 'Hatton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (7, 'Alfons', 'Hedan', 'ahedan6@devhub.com', 'London', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (8, 'Rockie', 'Spini', 'rspini7@uiuc.edu', 'Ashley', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (9, 'Fredra', 'Hune', 'fhune8@exblog.jp', 'Denton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (10, 'Liane', 'Wheatcroft', 'lwheatcroft9@360.cn', 'Sheffield', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (11, 'Franky', 'Tullis', 'ftullisa@google.co.uk', 'Ford', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (12, 'Alberik', 'Slingsby', 'aslingsbyb@cyberchimps.com', 'Middleton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (13, 'Davy', 'Ondracek', 'dondracekc@discuz.net', 'Sheffield', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (14, 'Bree', 'Bowshire', 'bbowshired@princeton.edu', 'London', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (15, 'Madelina', 'Hinksen', 'mhinksene@lycos.com', 'Newport', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (16, 'Berry', 'Haynesford', 'bhaynesfordf@feedburner.com', 'Twyford', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (17, 'Igor', 'Derham', 'iderhamg@meetup.com', 'Sheffield', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (18, 'Merrily', 'Avrahamoff', 'mavrahamoffh@wiley.com', 'Manchester', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (19, 'Hettie', 'Bax', 'hbaxi@cbsnews.com', 'Thorpe', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (20, 'Jarret', 'Dumberell', 'jdumberellj@sfgate.com', 'Sheffield', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (21, 'Drusi', 'Jurkowski', 'djurkowskik@cbslocal.com', 'Craigavon', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (22, 'Cora', 'Jarrad', 'cjarradl@businesswire.com', 'Swindon', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (23, 'Rozalin', 'Orrobin', 'rorrobinm@about.me', 'Kinloch', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (24, 'Layne', 'Durbin', 'ldurbinn@tiny.cc', 'Aston', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (25, 'Jerrilee', 'Oloman', 'jolomano@cnbc.com', 'Milton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (26, 'Moore', 'Gladdor', 'mgladdorp@usa.gov', 'Horton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (27, 'Gretta', 'Swanwick', 'gswanwickq@ning.com', 'Church End', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (28, 'Cyrille', 'Jenckes', 'cjenckesr@mail.ru', 'Eaton', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (29, 'Nikolaus', 'Vel', 'nvels@fc2.com', 'Weston', 'United Kingdom');
insert into customers (id, first_name, last_name, email, city, country) values (30, 'Cleopatra', 'Doble', 'cdoblet@over-blog.com', 'Pentre', 'United Kingdom');

/* Suppliers */
DROP TABLE IF EXISTS suppliers;
create table suppliers (
	id INT,
	name VARCHAR(50),
	email VARCHAR(50),
	city VARCHAR(50),
	country VARCHAR(50),
  PRIMARY KEY (id)
);

insert into suppliers (id, name, email, city, country) values (1, 'Camido', 'lpreshous0@epa.gov', 'Norton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (2, 'Kanoodle', 'dneylon1@dropbox.com', 'Carlton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (3, 'Photobean', 'hlowde2@oakley.com', 'Charlton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (4, 'Viva', 'sknill3@friendfeed.com', 'Seaton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (5, 'Voonix', 'pmarcum4@live.com', 'Upton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (6, 'Leexo', 'bmacaskill5@networksolutions.com', 'Whitwell', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (7, 'Brightbean', 'madamiak6@github.io', 'Denton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (8, 'Jayo', 'lzarfati7@amazon.de', 'Liverpool', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (9, 'Topiclounge', 'awoolaghan8@berkeley.edu', 'Dean', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (10, 'Skyvu', 'hgraser9@springer.com', 'Church End', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (11, 'Twitterwire', 'nramsella@is.gd', 'London', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (12, 'Kayveo', 'bpinnockb@linkedin.com', 'Tullich', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (13, 'Yodo', 'lvaggsc@noaa.gov', 'Norton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (14, 'Yombu', 'rmcilmoried@bbc.co.uk', 'Kingston', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (15, 'Kare', 'vmcandiee@nsw.gov.au', 'Manchester', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (16, 'Livefish', 'aewdalef@free.fr', 'Bristol', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (17, 'Fanoodle', 'hmaxweellg@tuttocitta.it', 'Church End', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (18, 'Thoughtmix', 'nsnowh@google.com.br', 'Church End', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (19, 'Jabbersphere', 'cgalliei@shinystat.com', 'Buckland', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (20, 'Rhynyx', 'gbuckeridgej@booking.com', 'Sheffield', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (21, 'Eazzy', 'pclougherk@indiatimes.com', 'Whitwell', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (22, 'Photolist', 'gjeckellsl@odnoklassniki.ru', 'Swindon', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (23, 'Zoomlounge', 'mclaceym@gov.uk', 'Seaton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (24, 'Voonix', 'lbleakmann@livejournal.com', 'Craigavon', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (25, 'Twimm', 'tdannielo@nps.gov', 'Linton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (26, 'Voolith', 'pgrundeyp@zimbio.com', 'Aberdeen', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (27, 'Pixonyx', 'lcaldicottq@scientificamerican.com', 'Aston', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (28, 'Mydeo', 'idhoogher@skype.com', 'Stapleford', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (29, 'Tagcat', 'scicculinis@icio.us', 'Norton', 'United Kingdom');
insert into suppliers (id, name, email, city, country) values (30, 'Oyoba', 'tristet@army.mil', 'Manchester', 'United Kingdom');

/* Products */
DROP TABLE IF EXISTS products;
create table products (
	id INT,
	name VARCHAR(50),
	description TEXT,
	price decimal(10,2),
	cost decimal(10,2),
  PRIMARY KEY (id)
);

insert into products (id, name, description, price, cost) values (1, 'Yogurt - Assorted Pack', 'dui nec nisi volutpat', 2.68, 6.82);
insert into products (id, name, description, price, cost) values (2, 'Ostrich - Fan Fillet', 'eu sapien', 8.23, 7.52);
insert into products (id, name, description, price, cost) values (3, 'Fish - Halibut, Cold Smoked', 'ligula suspendisse ornare', 9.99, 6.16);
insert into products (id, name, description, price, cost) values (4, 'Tomatoes Tear Drop Yellow', 'pellentesque viverra pede', 9.78, 8.07);
insert into products (id, name, description, price, cost) values (5, 'Pasta - Fettuccine, Egg, Fresh', 'arcu adipiscing molestie hendrerit', 8.81, 2.10);
insert into products (id, name, description, price, cost) values (6, 'Plastic Wrap', 'vestibulum ante ipsum primis', 8.24, 7.45);
insert into products (id, name, description, price, cost) values (7, 'Pineapple - Regular', 'ut at dolor quis', 6.47, 4.02);
insert into products (id, name, description, price, cost) values (8, 'Quail - Eggs, Fresh', 'lorem quisque', 7.08, 0.64);
insert into products (id, name, description, price, cost) values (9, 'Pork - Ground', 'in hac habitasse', 9.83, 8.51);
insert into products (id, name, description, price, cost) values (10, 'Lamb Shoulder Boneless Nz', 'curae duis', 5.32, 3.61);
insert into products (id, name, description, price, cost) values (11, 'Sausage - Meat', 'at turpis a pede', 4.65, 8.62);
insert into products (id, name, description, price, cost) values (12, 'Herb Du Provence - Primerba', 'suscipit nulla elit ac', 4.00, 2.60);
insert into products (id, name, description, price, cost) values (13, 'Bread - Kimel Stick Poly', 'aenean lectus pellentesque eget', 3.59, 1.26);
insert into products (id, name, description, price, cost) values (14, 'Food Colouring - Red', 'metus aenean fermentum donec', 5.84, 4.08);
insert into products (id, name, description, price, cost) values (15, 'Cheese - Grie Des Champ', 'id ligula suspendisse ornare', 6.16, 3.56);
insert into products (id, name, description, price, cost) values (16, 'Longos - Lasagna Veg', 'velit nec', 8.59, 7.13);
insert into products (id, name, description, price, cost) values (17, 'Beets - Golden', 'tincidunt in leo', 9.49, 7.64);
insert into products (id, name, description, price, cost) values (18, 'Bread - Dark Rye', 'erat tortor sollicitudin', 9.95, 5.94);
insert into products (id, name, description, price, cost) values (19, 'Pepperoni Slices', 'consequat nulla nisl', 3.38, 2.94);
insert into products (id, name, description, price, cost) values (20, 'Glass - Wine, Plastic, Clear 5 Oz', 'pede venenatis', 4.86, 1.91);
insert into products (id, name, description, price, cost) values (21, 'Soup - Campbells, Beef Barley', 'mi nulla', 9.90, 8.89);
insert into products (id, name, description, price, cost) values (22, 'Bread - Kimel Stick Poly', 'ipsum ac tellus semper', 8.19, 7.62);
insert into products (id, name, description, price, cost) values (23, 'Plate - Foam, Bread And Butter', 'lobortis sapien sapien non', 9.01, 6.19);
insert into products (id, name, description, price, cost) values (24, 'Parsley - Fresh', 'eget congue', 3.30, 2.83);
insert into products (id, name, description, price, cost) values (25, 'Cookie - Oreo 100x2', 'laoreet ut', 9.00, 5.51);
insert into products (id, name, description, price, cost) values (26, 'Bread - Crusty Italian Poly', 'pede ac', 9.03, 4.23);
insert into products (id, name, description, price, cost) values (27, 'Wine - Chateauneuf Du Pape', 'malesuada in', 9.14, 8.33);
insert into products (id, name, description, price, cost) values (28, 'Country Roll', 'cursus urna ut tellus', 9.83, 7.09);
insert into products (id, name, description, price, cost) values (29, 'Wine - Redchard Merritt', 'mi integer ac', 8.12, 1.75);
insert into products (id, name, description, price, cost) values (30, 'Doilies - 5, Paper', 'tincidunt eget tempus vel', 7.44, 1.72);

/* Sales Orders */
DROP TABLE IF EXISTS sales_orders;
CREATE TABLE sales_orders (
  id            INT ,
  order_date    DATETIME,
  customer_id   INT ,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) references customers(id)
);

/* Sales Order Details */
DROP TABLE IF EXISTS sales_order_details;
CREATE TABLE sales_order_details (
  id                INT,
  sales_order_id    INT,
  product_id        INT,
  quantity          INT,
  price             decimal(10,2),
  PRIMARY KEY (id),
  FOREIGN KEY (sales_order_id) references sales_orders(id),
  FOREIGN KEY (product_id) references products(id)
);

/* Purchase Orders */
DROP TABLE IF EXISTS purchase_orders;
CREATE TABLE purchase_orders (
  id            INT,
  order_date    DATETIME,
  supplier_id   INT,
  PRIMARY KEY (id),
  FOREIGN KEY (supplier_id) references suppliers(id)
);

INSERT INTO purchase_orders (id, order_date, supplier_id) VALUES (1, now(), 1);

/* Purchase Order Details */
DROP TABLE IF EXISTS purchase_order_details;
CREATE TABLE purchase_order_details (
  id                INT,
  purchase_order_id INT,
  product_id        INT,
  quantity          INT,
  cost              decimal(10,2),
  PRIMARY KEY (id),
  FOREIGN KEY (purchase_order_id) references purchase_orders(id),
  FOREIGN KEY (product_id) references products(id)
);

insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (1, 1, 1, 100, 6.82);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (2, 1, 2, 100, 7.52);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (3, 1, 3, 100, 6.16);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (4, 1, 4, 100, 8.07);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (5, 1, 5, 100, 2.10);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (6, 1, 6, 100, 7.45);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (7, 1, 7, 100, 4.02);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (8, 1, 8, 100, 0.64);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (9, 1, 9, 100, 8.51);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (10, 1, 10, 100, 3.61);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (11, 1, 11, 100, 2.62);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (12, 1, 12, 100, 2.60);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (13, 1, 13, 100, 1.26);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (14, 1, 14, 100, 4.08);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (15, 1, 15, 100, 3.56);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (16, 1, 16, 100, 7.13);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (17, 1, 17, 100, 7.64);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (18, 1, 18, 100, 5.94);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (19, 1, 19, 100, 2.94);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (20, 1, 20, 100, 1.91);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (21, 1, 21, 100, 8.89);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (22, 1, 22, 100, 7.62);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (23, 1, 23, 100, 6.19);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (24, 1, 24, 100, 2.83);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (25, 1, 25, 100, 5.51);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (26, 1, 26, 100, 4.23);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (27, 1, 27, 100, 8.33);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (28, 1, 28, 100, 7.09);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (29, 1, 29, 100, 1.75);
insert into purchase_order_details(id, purchase_order_id, product_id, quantity, cost) values (30, 1, 30, 100, 1.72);

DROP TABLE IF EXISTS dcxx_out_of_stock_events;
CREATE TABLE dcxx_out_of_stock_events (
  product_id            INT,
  window_start_time     VARCHAR(50),
  window_end_time       VARCHAR(50),
  stock_level           INT,
  demand_last_3mins     INT,
  quantity_to_purchase  INT
);
