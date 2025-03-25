create database music_store;
use music_store;

select top 4 * from album;
select top 4 * from artist;
select top 4 * from employee;
select top 4 * from genre;
select top 4 * from invoice;
select top 4 * from customer;
select top 4 * from invoice_line;
select top 4 * from media_type;
select top 4 * from playlist;
select top 4 * from playlist_track;
select top 4 * from track;

/* altering data type */
ALTER TABLE invoice
ALTER COLUMN customer_id int not null;


--------

select * from employee
where title like 'Senior%';
--or
select top 1 * from employee
order by levels desc;

/* Senior most employee is Mohan Madan */



select count(*) as num, billing_country
from invoice
group by billing_country
order by num desc;

/* USA has 131 count, Canada has 76 and Brazil has 61 Invoices */



select top 3 total, billing_country
from invoice
order by total desc;

/* France, Canada have top 3 total values (Canada holds 2nd and 3rd place) */



/* Which city has the best customers? We would like to throgh a promotional music festival in the city 
   we made the most money. Write a query that returns one city that has highest sum of total invoices.
   Return both the city name and sum of all invoices totals */
select top 1 billing_city, sum(total) as totals
from invoice
group by billing_city
order by totals desc;

/*Prague has the best customers with total of 273 bookings. Here, We would like to throgh a promotional music festival in the city we made the most money */



/* Who is the best customer? The customer who has spent the most money will bw declared the best customer.
   Write a query that returns the person who has spent the most money */
select top 1 t1.customer_id, concat(t1.first_name,' ', t1.last_name) as cust_name, sum(t2.total) as money_spent
from customer t1
join invoice t2
	on t1.customer_id = t2.customer_id
group by t1.customer_id,concat(t1.first_name,' ', t1.last_name)
order by money_spent desc;

/* The best customer is František Wichterlová who spent total money off $145K */



/*  Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */
select t1.email, t1.first_name, t1.last_name, t5.name
from customer t1
join invoice t2 on t1.customer_id = t2.customer_id 
join invoice_line t3 on t2.invoice_id = t3.invoice_id
join track t4 on t3.track_id = t4.track_id
join genre t5 on t4.genre_id = t5.genre_id and t5.name like 'Rock'
group by t1.email, t1.first_name, t1.last_name, t5.name 
order by t1.email asc;



/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 t1.artist_id, t1.name, count(t3.track_id) as total_count
from artist t1
join album t2 on t1.artist_id = t2.artist_id
join track t3 on t2.album_id = t3.album_id
where genre_id in (select genre_id
				   from genre
				   where name like 'Rock')
group by t1.name, t1.artist_id
order by total_count desc;


/* Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_seconds
	                  from track)
order by milliseconds desc; 



/* Find how much amount spent by each customer on artists? 
   write a query to return customer name, artist name, total spent */

with most_selling_price as 
(
	select top 2 t4.artist_id as artist_id, t4.name as artist_name , sum(t1.unit_price * t1.quantity) as price
	from invoice_line t1
	join track t2 on t1.track_id = t2.track_id
	join album t3 on t2.album_id = t3.album_id
	join artist t4 on t3.artist_id = t4.artist_id
	group by t4.artist_id, t4.name
	order by 3 desc
)
select concat(t2.first_name,' ',t2.last_name) as customer_name, bsa.artist_name, bsa.price
from invoice t1
join  customer t2 on t1.customer_id = t2.customer_id
join invoice_line t3 on t1.invoice_id = t3.invoice_id
join track t4 on t3.track_id = t4.track_id
join album t5 on t4.album_id = t5.album_id 
join most_selling_price as bsa on t5.artist_id = bsa.artist_id
group by concat(t2.first_name,' ',t2.last_name),bsa.artist_name, bsa.price
order by bsa.price desc ;


/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with total_music_sales as
(
select count(t1.quantity) as total_sales, t3.country, t5.genre_id, t5.name ,
ROW_NUMBER() over(partition by t3.country order by count(t1.quantity) desc) as row_num
from invoice_line t1
join invoice t2 on t1.invoice_id = t2.invoice_id
join customer t3 on t2.customer_id = t3.customer_id
join track t4 on t1.track_id = t4.track_id
join genre t5 on t4.genre_id = t5.genre_id
group by t3.country, t5.name, t5.genre_id
)
select * from total_music_sales where row_num <= 1;



/*  Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with country_per_customer as
(
	select t2.customer_id, concat(t2.first_name,' ',t2.last_name) as customer, t1.billing_country, sum(t1.total) as total_spent,
	row_number() over(partition by t1.billing_country order by sum(t1.total) desc) as row_num
	from invoice t1
	join customer t2 on t1.customer_id = t2.customer_id
	group by t2.customer_id, concat(t2.first_name,' ',t2.last_name), t1.billing_country
	
)
select * 
from country_per_customer
where row_num <= 1;