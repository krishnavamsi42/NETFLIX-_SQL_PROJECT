-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);




SELECT * FROM Netflix;


SELECT 
     COUNT(*) AS Total_count
FROM Netflix;

/*-- 15 Business Problems & Solutions

1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/



-- 1. Count the number of Movies vs TV Shows
SELECT 
      type,
      count(*) as total_count
FROM netflix
group by 1;





-- 2. Find the most common rating for movies and TV shows
SELECT
     type,
	 rating
FROM	 
(	 
SELECT
     type,
	 rating,
	 count(*) as rating_count,
	 dense_rank() over(partition by type order by count(*) desc) as d_rank
FROM netflix
group by 1,2) AS T1
WHERE d_rank=1






-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
      type
FROM netflix
WHERE release_year=2020 AND type='Movie';






-- 4. Find the top 5 countries with the most content on Netflix
SELECT
     UNNEST(STRING_TO_ARRAY(COUNTRY,',')) AS new_country,
	 count(show_id) as movie_count
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
limit 5;






-- 5. Identify the longest movie
SELECT
      duration
FROM netflix
WHERE TYPE='Movie' 
AND 
duration=(SELECT MAX(duration) FROM netflix)






-- 6. Find content added in the last 5 years

SELECT 
     *
FROM netflix
WHERE TO_DATE(DATE_ADDED ,'MONTH DD, YEAR') >=CURRENT_DATE-INTERVAL '5 YEARS'






-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT type,
       director
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'



-- 8. List all TV shows with more than 5 seasons
SELECT type,
       duration
FROM netflix
WHERE TYPE='TV Show' 
AND
cast(SPLIT_PART(duration,' ',1) as int)> 5;






-- 9. Count the number of content items in each genre
SELECT 
      UNNEST(string_to_array(listed_in,',')) as genre,
	   count(*) as total_content
FROM netflix
GROUP BY 1;






-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
      extract(year from cast(date_added as Date)) as year,
	  count(*) as yearly_content,
	  round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric * 100,2) as avg_content
FROM netflix
WHERE country='India'
group by 1
order by 3 desc
limit 5;







-- 11. List all movies that are documentaries
SELECT 
     type,
	 listed_in
FROM netflix
where type='Movie'
AND
listed_in ILIKE '%documentaries%';






-- 12. Find all content without a director
SELECT 
      TYPE,
      director
FROM netflix
where director is null;






-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
     AND
     release_year > extract(year from current_date-interval '10 years')






-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
      UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	  count(*) as asctors_count
FROM NETFLIX
WHERE country ILIKE '%india'
group by 1
order by 2 desc
limit 10;






/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
WITH NEW_TABLE AS(
SELECT description,
       CASE
	       WHEN description ILIKE '%KILL%' OR
		        description ILIKE '%VIOLANCE%' THEN 'Bad_content'
		        ELSE 'Good_content'
		   END AS category
FROM netflix)

SELECT
    category,
	count(*) as category_count
FROM NEW_TABLE
group by 1;
