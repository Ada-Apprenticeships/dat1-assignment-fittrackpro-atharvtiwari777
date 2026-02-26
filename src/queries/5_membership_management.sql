.open fittrackpro.db
.mode column

-- 5.1 
SELECT m.member_id, m.first_name, m.last_name, ms.type AS membership_type, m.join_date
FROM members m
JOIN memberships ms ON m.member_id = ms.member_id
WHERE ms.status = 'Active';

-- 5.2 
SELECT ms.type AS membership_type,
       ROUND(AVG((julianday(a.check_out_time) - julianday(a.check_in_time)) * 24 * 60), 2) AS avg_visit_duration_minutes
FROM memberships ms
JOIN attendance a ON ms.member_id = a.member_id
WHERE a.check_out_time IS NOT NULL
GROUP BY ms.type;

-- 5.3 
-- 5.3
SELECT m.member_id, m.first_name, m.last_name, m.email, ms.end_date
FROM members m
JOIN memberships ms ON m.member_id = ms.member_id
WHERE ms.end_date BETWEEN 2025-12-31 AND 2025-01-01;
