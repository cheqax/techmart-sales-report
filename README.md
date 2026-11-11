# TechMart Electronics — Sales Performance Analysis

A SQL + Tableau portfolio project analyzing a year of sales data for a fictional
electronics retailer, built to practice turning a business question into a
query into an answer.

## Business context

TechMart Electronics is a fictional mid-size electronics retailer selling
laptops, monitors, audio gear, storage, and accessories through a small sales
team. This project analyzes a full year (2023) of orders to answer questions
a sales operations or business analyst at a company like this would actually
be asked: which months are strongest, who are the best customers, which
employees are performing well, which products are dead weight, and where
the cancellation problems are.

## Dataset

- **150 customers** across 15 Indian cities, signing up gradually through the year
- **18 products** across 5 categories (Laptop, Monitor, Audio, Storage, Accessory)
- **10 employees** (5 of them handle sales orders directly)
- **480 orders / 977 order line items**, dated across all of 2023, with a
  realistic status mix (Delivered, Shipped, Pending, Cancelled) and a
  noticeable sales ramp into the Oct–Nov festive period
- A few intentionally missing phone numbers, to mirror real-world messy data

Full schema (5 tables, with primary/foreign keys, NOT NULL and UNIQUE
constraints) is in [`techmart_full_dataset.sql`](techmart_full_dataset.sql).

| Table | Purpose |
|---|---|
| `employees` | Sales, support and warehouse staff |
| `customers` | Everyone who has placed an order |
| `products` | Catalog: name, category, price, stock |
| `orders` | One row per order: who, when, which employee, status |
| `order_items` | Line items within each order: product, quantity, price paid |

## How to run this yourself

1. Install MySQL (8.0+) if you don't have it already.
2. Run the schema + data file:
   ```
   mysql -u root -p < techmart_full_dataset.sql
   ```
3. Run any of the analysis queries:
   ```
   mysql -u root -p techmart < business_questions.sql
   ```

## Business questions answered

Each of these is a real query in [`business_questions.sql`](business_questions.sql),
with a comment above it explaining why a business would ask it.

1. **Monthly revenue trend** — which months are strongest, where's the growth
2. **Top 10 customers by spend** — who to prioritize for loyalty/outreach
3. **Revenue share by product category** — where the money actually comes from
4. **Sales employee performance** — orders handled, cancellation rate, revenue closed, per employee
5. **Top 10 best-selling products** — by both units sold and revenue
6. **Products that have never sold** — dead stock / catalog cleanup candidates
7. **Monthly cancellation rate** — is the cancellation problem getting better or worse
8. **Above-average-spend customer segment** — who qualifies for a targeted campaign
9. **Customers who've never bought a Laptop** — a cross-sell opportunity, since they're already buying something

## Key findings

- **Laptops drive ~71% of total revenue** despite being only 3 of 18 products in the catalog — a classic high-price/low-volume pattern worth knowing before making any inventory decisions based on units sold alone.
- **Sales are heavily concentrated in Q4** (Oct–Dec), consistent with festive-season buying — useful for staffing and inventory planning.
- **Employee performance varies meaningfully**: the top sales rep closes almost 2x the delivered revenue of the lowest performer, and cancellation rates differ by rep as well, worth investigating as a coaching opportunity rather than assuming it's random.
- Every product in the catalog has sold at least once this year — no dead stock currently, a sign the catalog is lean rather than bloated.

## Tools used

- **MySQL 8.4** — schema design, data generation, and all analysis queries (joins, subqueries, conditional aggregation, anti-joins, window-free running calculations)
- **Tableau Public** — interactive dashboard built on this data ([link here once published])
- **Python** — used to generate the realistic synthetic dataset (`generate_dataset.py`), not part of the analysis itself

## About this project

Built as a hands-on SQL practice project while transitioning into a Data
Analyst role, after working in fraud/risk operations (PayPal, Alorica). All
data is synthetic. Feedback welcome — this is a learning project, not a
finished product.

**Author:** Chethan Ramesh Reddy
**LinkedIn:** [add your profile link]
