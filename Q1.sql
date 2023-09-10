#1.Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. Write an answer to the following question: Does this table have everything you need to compute metrics like 30-day view-binary?

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa

Answer: No, we need the date and time of assignment to compute metrics

#2.Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type. 
SELECT
  item_id,
  test_a AS test_assignment,
  (CASE WHEN test_a IS NOT NULL THEN 'item_test_a'
        ELSE NULL END) AS test_number,
  (CASE WHEN test_a IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL END) AS test_start_date
FROM
 dsv1069.final_assignments_qa
UNION
SELECT
  item_id,
  test_b AS test_assignment,
  (CASE WHEN test_b IS NOT NULL THEN 'item_test_b'
        ELSE NULL END) AS test_number,
  (CASE WHEN test_b IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL END) AS test_start_date
FROM
 dsv1069.final_assignments_qa
UNION
SELECT
  item_id,
  test_c AS test_assignment,
  (CASE WHEN test_c IS NOT NULL THEN 'item_test_c'
        ELSE NULL END) AS test_number,
  (CASE WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL END) AS test_start_date
FROM
 dsv1069.final_assignments_qa
UNION
SELECT
  item_id,
  test_d AS test_assignment,
  (CASE WHEN test_d IS NOT NULL THEN 'item_test_d'
        ELSE NULL END) AS test_number,
  (CASE WHEN test_d IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL END) AS test_start_date
FROM
 dsv1069.final_assignments_qa
UNION
SELECT
  item_id,
  test_e AS test_assignment,
  (CASE WHEN test_e IS NOT NULL THEN 'item_test_e'
        ELSE NULL END) AS test_number,
  (CASE WHEN test_e IS NOT NULL THEN '2013-01-05 00:00:00'
        ELSE NULL END) AS test_start_date
FROM
 dsv1069.final_assignments_qa
 


#3.Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2 (You may include the day the test started)
SELECT
      item_test_2.item_id,
      item_test_2.test_assignment,
      item_test_2.test_number,
      item_test_2.test_start_date,
      item_test_2.created_at,
      MAX(
        CASE
          WHEN (
            created_at > test_start_date
            AND DATE_PART('day', created_at - test_start_date) <= 30
          ) THEN 1
          ELSE 0
        END
      ) AS order_binary
    FROM
      (
        SELECT
          f.*,
          DATE(o.created_at) AS created_at
        FROM
          dsv1069.final_assignments AS f
          JOIN dsv1069.orders AS o ON f.item_id = o.item_id
        WHERE
          f.test_number = 'item_test_2'
      ) AS item_test_2
    GROUP BY
      item_test_2.item_id,
      item_test_2.test_assignment,
      item_test_2.test_number,
      item_test_2.test_start_date,
      item_test_2.created_at


#4.Use the final_assignments table to calculate the view binary, and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)
SELECT
      item_test_2.item_id,
      item_test_2.test_assignment,
      item_test_2.test_number,
      MAX(
        CASE
          WHEN(view_date > test_start_date)
          AND DATE_PART('day', view_date - test_start_date) <= 30 THEN 1
          ELSE 0
        END
      ) AS view_binary
    FROM
      (
        SELECT
          f.*,
          DATE(v.event_time) AS view_date
        FROM
          dsv1069.final_assignments AS f
          LEFT JOIN (
            SELECT
              event_id,
              event_time,
              user_id,
              platform,
              CASE
                WHEN parameter_name = 'item_id' THEN CAST(parameter_value AS integer)
                ELSE 0
              END AS item_id
            FROM
              dsv1069.events AS e
            WHERE
              event_name = 'view_item'
          ) AS v ON f.item_id = v.item_id
        WHERE
          f.test_number = 'item_test_2'
      ) AS item_test_2
    GROUP BY
      item_test_2.item_id,
      item_test_2.test_assignment,
      item_test_2.test_number

#5.Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 

#order_binary…p-value 0.90/Improvement -15%–13%(-0.9%)
#view_binary…p-value 0.27/Improvement -1.8%–6.4%(2.3%)

