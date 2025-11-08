
create database hostelDB;
use hostelDB;
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    gender VARCHAR(10),
    course VARCHAR(50),
    year INT
);


CREATE TABLE Hostels (
    hostel_id INT PRIMARY KEY,
    hostel_name VARCHAR(50),
    capacity INT
);


CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    hostel_id INT,
    room_number VARCHAR(10),
    capacity INT,
    FOREIGN KEY (hostel_id) REFERENCES Hostels(hostel_id)
);


CREATE TABLE Room_Allocation (
    allocation_id INT PRIMARY KEY,
    student_id INT,
    room_id INT,
    allocation_date DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);


INSERT INTO Students VALUES
(1, 'Alice', 'Female', 'B.Tech', 2),
(2, 'Bob', 'Male', 'B.Sc', 1),
(3, 'Charlie', 'Male', 'B.Tech', 2),
(4, 'Diana', 'Female', 'BBA', 3),
(5, 'Ethan', 'Male', 'BCA', 1),
(6, 'Fiona', 'Female', 'B.Sc', 1),
(7, 'George', 'Male', 'BBA', 3),
(8, 'Hannah', 'Female', 'B.Tech', 2);


INSERT INTO Hostels VALUES
(1, 'Sunrise Hostel', 10),
(2, 'Moonlight Hostel', 8);


INSERT INTO Rooms VALUES
(1, 1, '101', 2),
(2, 1, '102', 2),
(3, 1, '103', 2),
(4, 2, '201', 2),
(5, 2, '202', 2),
(6, 2, '203', 2);


INSERT INTO Room_Allocation VALUES
(1, 1, 1, '2025-01-10'),
(2, 2, 1, '2025-01-11'),
(3, 3, 2, '2025-01-12'),
(4, 4, 2, '2025-01-13'),
(5, 5, 3, '2025-01-14'),
(6, 6, 3, '2025-01-15'),
(7, 7, 4, '2025-01-16'),
(8, 8, 5, '2025-01-17');

-- 1:List all students
SELECT * FROM Students;

-- 2: Find all rooms in Sunrise Hostel
SELECT room_number FROM Rooms 
WHERE hostel_id = (SELECT hostel_id FROM Hostels WHERE hostel_name='Sunrise Hostel');

-- 3: Show students allocated to room 101
SELECT student_name FROM Students
WHERE student_id IN (SELECT student_id FROM Room_Allocation WHERE room_id=1);

-- 4: Count total students in each hostel
SELECT h.hostel_name, COUNT(ra.student_id) AS total_students
FROM Hostels h
JOIN Rooms r ON h.hostel_id = r.hostel_id
JOIN Room_Allocation ra ON r.room_id = ra.room_id
GROUP BY h.hostel_name;

-- 5: List unallocated students
SELECT student_name FROM Students
WHERE student_id NOT IN (SELECT student_id FROM Room_Allocation);

-- 6: Find rooms with remaining capacity
SELECT r.room_number, (r.capacity - COUNT(ra.student_id)) AS remaining_capacity
FROM Rooms r
LEFT JOIN Room_Allocation ra ON r.room_id = ra.room_id
GROUP BY r.room_id, r.room_number, r.capacity
HAVING remaining_capacity > 0;

-- 7: Get allocation date for each student
SELECT s.student_name, ra.allocation_date
FROM Students s
JOIN Room_Allocation ra ON s.student_id = ra.student_id;

-- 8: List male students in Moonlight Hostel
SELECT s.student_name FROM Students s
JOIN Room_Allocation ra ON s.student_id = ra.student_id
JOIN Rooms r ON ra.room_id = r.room_id
JOIN Hostels h ON r.hostel_id = h.hostel_id
WHERE s.gender='Male' AND h.hostel_name='Moonlight Hostel';

-- 9: Find hostels with more than 1 student allocated
SELECT h.hostel_name FROM Hostels h
JOIN Rooms r ON h.hostel_id = r.hostel_id
JOIN Room_Allocation ra ON r.room_id = ra.room_id
GROUP BY h.hostel_name
HAVING COUNT(ra.student_id) > 1;

-- 10: Show students allocated in alphabetical order
SELECT 
    s.student_name
FROM
    Students s
        JOIN
    Room_Allocation ra ON s.student_id = ra.student_id
ORDER BY s.student_name;

-- 11: Display hostel capacity vs allocated students
SELECT h.hostel_name, h.capacity, COUNT(ra.student_id) AS allocated_students
FROM Hostels h
LEFT JOIN Rooms r ON h.hostel_id = r.hostel_id
LEFT JOIN Room_Allocation ra ON r.room_id = ra.room_id
GROUP BY h.hostel_name, h.capacity;

-- 12: List students allocated after a specific date
SELECT s.student_name, ra.allocation_date FROM Students s
JOIN Room_Allocation ra ON s.student_id = ra.student_id
WHERE ra.allocation_date > '2025-01-10';

-- 13: Find students sharing the same room
SELECT r.room_number, GROUP_CONCAT(s.student_name) AS students
FROM Rooms r
JOIN Room_Allocation ra ON r.room_id = ra.room_id
JOIN Students s ON ra.student_id = s.student_id
GROUP BY r.room_number
HAVING COUNT(s.student_id) > 1;

-- 14: Count students by course in hostels
SELECT s.course, COUNT(ra.student_id) AS total_students
FROM Students s
LEFT JOIN Room_Allocation ra ON s.student_id = ra.student_id
GROUP BY s.course;

-- 15: Find rooms fully occupied
SELECT r.room_number FROM Rooms r
JOIN Room_Allocation ra ON r.room_id = ra.room_id
GROUP BY r.room_id, r.capacity, r.room_number
HAVING COUNT(ra.student_id) = r.capacity;
