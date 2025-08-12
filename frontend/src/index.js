import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './components/App';
import reportWebVitals from './reportWebVitals';

// Root container
const container = document.getElementById('root');

// Add concurrent rendered root
const root = createRoot(container);

// Render app
root.render(
  <StrictMode>
    <App />
  </StrictMode>
);

// Measure performance
reportWebVitals();