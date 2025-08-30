import express from "express";
import { EmployeeController } from "../controllers/employeeController.js";

const router = express.Router();

router.get("/", EmployeeController.getActive);
router.get("/all", EmployeeController.getAll);
router.get("/:id", EmployeeController.getById);

router.post("/", EmployeeController.create);
router.put("/:id", EmployeeController.update);
router.patch("/:id", EmployeeController.patch);

router.delete("/:id", EmployeeController.softDelete);
router.delete("/hard/:id", EmployeeController.hardDelete);

export default router;
