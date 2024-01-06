--Having a first look at the table

SELECT * FROM dbo.[Video Games Sales]


--Find Which Gaming Platform has the most Units SOLD Worldwide// PS2 leading the way with Wii and XBOX360 after

SELECT "Platform",ROUND(SUM("Global"),0) AS Total_Units_Sold_in_MIL
FROM dbo.[Video Games Sales]
GROUP BY "Platform"
ORDER BY "Total_Units_Sold_in_MIL" DESC


--What are the % portions of each continent? NA is leading with 51% of the market, following with europe at 28%

SELECT 	ROUND(SUM("North_America")/ SUM("Global") * 100 ,0) AS "% OF TOTAL NA",
		ROUND(SUM("Europe")/ SUM("Global") * 100 ,0) AS "% OF TOTAL EUROPE",
		ROUND(SUM("Japan")/ SUM("Global") * 100 ,0) AS "% OF TOTAL Japan",
		ROUND(SUM("Rest_of_world")/ SUM("Global") * 100 ,0) AS "% OF TOTAL REST OF WORLD"
FROM dbo.[Video Games Sales]

--Which publisher made the most sales? // 1. Nintendo, 2. EA, 3. Sony//

SELECT "Publisher", ROUND(SUM("Global"),0) AS "SUM OF SALES IN MIL"
FROM dbo.[Video Games Sales]
GROUP BY "Publisher"
ORDER BY "SUM OF SALES IN MIL" DESC


--YoY growth of Ninento, the publisher with the most Sales

select Publisher , "Year", ROUND(sum(Global),0) AS TOTAL_SALES_IN_MIL,
  format(((sum(Global)/convert(float,lag(sum(Global)) over( partition by Publisher order by Publisher,year("Year"))))-1),'p') AS "% of YOY"
from dbo.[Video Games Sales]
WHERE  Publisher ='Nintendo' AND "Year" IS NOT NULL
GROUP by Publisher , Year
Order BY Year

--Does review have any connection to Sales? Yes it does- 40% of games below 10MIL Sales are <80 Review, 819 titles/1907, only 5 games out of 1907 are above 10MIL Sales but below 80 Review// Well selling games usually have good reviews, 40% of <10MIL Sales games have bad reviews
--Still 60% of bad selling games have good reviews// While they do have a connection its not a indicator 

--Below looking at top 10 best selling ames, most of them(8/10 have >80 review)
SELECT TOP 10 "Game_Title", ROUND("Global",0) AS "GLOBAL SALES",ROUND("Review",0) AS "REVIEW"
FROM dbo.[Video Games Sales]
ORDER BY "Global" DESC

--Below looking at Sales Over 10 MIL with Bad reviews//Only 5 of them
SELECT  "Game_Title", ROUND("Global",0) AS "GLOBAL SALES",ROUND("Review",0) AS "REVIEW"
FROM dbo.[Video Games Sales]
WHERE "Global" > 10 AND "Review" <80
ORDER BY "Global" DESC

--Which year was the most profitable for each platform? 


SELECT TOP 1 WITH ties
    "Platform","YEAR","Global" AS "GLOBAL SALES IN MIL"
FROM
    dbo.[Video Games Sales]
ORDER BY 
    CASE 
        WHEN row_number() OVER(PARTITION BY "Platform" ORDER BY "Global" DESC) <= 1
        THEN 0 
        ELSE 1 
    END

---Which genre stays the most sold every year? Trends? % of total?// Last 2 years 2011,2012 shooter is winning but overall Platform is the winner with 8 year of highest sales but its in the span of 1985-1996


SELECT  TOP 1 WITH ties
    "Genre","YEAR","Global" AS "GLOBAL SALES IN MIL",
CASE WHEN "Genre"='Platform' THEN 1  END AS "Platform",
CASE WHEN "Genre" = 'Adventure' THEN 1  END AS "Adventure",
CASE WHEN "Genre" = 'Sports' THEN 1  END AS "Sports",
CASE WHEN "Genre" = 'Shooter' THEN 1 END AS "Shooter",
CASE WHEN "Genre" = 'Puzzle' THEN 1 END AS "Puzzle",
CASE WHEN "Genre" = 'Racing' THEN 1 END AS "Racing",
CASE WHEN "Genre" = 'Role-Playing' THEN 1 END AS "Role-Playing",
CASE WHEN "Genre" = 'Simulation' THEN 1 END AS "Simulation",
CASE WHEN "Genre" = 'Action' THEN 1 END AS "Action",
CASE WHEN "Genre" = 'Misc' THEN 1 END AS "Misc",
CASE WHEN "Genre" = 'Shooter' THEN 1 END AS "Shooter"
FROM
    dbo.[Video Games Sales]
WHERE "YEAR" IS NOT NULL
GROUP BY "Global", "Genre" , "Year", "Platform"
ORDER BY 
    CASE 
        WHEN row_number() OVER(PARTITION BY "Year" ORDER BY "Global" DESC) <= 1
        THEN 0 
        ELSE 1 
    END

--What %^does Genre have ALL TIME between years 1983-2012

SELECT CASE WHEN "Genre" IS NULL THEN 'TOTAL' ELSE "Genre" END AS "Genre", ROUND((SUM("Global")/4746) *100,0) AS "% OF GLOBAL SALES"
FROM dbo.[Video Games Sales]
GROUP BY ROLLUP("Genre")
ORDER BY 2 DESC

--What Genre is the most Sold in every region? 

SELECT TOP 1 WITH ties
    "Genre",ROUND("North_America",0) AS "North_America",ROUND("Europe",0) AS "EUROPE", ROUND("Japan",0) AS "JAPAN", ROUND("Rest_of_World",0) AS "ROW"
FROM
    dbo.[Video Games Sales]
ORDER BY 
    CASE 
        WHEN row_number() OVER(PARTITION BY "Genre" ORDER BY "Europe" DESC) <= 1
        THEN 0 
        ELSE 1 
    END

--What portion of the market is Rest of the World vs Global regions on top sellers? Is it negligible? 

SELECT 	TOP 10 "Game_Title",
		ROUND(SUM("Japan")/ SUM("Global") * 100 ,0) AS "% OF TOTAL Japan",
		ROUND(SUM("Rest_of_world")/ SUM("Global") * 100 ,0) AS "% OF TOTAL REST OF WORLD"
FROM dbo.[Video Games Sales]
GROUP BY "Game_Title", "Global"
ORDER BY "Global" DESC


--YoY growth of every region, which has the most future?// CTE  - NA is the one which has the most future, even though years 2011 and 2012 have been rough

with c_yearly_sales as
(
 select 
  "Year",
  sum(VGS.North_America) as "Total_NA_SALES",
  sum(VGS.Europe) as "Total_EUROPE_SALES",
  sum(VGS.Japan) as "Total_JAPAN_SALES",
  sum(VGS.Rest_of_World) as "Total_ROW_SALES"
 from dbo.[Video Games Sales] VGS
 group by "Year"
),
c_prev_year as
(
 select
  c."Year",
  c."Total_NA_SALES",
  c."Total_EUROPE_SALES",
  c."Total_JAPAN_SALES",
  c."Total_ROW_SALES",
  lag(c.Total_NA_SALES,1,c.Total_NA_SALES)over(order by "Year" )as LAST_YEAR_SALES_NA,
  lag(c.Total_EUROPE_SALES,1,c.Total_EUROPE_SALES)over(order by "Year" )as LAST_YEAR_SALES_EUROPE,
  lag(c.Total_JAPAN_SALES,1,c.Total_JAPAN_SALES)over(order by "Year" )as LAST_YEAR_SALES_JAPAN,
  lag(c.Total_ROW_SALES,1,c.Total_ROW_SALES)over(order by "Year" )as LAST_YEAR_SALES_ROW
 from c_yearly_sales c
)
select "Year",
	(cp."Total_NA_SALES" - cp."LAST_YEAR_SALES_NA") / cp.LAST_YEAR_SALES_NA * 100  AS YOY_NA,
	(cp."Total_EUROPE_SALES" - cp."LAST_YEAR_SALES_EUROPE") / cp.LAST_YEAR_SALES_EUROPE * 100  AS YOY_EUROPE,
	(cp."Total_JAPAN_SALES" - cp."LAST_YEAR_SALES_JAPAN") / cp.LAST_YEAR_SALES_JAPAN * 100  AS YOY_JAPAN,
	(cp."Total_ROW_SALES" - cp."LAST_YEAR_SALES_ROW") / cp.LAST_YEAR_SALES_ROW * 100  AS YOY_ROW
from c_prev_year cp
WHERE "Year" IS NOT NULL AND "Year" > 1984













