-- База данных 4: Структура организации
-- Задача 1: Найти всех сотрудников, подчиняющихся Ивану Иванову (EmployeeID = 1), с использованием RECURSIVE

WITH RECURSIVE hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        0 AS level
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        h.level + 1
    FROM Employees e
    JOIN hierarchy h ON e.ManagerID = h.EmployeeID
),
employee_projects AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
    FROM Employees e
    LEFT JOIN Projects p ON e.DepartmentID = p.DepartmentID
    GROUP BY e.EmployeeID
),
employee_tasks AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY e.EmployeeID
)
SELECT
    h.EmployeeID,
    h.Name AS EmployeeName,
    h.ManagerID,
    d.DepartmentName,
    r.RoleName,
    ep.ProjectNames,
    et.TaskNames
FROM hierarchy h
JOIN Departments d ON h.DepartmentID = d.DepartmentID
JOIN Roles r ON h.RoleID = r.RoleID
LEFT JOIN employee_projects ep ON h.EmployeeID = ep.EmployeeID
LEFT JOIN employee_tasks et ON h.EmployeeID = et.EmployeeID
ORDER BY h.Name;

-- Задача 2: Найти всех сотрудников, подчиняющихся Ивану Иванову, с количеством задач и подчиненных

WITH RECURSIVE hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        0 AS level
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        h.level + 1
    FROM Employees e
    JOIN hierarchy h ON e.ManagerID = h.EmployeeID
),
employee_projects AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
    FROM Employees e
    LEFT JOIN Projects p ON e.DepartmentID = p.DepartmentID
    GROUP BY e.EmployeeID
),
employee_tasks AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames,
        COUNT(DISTINCT t.TaskID) AS TotalTasks
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY e.EmployeeID
),
subordinate_count AS (
    SELECT
        ManagerID,
        COUNT(*) AS TotalSubordinates
    FROM Employees
    GROUP BY ManagerID
)
SELECT
    h.EmployeeID,
    h.Name AS EmployeeName,
    h.ManagerID,
    d.DepartmentName,
    r.RoleName,
    ep.ProjectNames,
    et.TaskNames,
    et.TotalTasks,
    COALESCE(sc.TotalSubordinates, 0) AS TotalSubordinates
FROM hierarchy h
JOIN Departments d ON h.DepartmentID = d.DepartmentID
JOIN Roles r ON h.RoleID = r.RoleID
LEFT JOIN employee_projects ep ON h.EmployeeID = ep.EmployeeID
LEFT JOIN employee_tasks et ON h.EmployeeID = et.EmployeeID
LEFT JOIN subordinate_count sc ON h.EmployeeID = sc.ManagerID
ORDER BY h.Name;

-- Задача 3: Найти менеджеров с подчиненными с использованием RECURSIVE

WITH RECURSIVE hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN hierarchy h ON e.ManagerID = h.EmployeeID
),
all_subordinates AS (
    SELECT
        h.EmployeeID AS manager_id,
        COUNT(DISTINCT sub.EmployeeID) AS TotalSubordinates
    FROM hierarchy h
    JOIN hierarchy sub ON sub.ManagerID = h.EmployeeID OR sub.EmployeeID IN (
        SELECT EmployeeID FROM hierarchy WHERE ManagerID = h.EmployeeID
    )
    WHERE h.EmployeeID != sub.EmployeeID
    GROUP BY h.EmployeeID
),
manager_subordinates AS (
    SELECT
        e.EmployeeID,
        COUNT(DISTINCT sub.EmployeeID) AS TotalSubordinates
    FROM Employees e
    JOIN hierarchy sub ON sub.ManagerID = e.EmployeeID
    WHERE e.RoleID = 1
    GROUP BY e.EmployeeID
    HAVING COUNT(DISTINCT sub.EmployeeID) > 0
),
employee_projects AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
    FROM Employees e
    LEFT JOIN Projects p ON e.DepartmentID = p.DepartmentID
    GROUP BY e.EmployeeID
),
employee_tasks AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY e.EmployeeID
)
SELECT
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    ep.ProjectNames,
    et.TaskNames,
    ms.TotalSubordinates
FROM Employees e
JOIN manager_subordinates ms ON e.EmployeeID = ms.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Roles r ON e.RoleID = r.RoleID
LEFT JOIN employee_projects ep ON e.EmployeeID = ep.EmployeeID
LEFT JOIN employee_tasks et ON e.EmployeeID = et.EmployeeID
ORDER BY e.Name;
