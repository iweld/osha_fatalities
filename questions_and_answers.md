# OSHA Work Related Fatality Records
## Questions and Answers
#### by jaime.m.shaker@gmail.com


#### Test newly populated database
##### Limit the results to the first 10 entries.

````sql
SELECT *
FROM fatalities
ORDER BY incident_date DESC
LIMIT 10;
````

**Results:**

incident_date|city        |state|description                                                                 |plan   |citation|id  |
-------------|------------|-----|----------------------------------------------------------------------------|-------|--------|----|
   2022-04-22|Smyrna      |TN   |Phongphet Mingsisouphanh (58) fatally struck by concrete pillar.            |State  |No      |8981|
   2022-04-15|Provo       |UT   |Aldiar Bruno (30) died in fall from roof.                                   |State  |No      |8982|
   2022-04-14|Toledo      |OH   |Shaun Baker (42) died after becoming caught in machine drive shaft.         |Federal|Yes     |8983|
   2022-04-10|Mason City  |IA   |Salena Williams (62) suffered fatal injuries in fall on sidewalk.           |State  |No      |8984|
   2022-04-08|Paton       |IA   |Kevin Cummings (57) fatally crushed under excavator.                        |State  |Yes     |8985|
   2022-04-07|Spring      |TX   |Miqueas Misael Miranda Perez (33) died in fall from roof.                   |Federal|Yes     |8986|
   2022-03-31|Santa Rita  |GU   |Hart Lacanilo (58) died in fall from ladder after contacting energized wire.|Federal|Yes     |8987|
   2022-03-28|Houston     |TX   |Margarito Ladezma (50) electrocuted by power lines while trimming trees.    |Federal|No      |8989|
   2022-03-28|Cicero      |IL   |Elias Avila-Romero (37) fatally crushed under forklift.                     |Federal|Yes     |8988|
   2022-03-25|Williamsburg|IA   |Robert Chittick (63) fatally engulfed in corn bin.                          |State  |Yes     |8990|

#### The OSHA reported data contains duplicates. Lets remove all duplicate entries.

````sql
DELETE  	
FROM fatalities AS f1
USING fatalities AS f2
WHERE
	f1.incident_date = f2.incident_date
AND 
	f1.state = f2.state
AND
	f1.city = f2.city
AND 
	f1.id < f2.id;
````

##### Check for duplicate entries

````sql
SELECT
	incident_date,
	city,
	state,
	count(*)
FROM 
	fatalities
GROUP BY 
	incident_date,
	city,
	state
HAVING count(*) > 1;
````

**Results:**

incident_date|city|state|count|
-------------|----|-----|-----|

#### Create a new temp table with 'cleaned' and formatted data
##### Lets restructure the table:
* Add a day of the week column.
* Convert columns to lowercase.
* Remove victim names and age (Victims age would be useful but incomplete for the majority of the archives).
* Fix plan columm for consistency.

````sql
DROP TABLE IF EXISTS fatalities_cleaned;
CREATE TEMP TABLE fatalities_cleaned AS (
	SELECT
		id,
		incident_date,
		to_char(incident_date, 'day') AS day_of_week,
		lower(city) AS city,
		CASE 
			WHEN state ILIKE 'AK%' THEN 'alaska'
			WHEN state ILIKE 'AL%' THEN 'alabama'
			WHEN state ILIKE 'AS%' THEN 'american samoa'
			WHEN state ILIKE 'AZ%' THEN 'arizona'
			WHEN state ILIKE 'AR%' THEN 'arkansas'
			WHEN state ILIKE 'CA%' THEN 'california'
			WHEN state ILIKE 'CT%' THEN 'connecticut'
			WHEN state ILIKE 'CO%' THEN 'colorado'
			WHEN state ILIKE 'DC%' THEN 'district of columbia'
			WHEN state ILIKE 'DE%' THEN 'delaware'
			WHEN state ILIKE 'FL%' THEN 'florida'
			WHEN state ILIKE 'GA%' THEN 'georgia'
			WHEN state ILIKE 'GU%' THEN 'guam'
			WHEN state ILIKE 'HI%' THEN 'hawaii'
			WHEN state ILIKE 'IA%' THEN 'iowa'
			WHEN state ILIKE 'ID%' THEN 'idaho'
			WHEN state ILIKE 'IL%' THEN 'illinois'
			WHEN state ILIKE 'IN%' THEN 'indiana'
			WHEN state ILIKE 'KS%' THEN 'kansas'
			WHEN state ILIKE 'KY%' THEN 'kentucky'
			WHEN state ILIKE 'LA%' THEN 'louisiana'
			WHEN state ILIKE 'MD%' THEN 'maryland'
			WHEN state ILIKE 'ME%' THEN 'maine'
			WHEN state ILIKE 'MS%' THEN 'mississippi'
			WHEN state ILIKE 'MN%' THEN 'minnesota'
			WHEN state ILIKE 'MT%' THEN 'montana'
			WHEN state ILIKE 'MO%' THEN 'missouri'
			WHEN state ILIKE 'MI%' THEN 'michigan'
			WHEN state ILIKE 'MA%' THEN 'massachusetts'
			WHEN state ILIKE 'MP%' THEN 'mariana islands'
			WHEN state ILIKE 'NC%' THEN 'north carolina'
			WHEN state ILIKE 'ND%' THEN 'north dakota'
			WHEN state ILIKE 'NH%' THEN 'new hampshire'
			WHEN state ILIKE 'NJ%' THEN 'new jersey'
			WHEN state ILIKE 'NM%' THEN 'new mexico'
			WHEN state ILIKE 'NV%' THEN 'nevada'
			WHEN state ILIKE 'NY%' THEN 'new york'
			WHEN state ILIKE 'NE%' THEN 'nebraska'
			WHEN state ILIKE 'OH%' THEN 'ohio'
			WHEN state ILIKE 'OK%' THEN 'oklahoma'
			WHEN state ILIKE 'OR%' THEN 'oregon'
			WHEN state ILIKE 'PA%' THEN 'pennsylvania'
			WHEN state ILIKE 'PR%' THEN 'puerto rico'
			WHEN state ILIKE 'RI%' THEN 'rhode island'
			WHEN state ILIKE 'SC%' THEN 'south carolina'
			WHEN state ILIKE 'SD%' THEN 'south dakota'
			WHEN state ILIKE 'TN%' THEN 'tennessee'
			WHEN state ILIKE 'TX%' THEN 'texas'
			WHEN state ILIKE 'UT%' THEN 'utah'
			WHEN state ILIKE 'VT%' THEN 'vermont'
			WHEN state ILIKE 'WA%' THEN 'washington'
			WHEN state ILIKE 'WI%' THEN 'wisconsin'
			WHEN state ILIKE 'WV%' THEN 'west virginia'
			WHEN state ILIKE 'WY%' THEN 'wyoming'
			WHEN state ILIKE 'VA%' THEN 'virginia'
			WHEN state ILIKE 'VI%' THEN 'virgin islands'
		END AS state,
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

SELECT * 
FROM fatalities_cleaned 
ORDER BY incident_date 
DESC LIMIT 10;
````

**Results:**

id  |incident_date|day_of_week|city        |state    |description                                               |plan   |citation|
----|-------------|-----------|------------|---------|----------------------------------------------------------|-------|--------|
8981|   2022-04-22|friday     |smyrna      |tennessee| fatally struck by concrete pillar.                       |state  |no      |
8982|   2022-04-15|friday     |provo       |utah     | died in fall from roof.                                  |state  |no      |
8983|   2022-04-14|thursday   |toledo      |ohio     | died after becoming caught in machine drive shaft.       |federal|yes     |
8984|   2022-04-10|sunday     |mason city  |iowa     | suffered fatal injuries in fall on sidewalk.             |state  |no      |
8985|   2022-04-08|friday     |paton       |iowa     | fatally crushed under excavator.                         |state  |yes     |
8986|   2022-04-07|thursday   |spring      |texas    | died in fall from roof.                                  |federal|yes     |
8987|   2022-03-31|thursday   |santa rita  |guam     | died in fall from ladder after contacting energized wire.|federal|yes     |
8989|   2022-03-28|monday     |houston     |texas    | electrocuted by power lines while trimming trees.        |federal|no      |
8988|   2022-03-28|monday     |cicero      |illinois | fatally crushed under forklift.                          |federal|yes     |
8990|   2022-03-25|friday     |williamsburg|iowa     | fatally engulfed in corn bin.                            |state  |yes     |


#### What is the number of reported incidents?

````sql
SELECT 
	count(*) AS n_fatalities
FROM 
	fatalities_cleaned;
````

**Results:**

n_fatalities|
------------|
14914|

#### What is the year to year change for the number of fatal incidents?

````sql
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
````

**Results:**

incident_year|n_fatalities|previous_year|year_to_year|
-------------|------------|-------------|------------|
2009|         515|             |            |
2010|        1110|          515|       116.0|
2011|        1185|         1110|         7.0|
2012|         997|         1185|       -16.0|
2013|        1189|          997|        19.0|
2014|        1345|         1189|        13.0|
2015|        1148|         1345|       -15.0|
2016|        1106|         1148|        -4.0|
2017|        1541|         1106|        39.0|
2018|        1260|         1541|       -18.0|
2019|        1376|         1260|         9.0|
2020|        1119|         1376|       -19.0|
2021|         950|         1119|       -15.0|

#### What is the number of fatalities that received a citation?

````sql
SELECT
	citation,
	count(*)
FROM
	fatalities_cleaned
GROUP BY 
	citation;
````

**Results:**

citation|count|
--------|-----|
yes     | 3345|
no      | 2683|
unknown | 8886|

#### What day of the week has the most fatalities and what is the overall percentage?

````sql
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
````

**Results:**

day_of_week|n_fatalities|percentage|
-----------|------------|----------|
tuesday    |        2728|     18.29|
wednesday  |        2706|     18.14|
monday     |        2626|     17.61|
thursday   |        2612|     17.51|
friday     |        2335|     15.66|
saturday   |        1177|      7.89|
sunday     |         730|      4.89|

#### What is the number of fatalities involving welding?

````sql
SELECT
	count(*) AS welding_fatalities
FROM
	fatalities_cleaned
WHERE
	description ILIKE '%weld%'
````

**Results:**

welding_fatalities|
------------------|
79|

#### Select the last 5 from the previous query

````sql
SELECT
	*
FROM
	fatalities_cleaned
WHERE
	description ILIKE '%weld%'
ORDER BY 
	incident_date DESC
LIMIT 5;
````

**Results:**

id   |incident_date|day_of_week|city     |state|description                                            |plan   |citation|
-----|-------------|-----------|---------|-----|-------------------------------------------------------|-------|--------|
 9666|   2021-04-14|wednesday  |cleveland|ohio |Worker electrocuted by portable welding machine.       |federal|yes     |
 9896|   2021-01-30|saturday   |mission  |texas|Worker died in welding explosion.                      |federal|yes     |
10091|   2020-12-10|thursday   |urbana   |ohio |Worker fatally crushed by seam welder.                 |federal|yes     |
10785|   2020-05-24|sunday     |dallas   |texas|Worker electrocted while welding HVAC pipe.            |federal|no      |
11866|   2019-07-08|monday     |kingwood |texas|Worker electrocuted while welding air conditioner unit.|federal|no      |

#### Select the top 5 states with the most fatal incidents.

````sql
SELECT 
	state,
	count(*) AS incidents
FROM fatalities_cleaned
GROUP BY 
	state
ORDER BY 
	incidents DESC
LIMIT 5;
````

**Results:**

state     |incidents|
----------|---------|
texas     |     1758|
california|     1352|
florida   |     1021|
new york  |      726|
illinois  |      635|










