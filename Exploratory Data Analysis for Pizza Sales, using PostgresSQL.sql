create table Order_details (Order_detail_id int primary key,
							Order_id int,
							Pizza_id varchar,
							Quantity int,
							foreign key(Order_id) references Orders(Order_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

create table Orders (Order_id Int primary key,
					 Date Date,
					 Time Time
);

create table Pizza_types (Pizza_type_id varchar primary key,
						  Name varchar(90),
						  Category varchar(20),
						  Ingredients text
);

create table Pizzas (Pizza_id varchar primary key,
					 Pizza_type_id varchar,
					 Size char(3),
					 Price float,
					 foreign key(Pizza_type_id) references Pizza_types(Pizza_type_id) ON DELETE NO ACTION ON UPDATE NO ACTION
					);
					


drop table Pizza_types cascade;
drop table Pizzas cascade;
drop table Order_details cascade;

select * From Pizzas;

/* Create a temporary table that combines the data in 
Pizzas and Pizza_types tables together */			
create view "Pizza table" as (select Pizza_id, PT.Pizza_type_id, Name,
						    Category, Size, Price, Ingredients 
							from Pizzas PI
							join Pizza_types PT
							on PI.Pizza_type_id = PT.Pizza_type_id);


select * From 
"Pizza table";
Drop view "Pizza table";							
							
												
/* Create a temporary table that combines the data in 
Orders and Order_details tables together */								
create view "Order table" as (select O.Order_id, Order_detail_id, 
							Pizza_id, Quantity, Date, Time
						   from Orders O
							 join Order_details Od
							 on Od.Order_id = O.Order_id);					

select * From 
"Order table";
Drop view "Order table";	


-- Quantity by order
select order_id, count(Order_detail_id) "No. of Order details",
count(Quantity) Quantity
from "Order table"
group by order_id
Order by Quantity desc;


/* Create a temporary table that combines the data in 
"Order table" and "Pizza table" together */	
create view "Sale table" as (select Order_id, Order_detail_id, 
	                         Quantity, Date, Time,  PT.Pizza_id, 
							 Pizza_type_id, Name, Category,
						     Size, Price, (Price*Quantity) Sales, Ingredients 
						     from "Order table" OT
							 join "Pizza table" PT
							 on OT.Pizza_id = PT.Pizza_id);
		
Drop view "Sale table";
select * From 
"Sale table";


--sales by Category
select category, round(sum(sales)) "Total sales $"
From "Sale table"
group by category
Order by 2 desc;

--Quantity by Category
select category, sum(Quantity) "Total Quantity"
From "Sale table"
group by category
Order by "Total Quantity" desc;


--avg price by Category
select category, round(avg(price)) "Avg price $"
From "Sale table"
group by category;


--Price, Orders, Quantity and Sales by Pizza_type_id
select Pizza_type_id, round(avg(price)) "Avg price $", count((order_id)) "Total orders",
sum(Quantity) "Total Quantity", round(sum(sales)) "Total sales $"
From "Sale table"
group by Pizza_type_id
Order by 4 desc;


--Price, Orders, Quantity and Sales by Pizza_id
select Pizza_id, round(avg(price)) "Avg price $", count((order_id)) "Total orders",
sum(Quantity) "Total Quantity", round(sum(sales)) "Total sales $"
From "Sale table"
group by Pizza_id
Order by 5 desc;


--Price, Orders, Quantity and Sales by Size
select Size, round(avg(price)) "Avg price $", count((order_id)) "Total orders",
sum(Quantity) "Total Quantity", round(sum(sales)) "Total sales $"
From "Sale table"
group by Size
Order by 4 desc;


--Top 10 Pizza with the Highest Revenue 
select Pizza_id, sum(sales) sales
	  from "Sale table"
	  group by Pizza_id
	  order by sales desc
	  limit 10;
	  

--Pizza with the Highest Revenue for each Size
select Pizza_id, Size, sales, row_number() over (partition by Size order by sales 
												 desc) as rank 
From (select Pizza_id, Size, sum(sales) sales
	  from "Sale table"
	  group by Pizza_id, Size) T;
	  
	  
--Top 3 Pizza with the Highest Revenue for each Size
With Highest_Revenue as (select Pizza_id, Size, sales, row_number() over (partition by Size order by sales 
												 desc) as rank 
From (select Pizza_id, Size, sum(sales) sales
	  from "Sale table"
	  group by Pizza_id, Size) T)  
select Pizza_id, Size, sales
From Highest_Revenue
where rank < 4;


--Pizza type with the Highest Revenue for each Size
select Pizza_type_id, Size, sales, row_number() over (partition by Size order by sales 
												 desc) as rank 
From (select Pizza_type_id, Size, sum(sales) sales
	  from "Sale table"
	  group by Pizza_type_id, Size) T;
	  
--The hottest Month
select date_part('month', date) "Month_index" , to_char(date, 'Mon') "Month",  
count(distinct (order_id)) Orders
from "Sale table"
group by 1, 2
order by 3 desc;

--The hottest hour
select to_char(time, 'HH24') "Hour of the day", count(distinct (order_id)) Orders
from "Sale table"
group by 1
order by 2 desc;

select extract (hour from time) "Hour of the day" , count(distinct (order_id)) Orders
from "Sale table"
group by 1;

 
