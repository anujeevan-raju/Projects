CREATE DATABASE EMPLOYEE_LAYOFFS;
USE EMPLOYEE_LAYOFFS;
SELECT * FROM [dbo].[layoffs_data];


/* CLEANING THE DATA */

/* COPYING THE DATA FROM RAW TABLE TO ANOTHER TABLE */

SELECT * INTO EMP_LAYOFF 
FROM [dbo].[layoffs_data];

SELECT * FROM EMP_LAYOFF;

/* CLEAING THE DATA */

/* Removing the duplicates from the table */

SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY COMPANY, LOCATION_HQ, INDUSTRY, LAID_OFF_COUNT, 
	DATE, SOURCE, FUNDS_RAISED, STAGE, DATE_ADDED, COUNTRY, PERCENTAGE, LIST_OF_EMPLOYEES_LAID_OFF
	ORDER BY COMPANY) AS ROW_NUM
FROM EMP_LAYOFF;


/* CHECKING THE EXISTENCE OF DUPLICATES */

WITH DUPLI_LAYOFF AS
(
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY COMPANY, LOCATION_HQ, INDUSTRY, LAID_OFF_COUNT, 
		DATE, SOURCE, FUNDS_RAISED, STAGE, DATE_ADDED, COUNTRY, PERCENTAGE, LIST_OF_EMPLOYEES_LAID_OFF
		ORDER BY COMPANY) AS ROW_NUM
	FROM EMP_LAYOFF
)
SELECT *
FROM DUPLI_LAYOFF
WHERE ROW_NUM > 1;


/* THERE IS NO DUPLICATES IN THE TABLE */

/* STANDARDIZING THE DATA */
/* REMOVING THE EXTRA SPACES IN THE COLUMNS */
SELECT *
FROM EMP_LAYOFF;

UPDATE EMP_LAYOFF
SET COMPANY = TRIM(COMPANY);

UPDATE EMP_LAYOFF
SET LOCATION_HQ = TRIM(LOCATION_HQ);

UPDATE EMP_LAYOFF
SET INDUSTRY = TRIM(INDUSTRY);

UPDATE EMP_LAYOFF
SET STAGE = TRIM(STAGE);

UPDATE EMP_LAYOFF
SET COUNTRY = TRIM(COUNTRY);

UPDATE EMP_LAYOFF
SET SOURCE = TRIM(SOURCE);

UPDATE EMP_LAYOFF
SET LIST_OF_EMPLOYEES_LAID_OFF = TRIM(LIST_OF_EMPLOYEES_LAID_OFF);

/* REMOVING THE UNWANTED COLUMNS */
SELECT * FROM EMP_LAYOFF;

ALTER TABLE EMP_LAYOFF
DROP COLUMN SOURCE;

ALTER TABLE EMP_LAYOFF
DROP COLUMN LIST_OF_EMPLOYEES_LAID_OFF;

ALTER TABLE EMP_LAYOFF
DROP COLUMN DATE_ADDED;

/* REMOVED SOURCE, LIST_OF_EMPLOYEES_LAID_OFF, AND DATE_ADDED COLUMNS BECAUSE THOSE WERE NOT APPROPRIATE FOR ANALYSIS */


/* REMOVING THE NULL AND BLANK VALUES */

SELECT * FROM EMP_LAYOFF
WHERE  LAID_OFF_COUNT IS NULL AND PERCENTAGE IS NULL;

DELETE 
FROM EMP_LAYOFF
WHERE LAID_OFF_COUNT IS NULL AND PERCENTAGE IS NULL;

/* REMOVED NULL VALUES WHICH IS NOT RELAVENT TO ANALYSIS */

/* EXPLORATORY DATA ANALYSIS */

SELECT MAX(DATE), MIN(DATE)
FROM EMP_LAYOFF;

SELECT SUM(LAID_OFF_COUNT) AS TOTAL_LAYOFF
FROM EMP_LAYOFF;

/* TOTAL 616186 EMPLOYEES WERE LAID_OFF FROM MARCH 2020 TO JUNE 2024 FROM ALLTHE COMPANIES AND THE INDUSTRIES */
/* LAYOFF STARTED IN THE 1ST WAVE OF THE COVID-19 PANDEMIC */

/* TOP 4 COMPANIES WITH HIGHEST AND LOWEST LAID_OFF IN THE COMPANIES */
WITH LAID_OFF AS 
(
SELECT TOP 4 COMPANY, SUM(LAID_OFF_COUNT) AS TOTAL_LAID
FROM EMP_LAYOFF
WHERE LAID_OFF_COUNT IS NOT NULL
GROUP BY COMPANY
ORDER BY 2 DESC
UNION
SELECT TOP 4 COMPANY, SUM(LAID_OFF_COUNT) AS TOTAL_LAID
FROM EMP_LAYOFF
WHERE LAID_OFF_COUNT IS NOT NULL
GROUP BY COMPANY
ORDER BY 2
)
SELECT * 
FROM LAID_OFF
ORDER BY TOTAL_LAID DESC;

/* THE TOP 4 WITH HIGHEST LAID OFF IS FROM AMAZON, META, TESLA, AND MICROSOFT WHICH IS 27840, 21000, 14500, 14058 AND 
   THE TOP 4 WITH LOWEST LAID OFF IS FROM TUTOR MUNDI, SPYCE, FLYTEDESK, AND AVANTAGE ENTERTAINMENT WHICH IS 4, 4, 4, 5 */

/* HOW MANY COMPANIES WENT COMPLETE LAYOFF */

SELECT COUNT(COMPANY)
FROM EMP_LAYOFF
WHERE PERCENTAGE = 1 AND LAID_OFF_COUNT IS NOT NULL;
 
/* PERCENTAGE 1 MEANS 100%, AND  
   TOTAL 66 COMPANIES WENT COMPLETE LAYOFF BECAUSE I THINK MOST OF THEM WERE STARTUPS AND MAY BE DUE TO PANDEMIC */

/* WHICH INDUSTRY GOT HIGHEST LAYOFF HIT */
SELECT INDUSTRY, SUM(LAID_OFF_COUNT) AS TOTAL_LAYOFF
FROM EMP_LAYOFF
GROUP BY INDUSTRY
ORDER BY 2 DESC;

/* INDUSTRIES LIKE RETAIL WITH 70157, CONSUMER WITH 67675, TRANSPORTATION WITH 59417 AND FOOD WITH 45625 ETC.. GOT HISHEST HIT AND 
   AI WITH 262, LEGAL WITH 966, AEROSPACE WITH 1188 AND UNKNOWN WITH 35 GOT THE LOWEST LAYOFF HIT */

/* COUNTRIES WITH HIGHEST LAID OFF */

SELECT COUNTRY, SUM(LAID_OFF_COUNT) AS TOTAL_LAID
FROM EMP_LAYOFF
GROUP BY COUNTRY
ORDER BY 2 DESC;

/* COUNTRIES LIKE UNITED SATATES WITH 414013, INDIA WITH 51234, GERMANY WITH 26353, UNITED KINGDOM 19769 AND 
   NETHERLANDS WITH 18445 GOT HIGHEST LAID OFF AND 
   COUNTRIES LIKELUXEMBOURG WITH 45, UKRAINE WITH 50, BELGIUM WITH 50, THAILAND WITH 55, AND LITHUANIA WITH 60 GOT LOWEST LAID OFF */

/* NOW GO THROUGH WITH THE YEARS */

SELECT YEAR(DATE) AS YEAR, SUM(LAID_OFF_COUNT) AS TOTAL_LAIDOFF
FROM EMP_LAYOFF
GROUP BY YEAR(DATE)
ORDER BY 1;

/* IN THE YEAR 2020 IT WAS 80998, IN 2021 IT WAS 15823, IN 2022 IT WAS 165269, IN 2023 IT WAS 263180, 2024(TILL JUNE) IT WAS 90916 
   HIGHEST LAID OFF WAS IN 2023 AND IN 2024 IT IS SLIGHTLY DOWN BUT STILL LAYOFF IS GOING ON */


SELECT YEAR(DATE) AS YEAR, SUM(LAID_OFF_COUNT) AS TOTAL_LAIDOFF
FROM EMP_LAYOFF
WHERE COUNTRY = 'INDIA'
GROUP BY YEAR(DATE)
ORDER BY 1;

/* IN INDIA IN 2020 LAYOFF WAS 12932, IN 2021 LAYOFF WAS 4080, IN 2022 LAYOFF WAS 14224, IN 2023 LAYOFF WAS 16398, AND 
   IN 2024(TILL JUNE) LAYOFF WAS 3600 */

/* ROLLING DATE LAYOFF */
WITH ROLLING_TOTAL AS 
(
    SELECT 
        FORMAT([DATE], 'yyyy-MM') AS MONTH, 
        SUM(LAID_OFF_COUNT) AS TOTAL_LAID,
        MIN([DATE]) AS MIN_DATE  -- To get the earliest date for each month for ordering
    FROM EMP_LAYOFF
    WHERE [DATE] IS NOT NULL
    GROUP BY FORMAT([DATE], 'yyyy-MM')
)
SELECT 
    MONTH, 
    TOTAL_LAID,  -- No need to SUM(TOTAL_LAID) here since it's already aggregated
    SUM(TOTAL_LAID) OVER (ORDER BY MIN_DATE) AS ROLLING_DATA  -- Cumulative sum
FROM ROLLING_TOTAL
ORDER BY MONTH;


/* RANKING ACCORDING TO THE YEAR */

WITH COMPANY_YEAR (COMPANY, YEARS, LAIDOFF) AS
(
	SELECT COMPANY, YEAR(DATE), SUM(LAID_OFF_COUNT)
	FROM EMP_LAYOFF
	GROUP BY COMPANY, YEAR(DATE)
), COMPANY_YEAR_RANK AS
(
	SELECT *, 
	DENSE_RANK() OVER(PARTITION BY YEARS ORDER BY LAIDOFF DESC) AS RANKING
	FROM COMPANY_YEAR
	WHERE YEARS IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKING <= 5;

/* COMPANY		YEARS		LAIDOFF		RANKING
	Uber		2020		7525		1
	Booking.com	2020		4375		2
	Groupon		2020		2800		3
	Swiggy		2020		2250		4
	Airbnb		2020		1900		5
	Bytedance	2021		3600		1
	Katerra		2021		2434		2
	Zillow		2021		2000		3
	Instacart	2021		1877		4
	WhiteHat Jr	2021		1800		5
	Meta		2022		11000		1
	Amazon		2022		10150		2
	Cisco		2022		4100		3
	Peloton		2022		4084		4
	Philips		2022		4000		5
	Carvana		2022		4000		5
	Amazon		2023		17260		1
	Google		2023		12115		2
	Microsoft	2023		11158		3
	Meta		2023		10000		4
	Ericsson	2023		8500		5
	Tesla		2024		14500		1
	SAP			2024		8000		2
	Dell		2024		6000		3
	Cisco		2024		4250		4
	Toshiba		2024		4000		5 */



