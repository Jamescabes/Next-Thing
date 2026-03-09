import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import ErrorBoundary from './components/ErrorBoundary/ErrorBoundary'
import OfflineIndicator from './components/OfflineIndicator/OfflineIndicator'

import { TaskProvider } from './context/TaskContext'
import { GoogleAuthProvider } from './context/GoogleAuthContext'

function App() {
    return (
        <ErrorBoundary>
            <TaskProvider>
                <GoogleAuthProvider>
                    <Router>
                        <OfflineIndicator />
                        <div className="app-container">
                            <Routes>
                                <Route path="/" element={<Home />} />
                            </Routes>
                        </div>
                    </Router>
                </GoogleAuthProvider>
            </TaskProvider>
        </ErrorBoundary>
    )
}

export default App
