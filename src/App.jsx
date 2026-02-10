import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Home from './pages/Home'

import { TaskProvider } from './context/TaskContext'

function App() {
    return (
        <TaskProvider>
            <Router>
                <div className="app-container">
                    <Routes>
                        <Route path="/" element={<Home />} />
                    </Routes>
                </div>
            </Router>
        </TaskProvider>
    )
}

export default App
