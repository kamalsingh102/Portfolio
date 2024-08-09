-- EDA
-- selecting maximum layoffs
select * from clean_data;
select max(total_laid_off), max(percentage_laid_off)
from clean_data;

--comapnies which laidoff their whole staff
select *
from clean_data
where percentage_laid_off = 1
order by total_laid_off desc;

select *
from clean_data
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- total laid off employees per company
select company, sum(total_laid_off)
from clean_data
group by company
order by 2 desc;

--total laid off employees industry wise
select industry, sum(total_laid_off)
from clean_data
group by industry
order by 2 desc;

--total laid off employees country wise
select country, sum(total_laid_off)
from clean_data
group by country
order by 2 desc;

--employees laid off vs stages of investment
select stage, sum(total_laid_off)
from clean_data
group by stage
order by 2 desc;

--total laid off employees
 select sum(total_laid_off) from clean_data;

--changing data type of total_laid_off column
alter table clean_data
modify total_laid_off int;


select max(total_laid_off)
from clean_data;

--changing data type of date
alter table clean_data 
modify dates date;


--employees laid off each year
select year(dates), sum(total_laid_off)
from clean_data
group by year(dates)
order by 1 desc;

--employees laid off per month
select substring(dates, 1, 7) as month, sum(total_laid_off)
from clean_data
where substring(dates, 1, 7) is not null
group by month
order by 1;

--rolling total of employees laid off each month
with Rolling_Total as
(select substring(dates, 1, 7) as month, sum(total_laid_off) as total_off
from clean_data
where substring(dates, 1, 7) is not null
group by month
order by 1)
select month, total_off, sum(total_off) over(order by month) as rolling_total
from Rolling_Total;

-- laid off employees by each company each year
select company, year(dates), sum(total_laid_off)
from clean_data
group by company, year(dates)
order by 1 desc; 

--top 5 companies laying off max employees each year
with company_year(company, years, total_laid_off) as
(
select company, year(dates), sum(total_laid_off)
from clean_data
group by company, year(dates)
), company_year_rank as
(select *,
 dense_rank() over (partition by years order by total_laid_off desc) as ranking
 from company_year
 where years is not null)
select * from company_year_rank
where ranking<=5;

select company, (total_laid_off/percentage_laid_off)
from clean_data
where total_laid_off is not null and percentage_laid_off is not null
order by 2 desc;


--total staff of company not given hence creating a column showing company's staff using total_laid_off and percentage_laid_off columns
alter table clean_data
add column company_staff int;

select * from
clean_data;


UPDATE clean_data
SET company_staff = (total_laid_off / percentage_laid_off)
WHERE total_laid_off IS NOT NULL 
  AND percentage_laid_off IS NOT NULL 
  AND percentage_laid_off != 0;
  
  select * from clean_data
  order by company_staff desc;
  
  




