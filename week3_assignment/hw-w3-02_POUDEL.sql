-- Week 3: SQL Problem 2

-- PART 1: What is wrong with SELECT Site_name, MAX(Area) FROM Site;?

-- The problem is a mismatch between aggregated and non-aggregated columns.
-- MAX(Area) is an aggregate function. It scans every row in the entire Site table and
-- collapses all those Area values down into one single number (the biggest one).
-- The result is one row. But Site_name is a plain column. It has one value per row, 
-- meaning there are as many site names as there are rows in the table.

-- So the database is being asked to do two contradictory things at the same time:
    -- Give me one number (the max area)
    -- Give me many site names (one per row)

-- These cannot be combined into a single result. Which site name should appear next to that one max number?
-- The database genuinely does not know, and there is no correct answer, because the query never told it how to choose.

-- It is the same conceptual flaw with any aggregate:
    -- SELECT Site_name, AVG(Area)  FROM Site; [AVG - 1 row, Site_name - many rows]
    -- SELECT Site_name, COUNT(*)   FROM Site; [COUNT - 1 row, Site_name - many rows]
    -- SELECT Site_name, SUM(Area)  FROM Site; [SUM - 1 row, Site_name - many rows]

-- The rule:
-- Site_name has no aggregate and no GROUP BY, so DuckDB doesn't know which name to show.


-- PART 2: Find the site with the largest area using ORDER + LIMIT

-- Sort all sites from largest to smallest area, then grab only the top row.

SELECT Site_name, Area
FROM Site
ORDER BY Area DESC   -- largest area first
LIMIT 1;             -- keep only the #1 row

-- Expected result:
-- ┌──────────────┬────────┐
-- │  Site_name   │  Area  │
-- ├──────────────┼────────┤
-- │ Coats Island │ 1239.1 │
-- └──────────────┴────────┘


-- PART 3: Same result using a nested (subquery) approach

-- The inner query finds the single maximum area value.
-- The outer query finds whichever site has that area.

SELECT Site_name, Area
FROM Site
WHERE Area = (
    SELECT MAX(Area) -- inner query: returns one number, e.g. 1239.1
    FROM Site
);

-- Why this is useful vs LIMIT:
--   If two sites happened to share the exact same max area,
--   LIMIT 1 would silently drop one of them.
--   The subquery approach returns ALL sites tied for the maximum.