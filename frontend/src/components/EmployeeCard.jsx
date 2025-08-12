import React, { memo } from 'react';
import PropTypes from 'prop-types';
import '../app.css';

const EmployeeCard = ({ employee, onClick }) => {
  const { fullname, area, seniority } = employee;

  const handleClick = () => {
    onClick(employee);
  };

  return (
    <div className="employee-card" onClick={handleClick}>
      <h3>{fullname}</h3>
      <p>Área: {area}</p>
      <p>Antigüedad: {seniority} años</p>
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
