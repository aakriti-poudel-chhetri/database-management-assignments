#!/bin/bash
# EDS 213 Week 5, Homework 3: Create a test harness

# Part 1

# Give a query, tell it how many times to run,
# and record how long each run took on average.
#
# How to use it:
#   bash hw-05-3.sh label num_reps query db_file csv_file
#
# Example:
#   bash hw-05-3.sh subquery 1000 \
#       'SELECT Code FROM Species WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests)' \
#       database.duckdb timings.csv

# 5 inputs the user typed when running the script.
# $1 means the first word typed, $2 the second, and so on.
label=$1      # a name describing this run, e.g. "subquery"
num_reps=$2   # how many times to run the query, e.g. 1000
query=$3      # the SQL query to run
db_file=$4    # the database file to run it on
csv_file=$5   # the CSV file where results will be saved

# Check the user provided all 5 inputs.
# If not, print a helpful message and stop.
# $# means "how many inputs were given."

if [ $# -ne 5 ]; then
    echo "Usage: bash hw-05-3.sh label num_reps query db_file csv_file"
    exit 1
fi

# Record what time it is right now, before the loop starts.
# $SECONDS is a built-in counter that tracks how many seconds
# have passed since the script started running.

start_time=$SECONDS

# Run the query over and over, num_reps times.
# Each time, DuckDB opens the database and runs the query.
# We throw away the output (> /dev/null 2>&1) because
# we only care about how long it takes, not what it returns.

for i in $(seq "$num_reps"); do
    duckdb "$db_file" "$query" > /dev/null 2>&1
done

# Record what time it is now, after the loop is done.
# Subtract the start time to find out how many seconds
# the whole loop took.

end_time=$SECONDS
elapsed=$(( end_time - start_time ))

# Divide the total time by the number of repetitions
# to get the average time per single query run.
# Bash can only do whole number math, so we use Python
# to handle the decimal places.

time_per_query=$(python3 -c "print(round($elapsed / $num_reps, 7))")

# Save the result to the CSV file.
# ">>" means "add to the end of the file" without erasing
# what is already in it. So each time you run this script,
# a new line gets added.

echo "${label},${time_per_query}" >> "$csv_file"

# Print a summary to the screen so you can see it worked.

echo "Done! Ran query $num_reps times in $elapsed seconds."
echo "Time per query: $time_per_query seconds"
echo "Result appended to $csv_file"


# Part 2

# These are the three commands used to time the three different queries.
# Run each one from your data folder in the terminal.

# Method 1 - using NOT IN (called "subquery"):
# bash hw-05-3.sh subquery 1000 \
#     'SELECT Code FROM Species WHERE Code NOT IN (SELECT DISTINCT Species FROM Bird_nests)' \
#     database.duckdb timings.csv

# Method 2 - using a join (called "outer_join"):
# bash hw-05-3.sh outer_join 1000 \
#     'SELECT Code FROM Bird_nests RIGHT JOIN Species ON Species = Code WHERE Nest_ID IS NULL' \
#     database.duckdb timings.csv

# Method 3 - using EXCEPT (called "except"):
# bash hw-05-3.sh except 1000 \
#     'SELECT Code FROM Species EXCEPT SELECT DISTINCT Species FROM Bird_nests' \
#     database.duckdb timings.csv

# Results saved in timings.csv:
#   subquery,0.016
#   outer_join,0.015
#   except,0.017
#
# I used 1000 repetitions to get timings above 0.
# The outer_join method was the fastest at 0.015 seconds per query.
# All three methods were very close in speed.
