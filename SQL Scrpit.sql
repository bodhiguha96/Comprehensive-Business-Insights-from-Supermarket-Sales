create database project_db;
use project_db;
desc supermarket_sales;

/* Check whether the supermarket_sales dataset has been imported sucessfully or not */
select * from supermarket_sales;

/* Modifying the column names where it contains ' ' for easier code writing. Replacing ' ' with '_' */
alter table supermarket_sales
change `Invoice ID` `Invoice_ID` text;
alter table supermarket_sales
change `Customer type` `Customer_type` text;
alter table supermarket_sales
change `Product line` `Product_line` text;
alter table supermarket_sales
change `gross margin percentage` `gross_margin_percentage` double;
alter table supermarket_sales
change `gross income` `gross_income` double;
alter table supermarket_sales
change `Tax 5%` `Tax_5%` double;
alter table supermarket_sales
change `Unit price` Unit_price double;


/*DATA CLEANING & TRANSFORMATION (ETL)/*
/* Deleting  the gross_margin_percentage column as it is same for every row */
alter table supermarket_sales
drop column gross_margin_percentage;

/* Checking for duplicates and removing if required */
select Invoice_ID, count(Invoice_ID) from supermarket_sales
group by Invoice_ID having count(Invoice_ID) > 1;

/* Checking for different date formats in the dataset */
select
	case
		when date like '_/__/____' then 'M/DD/YYYY'
        when date like '__-__-____' then 'MM/DD/YYYY'
        else 'unknown format'
        end as date_format,
	count(*) as format_count
from supermarket_sales group by date_format;

/* Adding a new column for date as formatted_date which will hold evry date in YYYY-MM-DD format */
alter table supermarket_sales
add column formatted_date date;

/* Updating the formatted_date column */
update supermarket_sales
set formatted_date = 
    case
        when date like '_/__/____' then
            STR_TO_DATE(date, '%m/%d/%Y')
        when date like '__-__-____' then
            STR_TO_DATE(date, '%m-%d-%Y')
        else
            NULL  -- or use a default date if necessary
    end;
    
/* converting categorical value to numeric value for analysis */    
/* Adding a new column as customer_type_code */
alter table supermarket_sales
add customer_type_code int;


/* EXPLORATORY DATA ANALYSIS */
/* Find out total sales revenue by product line */
select product_line, sum(total) from supermarket_sales
group by product_line;

/* Find out the avg rating of products by product line */
select product_line, avg(Rating) from supermarket_sales
group by Product_line;

/* What is the sales distribution across different customer types (Member vs Normal) */
select customer_type, count(*) as num_sales, sum(Total) as total_rev,
(sum(Total)/(select sum(Total) from supermarket_sales) * 100) as pct_total_revenue
from supermarket_sales
group by customer_type;

/* What is the most popular payment method */
with cte_payment as
(
select Payment, count(Payment) as num_transaction,
dense_rank() over(order by count(Payment) desc) as ranking
from supermarket_sales
group by Payment
)
select * from cte_payment where ranking = 1;

/* How does revenue vary by gender and customer type */
select Customer_type, Gender, sum(Total)
from supermarket_sales
group by Customer_type, Gender;

/* What are the top 3 busiest days of the week in terms of total sales */
select dayname(formatted_date) as week_day, sum(Total) as total_rev
from supermarket_sales
group by dayname(formatted_date)
order by sum(Total) desc limit 3;

/* What is the average unit price by product line */
select Product_line, avg(Unit_price) from supermarket_sales
group by Product_line;

/* What is the relationship between quantity sold and total revenue */
select Quantity, sum(Total) as Total_revenue
from supermarket_sales group by Quantity order by Quantity;

/* Find out the total monthly sales amounnt */
select monthname(formatted_date) as month_name, sum(Total) as total_revenue
from supermarket_sales group by month_name;
