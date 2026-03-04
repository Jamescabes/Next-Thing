import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Home from './pages/Home'

import { TaskProvider } from './context/TaskContext'
import { GoogleAuthProvider } from './context/GoogleAuthContext'

function App() {
    return (
        <TaskProvider>
            <GoogleAuthProvider>
                <Router>
                    <div className="app-container">
                        <Routes>
                            <Route path="/" element={<Home />} />
                        </Routes>
                    </div>
                </Router>
            </GoogleAuthProvider>
        </TaskProvider>
    )
}

export default App
