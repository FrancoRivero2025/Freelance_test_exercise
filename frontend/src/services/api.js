const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000';
const API_TIMEOUT = 8000;

// HTTP client
const httpClient = async (endpoint, options = {}) => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), API_TIMEOUT);

  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      signal: controller.signal,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error('La solicitud tardó demasiado tiempo');
    }
    console.error(`API Error: ${endpoint}`, error);
    throw error;
  }
};

// Employees service
export const employeeService = {
  fetchEmployees: async () => {
    return httpClient('/employees');
  },
  
  fetchEmployeeById: async (id) => {
    return httpClient(`/employees/${id}`);
  },
  
  // TODO: Ready to add the rest of the API services.
};

export const fetchEmployees = employeeService.fetchEmployees;