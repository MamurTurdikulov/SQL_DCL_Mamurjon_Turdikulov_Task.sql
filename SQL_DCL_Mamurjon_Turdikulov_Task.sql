CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvd_rental TO rentaluser;

GRANT SELECT ON TABLE customer TO rentaluser;

CREATE GROUP rental;
ALTER USER rentaluser IN GROUP rental;

GRANT INSERT, UPDATE ON TABLE rental TO rental;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date) 
VALUES ('2023-11-25', 1, 1, NULL);
UPDATE rental SET return_date = '2023-12-01' WHERE rental_id = 1;

REVOKE INSERT ON TABLE rental FROM rental;

CREATE ROLE client_first_name_last_name;
GRANT USAGE, SELECT ON TABLE rental TO client_first_name_last_name;
GRANT USAGE, SELECT ON TABLE payment TO client_first_name_last_name;

GRANT client_first_name_last_name TO {customer_id};

SET ROLE client_first_name_last_name;
SELECT * FROM rental WHERE customer_id = {customer_id};
SELECT * FROM payment WHERE customer_id = {customer_id};
RESET ROLE;
