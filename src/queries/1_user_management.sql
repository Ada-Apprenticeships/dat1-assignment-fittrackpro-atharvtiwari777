.open fittrackpro.db
.mode column

-- 1.1
SELECT member_id, first_name, last_name, email, join_date 
FROM members;

-- 1.2
UPDATE members
SET phone_number = '07000 100005', email = 'emily.jones.updated@newemail.com'
WHERE member_id = 5;

-- 1.3
SELECT COUNT(*)
FROM members;

-- 1.4
SELECT m.member_id, m.first_name, m.last_name, COUNT(*) AS registration_count
FROM members m
JOIN class_attendance ca ON m.member_id = ca.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY registration_count DESC
LIMIT 1;

-- 1.5
SELECT m.member_id, m.first_name, m.last_name, COUNT(*) AS registration_count
FROM members m
JOIN class_attendance ca ON m.member_id = ca.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY registration_count ASC
LIMIT 1;

-- 1.6
SELECT COUNT(*) AS total_members
FROM (
    SELECT m.member_id
    FROM members m
    JOIN class_attendance ca ON m.member_id = ca.member_id
    WHERE ca.attendance_status = 'Attended'
    GROUP BY m.member_id
    HAVING COUNT(*) >= 2
);
