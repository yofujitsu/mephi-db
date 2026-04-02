-- База данных 3: Бронирование отелей
-- Задача 1: Найти клиентов, сделавших более двух бронирований в разных отелях

WITH customer_bookings AS (
    SELECT
        c.ID_customer,
        c.name,
        c.email,
        c.phone,
        COUNT(b.ID_booking) AS total_bookings,
        STRING_AGG(DISTINCT h.name, ', ' ORDER BY h.name) AS hotels,
        AVG(b.check_out_date - b.check_in_date) AS avg_stay
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name, c.email, c.phone
    HAVING COUNT(b.ID_booking) > 2
)
SELECT
    name,
    email,
    phone,
    total_bookings,
    hotels,
    avg_stay
FROM customer_bookings
ORDER BY total_bookings DESC;

-- Задача 2: Найти клиентов с более чем 2 бронированиями и суммой трат более $500

WITH customer_stats AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name
)
SELECT
    ID_customer,
    name,
    total_bookings,
    total_spent,
    unique_hotels
FROM customer_stats
WHERE total_bookings > 2
    AND unique_hotels > 1
    AND total_spent > 500
ORDER BY total_spent;

-- Задача 3: Предпочтения клиентов по типу отелей на основе категории цен

WITH hotel_avg_price AS (
    SELECT
        h.ID_hotel,
        h.name AS hotel_name,
        AVG(r.price) AS avg_price,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
customer_hotels AS (
    SELECT
        c.ID_customer,
        c.name,
        hcp.hotel_category,
        hcp.hotel_name
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN hotel_avg_price hcp ON r.ID_hotel = hcp.ID_hotel
),
customer_preference AS (
    SELECT
        ID_customer,
        name,
        CASE
            WHEN MAX(CASE WHEN hotel_category = 'Дорогой' THEN 1 ELSE 0 END) = 1 THEN 'Дорогой'
            WHEN MAX(CASE WHEN hotel_category = 'Средний' THEN 1 ELSE 0 END) = 1 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type,
        STRING_AGG(DISTINCT hotel_name, ',' ORDER BY hotel_name) AS visited_hotels
    FROM customer_hotels
    GROUP BY ID_customer, name
)
SELECT
    ID_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM customer_preference
ORDER BY
    CASE preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END,
    name;
