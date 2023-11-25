-- 1. Create a new user with limited permissions
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvd_rental TO rentaluser;

-- 2. Grant SELECT permission for the "customer" table to rentaluser
GRANT SELECT ON TABLE customer TO rentaluser;

-- 3. Create a new user group and add rentaluser to it
CREATE GROUP rental;
ALTER USER rentaluser IN GROUP rental;

-- 4. Grant INSERT and UPDATE permissions for the "rental" table to the "rental" group
GRANT INSERT, UPDATE ON TABLE rental TO rental;

-- Insert a new row and update an existing row in the "rental" table under the "rental" role
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date) 
VALUES ('2023-11-25', 1, 1, NULL);

UPDATE rental SET return_date = '2023-12-01' WHERE rental_id = 1;

-- 5. Revoke INSERT permission for the "rental" table from the "rental" group
REVOKE INSERT ON TABLE rental FROM rental;

-- Try to insert a new row (this should result in an error)
-- INSERT INTO rental (rental_date, inventory_id, customer_id, return_date) 
-- VALUES ('2023-11-26', 2, 2, NULL);

-- 6. Create a personalized role for existing customers
-- Replace {first_name}, {last_name}, and {customer_id} with actual values
CREATE ROLE client_first_name_last_name;
GRANT USAGE, SELECT ON TABLE rental TO client_first_name_last_name;
GRANT USAGE, SELECT ON TABLE payment TO client_first_name_last_name;
GRANT client_first_name_last_name TO {customer_id};

-- Verify that the user sees only their own data
-- Replace {customer_id} with the actual customer ID
SET ROLE client_first_name_last_name;
SELECT * FROM rental WHERE customer_id = {customer_id};
SELECT * FROM payment WHERE customer_id = {customer_id};
RESET ROLE;
