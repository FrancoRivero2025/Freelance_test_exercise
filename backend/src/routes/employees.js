import express from "express";
import pool from "../db.js";

const router = express.Router();

// GET /employees - List all active employees (using the view)
router.get("/", async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT * FROM active_employees
      ORDER BY fullname ASC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error getting employees:", err);
    res.status(500).json({ error: "Error getting employees" });
  }
});

// GET /employees/all - List all employees including inactive ones
router.get("/all", async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT * FROM employees
      ORDER BY fullname ASC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error getting all employees:", err);
    res.status(500).json({ error: "Error getting all employees" });
  }
});


// GET /employees/:id - Get single employee by id
router.get("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const { rows } = await pool.query(`
      SELECT * FROM employees 
      WHERE ID = $1
    `, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: "Employee not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("Error getting employee:", err);
    res.status(500).json({ error: "Error getting employee" });
  }
});

// POST /employees - Create new employee
router.post("/", async (req, res) => {
  const { fullName, age, area, seniority, phone, is_active = true } = req.body;

  // Basic validation
  if (!fullName || !age || !area || !seniority || !phone) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // Using the stored procedure
    await pool.query(`
      CALL insert_employee($1, $2, $3, $4, $5, $6)
    `, [fullName, age, area, seniority, phone, is_active]);

    // Get the newly created employee to return it
    const { rows } = await pool.query(`
      SELECT * FROM employees 
      WHERE fullName = $1 
      ORDER BY created_at DESC 
      LIMIT 1
    `, [fullName]);

    res.status(201).json(rows[0]);
  } catch (err) {
    console.error("Error creating employee:", err);
    res.status(500).json({ error: "Error creating employee" });
  }
});

// PUT /employees/:id - Update employee
router.put("/:id", async (req, res) => {
  const { id } = req.params;
  const { fullName, age, area, seniority, phone, is_active } = req.body;

  try {
    const { rows } = await pool.query(
      'SELECT * FROM update_employee($1, $2, $3, $4, $5, $6, $7)',
      [id, fullName, age, area, seniority, phone, is_active]
    );

    if (!rows[0]?.update_employee) {
      return res.status(404).json({ error: "Employee not found" });
    }

    res.json(rows[0].update_employee);
  } catch (err) {
    console.error("Error updating employee:", err);
    res.status(500).json({ 
      error: "Error updating employee",
      details: err.message 
    });
  }
});

// PATCH /employees/:id - Partial update employee
router.patch("/:id", async (req, res) => {
  const { id } = req.params;
  const updates = req.body;

  if (Object.keys(updates).length === 0) {
    return res.status(400).json({ error: "No fields to update" });
  }

  try {
    const allowedFields = ['fullName', 'age', 'area', 'seniority', 'phone', 'is_active'];
    const filteredUpdates = {};
    
    for (const [key, value] of Object.entries(updates)) {
      if (allowedFields.includes(key)) {
        filteredUpdates[key] = value;
      }
    }

    const query = `
      SELECT update_employee(
        $1, -- id
        $2, -- fullName
        $3, -- age
        $4, -- area
        $5, -- seniority
        $6, -- phone
        $7  -- is_active
      ) as result`;
    
    const values = [
      id,
      filteredUpdates.fullName || null,
      filteredUpdates.age || null,
      filteredUpdates.area || null,
      filteredUpdates.seniority || null,
      filteredUpdates.phone || null,
      filteredUpdates.is_active !== undefined ? filteredUpdates.is_active : null
    ];

    const { rows } = await pool.query(query, values);

    const result = rows[0].result;
    
    res.json(result);
  } catch (err) {
    console.error("Error partially updating employee:", err);
    
    if (err.message && err.message.includes('not found')) {
      return res.status(404).json({ error: err.message });
    }
    
    res.status(500).json({ error: "Error updating employee" });
  }
});

// DELETE /employees/:id - Soft delete (set inactive) employee
router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const { rows } = await pool.query('SELECT deactivate_employee($1) as employee', [id]);
    res.json(rows[0].employee);
  } catch (err) {
    console.error("Error deactivating employee:", err);
    res.status(500).json({ error: err.message });
  }
});

// DELETE /employees/hard/:id - Hard delete employee (permanent)
router.delete("/hard/:id", async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query('CALL delete_employee($1, NULL)', [id]);
    
    const result = await pool.query(
      'SELECT p_deleted_employee FROM delete_employee_result'
    );
    
    res.json(result.rows[0].p_deleted_employee);
  } catch (err) {
    console.error("Error deleting employee:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
