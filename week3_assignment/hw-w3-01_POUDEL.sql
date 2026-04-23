-- Week 3: SQL Problem 1


-- PART 1: Construct an SQL experiment

-- Create a temporary table with one column that has data type REAL
-- TEMP means it disappears when the session ends (no cleanup needed).
CREATE TEMP TABLE mytable (
    mycolumn REAL
);

-- Insert numbers AND one NULL in a single INSERT statement.
-- Answer to the "(Hmm, can you?)" question: YES, you can insert
-- multiple rows at once using a comma-separated VALUES list.
INSERT INTO mytable (mycolumn) VALUES
    (10.0),
    (20.0),
    (30.0),
    (NULL);   -- this is the NULL we're testing

-- Quick check to see what's in the table
SELECT * FROM mytable;

-- EXPERIMENT: How does AVG() behave when there are NULL values?

-- Run AVG on the column
SELECT AVG(mycolumn) AS avg_result FROM mytable;

-- Let's compute what each possible behavior would return, so we can compare:

-- Scenario A: AVG *ignores* NULL [averages only (10, 20, 30)]
-- Expected = (10 + 20 + 30) / 3 = 20.0
SELECT (10.0 + 20.0 + 30.0) / 3 AS expected_if_nulls_ignored;

-- Scenario B: AVG *counts* NULL as 0 [averages (10, 20, 30, 0)]
-- Expected = (10 + 20 + 30 + 0) / 4 = 15.0
SELECT (10.0 + 20.0 + 30.0 + 0) / 4 AS expected_if_null_counts_as_zero;

-- RESULT: SQL's AVG() ignores NULLs. It only averages the rows that have actual values.
-- The NULL does not factor into the calculation at all, not in the numerator (sum) and not in the denominator (count).


-- PART 2: Manual average using SUM / COUNT (no AVG function)

-- Option A: divide by COUNT(*) — counts ALL rows including NULLs
SELECT SUM(mycolumn) / COUNT(*) AS avg_option_a FROM mytable;
-- COUNT(*) = 4  (rows: 10, 20, 30, NULL)
-- SUM = 60
-- Result = 60 / 4 = 15.0 - WRONG (treats NULL as if it were 0)

-- Option B: divide by COUNT(mycolumn) — counts only NON-NULL rows
SELECT SUM(mycolumn) / COUNT(mycolumn) AS avg_option_b FROM mytable;
-- COUNT(mycolumn) = 3  (only 10, 20, 30 are counted; NULL is skipped)
-- SUM = 60
-- Result = 60 / 3 = 20.0 - CORRECT (matches AVG behavior)

-- EXPLANATION:
--   COUNT(*): counts every row regardless of NULLs, inflates denominator
--   COUNT(mycolumn): counts only rows where the column is NOT NULL, correct denominator

-- The second query is correct because SUM() already ignores NULLs (only adds 10 + 20 + 30 = 60),
-- so the denominator must also ignore NULLs to match. COUNT(mycolumn) does exactly that,
-- it counts only the same non-NULL rows that SUM() used. COUNT(*) breaks the logic because
-- it inflates the denominator by counting the NULL row, even though that row contributed nothing to the numerator.
-- Simple rule: When manually computing an average, always use COUNT(column_name) not COUNT(*)
-- so the numerator and denominator are counting the same set of rows.


-- CLEANUP: drop the temp table
DROP TABLE mytable;
