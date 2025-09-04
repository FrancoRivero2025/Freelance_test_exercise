import React, { memo } from 'react';
import PropTypes from 'prop-types';
import '../app.css';

const EmployeeCard = ({ employee, onClick, role }) => {
const { fullname, area, seniority } = employee;
  return (
    <div
      className="employee-card bg-white border border-gray-200 rounded-lg p-5 cursor-pointer transition-all duration-300 ease-in-out hover:-translate-y-1 hover:shadow-lg hover:border-blue-300 relative overflow-hidden"
      onClick={() => onClick(employee)}
      role={role}
    >
      <h3 className="text-gray-800 text-lg font-semibold mb-2">{fullname}</h3>
      <p className="text-gray-600 text-sm mb-1">Área: {area}</p>
      <p className="text-gray-600 text-sm">Antigüedad {seniority} años</p>
    </div>
  );
};

EmployeeCard.propTypes = {
  employee: PropTypes.shape({
    fullname: PropTypes.string.isRequired,
    area: PropTypes.string.isRequired,
    seniority: PropTypes.number.isRequired,
  }).isRequired,
  onClick: PropTypes.func.isRequired,
};

export default memo(EmployeeCard);
