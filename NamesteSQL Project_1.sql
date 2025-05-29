Use [Credit Card Spending Habits in India Project];

--Project1
/* This dataset contains insights into credit card transactions made in India, offering a comprehensive look at the spending habits of Indians across the nation

City: The city in which the transaction took place. (String)
Date: The date of the transaction. (Date)
Card Type: The type of credit card used for the transaction. (String)
Exp Type: The type of expense associated with the transaction. (String)
Gender: The gender of the cardholder. (String)
Amount: The amount of the transaction. (Number) */



 


##write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends.
--steps to follow:
with city_spend as (
select city, sum(amount) as city_spend
from [dbo].[credit_card_transcations]
group by city
),Total_spend as(
select sum(cast(amount as bigint)) as Total_spend from [dbo].[credit_card_transcations])
select top 5 cs.city, cs.city_spend,round(cs.city_spend*1.0*100/ct.Total_spend,2) as percentage_contribution
from city_spend cs, Total_spend ct
order by cs.city_spend desc


##write a query to print highest spend month and amount spent in that month for each card type
with cte1 as(
select card_type, datepart(month, transaction_date) as month, datepart(year,transaction_date) as year, sum(amount) as month_spend
from [dbo].[credit_card_transcations]
group by card_type, datepart(month,transaction_date), datepart(year,transaction_date)),
rnking as (
select *, dense_rank()over(partition by card_type order by month_spend desc) as rnk
from cte1)
select * from rnking
where rnk=1


##write a query to print the transaction details(all columns from the table) for each card type when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte1 as
(select *, sum(amount) over(partition by card_type order by transaction_date, transaction_id asc) as cumulative_spend from [dbo].[credit_card_transcations])
select * from (select *,dense_rank() over(partition by card_type order by cumulative_spend desc) as rnk from cte1 where cumulative_spend<=1000000)A
where rnk=1


##write a query to find city which had lowest percentage spend for gold card type.
--steps to follow: 1)where- card filtering, group by city, sum(spend), cross join with sum(total sales), % percentage, order by asc, top 1 record
with cte1 as(
select city, sum(amount) as city_amount
from [dbo].[credit_card_transcations]
where card_type='Gold'
group by city)
select top 1 ct.*, (ct.city_amount*1.0*100/cs.total_spend) as percentage_contribution
from cte1 ct,(select cast(sum(amount) as bigint) as total_spend from [dbo].[credit_card_transcations] where card_type='Gold')cs
order by percentage_contribution


##write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
--steps to follow: Expense_type-Highest/lowest decided by amount spend
--group by exp_type, city, sum(amount)
--, rank() partition by exp_type, city order by amount_spend desc
--case when rank=1 then exp_type
with cte1 as (
select city,exp_type, sum(amount) as total_spend from [dbo].[credit_card_transcations]
group by city, exp_type), ranking as 
(select *, dense_rank() over(partition by city order by total_spend desc) as highest_spend,dense_rank() over(partition by city order by total_spend asc) as lowest_spend  from cte1)
select city, max(case when highest_spend=1 then exp_type end )as highest_expense_type, max(case when lowest_spend=1 then exp_type end) as lowest_expense_type
from ranking
group by city


## write a query to find percentage contribution of spends by females for each expense type
with cte1 as
(select exp_type, sum(amount) as exp_type_amount
from [dbo].[credit_card_transcations]
where gender='F'
group by exp_type)
select ct.exp_type, ct.exp_type_amount*1.0*100/cs.Total_spend  as Percentage_contribution 
from (select exp_type, sum(cast(amount as bigint)) as Total_spend from [dbo].[credit_card_transcations] group by exp_type) cs
inner join cte1 ct
on ct.exp_type=cs.exp_type


select exp_type, sum(case when gender='F' then amount end)*1.0*100/sum(cast(amount as bigint)) as percentage_contribution_female
from [dbo].[credit_card_transcations]
group by exp_type
order by percentage_contribution_female desc

---Per expe_type ante female_contribution/per expe_type total contribution




##which card and expense type combination saw highest month over month growth in Jan-2014.
--steps to follow:
with cte1 as(
select card_type, exp_type, format(cast(transaction_date as date), 'yyyy-MM') as Transacation_monthYear, sum(amount) as Actual_spend
from [dbo].[credit_card_transcations]
where datepart(year,CAST(transaction_date AS DATE)) = 2014
group by card_type, exp_type, format(cast(transaction_date as date), 'yyyy-MM'))
select card_type, exp_type, Transacation_monthYear,Actual_spend, previous_month_spend, (Actual_spend-previous_month_spend) as MOM_growth
from (select *, lag( Actual_spend) over(partition by card_type, exp_type order by Transacation_monthYear) as previous_month_spend from cte1)A


select * from [dbo].[credit_card_transcations]


##during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city, sum(amount)*1.0/count(transaction_id) as total_spend_total_no_of_transcations_ratio from [dbo].[credit_card_transcations]
where datename(weekday,cast(transaction_date as date)) in ('Saturday', 'Sunday')
group by city
order by total_spend_total_no_of_transcations_ratio desc 

----datename(weekday, date)--[mon,....sat, sun]
---datepart(weekday,date)--[1,2....7]


##select * from [dbo].[credit_card_transcations]
--which city took least number of days to reach its 500th transaction after the first transaction in that city
--steps to follow:
with cte1 as(select *, dense_rank() over(partition by city order by transaction_date, transaction_id) as rnk from [dbo].[credit_card_transcations])
select city, datediff(day,min(transaction_date), max(transaction_date)) as day_diff from cte1
where rnk=1 or rnk=500
group by city
having count(1)=2
order by day_diff asc









