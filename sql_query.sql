/* 
 * OSHA Work Related Fatality Records
 * 
 *  
*/

-- Test newly populated database

SELECT count(*) FROM fatalities;

-- Reults:

count|
-----+
15077|

SELECT * FROM fatalities;

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

-- Add a day of the week column.
-- 
 
DROP TABLE IF EXISTS fatalities_cleaned;
CREATE TEMP TABLE fatalities_cleaned AS (
	SELECT
		incident_date,
		to_char(incident_date, 'day') AS day_of_week,
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
   2022-04-22|friday     |smyrna      |tn   | fatally struck by concrete pillar.                       |state  |no      |
   2022-04-15|friday     |provo       |ut   | died in fall from roof.                                  |state  |no      |
   2022-04-14|thursday   |toledo      |oh   | died after becoming caught in machine drive shaft.       |federal|yes     |
   2022-04-10|sunday     |mason city  |ia   | suffered fatal injuries in fall on sidewalk.             |state  |no      |
   2022-04-08|friday     |paton       |ia   | fatally crushed under excavator.                         |state  |yes     |
   2022-04-07|thursday   |spring      |tx   | died in fall from roof.                                  |federal|yes     |
   2022-03-31|thursday   |santa rita  |gu   | died in fall from ladder after contacting energized wire.|federal|yes     |
   2022-03-28|monday     |houston     |tx   | electrocuted by power lines while trimming trees.        |federal|no      |
   2022-03-28|monday     |cicero      |il   | fatally crushed under forklift.                          |federal|yes     |
   2022-03-25|friday     |williamsburg|ia   | fatally engulfed in corn bin.                            |state  |yes     |
   
-- What is the number of reported incidents?
   
SELECT 
	count(*) AS n_fatalities
FROM 
	fatalities_cleaned;

-- Results:

n_fatalities|
------------+
       15077|
        
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
         2009|         518|            0|           0|
         2010|        1120|          518|       116.0|
         2011|        1198|         1120|         7.0|
         2012|        1023|         1198|       -15.0|
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
unknown | 8984|
 	
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
Tuesday    |        2757|     18.29|
Wednesday  |        2735|     18.14|
Monday     |        2655|     17.61|
Thursday   |        2645|     17.54|
Friday     |        2359|     15.65|
Saturday   |        1186|      7.87|
Sunday     |         740|      4.91|

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
                80|
                
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

 	
 	