# New-Wheels-SQL-Driven-Sales-and-Customer-Analytics

## Overview
New-Wheels is a vehicle resale platform offering an end-to-end app experience — from vehicle listing to shipping and after-sales feedback. Sales had been declining steadily, alongside a drop in new customers each quarter. As the data analyst, I used SQL to answer 10 key business questions and built a quarterly report for leadership to diagnose the root cause.

**Root cause identified:** A 3× deterioration in shipping SLA (57 → 174 days) drove a 36% decline in orders and a customer rating drop from 3.55 to 2.40 across 994 customers, using quarter-over-quarter (QoQ) analysis with SQL window functions.

## Business Questions Answered
1. Total customers & distribution across states
2. Top 5 preferred vehicle makers
3. Most preferred vehicle maker by state
4. Overall & quarterly average customer rating
5. Quarterly feedback distribution (dissatisfaction trend)
6. Order volume trend by quarter
7. Net revenue & QoQ % change (via `LAG()`)
8. Revenue & order volume trend by quarter
9. Average discount by credit card type
10. Average shipping time by quarter

Full queries: [`new_wheels_project.sql`](new_wheels_project.sql)

## Key Insights
- **Shipping time tripled** — from 57 days (Q1) to 174 days (Q4) — the single biggest operational red flag
- **Customer satisfaction collapsed** — average rating fell from 3.55 (Q1) to 2.40 (Q4), with "Bad"/"Very Bad" feedback rising from ~22% to ~60% of responses
- **Orders declined 36%** — from 310 (Q1) to 199 (Q4)
- **Net revenue fell every quarter** — down 17%, 11%, and 20% QoQ respectively, compounding to a steep annual decline
- **California and Texas** have the highest customer concentration; several states (New Mexico, Montana, Maine) have almost no presence
- **Chevrolet and Ford** are the most preferred brands overall, but preference varies significantly by state — no single maker dominates nationally

## SQL Highlight: QoQ Revenue Change with `LAG()`
```sql
SELECT 
    quarter_number,
    SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100)) AS net_revenue,
    LAG(SUM(order_t.quantity * product_t.vehicle_price * (1 - order_t.discount / 100))) 
        OVER (ORDER BY quarter_number) AS previous_quarter_revenue
FROM order_t
JOIN product_t ON order_t.product_id = product_t.product_id
GROUP BY quarter_number
ORDER BY quarter_number;
```

## Recommendations
- Investigate and fix shipping/logistics bottlenecks causing SLA deterioration — this is the primary driver of both order decline and poor ratings
- Launch targeted marketing campaigns in low-customer-count states
- Standardize discount policy across credit card types to protect margins
- Build an early-warning dashboard to flag rising negative feedback by quarter
- Promote high-margin models specifically in declining quarters to offset revenue pressure

## Tools Used
MySQL (Workbench) — joins, aggregate functions, `CASE` statements, subqueries, `LAG()` window functions

## Full Report
📄 [New Wheels Project.pdf](New%20Wheels%20Project.pdf) — complete business report with all queries, results, and insights
