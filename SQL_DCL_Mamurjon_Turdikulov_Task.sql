-- Create user and grant connect
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvd_rental TO rentaluser;

-- Grant SELECT permission for the "customer" table
GRANT SELECT ON TABLE customer TO rentaluser;

-- Create group and add user to the group
CREATE GROUP rental;
ALTER USER rentaluser IN GROUP rental;

-- Grant INSERT and UPDATE permissions for the "rental" table to the "rental" group
GRANT INSERT, UPDATE ON TABLE rental TO rental;

-- Insert and update rows in the "rental" table under the "rental" group
SET ROLE rental;
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date) 
VALUES ('2023-11-25', 1, 1, NULL);
UPDATE rental SET return_date = '2023-12-01' WHERE rental_id = 1;
RESET ROLE;

-- Revoke INSERT permission for the "rental" group on the "rental" table
REVOKE INSERT ON TABLE rental FROM rental;

-- Create personalized roles for existing customers
DO $$ 
DECLARE 
    customer_record record;
BEGIN 
    FOR customer_record IN SELECT customer_id, first_name, last_name FROM customer LOOP
        -- Check if customer has payment and rental history
        IF (SELECT COUNT(*) FROM payment WHERE customer_id = customer_record.customer_id) > 0 AND
           (SELECT COUNT(*) FROM rental WHERE customer_id = customer_record.customer_id) > 0 THEN
            EXECUTE 'CREATE ROLE client_' || customer_record.first_name || '_' || customer_record.last_name;
            EXECUTE 'GRANT USAGE, SELECT ON TABLE rental TO client_' || customer_record.first_name || '_' || customer_record.last_name;
            EXECUTE 'GRANT USAGE, SELECT ON TABLE payment TO client_' || customer_record.first_name || '_' || customer_record.last_name;
            EXECUTE 'GRANT client_' || customer_record.first_name || '_' || customer_record.last_name || ' TO ' || customer_record.customer_id;
        END IF;
    END LOOP;
END $$;

-- Query to make sure a user sees only their own data in the "rental" table
SET ROLE client_first_name_last_name;
-- Replace {customer_id} with the actual customer ID you want to test
SELECT * FROM rental WHERE customer_id = {customer_id};
RESET ROLE;
