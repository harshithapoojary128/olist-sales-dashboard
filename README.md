# Olist E-Commerce Sales & Customer Analysis

An end-to-end data analytics project that transforms the Olist Brazilian E-Commerce dataset into actionable business insights using SQL (PostgreSQL), Python, and Tableau.

**Live Dashboard:** https://public.tableau.com/app/profile/harshitha.poojary1281/viz/OlistE-CommerceSalesDashboard_17879158552020/SalesOverview

[Dashboard Screenshot](images/Sales Overview.png)

---

## Problem

Online retailers need to understand what's driving revenue, which products perform best, who their customers are, and what impacts customer satisfaction. This project analyzes ~100,000 real e-commerce orders to answer:

1. How has revenue trended over time?
2. Which product categories generate the most revenue?
3. How is customer spending distributed across the customer base?
4. Does delivery performance affect customer review scores?

## Data

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)

The dataset contains ~100,000 orders placed between 2016–2018 across multiple Brazilian marketplaces, split across 9 relational tables covering customers, orders, order items, payments, products, reviews, sellers, and geolocation.

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Relational database to store and query the dataset |
| DBeaver | SQL client for schema design, queries, and data import |
| Python (pandas, SQLAlchemy) | Loading a CSV with malformed rows that the standard import tool couldn't parse |
| Tableau Public | Building the interactive dashboard |

## Approach

1. **Schema design** — Designed a normalized relational schema across 9 tables with primary/foreign key relationships reflecting the real structure of an e-commerce order lifecycle.
2. **Data ingestion** — Loaded all CSVs into PostgreSQL via DBeaver. One file (`order_reviews`) contained malformed quoted text in free-text review fields that broke standard CSV parsing; this was resolved with a Python/pandas script that read the file correctly, deduplicated rows, and inserted them directly into Postgres.
3. **Data cleaning** — Handled duplicate primary keys, blank foreign key values, and PostgreSQL interval types that required conversion to clean numeric values (days) for downstream visualization.
4. **SQL analysis** — Wrote queries using joins, aggregations, and window functions to answer each business question.
5. **Visualization** — Built four charts and combined them into an interactive Tableau dashboard with a date filter and a key insights summary.

## Database Schema

```
customers ──┐
            ├─< orders ──< order_items >── products ──< product_category_translation
            │       │                  └── sellers
            │       ├──< order_payments
            │       └──< order_reviews
            └── geolocation (linked by zip code prefix)
```

## Key Findings

- **Revenue growth:** Revenue grew steadily from late 2016 through mid-2018, peaking at approximately $3.1M in Q2 2018.
- **Top category:** Beleza & Saúde (Health & Beauty) is the highest-revenue product category at ~$1.15M, followed by Cama, Mesa & Banho (Bed, Bath & Table) and Esporte & Lazer (Sports & Leisure).
- **Customer segments:** Customers split evenly across four spend quartiles (~24,800 each) via `NTILE(4)`, providing a baseline for future targeted marketing or loyalty analysis.
- **Delivery drives satisfaction:** This is the strongest finding in the analysis. Orders rated 5 stars arrived **~12 days ahead** of their estimated delivery date on average, while orders rated 1 star arrived much closer to the estimated date (~2 days early). This suggests that **beating delivery expectations, not just meeting them, is a major driver of customer satisfaction** — a company could likely improve review scores by setting more conservative delivery date estimates.

## SQL Queries

All SQL is in the [`/sql`](sql/) folder, organized by stage:

- [`Script.sql`](sql/Script.sql) — Database creation
- [`Create tables.sql`](sql/Create%20tables.sql) — Schema: all `CREATE TABLE` statements with primary/foreign keys
- [`analysis.sql`](sql/analysis.sql) — All four analysis queries: monthly revenue trend, top categories, customer segmentation, and delivery delay vs. review score

Example from `analysis.sql` — delivery delay vs. review score, using `EXTRACT(EPOCH ...)` to convert a PostgreSQL interval into a clean numeric value:

```sql
SELECT 
    r.review_score,
    AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400) AS avg_delay_days
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;
```

## Data Cleaning Notes

A few real-world data issues came up during this project and were resolved:

- **Blank foreign key values:** Some products had an empty `product_category_name`, which violated the foreign key constraint against the category translation table. Resolved by relaxing the constraint after confirming it didn't affect analysis integrity.
- **Duplicate primary keys:** The reviews file contained a small number of duplicate `review_id` values. Resolved by deduplicating on import (~1% of rows).
- **Malformed CSV quoting:** Free-text review comment fields contained unescaped quote characters that broke standard CSV parsers. Resolved by loading the file with Python/pandas instead, and excluding the free-text fields entirely since they weren't needed for analysis.

## Dashboard

The final dashboard includes:
- A monthly revenue trend line chart with a date range filter
- A horizontal bar chart of top product categories by revenue
- A customer segmentation chart by spend quartile
- A delivery delay vs. review score chart
- A key insights summary panel

View it live: https://public.tableau.com/app/profile/harshitha.poojary1281/viz/OlistE-CommerceSalesDashboard_17879158552020/SalesOverview

## What I'd Explore Next

- Join delivery performance data with customer segments to see if late deliveries disproportionately affect any particular spend quartile
- Build a cohort retention analysis to see if delivery experience affects repeat purchase behavior
- Layer in seller-level performance to identify which sellers most affect delivery delays

---

*Dataset: Olist Brazilian E-Commerce Public Dataset, sourced from Kaggle.*
