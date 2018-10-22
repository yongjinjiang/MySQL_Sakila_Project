
use sakila;

-- 1a
select first_name, last_name
from actor;

-- 1b
select UCASE(concat(first_name, '  ', last_name)) as Actor_Name
from actor;


-- 2a.
select *
from actor
where first_name="Joe";


-- 2b. Find all actors whose last name contain the letters GEN:
select *
from actor
where last_name like "%GEN%";


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like "%LI%"
order by last_name,first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select *
from country 
where country in
( "Afghanistan", "Bangladesh",  "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter TABLE actor
add column description Blob; 

Alter TABLE actor
add column description1 Blob after last_update; 


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor
drop column description,
drop column description1;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(*) as Num_last_name
from actor
group by last_name;


/* 4b. List last names of actors and the number of actors who have that last name, but only for names that 
are shared by at least two actors*/
-- method 1
select *
from (select last_name,count(*) as 'Totals' 
		 from actor
		 group by last_name) as AA
where AA.Totals>=2;

-- method 2
SELECT last_name, COUNT(last_name) AS 'Totals' 
FROM actor
GROUP BY last_name
having COUNT(last_name) >= 2;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
 update actor
 set first_name="HARPO",
  last_name="WILLIAMS"
 where actor_id in 
         (select AA.actor_id from
                (select * from actor
                where first_name="GROUCHO"&&last_name="WILLIAMS") as AA );
 


--  4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name="GROUCHO"
 where first_name="HARPO";
 
 -- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
 show create table address;
 
 -- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name,staff.last_name,address.address
from staff 
left join 
address 
on staff.address_id= address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select  sum(amount) as "total amount", count(*) as 'total count', staff_member
from
(select p.amount, concat(s.first_name,' ',s.last_name) as staff_member
from payment p 
left join 
staff s 
on s.staff_id= p.staff_id) as AA
group by staff_member;
--  6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select *
from  film_actor;
select  *
from film;

select title, count(*) as 'Number of actors'
from 
(select title, a.actor_id as actor_id
from film f
inner join
 film_actor a
 on f.film_id=a.film_id) as AA
 group by title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- method 1
select title, count(*) as "number of copies"
from (select i.*,f.title 
from inventory i
inner join 
film f
on i.film_id=f.film_id) as AA
group by title
having title= 'Hunchback Impossible';

-- method 2:

select  count(*)  as  "number of copies"
from inventory
where film_id in
(select film_id
from film
where title='Hunchback Impossible');


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
 
select Name1 as 'name',customer_id,sum(amount) as "Total amount paid"
from  
    (
        select p.customer_id,amount,first_name,last_name,concat(first_name,' ',last_name) as 'Name1'
        from payment p 
        inner join 
        customer c
        on p.customer_id=c.customer_id
    )
as AA
group by customer_id, Name1
order by last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
 Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
 select  title
 from film
 where ((title REGEXP '^k' ) or (title REGEXP '^q')) 
       and 
       (language_id in
            (
              select language_id
              from language
              where name='English'
            )
        );



-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id,concat(first_name,' ',last_name) as "actor's name for film: -Alone Trip"  
from actor
where actor_id in
    (select actor_id
	 from film_actor
     where film_id in 
             (select film_id
              from film
    where title='Alone Trip')
   );





/*7c. You want to run an email marketing campaign in Canada, for which you will need the names 
and email addresses of all Canadian customers. Use joins to retrieve this information.*/

select first_name, last_name,email
from customer
where address_id in
        (select address_id
        from address
        where city_id in
                (select city_id
                from city
                where country_id in
                    (select country_id
                    from country
                    where country='Canada')
                )
        );


select *
from country
where country='Canada';

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. I
dentify all movies categorized as family films.*/
select title
from film
where film_id in
        (select film_id
        from film_category
        where category_id in
            (select category_id
            from category
            where name="family")
        );

-- 7e. Display the most frequently rented movies in descending order.

select f.film_id as film_id,title,rented_times
from film f 
inner join
        (
        select film_id,count(film_id )  as "rented_times"
        from inventory
        where inventory_id in
            (select inventory_id
            from rental)
            group by film_id
        ) 
        as AA
on f.film_id=AA.film_id
order by rented_times DESC;

-- select *
-- from film;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- select *
-- from store;
-- select *
-- from rental;
select *
from staff;

select  staff_id as store_id,sum(amount) as Total_Amount
from payment
group by staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id,address,district,city,country
from country co
inner join
        ( 
        select store_id,address,district,city,country_id
        from  (
                    select store_id,address,district,city_id as city_id_AA
                    from store s
                    inner join 
                    address a
                    on s.address_id=a.address_id
                ) 
        as AA
        inner join
        city c
        on AA.city_id_AA= c.city_id
        ) 
as BB
on BB.country_id=co.country_id;



/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
following tables: category, film_category, inventory, payment, and rental.*/


select name as category, Total_Revenue_per_category
from 
        (
            select category_id, sum(amount) as "Total_Revenue_per_category"
            from film_category
            inner join
                    (
                        select i.film_id,amount
                        from inventory as i
                        inner join 
                                (
                                    select inventory_id,amount
                                    from rental r 
                                    inner JOIN
                                    payment p 
                                    on r.rental_id=p.rental_id
                                ) 
                        as AA
                        on i.inventory_id=AA.inventory_id
                    )
            as BB
            on film_category.film_id=BB.film_id
            group by category_id
        )
as CC 
inner join 
category CA
on CC.category_id=CA.category_id
order by Total_Revenue_per_category desc
limit 5;



/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres
 by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you
 can substitute another query to create a view.*/

  
 DROP VIEW if exists top5_genres;
 create view top5_genres as 
 select name as category, Total_Revenue_per_category
from 
        (
            select category_id, sum(amount) as "Total_Revenue_per_category"
            from film_category
            inner join
                    (
                        select i.film_id,amount
                        from inventory as i
                        inner join 
                                (
                                    select inventory_id,amount
                                    from rental r 
                                    inner JOIN
                                    payment p 
                                    on r.rental_id=p.rental_id
                                ) 
                        as AA
                        on i.inventory_id=AA.inventory_id
                    )
            as BB
            on film_category.film_id=BB.film_id
            group by category_id
        )
as CC 
inner join 
category CA
on CC.category_id=CA.category_id
order by Total_Revenue_per_category desc
limit 5;



-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it./*
 
 DROP VIEW if exists top5_genres;