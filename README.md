# Market Expansion Analytics: SQL-Driven Market Intelligence and Reporting System

-----

## 1\. Project Overview

**Project Title:** Market Expansion Analytics

**Client:** Monday Coffee Company

This project analyzes retail and online sales data for Monday Coffee, a consumer beverage company operating in multiple major Indian cities. The objective is to build a full SQL-based analytics and reporting workflow that supports market expansion decisions, performance monitoring, and customer insights.

The project simulates a real stakeholder request: management wants to determine the top cities suitable for opening new physical coffee shop locations. To achieve this, the project involves data modeling, schema design, SQL analysis, reporting queries, business metrics development, and recommendations.

## 2\. Business Context

Monday Coffee has been selling products online since January 2023. With increasing demand across metropolitan regions, the strategy team wants to identify the **top three cities** for physical store expansion using data-driven methods.

The data includes city demographics, customer information, products, and transaction-level sales. This project demonstrates end-to-end SQL capabilities required to support decision-making in a retail analytics environment.

## 3\. Stakeholder Requirements

**Key Stakeholders:**

  * Strategy and Expansion Team
  * Chief Operating Officer
  * Finance and Pricing Team
  * Marketing Analytics & Customer Experience Team

**Core Requirements:**

  * A complete SQL data model with integrity constraints.
  * Clean and well-documented tables ready for reporting.
  * SQL queries to answer **30 detailed business questions**.
  * A market attractiveness scoring approach.
  * City-level and product-level performance insights.
  * An ERD showing relationships among entities.
  * A final recommendation for the top three cities.

## 4\. Data Sources

The project uses four CSV datasets imported into PostgreSQL.

| Dataset | Description |
| :--- | :--- |
| **City** | Demographics, population, and estimated commercial rent. |
| **Customers** | Customer details, join dates, and city mappings. |
| **Products** | Product catalogue with pricing points. |
| **Sales** | Transaction-level data including dates, amounts, and ratings. |

## 5\. Data Modeling

The database follows a normalized relational structure with Primary Key (PK) and Foreign Key (FK) relationships enforced.

### ERD Overview: Relationships
* **`customers.city_id > city.city_id`**: A standard **Many-to-One** relationship. Many customers can live in one city.
* **`sales.product_id > products.product_id`**: **Many-to-One**. Many sales transactions can reference the same product type.
* **`sales.customer_id > customers.customer_id`**: **Many-to-One**. One customer can have multiple sales transactions.

## 6\. Entity-Relationship Diagram (ERD)

The ERD is available via the following files:
* `schemas\dbdiagram-erd.png`
* `schemas\erd.png`

## 7\. Schema Documentation
**Documentation:** DB Docs [https://dbdocs.io/akweiwonder3/Monday-Coffee-Database](https://dbdocs.io/akweiwonder3/Monday-Coffee-Database)

## 8\. Project Structure

```text
/project-root
│
├── schemas/
│   ├── Schemas.sql
│   └── ERD.dbdiagram.txt
│
├── data/
│   ├── city.csv
│   ├── customers.csv
│   ├── products.csv
│   └── sales.csv
│
├── analysis/
│   ├── Solutions.sql
│   ├── business_queries.sql
│   └── insights_summary.md
│
├── documentation/
│   ├── README.md
│   ├── dbdocs-export/
│   └── erd.png
│
└── outputs/
    ├── recommendations.md
    └── market-expansion-report.pdf
```

-----

## 9\. Business Analysis & SQL Queries

Below are the 30 key business questions, framed as problems with their corresponding SQL solutions and explanations.

### A. Market Size and Demographics

**1. Problem:** Estimate the number of coffee consumers per city assuming a 25% consumption rate.
**Query:**

```sql
SELECT 
    city_name, 
    population, 
    (population * 0.25) AS estimated_coffee_consumers
FROM city
ORDER BY estimated_coffee_consumers DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** This helps set a baseline for the Total Addressable Market (TAM) in each region.

**2. Problem:** Rank cities by potential coffee consumers.
**Query:**

```sql
SELECT 
    city_name, 
    (population * 0.25) AS potential_consumers,
    RANK() OVER (ORDER BY (population * 0.25) DESC) as city_rank
FROM city;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Ranking allows the strategy team to prioritize high-volume markets immediately.

**3. Problem:** Compare estimated consumers with actual customers acquired.
**Query:**

```sql
SELECT 
    c.city_name,
    (c.population * 0.25) as estimated_consumers,
    COUNT(cu.customer_id) as actual_customers
FROM city c
JOIN customers cu ON c.city_id = cu.city_id
GROUP BY c.city_name, c.population;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** This highlights the gap between market potential and current market capture.

**4. Problem:** Identify cities where customer penetration is below 5% of estimated demand.
**Query:**

```sql
WITH city_stats AS (
    SELECT 
        c.city_name, 
        (c.population * 0.25) as est_consumers,
        COUNT(cu.customer_id) as current_customers
    FROM city c
    JOIN customers cu ON c.city_id = cu.city_id
    GROUP BY c.city_name, c.population
)
SELECT city_name 
FROM city_stats
WHERE (current_customers::numeric / est_consumers) < 0.05;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** These cities represent massive untapped growth opportunities or potential marketing failures.

**5. Problem:** Analyze rent-to-population ratio to understand affordability for outlet placement.
**Query:**

```sql
SELECT 
    city_name, 
    estimated_rent, 
    population, 
    (estimated_rent::numeric / population) as rent_per_capita
FROM city
ORDER BY rent_per_capita DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** High rent per capita indicates expensive real estate relative to the customer base size, posing a risk to profitability.

-----

### B. Revenue and Sales Performance

**6. Problem:** Calculate total revenue across all cities for the last quarter.
**Query:**

```sql
SELECT 
    ci.city_name, 
    SUM(s.total) as total_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
WHERE s.sale_date >= DATE_TRUNC('quarter', CURRENT_DATE) - INTERVAL '3 month'
GROUP BY ci.city_name;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Provides a snapshot of recent financial performance to gauge current momentum.

**7. Problem:** Determine revenue contribution percentage by city.
**Query:**

```sql
WITH city_revenue AS (
    SELECT ci.city_name, SUM(s.total) as revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name
)
SELECT 
    city_name, 
    revenue,
    ROUND((revenue / (SELECT SUM(revenue) FROM city_revenue)) * 100, 2) as contribution_pct
FROM city_revenue
ORDER BY revenue DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Identifies which cities are "carrying" the business and which are lagging.

**8. Problem:** Calculate Average Order Value (AOV) by city.
**Query:**

```sql
SELECT 
    ci.city_name, 
    AVG(s.total) as average_order_value
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Higher AOV suggests customers with higher spending power, influencing pricing strategies for physical stores.

**9. Problem:** Analyze monthly sales growth trends by city.
**Query:**

```sql
SELECT 
    ci.city_name,
    EXTRACT(MONTH FROM s.sale_date) as month,
    EXTRACT(YEAR FROM s.sale_date) as year,
    SUM(s.total) as monthly_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, year, month
ORDER BY ci.city_name, year, month;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Visualizes the trajectory of growth to see if a market is expanding or stagnating.

**10. Problem:** Identify the peak sales month per city.
**Query:**

```sql
WITH monthly_sales AS (
    SELECT 
        ci.city_name, 
        TO_CHAR(s.sale_date, 'YYYY-MM') as sales_month,
        SUM(s.total) as revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, sales_month
)
SELECT city_name, sales_month, revenue
FROM (
    SELECT *, RANK() OVER(PARTITION BY city_name ORDER BY revenue DESC) as rn
    FROM monthly_sales
) tmp
WHERE rn = 1;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Critical for inventory planning and staffing during peak seasons.

**11. Problem:** Identify revenue seasonality (months with consistent high/low revenue).
**Query:**

```sql
SELECT 
    EXTRACT(MONTH FROM sale_date) as month, 
    AVG(total) as avg_revenue
FROM sales
GROUP BY month
ORDER BY avg_revenue DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Helps predict cash flow fluctuations throughout the year.

-----

### C. Product Insights

**12. Problem:** Count sales of each product overall.
**Query:**

```sql
SELECT p.product_name, COUNT(s.sale_id) as total_units_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Determines the "hero" products that should be front-and-center in a physical store.

**13. Problem:** Identify top 3 products per city by volume.
**Query:**

```sql
WITH product_rank AS (
    SELECT 
        ci.city_name, 
        p.product_name, 
        COUNT(s.sale_id) as units_sold,
        DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, p.product_name
)
SELECT * FROM product_rank WHERE rank <= 3;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Allows for localized inventory customization (e.g., City A prefers Latte, City B prefers Espresso).

**14. Problem:** Identify underperforming products (ranked lowest by sales).
**Query:**

```sql
SELECT p.product_name, COUNT(s.sale_id) as sales_count
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY sales_count ASC
LIMIT 5;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Candidates for discontinuation or marketing overhaul.

**15. Problem:** Compare price vs. total sales to identify price sensitivity.
**Query:**

```sql
SELECT 
    p.product_name, 
    p.price, 
    COUNT(s.sale_id) as volume
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_name, p.price
ORDER BY p.price DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** If high-priced items have low volume, the market might be price-sensitive.

-----

### D. Customer Behaviour and Segmentation

**16. Problem:** Count unique customers in each city.
**Query:**

```sql
SELECT city_name, COUNT(DISTINCT customer_id) as unique_customers
FROM customers c
JOIN city ci ON c.city_id = ci.city_id
GROUP BY city_name;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Validates the actual reach of the brand in specific geographies.

**17. Problem:** Calculate customer repeat rate (customers who purchased more than once).
**Query:**

```sql
WITH customer_orders AS (
    SELECT customer_id, COUNT(sale_id) as order_count
    FROM sales
    GROUP BY customer_id
)
SELECT 
    COUNT(CASE WHEN order_count > 1 THEN 1 END) as repeat_customers,
    COUNT(*) as total_customers,
    (COUNT(CASE WHEN order_count > 1 THEN 1 END)::numeric / COUNT(*)) * 100 as repeat_rate_pct
FROM customer_orders;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** High repeat rates indicate strong brand loyalty, a positive signal for physical expansion.

**18. Problem:** Average number of orders per customer per city.
**Query:**

```sql
SELECT 
    ci.city_name, 
    COUNT(s.sale_id)::numeric / COUNT(DISTINCT c.customer_id) as avg_orders_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** A metric for customer "stickiness" in each region.

**19. Problem:** Customer value segmentation (Low, Mid, High based on total spend).
**Query:**

```sql
SELECT 
    customer_id,
    SUM(total) as total_spend,
    CASE 
        WHEN SUM(total) < 100 THEN 'Low'
        WHEN SUM(total) BETWEEN 100 AND 500 THEN 'Mid'
        ELSE 'High'
    END as value_segment
FROM sales
GROUP BY customer_id;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Enables targeted marketing campaigns for the launch of new stores.

**20. Problem:** Identify customers with declining purchasing frequency.
**Query:**

```sql
/* Conceptual Query for Last 3 Months Trend */
SELECT customer_id, 
    COUNT(CASE WHEN sale_date BETWEEN NOW() - INTERVAL '30 days' AND NOW() THEN 1 END) as last_30,
    COUNT(CASE WHEN sale_date BETWEEN NOW() - INTERVAL '60 days' AND NOW() - INTERVAL '30 days' THEN 1 END) as prev_30
FROM sales
GROUP BY customer_id
HAVING COUNT(CASE WHEN sale_date BETWEEN NOW() - INTERVAL '30 days' AND NOW() THEN 1 END) < 
       COUNT(CASE WHEN sale_date BETWEEN NOW() - INTERVAL '60 days' AND NOW() - INTERVAL '30 days' THEN 1 END);
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Identifies "at-risk" customers who need re-engagement strategies.

-----

### E. Profitability and Cost Metrics

**21. Problem:** Average rent per customer in each city.
**Query:**

```sql
SELECT 
    ci.city_name, 
    ci.estimated_rent,
    COUNT(c.customer_id) as customer_count,
    (ci.estimated_rent::numeric / COUNT(c.customer_id)) as rent_per_customer
FROM city ci
JOIN customers c ON ci.city_id = c.city_id
GROUP BY ci.city_name, ci.estimated_rent;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** A lower rent-per-customer indicates better unit economics for that city.

**22. Problem:** Revenue-to-rent ratio per city.
**Query:**

```sql
WITH city_rev AS (
    SELECT ci.city_name, ci.estimated_rent, SUM(s.total) as total_revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, ci.estimated_rent
)
SELECT city_name, (total_revenue / estimated_rent) as revenue_rent_ratio
FROM city_rev
ORDER BY revenue_rent_ratio DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** The golden metric for retail. High ratios mean the revenue justifies the real estate cost.

**23. Problem:** Compute estimated revenue per capita.
**Query:**

```sql
SELECT 
    ci.city_name, 
    SUM(s.total) / ci.population as rev_per_capita
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name, ci.population;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Normalizes revenue against population size to find the most efficient markets.

**24. Problem:** Identify break-even cities assuming a fixed rent-to-revenue threshold (e.g., Rent should be \< 20% of Revenue).
**Query:**

```sql
WITH city_financials AS (
    SELECT ci.city_name, ci.estimated_rent, SUM(s.total) as revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, ci.estimated_rent
)
SELECT city_name 
FROM city_financials
WHERE (estimated_rent / revenue) < 0.2;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Filters out cities that are financially unviable for expansion based on current data.

-----

### F. Time-Series and Cohort Analytics

**25. Problem:** Build monthly cohorts of customers based on their first purchase month.
**Query:**

```sql
SELECT 
    customer_id, 
    MIN(DATE_TRUNC('month', sale_date)) as cohort_month
FROM sales
GROUP BY customer_id;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Defines the cohorts for subsequent retention analysis.

**26. Problem:** Calculate retention rate of each cohort.
**Query:**

```sql
/* Complex query requiring joining cohort definition back to sales activities */
-- (Simplified representation)
WITH cohorts AS (
    SELECT customer_id, MIN(DATE_TRUNC('month', sale_date)) as join_month
    FROM sales GROUP BY customer_id
)
SELECT 
    c.join_month, 
    DATE_TRUNC('month', s.sale_date) as activity_month, 
    COUNT(DISTINCT s.customer_id) as active_users
FROM sales s
JOIN cohorts c ON s.customer_id = c.customer_id
GROUP BY c.join_month, activity_month
ORDER BY c.join_month, activity_month;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Shows how long customers stay active after their first purchase.

**27. Problem:** Determine which cohort produced the highest lifetime revenue.
**Query:**

```sql
WITH cohorts AS (
    SELECT customer_id, MIN(DATE_TRUNC('month', sale_date)) as join_month
    FROM sales GROUP BY customer_id
)
SELECT 
    c.join_month, 
    SUM(s.total) as cohort_lifetime_revenue
FROM sales s
JOIN cohorts c ON s.customer_id = c.customer_id
GROUP BY c.join_month
ORDER BY cohort_lifetime_revenue DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Identifies the "golden era" of customer acquisition.

-----

### G. Store Expansion and Market Potential

**28. Problem:** Build a composite city score using revenue, rent, customers, and market size.
**Query:**

```sql
/* Weighted Score Calculation */
WITH city_metrics AS (
    SELECT 
        ci.city_name,
        SUM(s.total) as revenue,
        COUNT(DISTINCT s.customer_id) as customers,
        ci.estimated_rent,
        ci.population
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON c.city_id = ci.city_id
    GROUP BY ci.city_name, ci.estimated_rent, ci.population
)
SELECT 
    city_name,
    (revenue * 0.4 + customers * 0.3 + (population/1000) * 0.2 - (estimated_rent/1000) * 0.1) as composite_score
FROM city_metrics
ORDER BY composite_score DESC;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** A mathematical model to rank cities objectively.

**29. Problem:** Identify top 3 cities with the highest expansion potential.
**Query:**

```sql
SELECT city_name, composite_score
FROM (
    -- utilizing the CTE from Q28
    [Insert Q28 Logic Here]
) scored_cities
LIMIT 3;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** The direct answer to the key stakeholder question.

**30. Problem:** Provide final recommended ranking with justification.
**Query:**

```sql
-- This is a reporting query aggregating the key stats for the top 3
SELECT 
    city_name, 
    composite_score as score,
    revenue, 
    customers,
    estimated_rent
FROM city_metrics
ORDER BY composite_score DESC
LIMIT 3;
```

**Result:**
`[INSERT SCREENSHOT OF RESULT HERE]`
**Explanation:** Provides the data backing required for the formal "Expansion Recommendation Report."

-----

## 10\. Technical Skills Demonstrated

  * **SQL Schema Design:** Normalization and constraint implementation.
  * **Analytical SQL:** Window functions, Rank, Partition By.
  * **Data Aggregation:** CTEs and complex Joins.
  * **Business Intelligence:** Cohort analysis and metric formulation.
  * **Reporting:** Transforming raw data into actionable insights.

## 11\. Tools Used

  * **Database:** PostgreSQL (pgAdmin)
  * **Modeling:** dbdiagram.io
  * **Documentation:** DB Docs https://dbdocs.io/akweiwonder3/Monday-Coffee-Database
  * **Version Control:** GitHub
  * **Editor:** VS Code

## 12\. Deliverables

1.  **SQL Scripts:** Schema, Data Import, and Solutions (`.sql`).
2.  **ERD:** Visual representation of database topology.
3.  **Documentation:** Detailed README and Insights Summary.
4.  **Recommendation Report:** A strategic document outlining the top 3 cities.

## 12\. Final Recommendations

Based on the analysis, the top 3 cities recommended for expansion are detailed in `recommendations.md`. The selection is based on a balance of high demand (Sales/Consumers), market efficiency (Rent-to-Revenue), and future potential (Population/Growth).

-----
