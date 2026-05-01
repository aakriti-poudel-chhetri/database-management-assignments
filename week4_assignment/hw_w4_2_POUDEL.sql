-- Week 4, Homework 2: Who Worked With Whom?

-- Self-join on Camp_assignment to find overlapping co-workers by site

-- STEP 1: Base self-join, pair every row with every other row at the same site
-- Result: 15,521 rows

SELECT *
FROM Camp_assignment A
JOIN Camp_assignment B
    ON A.Site = B.Site;

-- STEP 2: Add date overlap condition
-- Two date ranges overlap when neither ends before the other starts:
--   A.Start <= B.End  AND  B.Start <= A.End
-- Result: 3,500 rows

SELECT *
FROM Camp_assignment A
JOIN Camp_assignment B
    ON  A.Site    = B.Site
    AND A.Start   <= B.End      -- A does not start after B ends
    AND B.Start   <= A.End;     -- B does not start after A ends

-- STEP 3a: Diagnose the problem, filter to one site to inspect rows
-- There's 8 rows for 'lkri' containing:
    -- Self-pairs  (person matched with themselves)
    -- Duplicates  (same pair appears twice with names reversed)
-- Result: 8 rows

SELECT *
FROM Camp_assignment A
JOIN Camp_assignment B
    ON  A.Site  = B.Site
    AND A.Start <= B.End
    AND B.Start <= A.End
WHERE A.Site = 'lkri';

-- STEP 3b: Fix self-pairs and duplicates with A.Observer < B.Observer
-- This keeps only alphabetically ordered, distinct pairs:
    -- A name is never < itself, eliminates self-pairs
    -- Only one ordering is kept per pair, eliminates reversed duplicates
-- Result: 2 rows for 'lkri'

SELECT *
FROM Camp_assignment A
JOIN Camp_assignment B
    ON  A.Site     = B.Site
    AND A.Start    <= B.End
    AND B.Start    <= A.End
    AND A.Observer < B.Observer     -- ordered distinct pairs only
WHERE A.Site = 'lkri';

-- STEP 4: Final query (clean columns, remove site filter, all sites)
-- Submission query

SELECT
    A.Site,
    A.Observer AS Observer_1,
    B.Observer AS Observer_2
FROM Camp_assignment A
JOIN Camp_assignment B
    ON  A.Site     = B.Site
    AND A.Start    <= B.End
    AND B.Start    <= A.End
    AND A.Observer < B.Observer
WHERE A.Site = 'lkri';


-- BONUS Problem!
-- Join with Personnel to display full names instead of abbreviations
-- Personnel is joined twice (p1 for Observer_1, p2 for Observer_2) so that
-- each observer abbreviation is independently resolved to a full name.

SELECT
    A.Site,
    p1.Name AS Name_1,
    p2.Name AS Name_2
FROM Camp_assignment A
JOIN Camp_assignment B
    ON  A.Site     = B.Site
    AND A.Start    <= B.End
    AND B.Start    <= A.End
    AND A.Observer < B.Observer
JOIN Personnel AS p1
    ON A.Observer = p1.Abbreviation
JOIN Personnel AS p2
    ON B.Observer = p2.Abbreviation
WHERE A.Site = 'lkri'
ORDER BY A.Site, Name_1, Name_2;