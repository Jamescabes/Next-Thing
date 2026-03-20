import React, { createContext, useContext, useState, useEffect } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db/db';
import { useAuth } from './AuthContext';

const TaskContext = createContext();

export const useTasks = () => useContext(TaskContext);

export const TaskProvider = ({ children }) => {
    const { currentUser } = useAuth();

    // Theme state
    const [isDarkMode, setIsDarkMode] = useState(false);

    const toggleTheme = () => setIsDarkMode(prev => !prev);

    useEffect(() => {
        if (isDarkMode) {
            document.documentElement.setAttribute('data-theme', 'dark');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    }, [isDarkMode]);

    // Live query: active (non-completed) tasks for the current user only
    const tasks = useLiveQuery(
        () => {
            if (!currentUser) return Promise.resolve([]);
            return db.tasks
                .where('userId')
                .equals(currentUser.id)
                .filter(t => !t.isCompleted)
                .toArray();
        },
        [currentUser?.id]
    ) || [];

    const saveTask = async (task) => {
        if (!currentUser) return;
        try {
            if (task.id && await db.tasks.get(task.id)) {
                await db.tasks.update(task.id, { ...task, userId: currentUser.id });
            } else {
                const { id, ...newTask } = task;
                await db.tasks.add({
                    ...newTask,
                    userId: currentUser.id,
                    isCompleted: false,
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
