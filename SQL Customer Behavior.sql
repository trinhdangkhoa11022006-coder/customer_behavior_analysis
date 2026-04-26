-- Explore table--
select top 5 * from dbo.customer

-- Male vs Female (revenue)
select gender, sum(purchase_amount) as [revenue]
from dbo.customer
group by gender
-- Customer use discount but still pay above average
select customer_id, purchase_amount
from dbo.customer
where discount_applied = 'Yes' 
    and purchase_amount >= (select avg(purchase_amount) from dbo.customer)
-- Top 5 products with highest avg rating--
select top 5 item_purchased, round(avg(review_rating),2) as avg_rating
from dbo.customer
group by item_purchased
order by avg_rating desc
-- Compare avg purchase amount between Standard and Express Shipping--
select shipping_type, round(avg(purchase_amount),2) as avg_purchase_amount
from dbo.customer
where shipping_type in ('Standard', 'Express')
group by shipping_type
-- Do subcribed customers spend more ? Compare avg spend and total revenue between sub and non-sub--
select subscription_status, sum(purchase_amount) as revenue, avg(purchase_amount) as avg_spend, count(customer_id) as 
[number]
from dbo.customer
group by subscription_status
-- 5 highest purchased product when discount applied--
select top 5 item_purchased, round(100* sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_ratio
from dbo.customer
group by item_purchased
order by discount_ratio desc
--Segment customer based on previous purchase, New, Returning, Loyal--
with customer_type as(
    select customer_id, previous_purchases,
    case 
    when previous_purchases = 1 then 'New'
    when previous_purchases between 2 and 10 then 'Returning'
    else 'Loyal'
    end as customer_segment
from dbo.customer
)
select customer_segment, count (*) as 'Number_of_customer'
from customer_type
group by customer_segment
-- Top 3 purhcased product for each category--
with items_count as (
select category, item_purchased, count(customer_id) as total_orders,
Row_number() over (PARTITION by category order by count(customer_id) desc) as item_rank
from dbo.customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from items_count
where item_rank <=3
-- Are customer repeated buyer (> 5 purhcases) are also subcribe--
select subscription_status, count(customer_id) as repeat_buyers
from dbo.customer
where previous_purchases > 5
group by subscription_status
-- What is the revenue contribution for each age group --
select age_group, sum(purchase_amount) as total_amount
from dbo.customer
group by age_group
order by total_amount desc