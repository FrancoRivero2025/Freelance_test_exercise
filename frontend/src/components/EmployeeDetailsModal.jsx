import React, { memo, useCallback, useEffect } from "react";
import PropTypes from "prop-types";
import "../app.css";

const EmployeeDetailsModal = ({ employee, onClose }) => {
  const getStatusColor = () => {
    return employee?.is_active ? "#e8f5e9" : "#ffebee";
  };

  const handleKeyDown = useCallback(
    (e) => {
      if (e.key === "Escape") onClose();
    },
    [onClose]
  );

  useEffect(() => {
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  if (!employee) return null;
  console.log(employee);
  const employeeDetails = [
    { label: "Nombre completo", value: employee.fullname },
    { label: "Estado", value: employee.is_active ? "Activo" : "Inactivo" },
    { label: "Edad", value: employee.age },
    { label: "Área", value: employee.area },
    { label: "Antigüedad", value: `${employee.seniority} años` },
    { label: "Teléfono", value: employee.phone },
  ];

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        style={{ backgroundColor: getStatusColor() }}
      >
        <button className="close-button" onClick={onClose}>
          ×
        </button>
        <h2>Detalles del Empleado</h2>
        <div className="employee-details">
          {employeeDetails.map((detail) => (
            <p key={detail.label}>
              <strong>{detail.label}:</strong> {detail.value}
            </p>
          ))}
        </div>
      </div>
    </div>
  );
};

EmployeeDetailsModal.propTypes = {
  employee: PropTypes.shape({
    fullname: PropTypes.string,
    active: PropTypes.bool,
    age: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    area: PropTypes.string,
    seniority: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    phone: PropTypes.string,
    is_active: PropTypes.bool,
  }),
  onClose: PropTypes.func.isRequired,
};

export default memo(EmployeeDetailsModal);
