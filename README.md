> **SQL foundations project.** This repository is intentionally compact and is kept as part of my learning progression. For a more complete end-to-end analytics case study, see [QuickBite Crisis Recovery Analytics](https://github.com/codernav01/QuickBite-Crisis-Recovery-Analytics).

# E-Commerce SQL Analytics — Foundations Project

## Purpose

This project demonstrates relational modelling and core-to-intermediate MySQL analysis using a small synthetic e-commerce schema.

The dataset is deliberately small, so this repository should be read as **SQL logic practice**, not evidence of large-scale production analytics.

## Data Model

- **Customers** — profile and signup information
- **Products** — category, price and stock
- **Orders** — order date and status
- **Order Items** — quantities and transaction prices
- **Payments** — method, amount and date
- **Reviews** — order-level ratings and text

## SQL Skills Demonstrated

- joins
- aggregations
- subqueries
- CTEs
- window functions
- stored procedures
- user-defined functions
- date analysis
- customer ranking
- product/category analysis

## Metric Definitions

- **Units sold** = sum of `order_items.quantity`
- **Transaction value** = `quantity × price_each`
- **Delivered revenue** = transaction value for delivered orders
- **Average product rating** = average order review across orders containing that product

These definitions avoid confusing inventory/list price with actual transaction value.

## Repository Contents

```text
Ecommerce-SQL-analytics-project/
├── Ecommerce-SQL-Project.sql
└── README.md
```

## Portfolio Context

This repository represents an earlier stage of my SQL progression. My current work places more emphasis on data validation, relational integrity, reusable analytical layers, and business interpretation.
