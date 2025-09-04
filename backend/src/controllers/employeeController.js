import { EmployeeModel } from "../models/employeeModel.js";

export const EmployeeController = {
  getActive: async (req, res) => {
    try {
      const employees = await EmployeeModel.getActive();
      res.json(employees);
    } catch (err) {
      console.error("Error getting employees:", err);
      res.status(500).json({ error: "Error getting employees" });
    }
  },

  getAll: async (req, res) => {
    try {
      const employees = await EmployeeModel.getAll();
      res.json(employees);
    } catch (err) {
      console.error("Error getting all employees:", err);
      res.status(500).json({ error: "Error getting all employees" });
    }
  },

  getById: async (req, res) => {
    try {
      const employee = await EmployeeModel.getById(req.params.id);
      if (!employee) {
        return res.status(404).json({ error: "Employee not found" });
      }
      res.json(employee);
    } catch (err) {
      console.error("Error getting employee:", err);
      res.status(500).json({ error: "Error getting employee" });
    }
  },

  create: async (req, res) => {
    const { fullName, age, area, seniority, phone, is_active = true } = req.body;

    if (!fullName || !age || !area || !seniority || !phone) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    try {
      const employee = await EmployeeModel.create({
        fullName,
        age,
        area,
        seniority,
        phone,
        is_active,
      });
      res.status(201).json(employee);
    } catch (err) {
      console.error("Error creating employee:", err);
      res.status(500).json({ error: "Error creating employee" });
    }
  },

  update: async (req, res) => {
    try {
      const updated = await EmployeeModel.update(req.params.id, req.body);
      if (!updated) {
        return res.status(404).json({ error: "Employee not found" });
      }
      res.json(updated);
    } catch (err) {
      console.error("Error updating employee:", err);
      res.status(500).json({ error: "Error updating employee" });
    }
  },

  patch: async (req, res) => {
    try {
      if (Object.keys(req.body).length === 0) {
        return res.status(400).json({ error: "No fields to update" });
      }
      const result = await EmployeeModel.patch(req.params.id, req.body);
      res.json(result);
    } catch (err) {
      console.error("Error partially updating employee:", err);
      res.status(500).json({ error: "Error updating employee" });
    }
  },

  softDelete: async (req, res) => {
    try {
      const result = await EmployeeModel.softDelete(req.params.id);
      res.json(result);
    } catch (err) {
      console.error("Error deactivating employee:", err);
      res.status(500).json({ error: err.message });
    }
  },

  hardDelete: async (req, res) => {
    try {
      const result = await EmployeeModel.hardDelete(req.params.id);
      res.json(result);
    } catch (err) {
      console.error("Error deleting employee:", err);
      res.status(500).json({ error: err.message });
    }
  },
};
