use sakila;
 -- Display the first and last names of all actors from the table `actor`.
 select first_name,last_name from actor;

-- Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.
 select concat(first_name,'  ',last_name) as 'Actor Name' from actor;
 
/* You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe."*/
select actor_id,first_name,last_name from actor 
WHERE first_name='Joe';

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
select actor_id,first_name,last_name from actor 
WHERE last_name like '%GEN%';

/* 2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order:*/
select actor_id,first_name,last_name from actor 
WHERE last_name like '%LI%'
order by last_name,first_name;

/* * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
Afghanistan, Bangladesh, and China: */
SELECT country_id,country FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

/* 
3a. You want to keep a description of each actor. You don't think you will be
 performing queries on a description, so create a column in the table `actor` named
  `description` and use the data type `BLOB`  */
   
ALTER TABLE actor
    ADD COLUMN description blob;

describe actor;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
 Delete the `description` column.*/

 ALTER TABLE actor
    DROP description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,count(last_name) FROM actor 
group by last_name;


*/*  4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors
 */
SELECT last_name,count(last_name) FROM actor 
group by last_name
HAVING count(last_name)>1;

/* * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
Write a query to fix the record. */
Update actor
SET first_name="HARPO"
WHERE last_name="WILLIAMS" and first_name="GROUCHO";

Select * from actor
WHERE last_name="WILLIAMS";

/* * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! In a single query, 
if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. */

UPDATE actor
SET first_name="GROUCHO"
WHERE first_name="HARPO";

/* You cannot locate the schema of the `address` table. Which query would you use to re-create it?*/
Show Create TABLE address;


/* * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`: */ 
SELECT s.first_name,s.last_name,concat(a.address,",",a.district) as Address
FROM staff as s JOIN address as a 
    ON s.address_id=a.address_id;

/* * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. */
 SELECT concat(s.first_name,s.last_name) as 'Staff Member',sum(p.amount) as 'Total Amount'
 FROM staff as s JOIN payment as p 
    ON p.staff_id=s.staff_id
GROUP BY p.staff_id;

/* * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join. */
SELECT f.title,count(fa.actor_id) 
FROM film as f inner join film_actor as fa 
    ON f.film_id=fa.film_id
GROUP BY fa.film_id;

/* * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? */
SELECT  f.title,count(i.inventory_id) 
FROM film as f inner join inventory as i
    ON f.film_id =i.film_id
WHERE f.title='Hunchback Impossible'
GROUP BY i.film_id;

/* * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
 List the customers alphabetically by last name: */
SELECT concat(c.last_name," ,",c.first_name) as Customer,sum(p.amount )as 'Total Paid'
FROM customer as c inner join payment as p
    ON c.customer_id=p.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name;

/* * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. */

SELECT f.title ,l.name as Language
FROM film as f JOIN language as l
    on f.language_id=l.language_id
WHERE f.title like 'Q%'or f.title like 'K%'
   and lower(l.name)='english';

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name,last_name FROM actor
WHERE actor_id in 
    (
        SELECT actor_id from film_actor
        WHERE film_id in 
            (
                SELECT film_id FROM film
                WHERE title='Alone Trip'
            )
    );

/* * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information. */

SELECT cus.last_name,cus.first_name,cus.email
FROM customer as cus
     JOIN address as a  on cus.address_id=a.address_id
     JOIN city as ci on a.city_id=ci.city_id
     JOIN country as c on c.country_id=ci.country_id
WHERE lower(c.country)='canada';

/* * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films. */
SELECT f.title 
FROM film as f
    join film_category as fct on fct.film_id=f.film_id
    join category as ct on ct.category_id=fct.category_id
WHERE lower(ct.name)='family';

-- * 7e. Display the most frequently rented movies in descending order.
SELECT f.title,count(i.film_id) as'Times Rented'
FROM  film as f 
	join inventory as i on i.film_id=f.film_id
	join rental as r on r.inventory_id=i.inventory_id
-- where i.film_id=80
GROUP BY i.film_id
ORDER BY count(i.film_id) DESC;	

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
 SELECT st.store_id,sum(p.amount) as 'Total Amount'
 FROM  store as st
	join staff as s on s.staff_id=st.manager_staff_id
    JOIN payment as p  ON p.staff_id=s.staff_id
GROUP BY p.staff_id;
-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id,ci.city,c.country
FROM store as s
     JOIN address as a  on s.address_id=a.address_id
     JOIN city as ci on a.city_id=ci.city_id
     JOIN country as c on c.country_id=ci.country_id;


/* * 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT ct.name as 'Genres',sum(p.amount) as 'Gross Revenue'
FROM  payment as p
     join rental as r  on r.rental_id=p.payment_id
    join inventory as i on r.inventory_id=i.inventory_id
	join film_category as fct on fct.film_id=i.film_id
    join category as ct on ct.category_id=fct.category_id
-- -- WHERE lower(ct.name)='family';
-- -- where i.film_id=80
GROUP BY ct.category_id
ORDER BY sum(p.amount) DESC
limit 5;	

/* * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. */
CREATE VIEW V_top_5_Genres as 
    SELECT ct.name as 'Genres',sum(p.amount) as 'Gross Revenue'
    FROM  payment as p
        join rental as r  on r.rental_id=p.payment_id
        join inventory as i on r.inventory_id=i.inventory_id
        join film_category as fct on fct.film_id=i.film_id
        join category as ct on ct.category_id=fct.category_id
    -- -- WHERE lower(ct.name)='family';
    -- -- where i.film_id=80
    GROUP BY ct.category_id
    ORDER BY sum(p.amount) DESC
    limit 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM V_top_5_Genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW V_top_5_Genres;