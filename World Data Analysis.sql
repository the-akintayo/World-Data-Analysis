/*Data Exploration*/
SELECT * 
FROM country;

SELECT COUNT(*) 
FROM country;
/*239 ROWS*/

SELECT * 
FROM city;

SELECT COUNT(*) 
FROM city;
/*4079 rows, 5 columns*/

SELECT * 
FROM countrylanguage;
SELECT COUNT(*) 
FROM countrylanguage;
/*984 rows, 4 columns*/

SELECT COUNT(*)
FROM country
WHERE GNPOld IS NULL;
/*61 countries have no entries for their previous GNP*/

SELECT DISTINCT (GovernmentForm)
FROM country;

SELECT COUNT(DISTINCT GovernmentForm)
FROM country;
/*35 unique government forms*/

CREATE VIEW Countries AS
SELECT Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, LifeExpectancy, GNP, HeadOfState, Capital
FROM country;

SELECT COUNT(*) 
FROM Countries
WHERE IndepYear between 1900 and 2000;
/*149 countries gained independence in the 20th Century*/

SELECT COUNT(*) 
FROM Countries
WHERE IndepYear < 1900;
/*43 countries gained independence before the 20th Century*/

SELECT *
FROM Countries
ORDER BY IndepYear DESC
LIMIT 10;
/*Palau in Oceania has the most recent independence in the year 1994*/

SELECT *
FROM Countries
WHERE IndepYear IS NOT NULL
ORDER BY IndepYear
LIMIT 10;
/*Alarming: China in Asia has its independence year as -1523
Then Ethiopia in Africa as -1000*/

SELECT COUNT(*)
FROM Countries
WHERE IndepYear IS NULL
;
/*47 countries have no independence date*/

SELECT Continent, COUNT(*) As NumberofCountries, SUM(SurfaceArea) AS TotalSurfaceArea, AVG(GNP) AS AverageGNP
FROM Countries
GROUP BY Continent
ORDER BY COUNT(*) DESC;
/*Africa has the highest number of countries i.e. 51, followed by Europe with 46 countries
Antarctica has the lowest number of countries with 5*/
/*Notably, Antarctica has an average GNP of 0, so let's check that*/

SELECT Name, SurfaceArea, Population, GNP
FROM Countries
WHERE Continent = "Antarctica";
/*Apparently, there is no record of population and GNP for countries in Antarctica*/

SELECT Name, Continent, SurfaceArea
FROM Countries
ORDER BY SurfaceArea DESC
LIMIT 5;

SELECT COUNT(*)
FROM Countries
WHERE SurfaceArea > (SELECT AVG(SurfaceArea) FROM Countries);
/*Average surface area is 623248.146 and only 43 countries have above the average*/

SELECT COUNT(*)
FROM Countries
WHERE Population > (SELECT AVG(Population) FROM Countries);
/*Average world population is 25,434,098 and only 38 countries have above that*/

CREATE VIEW LargeCountries
AS SELECT * FROM Countries
WHERE Population > (SELECT AVG(Population) FROM Countries) AND SurfaceArea > (SELECT AVG(SurfaceArea) FROM Countries);

SELECT COUNT(*) 
FROM LargeCountries;
/*Only 23 countries have population and surface area larger than the average*/

SELECT * 
FROM LargeCountries
ORDER BY SurfaceArea DESC
LIMIT 5;

SELECT * 
FROM LargeCountries
ORDER BY Population DESC
LIMIT 5;

SELECT Name, Population
FROM Countries
WHERE Population = (SELECT MAX(Population) FROM Countries);

SELECT Name, Continent, Population, GNP
FROM Countries
ORDER BY Population DESC
LIMIT 10;

SELECT Name, Continent, Population, GNP
FROM Countries
ORDER BY GNP DESC
LIMIT 10;

SELECT Name, Continent, SurfaceArea, Population, SurfaceArea/Population AS AreaPerCapita
FROM Countries
WHERE Population <> 0
ORDER BY AreaPerCapita
LIMIT 10;
/*Macao in Asia has the lowest surface area per person, followed by Monaco, HongKong, Singapore...
This could be translated has the most congested countries*/

SELECT Name, Continent, SurfaceArea, Population, SurfaceArea/Population AS AreaPerCapita
FROM Countries
WHERE Population <> 0
ORDER BY AreaPerCapita DESC
LIMIT 10;
/*Greenland in North America has the largest surface area per capita*/

SELECT Name, Continent, SurfaceArea, Population, GNP, GNP/Population AS GNPPerCapita
FROM Countries
WHERE Population <> 0
ORDER BY GNPPerCapita DESC
LIMIT 10;
/*Luxemborg in Europe has the highest GNPPerCapita of 0.03746, followed by Switzerland, Bermuda...*/

/*CITY TABLE*/
SELECT COUNT(DISTINCT(CountryCode))
FROM city;
/*Only 232 Country codes are in the city table, however, there are 239 country codes in the country table
Let's find out which countries are missing in the city table*/

SELECT Code, Name, Continent
FROM Countries 
WHERE Code NOT IN (SELECT CountryCode FROM city);
/*The countries not included are Antarctica, French Southern Territories, Bouvet Island, 
Heard Island and McDonald Island, British Indian Ocean Territory, South Georgia and the South Sandwich Islands
 United States Minor Outlying Islands*/


/*JOINS*/
/*Number of cities per country*/
SELECT CountryCode, Name, Continent, NumberofCities 
FROM ((SELECT CountryCode, COUNT(*) AS NumberofCities
		FROM country AS C
		LEFT JOIN city AS T
		ON C.Code = T.CountryCode
		GROUP BY CountryCode) AS S
        JOIN Countries C
        ON S.CountryCode = C.Code)
ORDER BY NumberofCities DESC
LIMIT 20;

/*Number of Countries that gained independence per year*/
SELECT IndepYear, COUNT(*)
FROM Countries
WHERE IndepYear IS NOT NULL
GROUP BY IndepYear
ORDER BY COUNT(*) DESC;
/*18 countries had their independence in 1991 and 1960*/

/*Countries with their independence year as 1991 or 1960*/
SELECT Code, Name, Continent, IndepYear
FROM Countries
WHERE IndepYear = 1991 OR IndepYear = 1960;

/*Just checking Nigeria*/
SELECT Code, Name
FROM Countries
WHERE Continent = "Africa" AND IndepYear = 1960;
/*That's more African countries than expected*/

SELECT COUNT(*)
FROM Countries
WHERE Continent = "Africa" AND IndepYear = 1960;
/*17 out of the 18 countries that gained independence in 1960 are in Africa, let's check the outlier*/

SELECT Code, Name, Continent
FROM Countries
WHERE Continent <> "Africa" AND IndepYear = 1960;
/*The odd one out is Cyprus in Asia*/

SELECT IndepYear, Continent, COUNT(*)
FROM Countries
WHERE IndepYear IS NOT NULL
GROUP BY IndepYear, Continent
ORDER BY COUNT(*) DESC;
/*10 out of the 18 countries that gained independence in 1991 are in Europe, the remaining 8 are Asian countries*/

/*Capital of Most Populated Countries*/
SELECT C.*, T.Name AS CapitalCity, T.Population AS PopulationOfCapital
FROM Countries C
LEFT JOIN city T
ON C.Capital = T.ID
ORDER BY Population DESC
LIMIT 10;

SELECT *
FROM Countries
WHERE LifeExpectancy IS NOT NULL
ORDER BY LifeExpectancy
LIMIT 20;
/*Lowest LifeExpectancy is 37.2 from Zambia, Africa
Africa was appearing too much, so I decided to check how many African countries are in bottom 20 in terms of lifeexpectancy*/

SELECT Continent, COUNT(*)
FROM 
	(SELECT *
	FROM Countries
	WHERE LifeExpectancy IS NOT NULL
	ORDER BY LifeExpectancy
	LIMIT 30) AS L
GROUP BY Continent
ORDER BY COUNT(*) DESC
;
/*27 African countries are in the bottom 30 in terms of life expectancy*/

SELECT Continent, COUNT(*)
FROM 
	(SELECT *
	FROM Countries
	WHERE GNP IS NOT NULL
	ORDER BY GNP
	LIMIT 30) AS L
GROUP BY Continent
ORDER BY COUNT(*) DESC
;
/*Oceanian countries are leading with 11 in the bottom 30 in terms of GNP
However, Africa and Antarctica are closely behind with 5 countries*/

SELECT AVG(LifeExpectancy)
FROM Countries;
/*Average Life Expectancy is 66.486*/

SELECT Name, Continent, LifeExpectancy
FROM Countries
WHERE LifeExpectancy = (SELECT MAX(LifeExpectancy) FROM Countries)
;
/*Andorra in Europe has the highest LifeExpectancy of 83.5*/

SELECT Name, Continent, LifeExpectancy
FROM Countries
WHERE LifeExpectancy = (SELECT MIN(LifeExpectancy) FROM Countries)
;
/*Zambia in Africa has the lowest LifeExpectancy of 37.2*/

SELECT Continent, COUNT(*) AS NumberofCountries, AVG(LifeExpectancy), AVG(Population), AVG(GNP), AVG(SurfaceArea)
FROM Countries
GROUP BY Continent
;
/*Only Africa has a life expectancy below the world average
Note: There is a discrepancy with Antarctica*/

SELECT *
FROM Countries
WHERE Continent = "Antarctica";
/*There are lots of missing data for Antarctica*/

SELECT COUNT(distinct(Language))
FROM countrylanguage;
/*There are 457 distinct languages*/

SELECT COUNT(distinct(Language))
FROM countrylanguage
WHERE IsOfficial = "T";
/*Only 102 of the 457 languages are official languages*/

SELECT Language, COUNT(*)
FROM countrylanguage
GROUP BY Language
ORDER BY COUNT(*) DESC;
/*English, Arabic, Spanish, French, German and Chinese are the most spoken languages with 60, 33,28,25,19,19 countries respectively*/

SELECT *
FROM Countries C
JOIN countrylanguage L
ON C.Code = L.CountryCode
WHERE L.IsOfficial = "T";

SELECT C.Name, Continent, NumberofLanguages
FROM Countries C
JOIN (SELECT CountryCode, COUNT(*) AS NumberofLanguages
		FROM countrylanguage
		GROUP BY CountryCode) AS L
ON C.Code = L.CountryCode
ORDER BY NumberofLanguages DESC;
/*Canada, China, India, Russian Federation, and United States have the highes spoken languages with 12*/

SELECT C.Name, Continent, NumberofLanguages
FROM Countries C
JOIN (SELECT CountryCode, COUNT(*) AS NumberofLanguages
		FROM countrylanguage
		GROUP BY CountryCode) AS L
ON C.Code = L.CountryCode
WHERE C.Name LIKE "Nig%";

SELECT Language, IsOfficial, Percentage
FROM Countries C
JOIN countrylanguage L
ON C.Code = L.CountryCode
WHERE C.Name = "Canada"
ORDER BY Percentage DESC;
/*English, French, Chinese, Italian and German are the most spoken languages in Canada*/

SELECT Language, IsOfficial, Percentage
FROM Countries C
JOIN countrylanguage L
ON C.Code = L.CountryCode
WHERE C.Name = "Nigeria"
ORDER BY Percentage DESC;
/*Yoruba, Hausa, Ibo, Fulani and Ibibio are the most spoken languages in Nigeria
However, Yoruba was misspelt as Joruba, most likely a data entry error*/

SELECT *
FROM countrylanguage
WHERE Language LIKE "%oruba";
/*So, the mistake is general in all spelling of Yoruba, let's change that*/

UPDATE countrylanguage SET Language = "Yoruba" WHERE Language = "Joruba" AND CountryCode IN ("BEN", "GHA", "NGA");
/*My safe update was on, so I had to add the key rows*/

SELECT *
FROM countrylanguage
WHERE Language LIKE "%oruba";
/*Now corrected*/

SELECT C.Name, C.Continent, T.Name AS Capital, L.Language AS OfficialLanguage, 
				C.Population, SurfaceArea, LifeExpectancy, GNP, 
                (C.Population * (L.Percentage/100)) AS PopulationSpeakingOfficialLanguage
FROM Countries C
JOIN city T
ON C.Capital = T.ID
JOIN countrylanguage L
ON C.Code = L.CountryCode
WHERE L.IsOfficial = "T";

SELECT *
FROM Countries
WHERE IndepYear < 0;
/*China, Ethiopia and Japan gained independence before Christ (BC)*/

SELECT Century, COUNT(*)
FROM (SELECT 
	CASE 
		WHEN IndepYear < 0 THEN "BC"
		WHEN IndepYear < 1000 THEN "1ST CENTURY"
		WHEN IndepYear < 1100 THEN "11TH CENTURY"
		WHEN IndepYear < 1200 THEN "12TH CENTURY"
		WHEN IndepYear < 1300 THEN "13TH CENTURY"
		WHEN IndepYear < 1400 THEN "14TH CENTURY"
		WHEN IndepYear < 1500 THEN "15TH CENTURY"
		WHEN IndepYear < 1600 THEN "16TH CENTURY"
		WHEN IndepYear < 1700 THEN "17TH CENTURY"
		WHEN IndepYear < 1800 THEN "18TH CENTURY"
		WHEN IndepYear < 1900 THEN "19TH CENTURY"
		WHEN IndepYear < 2000 THEN "20TH CENTURY"
		WHEN IndepYear < 2100 THEN "21ST CENTURY"
		END AS Century
	FROM Countries
	WHERE IndepYear IS NOT NULL) AS Independence
GROUP BY Century
ORDER BY COUNT(*) DESC;
 /*The 20th Century recorded 149 countries getting their independence, followed by the 19th Century with 27 countries*/

