-- EDS 213 Week 5, Homework 1: Egg Variance
-- Goal: Find if Dunlin (Calidris alpina) egg size changes
--       with longitude — mimicking a study done in Eurasia.


-- STEP 1: Load the CSV files into new tables

-- Load egg information (Nest_ID, Egg_num, Length, Width)
CREATE TABLE Eggs_big AS SELECT * FROM 'eggs_big.csv';

-- Load nest information (Site, Nest_ID, Species code)
CREATE TABLE Nests_big AS SELECT * FROM 'nests_big.csv';

-- Quick check: how many rows did we get?
SELECT COUNT(*) AS egg_count FROM Eggs_big;
SELECT COUNT(*) AS nest_count FROM Nests_big;

-- Look at what columns DuckDB created and their data types
DESCRIBE Eggs_big;
DESCRIBE Nests_big;

-- Peek at the first few rows of each table
SELECT * FROM Eggs_big LIMIT 5;
SELECT * FROM Nests_big LIMIT 5;

-- Check the table definitions that DuckDB created automatically.
SHOW Eggs_big;
SHOW Nests_big;


-- STEP 2: Join Eggs_big + Nests_big + Species then filter to Calidris alpina only 

-- We join on Nest_ID (links eggs to nests),
-- then on species code (links nests to species name).

SELECT * FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Nests_big.Species = Species.Code
WHERE Species.Scientific_name = 'Calidris alpina';


-- STEP 3: Compute egg volume for each egg

SELECT
    Nests_big.Site,
    (3.14 / 6) * (Eggs_big.Width * Eggs_big.Width) * Eggs_big.Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Nests_big.Species = Species.Code
WHERE Species.Scientific_name = 'Calidris alpina';


-- STEP 4: Replace Site with actual Longitude

SELECT
    Site.Longitude,
    (3.14 / 6) * (Eggs_big.Width * Eggs_big.Width) * Eggs_big.Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Nests_big.Species = Species.Code
    JOIN Site ON Nests_big.Site = Site.Code         -- join on site code to get longitude
WHERE Species.Scientific_name = 'Calidris alpina';


-- STEP 5: Fix longitude values that wrap around the globe

-- Some sites have a positive longitude (e.g., 170.6),
-- but they are actually west of the -180 meridian
-- they should be treated as negative (e.g., 170.6 - 360 = -189.4)
-- We use a CASE expression to correct this.

-- First, check the range of longitudes in the Site table:
SELECT MIN(Longitude), MAX(Longitude) FROM Site;

-- Fix the longitude and build the final dataset:

SELECT
    CASE
        WHEN Site.Longitude > 0 THEN Site.Longitude - 360  -- shift positive values west of -180
        ELSE Site.Longitude                                 -- negative values are already correct
    END AS Longitude,
    (3.14 / 6) * (Eggs_big.Width * Eggs_big.Width) * Eggs_big.Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Nests_big.Species = Species.Code
    JOIN Site ON Nests_big.Site = Site.Code
WHERE Species.Scientific_name = 'Calidris alpina';


-- STEP 6: Save the result as a VIEW for reuse

-- A view is like a saved query, it doesn't store data,
-- but lets us reference this result easily in the next step.

CREATE OR REPLACE VIEW egg_volume_longitude AS
SELECT
    CASE
        WHEN Site.Longitude > 0 THEN Site.Longitude - 360
        ELSE Site.Longitude
    END AS Longitude,
    (3.14 / 6) * (Eggs_big.Width * Eggs_big.Width) * Eggs_big.Length AS Volume
FROM Eggs_big
    JOIN Nests_big USING (Nest_ID)
    JOIN Species ON Nests_big.Species = Species.Code
    JOIN Site ON Nests_big.Site = Site.Code
WHERE Species.Scientific_name = 'Calidris alpina';

-- Confirm it looks right
SELECT * FROM egg_volume_longitude LIMIT 5;


-- STEP 7: Run the linear regression

-- regr_slope(y, x): slope of the line Volume ~ Longitude
-- corr(y, x): Pearson correlation coefficient between Volume and Longitude

-- Volume is the dependent variable (y)
-- Longitude is the independent variable (x)

SELECT
    regr_slope(Volume, Longitude) AS Slope,
    corr(Volume, Longitude)       AS PCC
    FROM egg_volume_longitude;

-- Slope -4.82 (egg volume slightly decreases as we go east)
-- PCC -0.108 (weak negative correlation)



-- PART 2 ANSWERS (as SQL comments)


-- Q1: Does DuckDB guarantee that a Nest_ID in Eggs_big exists in Nests_big?

-- NO. When DuckDB auto-creates a table from a CSV file using
-- CREATE TABLE ... AS SELECT * FROM 'file.csv', it infers column
-- names and data types — but it does NOT add foreign key constraints.
-- Foreign keys are what enforce the rule "this ID must exist in
-- that other table." Since no such constraint was created, it's
-- entirely possible for Eggs_big to contain a Nest_ID that doesn't
-- exist anywhere in Nests_big, and the database will not complain.

-- Q2: Queries to find min and max longitude in the Site table:
SELECT MIN(Longitude) AS min_lon, MAX(Longitude) AS max_lon FROM Site;
-- Or separately:
-- SELECT MIN(Longitude) FROM Site;
-- SELECT MAX(Longitude) FROM Site;

-- Q3: How to characterize the correlation between egg volume and longitude?
--
-- The PCC is about -0.108, which is very close to 0.
-- This means there is a WEAK NEGATIVE correlation:
-- egg volume very slightly tends to decrease as longitude increases
-- (i.e., as we move east across northern Canada).
-- However, the relationship is so weak that longitude alone
-- explains very little of the variation in egg size.
-- This is quite different from the strong longitudinal trend
-- Liu et al. found in Eurasia — suggesting the pattern
-- may not hold in the Canadian Arctic.
