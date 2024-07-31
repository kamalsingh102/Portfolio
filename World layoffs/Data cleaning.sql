SELECT date 
FROM layoffs;



-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE world_layoffs.layoffs_staging 
LIKE layoffs;

INSERT layoffs_staging 
SELECT * FROM layoffs;

-- Checking for duplicates

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		layoffs_staging;
        

SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
    
    
 SELECT *
FROM layoffs_staging
WHERE company = 'Oda'
;





SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;

with duplicate_cte as
(
	SELECT *, ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM layoffs_staging
        )
        delete from duplicate_cte
        where row_num>1;
        
-- delete duplicates        
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int ,
  row_num int
);



INSERT INTO `layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging;
        
        
 DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

select * from layoffs_staging2
where row_num>2;       

-- standardising data
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;


update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct location
from layoffs_staging2
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'United States'
where country like 'United States%';

select date,
str_to_date(date, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(date, '%m/%d/%Y')
where date like '__/__/____';

select date from layoffs_staging2;


select count(date) from layoffs_staging2
where date is null;

select * from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_staging2
where industry = '' or industry is null;

SELECT *
FROM layoffs_staging2
WHERE company IN ('Airbnb', 'Bally\'s Interactive', 'Carvana', 'Juul');

update layoffs_staging2
set industry = 'Travel'
where company = 'Airbnb';

update layoffs_staging2
set industry = 'Tranportation'
where company = 'Carvana';

select t1.industry, t2.industry from layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

select industry from layoffs_staging2
where company = 'Juul';

select count(row_num)
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

delete from
layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select * from  layoffs_staging2;

-- Remove duplicates
-- Standardise data
-- Remove null/Duplicates
-- remove columns
        
        


 