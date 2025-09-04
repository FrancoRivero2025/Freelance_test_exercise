import React, { memo} from 'react';
import PropTypes from 'prop-types';
import "../app.css";

const EmployeeDetailsModal = ({ employee, onClose }) => {
  return (
    <div className="modal-overlay fixed inset-0 bg-slate-900/70 backdrop-blur-sm flex justify-center items-center z-50 p-4">
      <div className={`modal-content bg-white p-6 rounded-xl max-w-md w-full relative shadow-lg border border-gray-200 ${
        employee.is_active === true ? 'bg-green-50' : 'bg-red-50'
      }`}>
        <button
          className="close-button absolute top-4 right-4 bg-gray-100 border-none w-8 h-8 rounded-full flex items-center justify-center cursor-pointer text-gray-500 hover:bg-gray-200 hover:text-gray-700 transition-colors"
          onClick={onClose}
        >
          &times;
        </button>
        <div className="employee-details">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">{employee.fullname}</h2>
          <p className="mb-2"><strong className="text-gray-800">Antigüedad:</strong> {employee.seniority} años </p>
          <p className="mb-2"><strong className="text-gray-800">Departamento:</strong> {employee.area}</p>
          <p className="mb-2"><strong className="text-gray-800">Teléfono:</strong> {employee.phone}</p>
          <p className="mb-0">
            <strong className="text-gray-800">Estado:</strong>
            <span className={`font-semibold ${employee.is_active === true ? 'text-green-600' : 'text-red-600'}`}>
              {employee.is_active === true ? ' Activo' : ' Inactivo'}
            </span>
          </p>
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
