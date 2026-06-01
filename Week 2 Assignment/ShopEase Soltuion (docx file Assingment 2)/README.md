# Celebal Summer Internship 2026 — Week 2 Task
## E-Commerce Sales Database (ShopEase)

SQL analysis of a relational e-commerce database for **ShopEase**, a mid-sized
Indian e-commerce company selling electronics, clothing, and home products. The
task covers schema design, filtering, aggregation, joins, and advanced concepts
(constraints, CASE, ACID, transactions) across 27 questions.

## Files

| File | What it is |
|------|------------|
| `ShopEase_Solutions.sql` | **Primary deliverable.** The complete MySQL script — schema, sample data, and all 27 answers. Run this in MySQL Workbench (or any MySQL client) to reproduce every result. |
| `ShopEase_Solutions.ipynb` | A rendered companion notebook (pandas + SQLite). Shows each question, its query, and the **output table** inline, so results are visible on GitHub without running anything. |

> The `.sql` file is the authoritative answer set and targets **MySQL** as the task
> specifies. The notebook is a read-only convenience view of the same queries with
> outputs already baked in. Where the two engines differ (constraint and foreign-key
> error wording), the notebook notes the MySQL equivalent in comments.

## Database schema

Four related tables:

```
customers ──(1:N)──▶ orders ──(1:N)──▶ order_items ◀──(N:1)── products
```

- **customers** — customer details (PK: `customer_id`)
- **products** — product catalogue (PK: `product_id`)
- **orders** — orders placed by customers (PK: `order_id`, FK → customers)
- **order_items** — line items per order (PK: `item_id`, FK → orders, products)

Constraints include `UNIQUE` (email), `CHECK` (positive prices/quantities, valid
status values), and `FOREIGN KEY` relationships enforcing referential integrity.

## How to run the SQL script

1. Open `ShopEase_Solutions.sql` in MySQL Workbench (or run via `mysql` CLI).
2. Execute top to bottom — it creates the database, loads sample data, then runs
   each question's query in order.
3. **Q6 is expected to raise a CHECK error** (inserting `unit_price = -50`) — that
   error *is* the correct result for that question.

## Question coverage

- **Section A — SQL Basics:** SELECT, DISTINCT, primary keys, constraints (Q1–Q6)
- **Section B — Filtering & Optimization:** WHERE, date ranges, indexes, SARGability (Q7–Q12)
- **Section C — Aggregation:** COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING (Q13–Q18)
- **Section D — Joins:** INNER, LEFT, three-table joins, FULL OUTER concepts, FK relationships (Q19–Q23)
- **Section E — Advanced:** CASE tiers, conditional aggregation, ACID, atomic transaction (Q24–Q27)

## Key insights

- Revenue concentrates in **Delivered** orders; Pending/Cancelled orders represent
  revenue at risk or lost, so reducing cancellations directly lifts realised revenue.
- **Electronics** is the premium, high-value category (the one whose average price
  exceeds ₹2000); **Home** is consistently the budget category.
- Order **status** is the natural fulfilment-health KPI — tracking the
  Delivered vs Not-Delivered split over time surfaces operational issues early.
- The schema actively enforces data integrity: negative prices and orphan orders are
  rejected at the database level (CHECK and FOREIGN KEY constraints), not just in app code.

---

*Submitted as Week 2 assignment — Celebal Summer Internship Program 2026.*
