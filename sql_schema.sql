
/*
	Create new table and import csv file
 */
DROP TABLE IF EXISTS fatalies;

CREATE TABLE fatalities (
	incident_date date,
	city varchar(50),
	state varchar(20),
	description varchar(250),
	plan varchar(10),
	citation varchar(10)
);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\osha_fatalities_2017_2022_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy12_federal-state_summaries_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy13_federal-state_summaries_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy14_federal-state_summaries_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy15_federal-state_summaries_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy16_federal-state_summaries_cleaned.csv'
with (format csv, header);

COPY fatalities
FROM 'C:\Users\Jaime\Desktop\DataSets\OSHA Fatalities\cleaned\fy17_federal-state_summaries cleaned.csv'
with (format csv, header);

-- Test newly populated database

SELECT count(*) FROM fatalities;

-- Reults:

count|
-----+
12555|

SELECT * FROM fatalities LIMIT 10;

-- Results:

incident_date|city        |state|description                                                                 |plan   |citation|
-------------+------------+-----+----------------------------------------------------------------------------+-------+--------+
   2022-04-22|Smyrna      |TN   |Phongphet Mingsisouphanh (58) fatally struck by concrete pillar.            |State  |No      |
   2022-04-15|Provo       |UT   |Aldiar Bruno (30) died in fall from roof.                                   |State  |No      |
   2022-04-14|Toledo      |OH   |Shaun Baker (42) died after becoming caught in machine drive shaft.         |Federal|Yes     |
   2022-04-10|Mason City  |IA   |Salena Williams (62) suffered fatal injuries in fall on sidewalk.           |State  |No      |
   2022-04-08|Paton       |IA   |Kevin Cummings (57) fatally crushed under excavator.                        |State  |Yes     |
   2022-04-07|Spring      |TX   |Miqueas Misael Miranda Perez (33) died in fall from roof.                   |Federal|Yes     |
   2022-03-31|Santa Rita  |GU   |Hart Lacanilo (58) died in fall from ladder after contacting energized wire.|Federal|Yes     |
   2022-03-28|Cicero      |IL   |Elias Avila-Romero (37) fatally crushed under forklift.                     |Federal|Yes     |
   2022-03-28|Houston     |TX   |Margarito Ladezma (50) electrocuted by power lines while trimming trees.    |Federal|No      |
   2022-03-25|Williamsburg|IA   |Robert Chittick (63) fatally engulfed in corn bin.                          |State  |Yes     |

-- Create a new temp table with 'cleaned' and formatted data   
 
DROP TABLE IF EXISTS fatalities_cleaned
CREATE TEMP TABLE fatalities_cleaned AS (
	SELECT
		incident_date,
		to_char(incident_date, 'Day') AS day_of_week,
		lower(city) AS city,
		lower(state) AS state,
		CASE
			WHEN description LIKE '%(__)%' THEN split_part(description, ')', 2)
			ELSE description
		END AS description,
		CASE
			WHEN lower(plan) = 'state plan' OR lower(plan) = 'state' THEN 'state'
			WHEN lower(plan) = 'federal' THEN 'federal'
			ELSE 'unknown'
		END AS plan,
		lower(citation) AS citation
	FROM
	 	fatalities
);
 	
SELECT * FROM fatalities_cleaned ORDER BY incident_date DESC LIMIT 10;
 	
-- Results:

incident_date|day_of_week|city        |state|description                                               |plan   |citation|
-------------+-----------+------------+-----+----------------------------------------------------------+-------+--------+
   2022-04-22|Friday     |smyrna      |tn   | fatally struck by concrete pillar.                       |federal|no      |
   2022-04-15|Friday     |provo       |ut   | died in fall from roof.                                  |federal|no      |
   2022-04-14|Thursday   |toledo      |oh   | died after becoming caught in machine drive shaft.       |federal|yes     |
   2022-04-10|Sunday     |mason city  |ia   | suffered fatal injuries in fall on sidewalk.             |federal|no      |
   2022-04-08|Friday     |paton       |ia   | fatally crushed under excavator.                         |federal|yes     |
   2022-04-07|Thursday   |spring      |tx   | died in fall from roof.                                  |federal|yes     |
   2022-03-31|Thursday   |santa rita  |gu   | died in fall from ladder after contacting energized wire.|federal|yes     |
   2022-03-28|Monday     |cicero      |il   | fatally crushed under forklift.                          |federal|yes     |
   2022-03-28|Monday     |houston     |tx   | electrocuted by power lines while trimming trees.        |federal|no      |
   2022-03-25|Friday     |williamsburg|ia   | fatally engulfed in corn bin.                            |federal|yes     |
   
-- What is the number of reported incidents?
   
SELECT 
	count(*) AS n_fatalities
FROM 
	fatalities_cleaned;

-- Results:

n_fatalities|
------------+
       12555|
        
-- What is the year to year change for the number of fatal incidents?
        
WITH get_yearly_fatalities AS (
	SELECT 
		date_part('year', incident_date)::int AS incident_year,
		count(*) AS n_fatalities
	FROM 
		fatalities_cleaned
	GROUP BY 
		incident_year
	ORDER BY incident_year
)

SELECT
	incident_year,
	n_fatalities,
	lag(n_fatalities) OVER () AS previous_year,
	round(((n_fatalities::float / lag(n_fatalities) OVER ()::float) - 1) * 100) AS year_to_year
FROM get_yearly_fatalities
WHERE incident_year <> '2022';

-- Results:

incident_year|n_fatalities|previous_year|year_to_year|
-------------+------------+-------------+------------+
         2011|         314|            1|     31300.0|
         2012|        1023|          314|       226.0|
         2013|        1203|         1023|        18.0|
         2014|        1359|         1203|        13.0|
         2015|        1156|         1359|       -15.0|
         2016|        1113|         1156|        -4.0|
         2017|        1554|         1113|        40.0|
         2018|        1273|         1554|       -18.0|
         2019|        1392|         1273|         9.0|
         2020|        1134|         1392|       -19.0|
         2021|         960|         1134|       -15.0|
         
-- What is the number of fatalities that received a citation?
         
SELECT
	citation,
	count(*)
FROM
	fatalities_cleaned
GROUP BY 
	citation;

-- Results:

citation|count|
--------+-----+
yes     | 3363|
no      | 2730|
unknown | 6462|
 	
-- What day of the week has the most fatalities and what is the overall percentage?

SELECT
	day_of_week,
	n_fatalities,
	round(n_fatalities / sum(sum(n_fatalities)) OVER () * 100, 2) AS percentage
from
	(SELECT
		day_of_week,
		count(*) AS n_fatalities
	FROM 
		fatalities_cleaned
	GROUP BY 
		day_of_week) AS tmp
GROUP BY
	day_of_week,
	n_fatalities
ORDER BY 
	n_fatalities desc;

-- Results:

day_of_week|n_fatalities|percentage|
-----------+------------+----------+
Tuesday    |        2296|     18.29|
Wednesday  |        2257|     17.98|
Thursday   |        2221|     17.69|
Monday     |        2217|     17.66|
Friday     |        1973|     15.71|
Saturday   |         979|      7.80|
Sunday     |         612|      4.87|

-- What is the number of fatalities involving welding?

SELECT
	count(*) AS welding_fatalities
FROM
	fatalities_cleaned
WHERE
	description ILIKE '%weld%'

-- Results:

welding_fatalities|
------------------+
                41|
                
-- Select the last 5 from the previous query
                
SELECT
	*
FROM
	fatalities_cleaned
WHERE
	description ILIKE '%weld%'
ORDER BY 
	incident_date DESC
LIMIT 5;

-- Results:

incident_date|day_of_week|city     |state|description                                            |plan   |citation|
-------------+-----------+---------+-----+-------------------------------------------------------+-------+--------+
   2021-04-14|Wednesday  |cleveland|oh   |Worker electrocuted by portable welding machine.       |federal|yes     |
   2021-01-30|Saturday   |mission  |tx   |Worker died in welding explosion.                      |federal|yes     |
   2020-12-10|Thursday   |urbana   |oh   |Worker fatally crushed by seam welder.                 |federal|yes     |
   2020-05-24|Sunday     |dallas   |tx   |Worker electrocted while welding HVAC pipe.            |federal|no      |
   2019-07-08|Monday     |kingwood |tx   |Worker electrocuted while welding air conditioner unit.|federal|no      |

 	
 	