import pool from "../db.js";

export const EmployeeModel = {
  getActive: async () => {
    const { rows } = await pool.query(`
      SELECT * FROM active_employees
      ORDER BY fullname ASC
    `);
    return rows;
  },

  getAll: async () => {
    const { rows } = await pool.query(`
      SELECT * FROM employees
      ORDER BY fullname ASC
    `);
    return rows;
  },

  getById: async (id) => {
    const { rows } = await pool.query(
      `SELECT * FROM employees WHERE id = $1`,
      [id]
    );
    return rows[0];
  },

  create: async ({ fullName, age, area, seniority, phone, is_active }) => {
    await pool.query(
      `CALL insert_employee($1, $2, $3, $4, $5, $6)`,
      [fullName, age, area, seniority, phone, is_active]
    );

    const { rows } = await pool.query(
      `SELECT * FROM employees 
       WHERE fullName = $1 
       ORDER BY created_at DESC 
       LIMIT 1`,
      [fullName]
    );

    return rows[0];
  },

  update: async (id, { fullName, age, area, seniority, phone, is_active }) => {
    const { rows } = await pool.query(
      "SELECT * FROM update_employee($1, $2, $3, $4, $5, $6, $7)",
      [id, fullName, age, area, seniority, phone, is_active]
    );
    return rows[0]?.update_employee;
  },

  patch: async (id, updates) => {
    const query = `
      SELECT update_employee($1, $2, $3, $4, $5, $6, $7) as result
    `;

    const values = [
      id,
      updates.fullName || null,
      updates.age || null,
      updates.area || null,
      updates.seniority || null,
      updates.phone || null,
      updates.is_active !== undefined ? updates.is_active : null,
    ];

    const { rows } = await pool.query(query, values);
    return rows[0].result;
  },

  softDelete: async (id) => {
    const { rows } = await pool.query(
      "SELECT deactivate_employee($1) as employee",
      [id]
    );
    return rows[0].employee;
  },

  hardDelete: async (id) => {
    await pool.query("CALL delete_employee($1, NULL)", [id]);
    const result = await pool.query(
      "SELECT p_deleted_employee FROM delete_employee_result"
    );
    return result.rows[0].p_deleted_employee;
  },
};
