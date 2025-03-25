create database pizza_sales;
use pizza_sales;

select top 5 * from pizzas;
select top 5 * from pizzas_types;
select top 5 * from orders;
select top 5 * from order_details;

/* Finding to toal number of order placed */

select distinct(count(order_id)) as total_orders
from orders;

/* Total revenue generated from pizzas sales */

select round(sum(quantity * price),2) as total_revenue
from pizzas t1
join order_details t2 on t2.pizza_id = t1.pizza_id


/* Highest price pizza */

select top 1 t1.pizza_type_id,t1.name, round(t2.price ,2)
from pizzas_types t1
join pizzas t2 on t2.pizza_type_id = t1.pizza_type_id
order by price desc;


/* Most common pizza size ordered */

select t1.size, count(t2.quantity) ordered
from pizzas t1
join order_details t2 on t2.pizza_id = t1.pizza_id
group by t1.size
order by ordered desc ;

/* Count comes like Large pizza size has a order count of 18526, Medium of 15385, 
   Small size of 14137, Extra Large size of 544 and Double Extra Large size of 28 */

/* Top 5 most ordered pizza type along with their quantity */

select top 5 t1.pizza_type_id,t1.name, sum(quantity)as total_quantity
from pizzas_types t1 
join pizzas t2 on t2.pizza_type_id = t1.pizza_type_id
join order_details t3 on t3.pizza_id = t2.pizza_id
group by t1.pizza_type_id,t1.name
order by total_quantity desc;


/* Join the necessary tables to find the total quantity of each pizza category ordered. */

select t1.category, sum(quantity)as total_quantity
from pizzas_types t1 
join pizzas t2 on t2.pizza_type_id = t1.pizza_type_id
join order_details t3 on t3.pizza_id = t2.pizza_id
group by t1.category
order by total_quantity desc;


/* Determine the distribution of orders by hour of the day */

select datepart(hour, time) as per_hour, count(order_id) as total_count
from orders
group by datepart(hour, time)
order by total_count desc;


/*Join relevant tables to find the category-wise distribution of pizzas. */
select category,count(name) as name
from pizzas_types
group by category


/* Group the orders by date and calculate the average number of pizzas ordered per day. */
select avg(total_count)as pizza_sales_per_day from
(select date, sum(quantity) as total_count
from orders t1
join order_details t2 on t1.order_id = t2.order_id
group by date) as total_quantity;

/* per day 138 pizzas will be ordered */

/* Determine the top 3 most ordered pizza types based on revenue.*/

select top 3 t1.name, sum(t2.price * t3.quantity) as revenue
from pizzas_types t1
join pizzas t2 on t1.pizza_type_id = t2.pizza_type_id
join order_details t3 on t3.pizza_id = t2.pizza_id
group by name 
order by revenue desc;

/*  The Thai Chicken Pizza			43434.25
	The Barbecue Chicken Pizza		42768
	The California Chicken Pizza	41409.5 */

/* Calculate the percentage contribution of each pizza type to total revenue.*/

select t1.category, 
round(sum(t2.price * t3.quantity) / (select round(sum(quantity * price),2) as total_revenue
									 from pizzas t1
									 join order_details t2 on t2.pizza_id = t1.pizza_id)* 100,2) as revenue
from pizzas_types t1
join pizzas t2 on t1.pizza_type_id = t2.pizza_type_id
join order_details t3 on t3.pizza_id = t2.pizza_id
group by t1.category 
order by revenue desc;



/*
Classic	26.91
Supreme	25.46
Chicken	23.96
Veggie	23.68
*/

/* Analyze the cumulative revenue generated over time.*/

with cumulative_revenue as
(
	select t2.date, round(sum(t1.quantity * t3.price),0) as revenue
	from order_details t1
	join orders t2 on t2.order_id = t1.order_id
	join pizzas t3 on t3.pizza_id = t1.pizza_id
	group by t2.date 
)
select date, revenue, 
sum(revenue) over(order by date) as rolling_revenue
from cumulative_revenue
order by date;


/* Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
 
 WITH PIZZAS_RANK (CATEGORY, NAME, REVENUE)AS
 (
 select t1.category, t1.name, sum((t3.quantity) * t2.price) as revenue
 from pizzas_types t1
 join pizzas t2 on t2.pizza_type_id = t1.pizza_type_id
 join order_details t3 on t2.pizza_id = t3.pizza_id
 group by t1.category, t1.name 
 
 ),PIZZA_RANKING AS
 ( 
 SELECT *, 
 DENSE_RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RANKING
 FROM PIZZAS_RANK
 )
 SELECT * FROM PIZZA_RANKING WHERE RANKING <= 3;

