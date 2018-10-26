USE sakila; 

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,  ' ', last_name) AS ' Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor 
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor 
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

SELECT * FROM actor;

-- 3a. Blob
ALTER TABLE actor
ADD COLUMN  description BLOB AFTER last_update;

SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP  description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name
HAVING COUNT > 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name='HARPO'
WHERE first_name = 'GROUCHO' AND last_name= 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct 
-- name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name='GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff s LEFT JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) AS "Total"
FROM staff s LEFT JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(a.actor_id) AS 'Total Actors'
FROM film f INNER JOIN film_actor a ON f.film_id = a.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id) AS "HBI Copies"
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Paid' 
FROM customer c JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(
			SELECT language_id FROM language WHERE name='English');
            
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (
		  SELECT actor_id 
		  FROM film_actor 
		  WHERE film_id IN 
				(
				SELECT film_id 
				FROM film 
				WHERE title='ALONE TRIP'
				)
		);
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email 
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city ct ON (a.city_id=ct.city_id)
JOIN country cntry ON (ct.country_id=cntry.country_id)
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT f.title 
FROM film f
WHERE film_id
	IN (
		  SELECT film_id 
		  FROM film_category 
		  WHERE category_id IN 
				(
				SELECT category_id 
				FROM category
				WHERE name='Family'
				)
		);

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title AS 'Movie', COUNT(r.rental_date) AS 'Rental Count'
FROM film AS f
JOIN inventory AS i ON i.film_id = f.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_date) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT CONCAT(c.city,', ',cntry.country) AS `Store`, s.store_id AS 'Store ID', SUM(p.amount) AS `Sales Total` 
FROM payment AS p
JOIN rental AS r ON r.rental_id = p.rental_id
JOIN inventory AS i ON i.inventory_id = r.inventory_id
JOIN store AS s ON s.store_id = i.store_id
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS c ON c.city_id = a.city_id
JOIN country AS cntry ON cntry.country_id = c.country_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS 'Store ID', c.city AS 'City', cntry.country AS `Country` 
FROM store AS s
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS c ON c.city_id = a.city_id
JOIN country AS cntry ON cntry.country_id = c.country_id
ORDER BY s.store_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
CREATE VIEW top_five_genres AS 
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross Revenue'
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

--  8B. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres
DROP VIEW top_five_genres;






