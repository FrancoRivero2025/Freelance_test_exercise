import React, { useState, useEffect, useMemo, useCallback } from 'react';
import PropTypes from 'prop-types';
import { fetchEmployees } from '../services/api';
import AreaSection from './AreaSection';
import EmployeeDetailsModal from './EmployeeDetailsModal';

// Component to manage load and error states
const StatusHandler = ({ loading, error }) => {
  if (loading) return (
    <div className="loading text-center p-5 text-gray-500 bg-gray-100 rounded-lg text-lg">
      Cargando empleados...
    </div>
  );
  if (error) return (
    <div className="error text-center p-5 text-white bg-red-500 rounded-lg text-lg shadow-md">
      Error: {error}
    </div>
  );

  return null;
};

StatusHandler.propTypes = {
  loading: PropTypes.bool.isRequired,
  error: PropTypes.string,
};

const App = () => {
  const [employees, setEmployees] = useState([]);
  const [selectedEmployee, setSelectedEmployee] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Save employee groups by area
  const employeesByArea = useMemo(() => {
    return employees.reduce((acc, employee) => {
      const { area } = employee;
      if (!acc[area]) {
        acc[area] = [];
      }
      acc[area].push(employee);
      return acc;
    }, {});
  }, [employees]);

  // Save click manager
  const handleEmployeeClick = useCallback((employee) => {
    setSelectedEmployee(employee);
  }, []);

  // Save close modal handler
  const handleCloseModal = useCallback(() => {
    setSelectedEmployee(null);
  }, []);

  useEffect(() => {
    let isMounted = true; // Avoid unnecessary updates

    const loadEmployees = async () => {
      try {
        const data = await fetchEmployees();
        if (isMounted) {
          setEmployees(data);
          setLoading(false);
        }
      } catch (err) {
        if (isMounted) {
          setError(err.message || 'Error al cargar los empleados');
          setLoading(false);
        }
      }
    };

    loadEmployees();

    return () => {
      isMounted = false; // Cleanup
    };
  }, []);

  return (
    <div className="app max-w-6xl mx-auto p-5 bg-gray-50 min-h-screen">
      <h1 className="text-4xl font-bold text-center mb-8 bg-gradient-to-r from-blue-500 to-blue-800 bg-clip-text text-transparent pb-2">
        Directorio de Empleados
      </h1>
      
      <StatusHandler loading={loading} error={error} />
      
      {!loading && !error && (
        <>
          {Object.entries(employeesByArea).map(([area, areaEmployees]) => (
            <AreaSection
              key={area}
              area={area}
              employees={areaEmployees}
              onEmployeeClick={handleEmployeeClick}
            />
          ))}
          
          {selectedEmployee && (
            <EmployeeDetailsModal
              employee={selectedEmployee}
              onClose={handleCloseModal}
            />
          )}
        </>
      )}
    </div>
  );
};

export default React.memo(App);
