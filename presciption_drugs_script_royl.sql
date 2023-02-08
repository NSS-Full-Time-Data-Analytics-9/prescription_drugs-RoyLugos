-- MVP
-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    
SELECT p1.npi, p2.nppes_provider_first_name AS first_name, p2.nppes_provider_last_org_name AS last_name, SUM(p1.total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
	USING (npi)
GROUP BY first_name, last_name, p1.npi
ORDER BY total_claims DESC
LIMIT 1;
	
-- Answer: NPI: 1881634483, total number of claims = 99,707

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT p1.npi, 
       p2.nppes_provider_first_name AS first_name, 
	   p2.nppes_provider_last_org_name AS last_name,
	   p2.specialty_description AS specialty,
	   SUM(p1.total_claim_count) AS total_claims
FROM prescription AS p1
LEFT JOIN prescriber AS p2
	USING (npi)
GROUP BY first_name, last_name, specialty, p1.npi
ORDER BY total_claims DESC
LIMIT 1;

-- Answer: Bruce Pendley, Specialty: Family Practice, total number of claims = 99,707


-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT p2.specialty_description AS specialty, SUM(p1.total_claim_count) AS total_claims
FROM prescription AS p1
INNER JOIN prescriber AS p2
	USING (npi)
GROUP BY specialty
ORDER BY total_claims DESC
LIMIT 1;

-- Answer: Family Practice (9,752,347 claims) 

--     b. Which specialty had the most total number of claims for opioids?

SELECT p1.specialty_description AS specialty, SUM(p2.total_claim_count) AS total_opioid_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING (npi)
WHERE drug_name IN
	(SELECT drug_name
	FROM drug
	WHERE opioid_drug_flag = 'Y')
GROUP BY specialty
ORDER BY total_opioid_claims DESC NULLS LAST;

-- Answer: Nurse Practitioner - total opioids claims = 900,845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT p1.specialty_description AS specialty, SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	USING (npi)
GROUP BY specialty
ORDER BY total_claims DESC;

-- Answer: 15 specialties (NEEDS BETTER CODE)

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- ********* WORK IN PROGRESS ***********




-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT p.drug_name AS brand_name, d.generic_name AS generic_name, SUM(p.total_drug_cost) AS total_cost
FROM prescription AS p
LEFT JOIN drug AS d
	USING (drug_name)
GROUP BY brand_name, generic_name
ORDER BY total_cost DESC
LIMIT 10;

-- Answer: Lyrica (generic name: Pregabalin) - total cost $78,645,939.89

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT drug_name, generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply), 2) AS total_cost_per_day
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY drug_name, generic_name
ORDER BY total_cost_per_day DESC
LIMIT 10;

-- Answer: CINRYZE (generic name: C1 ESTERASE INHIBITOR) - total cost per day = $3,495.22


-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT DISTINCT drug_name,
       CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	   		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	   		ELSE 'neither' END AS drug_type
FROM drug
ORDER BY drug_name ASC;

-- Answer: see table for first 10 of 3260 rows (3425 rows if not using DISTINCT drug_name)
-- drug_name						drug_type
-- "1ST TIER UNIFINE PENTIPS"		"neither"
-- "1ST TIER UNIFINE PENTIPS PLUS"	"neither"
-- "ABACAVIR"						"neither"
-- "ABACAVIR-LAMIVUDINE"			"neither"
-- "ABACAVIR-LAMIVUDINE-ZIDOVUDINE"	"neither"
-- "ABELCET"						"neither"
-- "ABILIFY"						"neither"
-- "ABILIFY MAINTENA"				"neither"
-- "ABRAXANE"						"neither"
-- "ABSORICA"						"neither"

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- NOTE: JOIN drug and prescription tables
-- "prescription" will be left table
-- use LEFT JOIN
-- "drug" will be right table
-- NOTE: aggregation of total drug cost using CASE statements

SELECT SUM(CASE WHEN d.opioid_drug_flag = 'Y' THEN p.total_drug_cost::money END) AS opioid_total_cost,
 	   SUM(CASE WHEN d.antibiotic_drug_flag = 'Y' THEN p.total_drug_cost::money END) AS antibiotic_total_cost
FROM prescription AS p
	LEFT JOIN drug AS d
	USING (drug_name);

-- Answer: More money was spent for opioids ($105M)	vs antibiotics ($38M).


-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT cbsa, cbsaname
FROM cbsa
WHERE cbsaname ILIKE '%TN'
GROUP BY cbsa, cbsaname;

--Answer: 6 
-- cbsa		cbsaname
-- "17420"	"Cleveland, TN"
-- "27740"	"Johnson City, TN"
-- "34100"	"Morristown, TN"
-- "27180"	"Jackson, TN"
-- "28940"	"Knoxville, TN"
-- "34980"	"Nashville-Davidson-Murfreesboro-Franklin, TN"

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- Note: CBSA name from "cbsa" table, total population from "population" table, 

-- How many fipscounty in TN?
SELECT *
FROM cbsa
WHERE cbsaname ILIKE '%TN';
-- Returns 33 counties with 6 cbsas.

SELECT cbsaname, SUM(CASE WHEN cbsaname ILIKE '%TN' THEN population END) AS total_cbsa_pop
FROM cbsa
	 INNER JOIN population
	 USING (fipscounty)
WHERE cbsaname ILIKE '%TN'
GROUP BY cbsaname
ORDER BY total_cbsa_pop DESC;

-- Answer: see table below
-- cbsaname											total_cbsa_pop	
-- "Nashville-Davidson--Murfreesboro--Franklin, TN"	1830410
-- "Knoxville, TN"									862490
-- "Johnson City, TN"								200767
-- "Jackson, TN"									129538
-- "Cleveland, TN"									120388
-- "Morristown, TN"									116352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT f.fipscounty
FROM fips_county as f
     LEFT JOIN cbsa as c
	 USING (fipscounty)
WHERE c.fipscounty IS NULL;
-- Note: returns 2034 rows

WITH counties_not_in_cbsa AS (SELECT f.fipscounty, f.county
							  FROM fips_county as f
     							   LEFT JOIN cbsa as c
	 							   USING (fipscounty)
							  WHERE c.fipscounty IS NULL)
SELECT *
FROM population AS p
	 INNER JOIN counties_not_in_cbsa
	 USING (fipscounty)
ORDER BY population DESC
LIMIT 5;

-- Answer: Sevier County pop: 95,523


-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT * 
FROM prescription
WHERE total_claim_count >= 3000;
-- Note: returns 9 rows

SELECT drug_name, SUM(total_claim_count) AS total_claims
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY total_claims DESC;
-- Note: returns 7 rows
-- Answer: see table below
-- drug_name					total_claims
-- "LEVOTHYROXINE SODIUM"		9262
-- "OXYCODONE HCL"				4538
-- "LISINOPRIL"					3655
-- "GABAPENTIN"					3531
-- "HYDROCODONE-ACETAMINOPHEN"	3376
-- "MIRTAZAPINE"				3085
-- "FUROSEMIDE"					3083

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, 
	   SUM(total_claim_count) AS total_claims,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	   		ELSE 'other' END AS opioid_drug
FROM prescription
	 LEFT JOIN drug
	 USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag
ORDER BY total_claims DESC;

-- Answer: see table below
-- drug_name					total_claims	opioid_drug
-- "LEVOTHYROXINE SODIUM"		9262			"other"
-- "OXYCODONE HCL"				4538			"opioid"
-- "LISINOPRIL"					3655			"other"
-- "GABAPENTIN"					3531			"other"
-- "HYDROCODONE-ACETAMINOPHEN"	3376			"opioid"
-- "MIRTAZAPINE"				3085			"other"
-- "FUROSEMIDE"					3083			"other"

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, 
	   SUM(total_claim_count) AS total_claims,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	   		ELSE 'other' END AS opioid_drug,
	   nppes_provider_first_name,
	   nppes_provider_last_org_name
FROM prescription AS p1
	 LEFT JOIN drug AS d
	 USING (drug_name)
	 LEFT JOIN prescriber AS p2
	 USING (npi)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag, nppes_provider_last_org_name, nppes_provider_first_name
ORDER BY total_claims DESC;

-- Answer: see table below
-- drug_name					total_claims	opioid_drug		first_name	last_name
-- "OXYCODONE HCL"				4538			"opioid"		"DAVID"		"COFFEY"
-- "LISINOPRIL"					3655			"other"			"BRUCE"		"PENDLEY"
-- "GABAPENTIN"					3531			"other"			"BRUCE"		"PENDLEY"
-- "HYDROCODONE-ACETAMINOPHEN"	3376			"opioid"		"DAVID"		"COFFEY"
-- "LEVOTHYROXINE SODIUM"		3138			"other"			"DEAVER"	"SHATTUCK"
-- "LEVOTHYROXINE SODIUM"		3101			"other"			"ERIC"		"HASEMEIER"
-- "MIRTAZAPINE"				3085			"other"			"BRUCE"		"PENDLEY"
-- "FUROSEMIDE"					3083			"other"			"MICHAEL"	"COX"
-- "LEVOTHYROXINE SODIUM"		3023			"other"			"BRUCE"		"PENDLEY"


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- Note: query for npi - Nashville - Pain Mgmt
SELECT npi
FROM prescriber
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE';
-- Note: 7 rows returned

-- Note: query for opioid drugs
SELECT drug_name
FROM drug
WHERE opioid_drug_flag = 'Y';
--Note: 91 rows returned

-- Note: combine queries
SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y';

-- Answer: returns a table of 637 rows

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p1.npi, d.drug_name, SUM(p2.total_claim_count) AS number_of_claims
FROM prescriber AS p1
	 CROSS JOIN drug AS d
	 LEFT JOIN prescription AS p2
	 USING (npi)
WHERE p1.specialty_description = 'Pain Management' AND p1.nppes_provider_city = 'NASHVILLE' AND d.opioid_drug_flag = 'Y'
GROUP BY p1.npi, d.drug_name
ORDER BY drug_name;

-- Note: WRONG - table returned had 637 rows but had repeating values in number of claims field.

  





--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.




-- BONUS
-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.