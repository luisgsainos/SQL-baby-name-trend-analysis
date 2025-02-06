USE baby_names_db;

SELECT		*
FROM		names;

-- Find the overall most popular girl and boy names 
WITH 		tb AS (SELECT		Gender, Name, sum(Births) as total_births
FROM		names
GROUP BY 	gender, name
)

SELECT		* 
FROM
		(
        SELECT		Gender, Name, total_births, rank() over(partition by gender Order by total_births desc) as birth_rank
		FROM		tb
        ) AS ranked_births
WHERE birth_rank = 1;

-- show how these names have changed in popularity rankings over the years
SELECT		* 
FROM
			(
			WITH 		total_babies AS (
							SELECT		year, name, sum(births) as total_births
							FROM		names
							WHERE		gender = 'M'
							group by	year,name
							)

			Select		year, name, rank() over(partition by year Order by total_births DESC) as popularity
			FROM 		total_babies 
			)	AS		year_popularity
WHERE		name = 'Michael';

-- Find the names with the biggest jumps in popularity from the first year of the data set to the last year (1980-2009)
WITH 	names_1980 AS (
	WITH 	all_names AS 
	(SELECT		year, name, sum(births) as total_births
	FROM		names
	group by	year,name
	) 

	SELECT		year, name, 
				rank() over(partition by year order by total_births DESC) as popularity
	FROM 		all_names
	WHERE		year = 1980
),
names_2009 AS (
	WITH 	all_names AS 
	(SELECT		year, name, sum(births) as total_births
	FROM		names
	group by	year,name
	) 

	SELECT		year, name, 
				rank() over(partition by year order by total_births DESC) as popularity
	FROM 		all_names
	WHERE		year = 2009
)
SELECT 		t1.year, t1.name, t1.popularity, t2.year, t2.name, t2.popularity,
			CAST(t2.popularity AS SIGNED) - CAST(t1.popularity AS SIGNED) AS popularity_gap
FROM		 names_1980 t1
INNER JOIN 	 names_2009 t2 ON  
			t1.name = t2.name
ORDER BY	popularity_gap;


-- For each year, return the 3 most popular girl names and 3 most popular boy names
SELECT *
FROM	(
	WITH 	year_count AS(
			SELECT		gender, year, name, sum(Births) as total_births
			FROM		names
			GROUP BY	gender, year, name
	)

	SELECT	 year,gender, name, total_births,
			rank() over(partition by year,gender order by total_births desc) as popularity
	FROM	year_count
) AS top_names
WHERE popularity <= 3;

-- For each decade, return the 3 most popular girl names and 3 most popular boy names

SELECT *
FROM	(
	WITH 	year_count AS(
			SELECT		CASE WHEN year between 1980 AND 1989 THEN 'Eighties'
							 WHEN year between 1990 AND 1999 THEN 'Nineties'
                             WHEN year between 2000 AND 2009 THEN 'Two_Thousands'
                             END AS decade, 
						gender,  name, sum(Births) as total_births
			FROM		names
			GROUP BY	decade,gender, name
	)

	SELECT	 decade,gender, name, total_births,
			rank() over(partition by decade,gender order by total_births desc) as popularity
	FROM	year_count
) AS top_names
WHERE popularity <= 3;


-- Return the number of babies born in each of the six regions (NOTE: The state of MI should be in the Midwest region)
WITH total_babies AS (
		SELECT		state, gender,name, sum(Births) as total_births
		FROM		names
		GROUP BY	state, gender, name
)

SELECT		r.region,  sum(n.Births) as total_births
FROM		names n left JOIN regions r
ON			n.state = r.state
GROUP BY	r.region
ORDER by  total_births DESC;

SELECT 	* 
FROM 	regions;

			


-- Return the 3 most popular girl names and 3 most popular boy names within each region
