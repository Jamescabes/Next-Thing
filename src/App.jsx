import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { TaskProvider } from './context/TaskContext';
import Home from './pages/Home';
import Login from './pages/Login';

// Inner component so it can access AuthContext
function AppContent() {
    const { currentUser, isLoading } = useAuth();

    if (isLoading) {
        return (
            <div style={{
                minHeight: '100vh',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--color-text-tertiary)',
                fontSize: 'var(--font-size-sm)'
            }}>
                Loading...
            </div>
        );
    }

    if (!currentUser) {
        return <Login />;
    }

    return (
        <TaskProvider>
            <div className="app-container">
                <Routes>
                    <Route path="/" element={<Home />} />
                </Routes>
            </div>
        </TaskProvider>
    );
}

function App() {
    return (
        <AuthProvider>
            <Router>
                <AppContent />
            </Router>
        </AuthProvider>
    );
}

export default App;
