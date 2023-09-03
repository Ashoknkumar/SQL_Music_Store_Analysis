/* Question set 1 -Easy */


/*Q1: Who is the senior most employee based on job title ? */

select * 
from  employee
order by levels desc 
limit 1;

/* Q2: Which countries have the most invoices ? */


select count(*) as c ,billing_country 
from invoice
group by billing_country 
order by c desc 
limit 1 ;

/* Q3: What are the top 3 values of total  invoice ? */

 select total  
 from invoice
 order by total desc 
 limit 3;
 
 /* Q4: Which city has the best customer ? We would like to throw a promotional music festival in the city we made the most money.Write a query that returns one city that has the highest sum of invoice totals.Return both the city name and sum of all invoice totals */ 
 
 
 select billing_city , sum(total)as invoice_total
 from invoice 
 group by billing_city 
 order by invoice_total  desc
 limit 1;
 
 
 /* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money */


select final_table.first_name,final_table.last_name,final_table.s
 from (select *,dense_rank() over(order by t.s desc) as d from (select c.first_name,c.last_name,sum(i.total) s 
 from customer c 
 inner join invoice i
 on c.customer_id=i.customer_id 
 group by 1,2) as t)
 as final_table
 where final_table.d=1;

/* Question set-2 */


/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.*/
/* Method 1 */



SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

/*Method 2 */


SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q2: Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands */


select dence_final.name,dence_final.co from (select *, dense_rank() over(order by main_t.co desc) d from(select a.name,count(*) co  from artist a inner join album al on al.artist_id=a.artist_id
inner join track t on t.album_id= al.album_id 
where al.album_id in(
select t.album_id from track t inner join genre g on g.genre_id=t.genre_id where g.name="Rock") group by 1) main_t) dence_final where dence_final.d<=10


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


select name,milliseconds 
from track 
where milliseconds > (select avg(milliseconds) average from track )
order by 2 desc;

select * 
from  (select  name,milliseconds ,avg(milliseconds) over() average from track) as t 
where milliseconds>t.average
order by milliseconds desc;


/* Questionn set - 3 Advance  */


/*Q1:Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/*Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist*/


with best_selling_artist as (
select artist.artist_id as artist_id ,artist.name as artist_name,sum(invoiceline.unit_price*invoiceline.quantity) as total_sales from invoiceline 
join track on invoiceline.track_id= track.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id= album.artist_id group by 1,2 order by 3 desc)


select c.customer_id,c.first_name,c.last_name, bsa.artist_name,sum(l.unit_price*l.quantity) as total_spent from customer c inner join invoice i on c.customer_id= i.customer_id
inner join invoiceline l on l.invoice_id= i.invoice_id inner join 
track t on t.track_id = l.track_id inner join album al on al.album_id=t.album_id inner join best_selling_artist  bsa on bsa.artist_id=al.artist_id group by 1,2,3,4 order by 5 desc



/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.*/



select ttt.country,ttt.name,ttt.co from (select *,rank() over(partition by country order by co desc) as r from 
(select c.country,g.name,count(l.quantity) as co from customer c inner join invoice i on c.customer_id= i.customer_id 
inner join invoiceline l on i.invoice_id= l.invoice_id inner join track t on l.track_id=t.track_id inner join 
genre g on g.genre_id= t.genre_id group by 1,2) as tt) as ttt where ttt.r=1 order by co desc; 



WITH popular_genre AS 
(
    SELECT COUNT(invoiceline.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoiceline.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoiceline.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
into outfile '/temp/Music_Store.Sql query .txt';




