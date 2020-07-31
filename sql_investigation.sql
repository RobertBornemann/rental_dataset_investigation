-- Please find below my SQL queries from the "investigate a relation database" udacity project practice quizes and the question sets:

-- (Q1.1) Actors first and last name combined as full_name, film title, film description and length of the movie.
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.description, f.length
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id;

-- (Q1.2) Actors and movies where the movie length was more than 60 minutes.
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.description, f.length
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.length > 60;

-- (Q1.3) Capturing actor id, full name of the actor, and count the number of movies each actor has made. 
SELECT a.actor_id, concat(a.first_name, ' ', a.last_name) as full_name, COUNT(f.film_id) as number_of_movies
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY 1
ORDER BY 3 DESC;

-- (EXTRA QUERY) Actor with max & min number of movies.
SELECT *
FROM (
	SELECT a.actor_id, concat(a.first_name, ' ', a.last_name) as full_name, COUNT(f.film_id) as number_of_movies
	FROM actor a
	JOIN film_actor fa ON a.actor_id = fa.actor_id
	JOIN film f ON fa.film_id = f.film_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1) t1

UNION ALL

SELECT *
FROM (
	SELECT a.actor_id, concat(a.first_name, ' ', a.last_name) as full_name, COUNT(f.film_id) as number_of_movies
	FROM actor a
	JOIN film_actor fa ON a.actor_id = fa.actor_id
	JOIN film f ON fa.film_id = f.film_id
	GROUP BY 1
	ORDER BY 3 
	LIMIT 1) t2;
	
-- (Q2.1) Actor's full name, film title, length of movie + column name "filmlen_groups" that classifies movies based on their length (4 categories: <= 1h, 1-2h, 2-3h, >3h)
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.length,
     CASE 
	 	WHEN f.length <= 60 THEN '<1h'
	  	WHEN f.length > 60 AND f.length < 120 THEN '1-2h'
	  	WHEN f.length > 120 AND f.length < 180 THEN '2-3h'
		WHEN f.length > 180 THEN '>3h'
     END AS filmlen_groups
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id;

-- (Q2.2) Counting movies in each of the 4 filmlen_groups.
SELECT filmlen_groups, COUNT(filmlen_groups) AS filmcount_bylencat
FROM(
		SELECT f.length,
		 CASE 
			WHEN f.length <= 60 THEN '<1h'
			WHEN f.length > 60 AND f.length <= 120 THEN '1-2h'
			WHEN f.length >= 120 AND f.length <= 180 THEN '2-3h'
			WHEN f.length > 180 THEN '>3h'
		 END AS filmlen_groups
	FROM film f
	) t1
GROUP BY 1
ORDER BY  filmlen_groups;

-- (EXTRA QUERY) OR LIKE THIS
SELECT DISTINCT(filmlen_groups), COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat
FROM  (
		SELECT f.title as title, f.length,
		 CASE 
			WHEN f.length <= 60 THEN '<1h'
			WHEN f.length > 60 AND f.length <= 120 THEN '1-2h'
			WHEN f.length >= 120 AND f.length <= 180 THEN '2-3h'
			WHEN f.length > 180 THEN '>3h'
		 END AS filmlen_groups
	FROM film f
	) t1
ORDER BY  filmlen_groups;

-- QUESTION SET 1.1: Movie, the film category it is classified in, and the number of times it has been rented out.
SELECT f.title, c.name, COUNT(rental_id) as nr_times_rented
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON f.film_id = fc.film_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2
HAVING c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music')
ORDER BY c.name;

-- QUESTION SET 1.2: Movie titles divided them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) 
	-- based on the quartiles (25%, 50%, 75%): 
SELECT 	DISTINCT(f.title), 
		c.name, 
		f.rental_duration, 
		ntile(4) OVER (ORDER BY rental_duration) standard_quartile
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music') 
ORDER BY 3,1;

-- QUESTION SET 1.3: Family-friendly film category, each of the quartiles, and the corresponding count of movies within each 
	-- combination of film category for each corresponding rental duration category:
SELECT category AS name, standard_quartile, COUNT(standard_quartile)
FROM (
	SELECT DISTINCT(f.title) film_title, c.name category, f.rental_duration, 
		ntile(4) OVER (ORDER BY rental_duration) standard_quartile
	FROM film f 
	JOIN film_category fc ON f.film_id = fc.film_id
	JOIN category c ON fc.category_id = c.category_id
	WHERE c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music') 
	ORDER BY 3,4
	)t1
GROUP BY 1,2
ORDER BY 1,2;

-- QUESTION SET 2.1: Store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month:
SELECT 	DATE_PART('month', r.rental_date) AS Rental_month, 
		DATE_PART('year', r.rental_date) AS Rental_year,
		store_id AS Store_ID,
		COUNT(r.rental_id) AS Count_rental
FROM rental r
JOIN staff st ON r.staff_id = st.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- QUESTION SET 2.2: Customer name, month and year of payment, and total payment amount for each month by the top 10 paying customers:
SELECT 	DATE_TRUNC('month', payment_date) AS pay_mon, 	
		concat(c.first_name, ' ', c.last_name) AS fullname, 
		COUNT(amount) AS pay_counterpermon, 
		sum(amount) AS pay_amount 
FROM payment 
JOIN customer c ON payment.customer_id = c.customer_id
WHERE c.customer_id IN(
		SELECT customer_id
		FROM (
				SELECT py.customer_id as customer_id, SUM(py.amount) AS pay_amount
				FROM payment py
				WHERE DATE_PART('year', py.payment_date) = 2007
				GROUP BY 1
				ORDER BY 2 DESC
				LIMIT 10
			)t1
		)
GROUP BY 1,2
ORDER BY 2,1;

-- QUESTION SET 2.3: Comparing the payment amounts in each successive month for the Top 10 paying customers. 
-- >>> Then displaying the customer name who paid the highest "lead" difference in terms of payments:
SELECT 	fullname, pay_mon,
		MAX(lead_difference) OVER (PARTITION BY fullname) AS max_lead_difference
FROM (
		SELECT pay_mon, fullname, pay_amount, 
				LEAD(pay_amount) OVER (ORDER BY fullname) - pay_amount AS lead_difference
		FROM (
				SELECT 	DATE_TRUNC('month', payment_date) AS pay_mon, 
						concat(c.first_name, ' ', c.last_name) AS fullname, 
						COUNT(amount)  AS pay_counterpermon, 
						sum(amount) AS pay_amount 
				FROM payment 
				JOIN customer c ON payment.customer_id = c.customer_id
				WHERE c.customer_id IN(
					SELECT customer_id
					FROM (
						SELECT py.customer_id as customer_id, SUM(py.amount) AS pay_amount
						FROM payment py
						WHERE DATE_PART('year', py.payment_date) = 2007
						GROUP BY 1
						ORDER BY 2 DESC
						LIMIT 10
						)t1
					)
				GROUP BY 1,2
				ORDER BY 2,1
				)t2
		)t3
ORDER BY 3 DESC
LIMIT 1;