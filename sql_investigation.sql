
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