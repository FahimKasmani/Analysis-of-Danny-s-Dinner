# Restaurant Sales Analysis
🍽️ Dive into the world of restaurant sales! This project explores 🧾 customer spending patterns, 🍔 popular menu items, and 📊 customer loyalty insights.

## Background
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favorite foods: sushi, curry, and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat. The restaurant has captured some very basic data from their few months of operation but has no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent, and which menu items are their favorite. Having this deeper connection with his customers will help him deliver a better and more personalized experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program. Additionally, he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

## Tools I Used
To conduct this analysis, I used the following tools:

- **SQL**: For querying the database and extracting insights.
- **PostgreSQL**: The database management system used for handling the sales data.
- **Visual Studio Code**: For writing and executing SQL queries.
- **Git & GitHub**: For version control and sharing the analysis.

## The Analysis
Each query in this project aims to answer specific questions about customer behavior and sales patterns. Here’s the approach for each question:

### 1. What is the total amount each customer spent at the restaurant?

```
SELECT 
    s.customer_id, 
    SUM(m.price) AS total_amount
FROM 
    sales AS s 
JOIN menu AS m ON 
    s.product_id = m.product_id
GROUP BY 
    s.customer_id;
```

### 2. How many days has each customer visited the restaurant?
```
SELECT 
    customer_id, 
    COUNT(DISTINCT(order_date)) AS no_of_days_visited
FROM 
    sales 
GROUP BY 
    customer_id;
```

### 3. What was the first item from the menu purchased by each customer?
```
WITH CTE AS (
    SELECT 
        s.order_date AS first_order, 
        s.customer_id, 
        m.product_name,
        RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rank
    FROM 
        sales AS s 
    JOIN menu AS m ON 
        s.product_id = m.product_id
)
SELECT 
    * 
FROM 
    CTE 
WHERE 
    rank = 1;
```

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```
WITH CTE AS (
    SELECT 
        COUNT(s.order_date) AS orders, 
        m.product_name
    FROM 
        sales AS s 
    JOIN menu AS m ON 
        s.product_id = m.product_id
    GROUP BY 
        m.product_name
    ORDER BY 
        orders DESC
    LIMIT 1
)
SELECT 
    * 
FROM 
    CTE;
```

### 5. Which item was the most popular for each customer?
```
WITH CTE AS (
    SELECT  
        m.product_name, 
        customer_id, 
        COUNT(s.order_date) AS orders,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(s.order_date) DESC) AS rn
    FROM 
        sales AS s 
    JOIN menu AS m ON 
        s.product_id = m.product_id
    GROUP BY 
        m.product_name, customer_id
)
SELECT 
    * 
FROM 
    CTE 
WHERE 
    rn = 1;
```

### 6. Which item was purchased first by the customer after they became a member?
```
WITH CTE AS (
    SELECT 
        s.customer_id, 
        product_name, 
        order_date, 
        p.join_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rn
    FROM 
        sales AS s 
    JOIN menu AS m ON 
        s.product_id = m.product_id
    JOIN members AS p ON 
        p.customer_id = s.customer_id
    WHERE 
        s.order_date >= p.join_date
)
SELECT 
    * 
FROM 
    CTE
WHERE 
    rn = 1;
```

### 7. Which item was purchased first by the customer before they became a member?
```
WITH CTE AS (
    SELECT 
        s.customer_id, 
        product_name, 
        order_date, 
        p.join_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rn
    FROM 
        sales AS s 
    JOIN menu AS m ON 
        s.product_id = m.product_id
    JOIN members AS p ON 
        p.customer_id = s.customer_id
    WHERE 
        s.order_date < p.join_date
)
SELECT 
    * 
FROM 
    CTE
WHERE 
    rn = 1;

```

### 8. What is the total items and amount spent for each member before they became a member?
```
SELECT 
    s.customer_id, 
    COUNT(s.order_date) AS total_items, 
    SUM(m.price) AS total_amount
FROM 
    sales AS s
JOIN menu AS m ON 
    s.product_id = m.product_id
JOIN members AS r ON 
    s.customer_id = r.customer_id
WHERE 
    s.order_date < r.join_date
GROUP BY 
    s.customer_id;
```

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?
```
SELECT 
    customer_id,
    SUM(
        CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
        END
    ) AS points
FROM 
    sales AS s
JOIN menu AS m ON 
    s.product_id = m.product_id
GROUP BY 
    customer_id;
```
### 10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January?
```
SELECT 
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN r.join_date AND (r.join_date + INTERVAL '6 DAY') THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS points
FROM 
    sales AS s
JOIN menu AS m ON 
    s.product_id = m.product_id
JOIN members AS r ON 
    s.customer_id = r.customer_id
WHERE 
    DATE_TRUNC('month', s.order_date) = DATE_TRUNC('month', DATE '2021-01-01')
GROUP BY 
    s.customer_id;
```

## Bonus Questions
### Create a table showing customer_id, order_date, product_name, price, and membership status

```
SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name, 
    m.price,
    r.join_date,
    CASE 
        WHEN r.join_date < s.order_date THEN 'YES'
        WHEN r.join_date IS NULL THEN 'NO'
        ELSE 'NO'
    END AS is_member
FROM 
    sales AS s
JOIN menu AS m ON 
    s.product_id = m.product_id
JOIN members AS r ON 
    s.customer_id = r.customer_id;
```
### Ranking of customer products, with null rankings for non-member purchases
```
WITH CTE AS (
    SELECT 
        s.customer_id, 
        s.order_date, 
        m.product_name, 
        m.price,
        CASE 
            WHEN r.join_date IS NULL THEN 'No'
            WHEN r.join_date < s.order_date THEN 'YES'
            ELSE 'NO'
        END AS is_member
    FROM 
        sales AS s
    JOIN menu AS m ON 
        s.product_id = m.product_id
    JOIN members AS r ON 
        s.customer_id = r.customer_id
)
SELECT 
    CTE.*,
    CASE 
        WHEN CTE.is_member = 'NO' THEN NULL
        ELSE ROW_NUMBER() OVER (PARTITION BY CTE.customer_id, is_member ORDER BY CTE.order_date) 
    END AS rank
FROM 
    CTE;
```
## What I Learned
Throughout this project, I've sharpened my SQL skills significantly:

🧩 **Complex Query Crafting**: Mastered advanced SQL techniques, including CTEs and window functions. 

📊 **Data Aggregation**: Enhanced my ability to summarize data using aggregate functions like `SUM()` and `COUNT()`. 

💡 **Analytical Thinking**: Improved my problem-solving skills by translating business questions into actionable SQL queries. 

## Conclusions
From the analysis, several key insights were drawn:

- **Customer Spending**: Identified the total spending of each customer.
- **Customer Visits**: Determined the number of days each customer visited the restaurant.
- **Menu Popularity**: Revealed the most popular items and purchase patterns.
- **Loyalty Program Impact**: Analyzed the influence of the loyalty program on customer behavior.

These insights can help the restaurant optimize its menu, improve customer engagement, and enhance the loyalty program.
