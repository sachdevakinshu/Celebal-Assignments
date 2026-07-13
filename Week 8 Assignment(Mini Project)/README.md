# E-Commerce Order Analytics System

Intern mini project: an end-to-end pipeline that generates messy e-commerce data,
cleans it, loads it into SQLite, answers 16 business questions with SQL, and exposes
a command-line reporting tool.

**Stack:** Python 3.13 · pandas · Faker · SQLite (stdlib `sqlite3`) · Jupyter

## Project structure

```
mini project/
├── notebooks/
│   ├── 01_data_generation.ipynb    Part 1 — generate 4 messy CSVs (Faker, seeded)
│   ├── 02_data_cleaning.ipynb      Part 2 — clean data + data quality report
│   ├── 03_sql_analysis.ipynb       Part 3 — build SQLite DB + run all 16 queries
│   └── 04_edge_case_tests.ipynb    Part 5 — unittest edge-case suite
├── src/
│   ├── cleaning.py                 cleaning functions (imported by notebooks 02 & 04)
│   └── report_cli.py               Part 4 — CLI report tool (sqlite3 + stdlib ONLY)
├── sql/
│   ├── schema.sql                  tables, constraints, indexes
│   └── 01_...16_*.sql              one file per analysis query
├── data/
│   ├── raw/                        generated messy CSVs
│   └── cleaned/                    cleaned CSVs + data_quality_report.txt
├── db/ecommerce.db                 SQLite database
└── output/query_results/           one CSV per query result
```

## How to run

```bash
pip install -r requirements.txt

# Run the notebooks in order (in Jupyter, or headless):
jupyter execute notebooks/01_data_generation.ipynb
jupyter execute notebooks/02_data_cleaning.ipynb
jupyter execute notebooks/03_sql_analysis.ipynb
jupyter execute notebooks/04_edge_case_tests.ipynb

# CLI report tool (Part 4):
python src/report_cli.py monthly 2026-01-01 2026-06-30
python src/report_cli.py            # interactive mode
```

Everything is seeded (`SEED = 42`), so every run reproduces the same data.

## The data

| File | Rows | Intentional issues injected |
|---|---|---|
| `customers.csv` | 800 | 2% invalid emails (missing `@` or domain) |
| `products.csv` | 500 | ~6% names with extra spaces / wrong case |
| `orders.csv` | 2,000 | 5% NULL/empty customer_id, 3% `DD-MM-YYYY` dates, 3 future dates |
| `order_items.csv` | 5,000 | 3% negative quantity (returns), 15 orphan order_ids, 5 rows discount > 100, 5 rows quantity = 0 |

Referential integrity is guaranteed *by construction* (orders sample real customer_ids,
items sample real order/product ids); violations are then injected deliberately so the
cleaning phase has known targets.

## Cleaning decisions (Part 2)

- **NULL customer_id** → kept as guest orders with a real SQL `NULL` (dropping 5% of orders would distort revenue).
- **Wrong date formats** → parsed and normalized to `YYYY-MM-DD HH:MM:SS`.
- **Future-dated orders** → reported and dropped (they would pollute time-based analyses).
- **Orphan order_items** → reported and dropped (clean foreign keys in the DB).
- **discount_percent > 100** → clamped to 100 (revenue can never go negative from a discount).
- **quantity = 0** → flagged and kept (contributes exactly 0 revenue).
- **Negative quantity** → kept — these are legitimate returns the analysis needs.
- **Invalid emails** → reported (we can't invent a correct address).

Full details in `data/cleaned/data_quality_report.txt`.

## The 16 SQL queries (Part 3)

Revenue everywhere = `quantity × unit_price × (1 − discount_percent/100)` — returns
(negative quantity) subtract, giving **net revenue**.

| # | Query | Technique |
|---|---|---|
| 1 | Revenue per category | JOIN + GROUP BY |
| 2 | Top 10 customers by order value | multi-join + LIMIT |
| 3 | Monthly order count, last 12 months | date functions, relative to max date |
| 4 | Customers who never had a delivery | NOT EXISTS anti-join |
| 5 | Products with more returns than purchases | conditional aggregation + HAVING |
| 6 | Return rate per category | conditional aggregation |
| 7 | Running revenue total per region | `SUM() OVER (PARTITION BY … ORDER BY …)` |
| 8 | Product rank within category | `DENSE_RANK()` |
| 9 | Days between consecutive orders + At-Risk flag | `LAG()` + `julianday()` |
| 10 | Monthly revenue → High/Medium/Low buckets | multi-level CTE |
| 11 | Lifetime-value quartiles (Platinum→Bronze) | `NTILE(4)` |
| 12 | Year-over-Year monthly revenue | CTE + self LEFT JOIN (NULL-safe growth) |
| 13 | First vs most recent purchased category | `FIRST_VALUE` / `LAST_VALUE` |
| 14 | Cumulative revenue distribution (Pareto) | windowed running sum + `ROW_NUMBER` |
| 15 | Cohort retention by registration month | CTEs + conditional COUNT DISTINCT |
| 16 | Products frequently bought together | self-join with `a.product_id < b.product_id` |

## CLI report tool (Part 4)

`src/report_cli.py` uses **only** `sqlite3` + the standard library. It takes a report
type (daily/weekly/monthly) and a date range — as arguments or interactively — and prints
total orders / net revenue / unique customers, the top 3 products, a % comparison against
the previous period of equal length, and a per-bucket breakdown. Invalid input (bad dates,
reversed ranges, unknown report types) produces friendly errors.

## Edge-case tests (Part 5)

`notebooks/04_edge_case_tests.ipynb` runs 6 unittest cases against `src/cleaning.py`:
orphan order_ids, discount > 100, quantity = 0, future order dates, wrong date formats,
and NULL customer_ids.
