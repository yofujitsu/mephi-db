-- База данных 2: Автомобильные гонки
-- Задача 1: Найти автомобили с наилучшей средней позицией в каждом классе

WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
best_per_class AS (
    SELECT
        car_class,
        MIN(average_position) AS min_avg_position
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count
FROM car_stats cs
JOIN best_per_class bpc ON cs.car_class = bpc.car_class AND cs.average_position = bpc.min_avg_position
ORDER BY cs.average_position;

-- Задача 2: Найти автомобиль с наилучшей общей средней позицией

WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
)
SELECT
    car_name,
    car_class,
    average_position,
    race_count,
    car_country
FROM car_stats
WHERE average_position = (SELECT MIN(average_position) FROM car_stats)
ORDER BY car_name
LIMIT 1;

-- Задача 3: Найти классы с наилучшей средней позицией и их общее количество гонок

WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
best_avg AS (
    SELECT MIN(average_position) AS min_avg FROM car_stats
),
best_classes AS (
    SELECT DISTINCT car_class
    FROM car_stats
    WHERE average_position = (SELECT min_avg FROM best_avg)
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cs.car_country,
    SUM(cs.race_count) OVER (PARTITION BY cs.car_class) AS total_races
FROM car_stats cs
JOIN best_classes bc ON cs.car_class = bc.car_class;

-- Задача 4: Найти автомобили со средней позицией лучше средней по классу (классы с минимум 2 автомобилями)

WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
class_stats AS (
    SELECT
        car_class,
        AVG(average_position) AS class_avg_position,
        COUNT(*) AS car_count
    FROM car_stats
    GROUP BY car_class
    HAVING COUNT(*) >= 2
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cs.car_country
FROM car_stats cs
JOIN class_stats cls ON cs.car_class = cls.car_class
WHERE cs.average_position < cls.class_avg_position
ORDER BY cs.car_class, cs.average_position;

-- Задача 5: Найти классы с наибольшим количеством автомобилей с низкой средней позицией (> 3.0)

WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(*) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
class_low_count AS (
    SELECT
        car_class,
        COUNT(*) AS low_position_count
    FROM car_stats
    WHERE average_position > 3.0
    GROUP BY car_class
),
max_low_count AS (
    SELECT MAX(low_position_count) AS max_count
    FROM class_low_count
),
target_classes AS (
    SELECT car_class
    FROM class_low_count
    WHERE low_position_count = (SELECT max_count FROM max_low_count)
),
class_total_races AS (
    SELECT
        car_class,
        SUM(race_count) AS total_races
    FROM car_stats
    GROUP BY car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cs.car_country,
    ctr.total_races,
    clc.low_position_count
FROM car_stats cs
JOIN target_classes tc ON cs.car_class = tc.car_class
JOIN class_low_count clc ON cs.car_class = clc.car_class
JOIN class_total_races ctr ON cs.car_class = ctr.car_class
ORDER BY clc.low_position_count DESC, cs.car_class;
