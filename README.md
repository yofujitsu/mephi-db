# MEPHI Database Final Assignment (SQL)

This project contains SQL solutions for the final assignment in the Database Management course at MEPhI. The assignment consists of 13 tasks across 4 different databases, implemented in PostgreSQL.

## Project Structure

```
sql_2sem/
├── databases/
│   ├── 01_vehicles/
│   │   ├── schema.sql      # Database schema and data
│   │   └── solutions.sql   # Task solutions
│   ├── 02_racing/
│   │   ├── schema.sql
│   │   └── solutions.sql
│   ├── 03_hotels/
│   │   ├── schema.sql
│   │   └── solutions.sql
│   └── 04_organization/
│       ├── schema.sql
│       └── solutions.sql
├── docker-compose.yml
└── README.md
```

## Databases Overview

### 1. Vehicles Database
Manages information about vehicles including cars, motorcycles, and bicycles.

**Tables:**
- `Vehicle` - Base table with manufacturer, model, and type
- `Car` - Car-specific attributes (engine capacity, horsepower, price, transmission)
- `Motorcycle` - Motorcycle-specific attributes (engine capacity, horsepower, price, type)
- `Bicycle` - Bicycle-specific attributes (gear count, price, type)

**Tasks:**
- Task 1: Query motorcycles with specific criteria (horsepower > 150, price < $20000, Sport type)
- Task 2: Combined query for vehicles matching different criteria using UNION

### 2. Racing Database
Tracks car racing information including classes, cars, races, and results.

**Tables:**
- `Classes` - Car classes with type, country, specifications
- `Cars` - Car names linked to classes
- `Races` - Race names and dates
- `Results` - Race results linking cars to races with positions

**Tasks:**
- Task 1: Find cars with best average position per class
- Task 2: Find the overall best performing car
- Task 3: Find classes with best average positions and total races
- Task 4: Find cars better than their class average
- Task 5: Find classes with most cars having low average positions (> 3.0)

### 3. Hotels Database
Manages hotel bookings, customers, and rooms.

**Tables:**
- `Hotel` - Hotel information (name, location)
- `Room` - Room details (type, price, capacity)
- `Customer` - Customer information (name, email, phone)
- `Booking` - Booking records with check-in/check-out dates

**Tasks:**
- Task 1: Find customers with more than 2 bookings in different hotels
- Task 2: Analyze customers with >2 bookings and >$500 spent
- Task 3: Categorize hotels by price and determine customer preferences

### 4. Organization Database
Represents company structure with employees, departments, roles, projects, and tasks.

**Tables:**
- `Departments` - Department names
- `Roles` - Role titles
- `Employees` - Employee hierarchy with manager relationships
- `Projects` - Projects linked to departments
- `Tasks` - Tasks assigned to employees

**Tasks:**
- Task 1: Recursive query to find all employees under the CEO (Иван Иванов)
- Task 2: Recursive query with task counts and subordinate counts
- Task 3: Find managers with subordinates using RECURSIVE

## Requirements

- Docker and Docker Compose
- PostgreSQL client (psql) or pgAdmin

## Quick Start

### Using Docker Compose

1. Start the PostgreSQL container with all databases:
   ```bash
   docker-compose up -d
   ```

2. Connect to PostgreSQL:
   ```bash
   docker exec -it mephi-db-postgres psql -U postgres
   ```

3. Run queries from the solutions files:
   ```bash
   docker exec -i mephi-db-postgres psql -U postgres -f /docker-entrypoint-initdb.d/01_vehicles.sql
   ```

### Manual Setup

1. Create a PostgreSQL database:
   ```bash
   createdb -U postgres vehicles
   ```

2. Load the schema:
   ```bash
   psql -U postgres -d vehicles -f databases/01_vehicles/schema.sql
   ```

3. Run solutions:
   ```bash
   psql -U postgres -d vehicles -f databases/01_vehicles/solutions.sql
   ```

## Testing

To verify the solutions:

1. Start the Docker container
2. Connect to each database
3. Execute the corresponding solutions.sql file
4. Compare output with expected results from AGENTS.md

## Key SQL Features Used

- **JOIN operations**: INNER JOIN, LEFT JOIN
- **Set operations**: UNION, UNION ALL
- **Aggregate functions**: COUNT, SUM, AVG, MIN, MAX
- **Window functions**: SUM() OVER (PARTITION BY ...)
- **Common Table Expressions (CTEs)**: WITH clause
- **Recursive CTEs**: WITH RECURSIVE for hierarchical queries
- **String aggregation**: STRING_AGG for concatenating values
- **Conditional logic**: CASE WHEN expressions
- **Filtering**: HAVING clause for grouped data

## Author

Final assignment for Database Management course at MEPhI.
