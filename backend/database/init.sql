-- Employee table creation with data validation constraints
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL CHECK (fullName <> ''),  -- Employee's full name (cannot be empty)
    age INT NOT NULL CHECK (age BETWEEN 18 AND 65),         -- Age must be between 18-65
    area VARCHAR(50) NOT NULL CHECK (area <> ''),           -- Department/area (cannot be empty)
    seniority INT NOT NULL CHECK (seniority <> 0),          -- Years of experience (cannot be zero)
    phone VARCHAR(20) NOT NULL CHECK (phone <> ''),         -- Contact number (cannot be empty)
    is_active BOOLEAN DEFAULT TRUE,                         -- Active status flag
    last_activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Last activity timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,         -- Record creation timestamp
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP          -- Last update timestamp
);

COMMENT ON TABLE employees IS 'Stores employee information with data validation';

-- Function to automatically update timestamps on record updates
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.last_activity_date = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute timestamp updates before any employee record update
CREATE TRIGGER update_employee_timestamp
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Function to clean and standardize employee data before insert/update
CREATE OR REPLACE FUNCTION clean_employee_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Trim and normalize whitespace in full name
    NEW.fullName = regexp_replace(trim(NEW.fullName), '\s+', ' ', 'g');
    
    -- Standardize phone number format (digits and + only)
    NEW.phone = regexp_replace(NEW.phone, '[^0-9+]', '', 'g');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute data cleaning before insert/update operations
CREATE TRIGGER clean_employee_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION clean_employee_data();

-- Procedure to insert new employee with basic validation
CREATE OR REPLACE PROCEDURE insert_employee(
    p_fullName VARCHAR(100),
    p_age INT,
    p_area VARCHAR(50),
    p_seniority INT,
    p_phone VARCHAR(20),
    p_is_active BOOLEAN DEFAULT TRUE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (fullName, age, area, seniority, phone, is_active)
    VALUES (p_fullName, p_age, p_area, p_seniority, p_phone, p_is_active);
    
    RAISE NOTICE 'Employee % added successfully', p_fullName;
    COMMIT;
END;
$$;

-- Function to update employee records with partial update capability
CREATE OR REPLACE FUNCTION update_employee(
    p_id INT,
    p_fullName VARCHAR(100) DEFAULT NULL,
    p_age INT DEFAULT NULL,
    p_area VARCHAR(50) DEFAULT NULL,
    p_seniority INT DEFAULT NULL,
    p_phone VARCHAR(20) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    -- Check if employee exists
    IF NOT EXISTS (SELECT 1 FROM employees WHERE id = p_id) THEN
        RAISE EXCEPTION 'Employee with ID % not found', p_id;
    END IF;
    
    -- Perform partial update (only non-null parameters will change)
    UPDATE employees 
    SET 
        fullName = COALESCE(p_fullName, fullName),
        age = COALESCE(p_age, age),
        area = COALESCE(p_area, area),
        seniority = COALESCE(p_seniority, seniority),
        phone = COALESCE(p_phone, phone),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id
    RETURNING to_json(employees.*) INTO result;
    
    RAISE NOTICE 'Successfully updated employee with ID %', p_id;
    RETURN result;
END;
$$;

-- Procedure to safely delete an employee and return their data
CREATE OR REPLACE PROCEDURE delete_employee(
    p_id INT,
    OUT p_deleted_employee JSON
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verify employee exists
    IF NOT EXISTS (SELECT 1 FROM employees WHERE id = p_id) THEN
        RAISE EXCEPTION 'Employee with ID % not found', p_id;
    END IF;
    
    -- Delete and return the deleted record
    DELETE FROM employees 
    WHERE id = p_id
    RETURNING to_json(employees.*) INTO p_deleted_employee;
    
    -- Verify deletion was successful
    IF p_deleted_employee IS NULL THEN
        RAISE EXCEPTION 'Employee with ID % could not be deleted', p_id;
    END IF;
    
    RAISE NOTICE 'Successfully deleted employee with ID %', p_id;
END;
$$;

-- Function to deactivate an employee
CREATE OR REPLACE FUNCTION deactivate_employee(
    p_id INT
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    result JSON;
BEGIN
    -- Verify employee exists
    IF NOT EXISTS (SELECT 1 FROM employees WHERE id = p_id) THEN
        RAISE EXCEPTION 'Employee with ID % not found', p_id;
    END IF;
    
    -- Check if already deactivated
    IF EXISTS (SELECT 1 FROM employees WHERE id = p_id AND is_active = false) THEN
        RAISE NOTICE 'Employee with ID % is already deactivated', p_id;
    END IF;
    
    -- Perform deactivation
    UPDATE employees 
    SET 
        is_active = false,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id
    RETURNING to_json(employees.*) INTO result;
    
    RAISE NOTICE 'Successfully deactivated employee with ID %', p_id;
    RETURN result;
END;
$$;

-- View showing only active employees
CREATE OR REPLACE VIEW active_employees AS
SELECT id, fullName, age, area, seniority, phone, is_active 
FROM employees 
WHERE is_active = TRUE;
