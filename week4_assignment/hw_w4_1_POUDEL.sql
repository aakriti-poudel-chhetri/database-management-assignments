-- Week 4, Homework 1: Missing Data

-- Question: Which sites have NO egg data?


-- TECHNIQUE 1: Using a Code NOT IN (subquery) clause.

-- We can use NOT IN here because Bird_eggs.Site is declared NOT NULL in the schema,
-- so the subquery will never return a NULL (which would cause NOT IN to silently return
-- NULL instead of TRUE for every row)

SELECT Code
FROM Site
WHERE Code NOT IN (
    SELECT DISTINCT Site
    FROM Bird_eggs
)
ORDER BY Code;


-- TECHNIQUE 2: Using an outer join with a WHERE clause that selects the desired rows

-- Bird_eggs is LEFT; Site is RIGHT (the "kept" side).
-- Sites with no egg records will have NULL in all Bird_eggs columns post-join.
-- We check IS NULL on be.Nest_ID: since it is the PRIMARY KEY of Bird_eggs,
-- it is never NULL naturally -- so NULL here strictly means "no match found".

SELECT s.Code
FROM Bird_eggs be RIGHT JOIN Site s ON be.Site = s.Code
WHERE be.Nest_ID IS NULL   -- Nest_ID is PK (NOT NULL) in Bird_eggs;
                            -- NULL here means no egg row matched this site
ORDER BY s.Code;
