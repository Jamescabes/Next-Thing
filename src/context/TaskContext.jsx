import React, { createContext, useContext, useState, useEffect } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db/db';

const TaskContext = createContext();

export const useTasks = () => useContext(TaskContext);

export const TaskProvider = ({ children }) => {
    // Theme state - Default to Light Mode as requested
    const [isDarkMode, setIsDarkMode] = useState(false);

    const toggleTheme = () => {
        setIsDarkMode(prev => !prev);
    }

    // Apply theme class to body
    useEffect(() => {
        if (isDarkMode) {
            document.documentElement.setAttribute('data-theme', 'dark');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    }, [isDarkMode]);


    // -- Database Integration --

    // Live query for active tasks (not completed), sorted by time
    // We fetch all here for the home page.
    const tasks = useLiveQuery(
        () => db.tasks.where('isCompleted').equals(0).sortBy('time')
    ) || [];

    const saveTask = async (task) => {
        try {
            if (task.id && await db.tasks.get(task.id)) {
                // Update
                await db.tasks.update(task.id, task);
            } else {
                // Add new (remove id if it's a temp timestamp one, let Dexie auto-increment)
                const { id, ...newTask } = task;
                await db.tasks.add({
                    ...newTask,
                    isCompleted: 0, // Ensure numeric/boolean consistency if needed, Dexie handles bools usually but let's be safe
                    createdAt: new Date()
                });
            }
        } catch (error) {
            console.error("Failed to save task:", error);
        }
    };

    const taskActions = {
        deleteTask: async (id) => await db.tasks.delete(id),
        toggleComplete: async (task) => {
            await db.tasks.update(task.id, { isCompleted: !task.isCompleted });
        }
    };

    return (
        <TaskContext.Provider value={{ tasks, saveTask, ...taskActions, isDarkMode, toggleTheme }}>
            {children}
        </TaskContext.Provider>
    );
};
