CREATE TYPE address_type AS (
  street character varying(50),
  country character varying(20),
  postcode   character varying(10)
);

CREATE TABLE customers (
    id SERIAL ,
    full_name character varying(50) NOT NULL,
    birthdate character varying(255) NOT NULL,
    fav_animal character varying(50),
    fav_colour character varying(50),
    fav_movie character varying(50),
    credits   character varying(5),
    street character varying(50),
    country character varying(20),
    postcode   character varying(10)
);

ALTER TABLE public.customers REPLICA IDENTITY FULL;

insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (1, 'Leone Puxley', '1995-02-06', 'Violet-eared waxbill', 'Puce', 'Oh! What a Lovely War','53.49', 'Lynchburg','Virginia','24515');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (2, 'Angelo Sharkey', '1996-04-08', 'Macaw, green-winged', 'Red', 'View from the Top, A','7.0', 'Manassas','Virginia','22111');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (3, 'Jozef Bailey', '1954-07-10', 'Little brown bat', 'Indigo', '99 francs','5.49', 'Lexington','Kentucky','40515');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (4, 'Evelyn Deakes', '1975-09-13', 'Vervet monkey', 'Teal', 'Jane Austen in Manhattan','8.09', 'Chicago','Illinois','60681');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (5, 'Dermot Perris', '1991-01-29', 'African ground squirrel (unidentified)', 'Khaki', 'Restless','3.49', 'Asheville','North Carolina','28805');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (6, 'Renae Bonsale', '1965-01-05', 'Brown antechinus', 'Fuscia', 'Perfect Day, A (Un giorno perfetto)','77.40', 'San Jose','California','95113');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (7, 'Florella Fridlington', '1950-08-07', 'Burmese brown mountain tortoise', 'Purple', 'Dot the I','50.0', 'Jamaica','New York','11431');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (8, 'Hettie Keepence', '1971-10-14', 'Crab-eating raccoon', 'Puce', 'Outer Space','4.0', 'Pensacola','Florida','32590');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (9, 'Briano Quene', '1990-05-02', 'Cormorant, large', 'Yellow', 'Peacekeeper, The','3.0', 'San Antonio','Texas','78296');
insert into customers (id, full_name, birthdate, fav_animal, fav_colour, fav_movie, credits, street, country, postcode) values (10, 'Jeddy Cassell', '1978-12-24', 'Badger, european', 'Indigo', 'Shadow of a Doubt','2.0', 'Charleston','West Virginia','25331');
