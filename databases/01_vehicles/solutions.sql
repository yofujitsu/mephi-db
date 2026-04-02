-- Database 1: Vehicles
-- Task 1: Find manufacturers and models of motorcycles with horsepower > 150, price < 20000, and type Sport
-- Sorted by horsepower descending

SELECT 
    v.maker,
    m.model
FROM Motorcycle m
JOIN Vehicle v ON m.model = v.model
WHERE m.horsepower > 150 
    AND m.price < 20000.00 
    AND m.type = 'Sport'
ORDER BY m.horsepower DESC;

-- Task 2: Find vehicles (cars, motorcycles, bicycles) matching specific criteria
-- Cars: horsepower > 150, engine_capacity < 3.0, price < 35000
-- Motorcycles: horsepower > 150, engine_capacity < 1.5, price < 20000
-- Bicycles: gear_count > 18, price < 4000
-- Sorted by horsepower descending (bicycles with NULL at the end)

(SELECT 
    v.maker,
    c.model,
    c.horsepower,
    c.engine_capacity,
    'Car' AS vehicle_type
FROM Car c
JOIN Vehicle v ON c.model = v.model
WHERE c.horsepower > 150 
    AND c.engine_capacity < 3.0 
    AND c.price < 35000.00)
UNION ALL
(SELECT 
    v.maker,
    m.model,
    m.horsepower,
    m.engine_capacity,
    'Motorcycle' AS vehicle_type
FROM Motorcycle m
JOIN Vehicle v ON m.model = v.model
WHERE m.horsepower > 150 
    AND m.engine_capacity < 1.5 
    AND m.price < 20000.00)
UNION ALL
(SELECT 
    v.maker,
    b.model,
    NULL AS horsepower,
    NULL AS engine_capacity,
    'Bicycle' AS vehicle_type
FROM Bicycle b
JOIN Vehicle v ON b.model = v.model
WHERE b.gear_count > 18 
    AND b.price < 4000.00)
ORDER BY horsepower DESC NULLS LAST;
