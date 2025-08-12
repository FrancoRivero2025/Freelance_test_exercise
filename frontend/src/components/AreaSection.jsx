import React, { memo } from "react";
import PropTypes from "prop-types";
import EmployeeCard from "./EmployeeCard";
import "../app.css";

const AreaSection = ({ area, employees, onEmployeeClick }) => {
  if (employees.length === 0) {
    return <div className="area-section empty">No hay empleados en {area}</div>;
  }
  return (
    <section className="area-section" aria-labelledby={`area-${area}`}>
      <h2 id={`area-${area}`}>
        {area}{" "}
        <span className="employee-count">({employees.length} empleados)</span>
      </h2>
      <div className="employees-grid" role="list">
        {employees.map((employee) => (
          <EmployeeCard
            key={employee._id}
            employee={employee}
            onClick={onEmployeeClick}
            role="listitem"
          />
        ))}
      </div>
    </section>
  );
};

AreaSection.propTypes = {
  area: PropTypes.string.isRequired,
  employees: PropTypes.arrayOf(
    PropTypes.shape({
      _id: PropTypes.string.isRequired,
    })
  ).isRequired,
  onEmployeeClick: PropTypes.func.isRequired,
};

export default memo(AreaSection);
