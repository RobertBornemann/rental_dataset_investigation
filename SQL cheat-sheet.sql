
select first_name, last_name 
from actor
Where char_length(first_name) < 5
and char_length(last_name) < 5

select first_name, last_name, email, store_id
from customer, rental
where store_id = 2


select first_name, last_name
from actor
where actor_id = 50

select count(email)
from customer
where store_id = 2


select count(email)
from customer
group by store_id


# which rating do we have the most films in

select count(rating), RATING
from film, 
group by rating
ORDER BY 1

select count(rating)
from film_list
where rating = "R"
and price = .99

# list of everyfilm, category, lang, 

select film.title, category.name, language.name

from language, film, category, film_category

where film.film_id = film_category.film_id
and film_category.category_id = category.category_id
and language.language_id = film.language_id

# How many times each movie has been rented out?

select f.title, count(r.rental_id)
from film f, inventory i, rental r
where f.film_id = i.film_id
and i.inventory_id = r.inventory_id
group by 1
order by 2 desc

select f.title as "Filmtitle" , count(r.rental_id) as "Total Sum of Rentals", count(r.rental_id) * f.rental_rate as "Total Revenue"
from film f, inventory i, rental r
where f.film_id = i.film_id
and i.inventory_id = r.inventory_id
group by 1
order by 2 desc

# What customer has paid most money

select customer_id, sum(amount)
from payment
group by 1
order by 2 desc

# what store has historically brought the most money

select i.store_id, sum(p.amount) as "Revenue"
from rental r, payment p, inventory i
where r.rental_id = p.rental_id
and r.inventory_id = i.inventory_id
group by 1
order by 2 desc

# grouped rental dates with left

select left(r.rental_date,7), count(r.rental_id)
from rental r 
group by 1
order by 2 desc


# every customers last rental date

select concat(c.first_name, " ", c.last_name), max(r.rental_date)
from customer c, rental r
where c.customer_id = r.customer_id 
group by 1

# revenue by each month

select left(p.payment_date, 7), sum(p.amount) as "Revenue by month"
from payment p
group by 1
order by 2 desc

# how many distinct renters per month

# number of distinct films rented per month

select count(distinct f.film_id), left(rental_date,7), count(distinct r.rental_id)
from rental r, inventory i, film f
where   f.film_id = i.film_id
and     i.inventory_id = r.inventory_id
group by 2


# How much reveneue has one single store made over pg 13 and r rated films

select i.store_id, sum(p.amount) as "Revenue", f.rating
from payment p, rental r, inventory i, film f
where p.rental_id = r.rental_id
and r.inventory_id = i.inventory_id
and i.film_id = f.film_id
and i.store_id = 1
and f.rating in ("PG-13","R")

group by 3
order by 2 desc

# We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers 
# only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.

SELECT accounts.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' 
     END 
 FROM accounts 
 JOIN orders ON orders.account_id = accounts.id
 WHERE DATE_TRUNC('year', orders.occurred_at) BETWEEN '2016-1-1' AND '2017-12-31'
 GROUP BY accounts.name
 ORDER BY total_spent DESC

# We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table 
# with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
# Place the top sales people first in your final table.

SELECT sales_reps.name, COUNT(orders.id) total_orders,
     CASE WHEN COUNT(orders.id) > 200 THEN 'top'
     ELSE 'low' 
     END  
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_reps.name
ORDER BY total_orders DESC

# The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see 
# these characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated 
# with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in 
# sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, 
# middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. 
# You might see a few upset sales people by this criteria!

SELECT sales_reps.name, COUNT(orders.id) total_orders, SUM(orders.total_amt_usd),
     CASE WHEN COUNT(orders.id) > 200 OR SUM(orders.total_amt_usd) > 750000 THEN 'top'
	 CASE WHEN COUNT(orders.id) >= 150 OR SUM(orders.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' 
     END  
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_reps.name
ORDER BY total_orders DESC

# We want to find the average number of events for each day for each channel. The first table will provide us the 
# number of events for each day and channel, and then we will need to average these values together using a second 
# query.

SELECT channel, AVG(events) AS average_events
FROM (SELECT web_events.channel, DATE_TRUNC('day', web_events.occurred_at) AS day, COUNT(*) as events
	FROM web_events
	GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;


