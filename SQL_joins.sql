-- Use this 'sakila' Database
USE sakila;

-- 1. Display all available tables in the Sakila database
-- This query lists all tables in the current database to understand the available data structures and relationships.
SHOW TABLES;

-- Challenge - Joining on multiple tables

-- 1. List the number of films per category
-- This query counts how many films are in each category, including categories without any films.
SELECT
    c.name AS category_name,
    COUNT(fc.film_id) AS film_count
FROM
    category AS c
-- A LEFT JOIN is used to ensure that even categories without films are included in the result.
LEFT JOIN 
    film_category AS fc ON fc.category_id = c.category_id
GROUP BY
    c.name
ORDER BY
    film_count DESC;

-- 2. Retrieve the store ID, city, and country for each store
-- This query fetches distinct combinations of store ID, city, and country to provide a geographical overview of the stores.
SELECT DISTINCT
    s.store_id,
    ci.city,
    co.country
FROM
    store AS s
JOIN
    address AS a ON s.address_id = a.address_id
JOIN
    city AS ci ON a.city_id = ci.city_id
JOIN
    country AS co ON ci.country_id = co.country_id;

-- 3. Calculate the total revenue generated by each store in dollars
-- This query calculates and rounds total earnings by each store, using payments data linked through rentals and inventory.
SELECT
    s.store_id,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM
    store AS s
JOIN
    inventory AS i ON s.store_id = i.store_id
JOIN
    rental AS r ON i.inventory_id = r.inventory_id
JOIN
    payment AS p ON r.rental_id = p.rental_id
GROUP BY
    s.store_id;

-- 4. Determine the average running time of films for each category
-- This query calculates the average length of films for each category and orders the results by the longest average time.
SELECT
    c.name AS category_name,
    ROUND(AVG(f.length), 2) AS avg_running_time
FROM
    category AS c
JOIN
    film_category AS fc ON c.category_id = fc.category_id
JOIN 
    film AS f ON fc.film_id = f.film_id
GROUP BY
    c.name
ORDER BY
    avg_running_time DESC;

-- Bonus:

-- 5. Identify the film categories with the longest average running time
-- This query lists the top 5 categories with the longest average film duration, highlighting film length trends.
SELECT
    c.name AS category_name,
    ROUND(AVG(f.length), 2) AS avg_running_time
FROM
    category AS c
JOIN
    film_category AS fc ON c.category_id = fc.category_id
JOIN 
    film AS f ON fc.film_id = f.film_id
GROUP BY
    c.name
ORDER BY
    avg_running_time DESC
LIMIT 5;

-- 6. Display the top 10 most frequently rented movies in descending order
-- This query identifies the movies most frequently rented, showing rental trends and popular films.
SELECT
    f.title AS film_title,
    COUNT(r.rental_id) AS rental_count
FROM
    film AS f
JOIN
    inventory AS i ON f.film_id = i.film_id
JOIN
    rental AS r ON i.inventory_id = r.inventory_id
GROUP BY
    f.title
ORDER BY
    rental_count DESC, f.title ASC
LIMIT 10;

-- 7. Determine if "Academy Dinosaur" can be rented from Store 1.
-- This query checks if "Academy Dinosaur" has available copies that can be rented from store 1.
SELECT
    f.title,
    s.store_id AS store_id,
    COUNT(i.inventory_id) AS available_copies
FROM
    store AS s
JOIN
    inventory AS i ON s.store_id = i.store_id
JOIN
    film AS f ON i.film_id = f.film_id
LEFT JOIN
    rental AS r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
WHERE
    f.title = "Academy Dinosaur" AND s.store_id = 1
    AND r.rental_id IS NULL -- Ensure only those not currently rented are counted
GROUP BY
    f.title, s.store_id;

-- 8. Provide a list of all distinct film titles, along with their availability status in the inventory.
-- This query checks the availability of each film, marking them as 'Available' if they have any copies not currently rented out,
-- and 'NOT available' otherwise. It uses a CASE statement with COUNT and LEFT JOIN to handle films not present in the inventory.
SELECT
    f.title,
    CASE
        WHEN COUNT(i.inventory_id) - COUNT(r.rental_id) > 0 THEN "Available"
        ELSE "NOT available"
    END AS availability_status
FROM
    film AS f
-- The LEFT JOIN ensures we include films with no inventory and count available copies only if they are not rented (r.return_date IS NULL).
LEFT JOIN
    inventory AS i ON f.film_id = i.film_id
LEFT JOIN
    rental AS r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
GROUP BY
    f.film_id, f.title
ORDER BY
    f.title;


