
-- Getting started to explore the dataset:

-- Actors first and last name combined as full_name, film title, film description and length of the movie.
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.description, f.length
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id

-- List of actors and movies where the movie length was more than 60 minutes.
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.description, f.length
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.length > 60

-- Capturing actor id, full name of the actor, and count the number of movies each actor has made. 
SELECT a.actor_id, concat(a.first_name, ' ', a.last_name) as full_name, COUNT(f.film_id) as number_of_movies
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY 1
ORDER BY 2

-- Actor with max & min number of movies.
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
	LIMIT 1) t2
	
-- actor's full name, film title, length of movie + column name "filmlen_groups" that classifies movies based on their length (4 categories: <= 1h, 1-2h, 2-3h, >3h)
SELECT concat(a.first_name, ' ', a.last_name) as full_name, f.title, f.length,
     CASE 
	 	WHEN f.length <= 60 THEN '<1h'
	  	WHEN f.length > 60 AND f.length < 120 THEN '1-2h'
	  	WHEN f.length > 120 AND f.length < 180 THEN '2-3h'
		WHEN f.length > 180 THEN '>3h'
     END AS filmlen_groups
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id

-- Counting movies in each of the 4 filmlen_groups.
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
ORDER BY  filmlen_groups
-- OR LIKE THIS
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
ORDER BY  filmlen_groups

-- We want to understand more about the movies that families are watching. 
-- The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
-- Thus we create a query that lists each movie in family movies along with the film category it is classified in, and the number of times it has been rented out:


SELECT f.title, c.name, COUNT(rental_id) as nr_times_rented
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON f.film_id = fc.film_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1,2
HAVING c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music')
ORDER BY c.name;

-- Let's look at the length of rental duration of these family-friendly movies and compare it to the duration that all movies are rented for. 
-- We provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) 
-- based on the quartiles (25%, 50%, 75%) 

-- I tried this first:

SELECT film_title, category, rental_duration,	
	ntile(4) over (partition by rental_duration ) percentile
FROM (
	SELECT DISTINCT(f.title) AS film_title, c.name AS category, DATE_PART('day', r.return_date - r.rental_date) AS rental_duration 
	FROM category c
	JOIN film_category fc ON c.category_id = fc.category_id
	JOIN film f ON f.film_id = fc.film_id
	JOIN inventory i ON fc.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r.inventory_id
	WHERE c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music') 
		AND DATE_PART('day', r.return_date - r.rental_date) > 0
	)t1
ORDER BY percentile;

-- but then I found out that there actually is a rental_rate column in the film table. That mean we can further simplyfy and refactor this query:

SELECT DISTINCT(f.title) film_title, c.name category, f.rental_duration, 
	ntile(4) OVER (ORDER BY rental_duration) standard_quartile
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music') 
ORDER BY 3,4

-- let's create a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category
-- for each corresponding rental duration category. The resulting table should have three columns:

SELECT category, standard_quartile, COUNT(standard_quartile)
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
ORDER BY 1,2
	
