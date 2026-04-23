-- Week 3: SQL Problem 3

-- Database: bird database (birds.db)
-- Tables used: Bird_eggs, Bird_nests, Species

-- Multi-step aggregation + JOINs

-- List bird species by their maximum average egg volume (largest eggs first)

-- STEP 1: Compute the average egg volume per nest

-- The egg volume formula is: (pi/6) * W^2 * L
-- We use 3.14 for pi, so the constant out front is 3.14/6 ≈ 0.5233
-- For each nest, we average that formula across all eggs in it.

-- We save this as a temp table so we can reuse it in Step 2.

CREATE TEMP TABLE Averages AS
    SELECT
        Nest_ID,
        AVG((3.14 / 6.0) * Width * Width * Length) AS Avg_volume
    FROM Bird_eggs
    GROUP BY Nest_ID;   -- one average per nest

-- Check: peek at a few rows
-- SELECT * FROM Averages LIMIT 5;


-- STEP 2: For each species, find the MAX of those nest averages
-- Then join to Species to get the scientific name

-- We need two joins:
-- Bird_nests - links Nest_ID to a species code (Species column)
-- Species - links the species code to the Scientific_name

-- USING (Nest_ID) is shorthand for ON Bird_nests.Nest_ID = Averages.Nest_ID
-- It works because both tables share the same column name.

SELECT
    sp.Scientific_name,
    MAX(av.Avg_volume) AS Max_avg_volume
FROM Bird_nests AS bn
    JOIN Averages AS av ON bn.Nest_ID  = av.Nest_ID       -- attach avg volumes to nests
    JOIN Species  AS sp ON bn.Species  = sp.Species_code  -- swap species code for full name
GROUP BY sp.Scientific_name -- collapse to one row per species
ORDER BY Max_avg_volume DESC; -- largest egg volume at the top


-- CLEANUP (optional — TEMP tables auto-drop when session ends)
DROP TABLE Averages;


-- EXPECTED OUTPUT:
-- ┌─────────────────────────┬────────────────────┐
-- │     Scientific_name     │   Max_avg_volume   │
-- ├─────────────────────────┼────────────────────┤
-- │ Pluvialis squatarola    │   36541.85...      │
-- │ Pluvialis dominica      │   33847.85...      │
-- │ Arenaria interpres      │   23338.62...      │
-- │ Calidris fuscicollis    │   13277.14...      │
-- │ Calidris alpina         │   12196.23...      │
-- │ Charadrius semipalmatus │   11266.97...      │
-- │ Phalaropus fulicarius   │   8906.77...       │
-- └─────────────────────────┴────────────────────┘

