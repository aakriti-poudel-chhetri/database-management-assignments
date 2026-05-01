-- Week 4, Homework 3: Who's the Culprit?

-- Find the observer who recorded exactly 36 nests at "nome"
-- between 1998 and 2008, where egg age was determined by floating.

-- Logic:
--   1. Filter Bird_nests to site = 'nome', years 1998-2008,
--      and ageMethod = 'float' (egg age was determined by floating).
--   2. Join to Personnel on Observer = Abbreviation to get the full name.
--   3. Count nests per observer.
--   4. Keep only the observer with exactly 36 nests.

SELECT
    p.Name,
    COUNT(*) AS Num_floated_nests
FROM Bird_nests n
JOIN Personnel p
    ON n.Observer = p.Abbreviation
WHERE
    n.Site = 'nome'
    AND n.Year BETWEEN 1998 AND 2008
    AND n.ageMethod = 'float'
GROUP BY p.Name
HAVING COUNT(*) = 36;
