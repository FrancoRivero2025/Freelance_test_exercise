import React, { memo } from "react";
import PropTypes from "prop-types";
import EmployeeCard from "./EmployeeCard";
import "../app.css";

const AreaSection = ({ area, employees, onEmployeeClick }) => {
  if (employees.length === 0) {
    return (
      <div className="area-section bg-white rounded-xl p-6 mb-6 shadow-md border border-gray-200">
        No hay empleados en {area}
      </div>
    );
  }
  return (
    <section
      className="area-section bg-white rounded-xl p-6 mb-6 shadow-md border border-gray-200 transition-shadow duration-300 hover:shadow-lg"
      aria-labelledby={`area-${area}`}
    >
      <h2
        id={`area-${area}`}
        className="text-blue-600 text-xl font-semibold pb-3 border-b border-blue-100 mb-4"
      >
        {area}
        <span className="employee-count text-gray-500 text-base font-medium block mt-1">
          ({employees.length} {employees.length === 1 ? 'empleado' : 'empleados'})
        </span>
      </h2>
      <div
        className="employees-grid grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4"
        role="list"
      >
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
