.open fittrackpro.db
.mode column

-- 2.1 
INSERT INTO payments (member_id, amount, payment_date, payment_method, payment_type)
VALUES (11, 50.00, datetime('now'), 'Credit Card', 'Monthly membership fee');

-- 2.2 
SELECT substr(payment_date, 1, 7) AS month, SUM(amount) AS total_revenue
FROM payments
WHERE payment_type = 'Monthly membership fee'
AND payment_date BETWEEN '2024-11-01' AND '2025-02-28'
GROUP BY month
ORDER BY month;

-- 2.3 
SELECT payment_id, amount, payment_date, payment_method
FROM payments
WHERE payment_type = 'Day pass';