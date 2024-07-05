-- 1. What is the total amount each customer spent at the restaurant?
Select 
		s.customer_id, 
		SUM(m.price) as total_amount
From 
	sales as s 
Join menu as m On 
s.product_id=m.product_id
Group By 
	s.customer_id

--2. How many days has each customer visited the restaurant?
Select Count(Distinct(order_date)) as No_of_days_visted, customer_id
from sales 
group by customer_id

	

--3. What was the first item from the menu purchased by each customer?
WITH CTE as	(Select s.order_date as First_order, s.customer_id, m.product_name,
		Rank () Over(Partition By customer_id Order by order_date ASC) as Rank
	From sales as s 
	Join menu as m On 
	s.product_id=m.product_id
)

Select * From CTE 
Where Rank = 1

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
With CTE as	(Select Count(s.order_date) as orders, m.product_name
	From 
		sales as s 
	Join menu as m On 
	s.product_id=m.product_id
	Group by m.product_name
	Order By orders DESC
	Limit 1)
Select *
From CTE 

--5. Which item was the most popular for each customer?

With CTE as	(Select  m.product_name, customer_id, Count(s.order_date) as orders,
	Rank () Over (Partition By customer_id order by Count(s.order_date) DESC) as rnk,
	Row_Number () Over (Partition By customer_id order by Count(s.order_date) DESC) as rn
	From 
		sales as s 
	Join menu as m On 
	s.product_id=m.product_id
	Group by m.product_name, customer_id
	)
Select *
From CTE 
where rn = 1 

-- 6. Which item was purchased first by the customer after they became a member?

with CTE AS (Select s.customer_id, product_name, order_date, p.join_date,
	Rank () Over(Partition By s.customer_id order by order_date ) as rnk,
	Row_Number () Over(Partition By s.customer_id order by order_date ) as rn
From sales as s 
Join menu as m On 
s.product_id=m.product_id
Join members as p ON
p.customer_id = s.customer_id
Where s.order_date >= p.join_date)
Select * 
From CTE
where rn =1

-- 7. Which item was purchased first by the customer before they became a member?

with CTE AS (Select s.customer_id, product_name, order_date, p.join_date,
	Rank () Over(Partition By s.customer_id order by order_date ) as rnk,
	Row_Number () Over(Partition By s.customer_id order by order_date ) as rn
From sales as s 
Join menu as m On 
s.product_id=m.product_id
Join members as p ON
p.customer_id = s.customer_id
Where s.order_date < p.join_date)
	
Select * 
From CTE
where rn =1

-- 8. What is the total items and amount spent for each member before they became a member?

Select s.customer_id, COunt(s.order_date) as total_items, Sum(m.price) as total_amount
From sales as s
Join menu as m on 
s.product_id = m.product_id
Join members as r On
s.customer_id=r.customer_id
	
where s.order_date < join_date
Group by s.customer_id

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
With CTE as (Select s.customer_id,
	Sum (CASE
		When product_name = 'sushi' then price*20
		Else price*10
	End)  as Points
From sales as s
Join menu as m on
s.product_id = m.product_id
Group By customer_id,product_name, price)

Select customer_id, SUM(Points)
From CTE
Group By customer_id

	-- Second approach

Select 
	customer_id,
	SUM(
	Case
		When product_name = 'sushi' then price * 10 * 2
		Else price *10 
	End ) as Points
From sales s
Join menu as m On
s.product_id = m.product_id
Group By customer_id



--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
	-- how many points do customer A and B have at the end of January

	

With CTE as (SELECT 
    s.customer_id,
    (
        CASE
            WHEN s.order_date BETWEEN r.join_date AND (r.join_date + INTERVAL '6 DAY') THEN m.price * 10 * 2
            ELSE m.price * 10 
        END
    ) AS Points,
    r.join_date AS offer_start,
    (r.join_date + INTERVAL '6 DAY') AS offer_end
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members r ON s.customer_id = r.customer_id

)
Select customer_id, Sum(Points)
from CTE 
Group By customer_id


-- How many points do customers A and B have at the end of January

SELECT 
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN r.join_date AND (r.join_date + INTERVAL '6 DAY') THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members r ON s.customer_id = r.customer_id
WHERE DATE_TRUNC('month', s.order_date) = DATE_TRUNC('month', DATE '2021-01-01')
GROUP BY s.customer_id;


-- The following questions are related to creating basic data tables that Danny and 
-- his team can quickly use to derive insights without needing to join the underlying tables using SQL.

-- Recreate the following table output using the available data:

-- customer_id	order_date	product_name	price	member

Select 
	s.customer_id, 
	s.order_date, 
	m.product_name, 
	m.price,
	r.join_date,
	case 
		when r.join_date < s.order_date Then 'YES'
		when join_date is Null Then 'No'
		Else 'NO'
	End as IsMember
From sales as s

join menu as m ON
s.product_id = m.product_id
join members as r On
s.customer_id = r.customer_id

/*BONUS Questions 
Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
for the records when customers are not yet part of the loyalty program.

customer_id	order_date	product_name	price	member	ranking

*/

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
        END AS IsMember    
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members r ON s.customer_id = r.customer_id
)

SELECT 
    CTE.*,
    CASE 
        WHEN CTE.IsMember = 'NO' THEN 'Null'
        ELSE CAST(Row_Number() OVER (PARTITION BY CTE.customer_id, IsMember ORDER BY CTE.order_date) AS VARCHAR)
    END AS Rank
FROM CTE;



