# E-Commerce SQL Analytics

## Project Overview

This repository contains a compact MySQL analytics project built around customers, products, orders, order items, payments, and reviews.

The project demonstrates relational modelling and SQL analysis across common business questions such as revenue, customer value, product performance, order trends, and feedback.

## Data Model

- **Customers** — customer profile and signup information
- **Products** — product, category, price, and stock information
- **Orders** — order date and status
- **Order Items** — product quantities and transaction prices
- **Payments** — payment method, amount, and date
- **Reviews** — order-level ratings and review text

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
- product and category analysis

## Business Questions

The SQL script covers questions such as:

- How many customers are in each state?
- What is the monthly order trend?
- Which products sold the most units?
- Which customers generated the highest transaction value?
- Which categories generated the most delivered-order revenue?
- Which returned orders still have payment records?
- Which products have the strongest average ratings?
- Which customers qualify as high-value based on spend?
- How does customer spending change across consecutive orders?

## Important Metric Definitions

- **Units sold** = sum of `order_items.quantity`
- **Transaction value / sales** = `quantity × price_each`
- **Delivered revenue** = transaction value for delivered orders
- **Average product rating** = average review rating across orders containing that product

These definitions prevent inventory values or product-list prices from being mistaken for actual sales.

## Repository Contents

```text
Ecommerce-SQL-analytics-project/
├── Ecommerce-SQL-Project.sql
└── README.md
```

## Purpose

The project is a SQL portfolio case study focused on **correct business metric logic**, relational joins, and analytical query design.
