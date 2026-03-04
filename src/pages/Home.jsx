import React, { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db/db';
import TopBar from '../components/TopBar/TopBar';
import BalloonCard from '../components/BalloonCard/BalloonCard';
import FloatingActionButton from '../components/FloatingActionButton/FloatingActionButton';
import SidePanel from '../components/SidePanel/SidePanel';
import EventCreationModal from '../components/EventCreationModal/EventCreationModal';
import History from '../components/History/History';
import { useTasks } from '../context/TaskContext';

const Home = () => {
    // We still use context for actions like save/toggleTheme, but fetch data locally for specific sort requirements
    const { saveTask, toggleComplete, isDarkMode, toggleTheme } = useTasks();
    const [isSettingsOpen, setIsSettingsOpen] = useState(false);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isHistoryOpen, setIsHistoryOpen] = useState(false);
    const [editingTask, setEditingTask] = useState(null);
    const [pastLimit, setPastLimit] = useState(10);
    const [now, setNow] = useState(new Date());

    // Update 'now' every minute for the tranquil crossing animation
    useEffect(() => {
        const timer = setInterval(() => setNow(new Date()), 60000);
        return () => clearInterval(timer);
    }, []);

    // -- Timeline Query --
    // Sort: Far Future -> Near Future -> Present -> Recent Past -> Far Past
    // This is simply: Order By Date Descending.
    const allTasks = useLiveQuery(
        () => db.tasks.orderBy('[date+time]').reverse().toArray()
    ) || [];

    // Filter AND Split Data using useMemo for stability
    const timelineItems = useMemo(() => {
        // 1. Only show tasks not yet marked as completed
        const activeTasks = allTasks.filter(t => !t.isCompleted);

        const future = [];
        const past = [];

        activeTasks.forEach(task => {
            // Robust date comparison: Create Date objects in local time
            // task.date is YYYY-MM-DD, task.time is HH:mm
            const taskDate = new Date(`${task.date}T${task.time}`);

            // If task date is valid (fallback to simple comparison if parsing fails)
            if (!isNaN(taskDate.getTime())) {
                if (taskDate > now) {
                    future.push(task);
                } else {
                    past.push(task);
                }
            } else {
                // Fallback string-based logic just in case
                const todayStr = now.toISOString().split('T')[0];
                const currentTimeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
                if (task.date > todayStr) {
                    future.push(task);
                } else if (task.date === todayStr) {
                    if (task.time >= currentTimeStr) {
                        future.push(task);
                    } else {
                        past.push(task);
                    }
                } else {
                    past.push(task);
                }
            }
        });

        const visiblePast = past.slice(0, pastLimit);

        return [
            ...future.map(t => ({ id: t.id, type: 'task', data: t, isFuture: true })),
            { id: 'now-marker', type: 'separator' },
            ...visiblePast.map(t => ({ id: t.id, type: 'task', data: t, isFuture: false })),
            ...(past.length > pastLimit ? [{ id: 'load-more', type: 'button' }] : [])
        ];
    }, [allTasks, now, pastLimit]);

    const handleEditTask = (task) => {
        setIsHistoryOpen(false);
        // Delay slightly to allow History modal to initiate exit animation
        // before opening the next heavyweight modal.
        setTimeout(() => {
            setEditingTask(task);
            setIsModalOpen(true);
        }, 100);
    };

    const handleAddNew = () => {
        setEditingTask(null);
        setIsModalOpen(true);
    }

    const handleCompleteTask = (task) => {
        toggleComplete(task);
    };

    const handleLoadMore = () => {
        setPastLimit(prev => prev + 30);
    };

    return (
        <div style={{ position: 'relative', minHeight: '80vh' }}>
            <TopBar
                onOpenSettings={() => setIsSettingsOpen(true)}
                onOpenHistory={() => setIsHistoryOpen(true)}
            />

            <main style={{ paddingBottom: '100px', paddingLeft: 'var(--space-md)', paddingRight: 'var(--space-md)' }}>
                <AnimatePresence mode='wait'>
                    <motion.div
                        key="main-timeline"
                        style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-lg)' }}
                    >
                        {timelineItems.map((item) => {
                            if (item.type === 'separator') {
                                return (
                                    <div
                                        key="now-marker"
                                        style={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: 'var(--space-md)',
                                            margin: 'var(--space-xl) 0',
                                            opacity: 0.5
                                        }}
                                    >
                                        <div style={{ flex: 1, height: '1px', background: 'var(--color-accent)' }}></div>
                                        <span style={{ fontSize: '10px', textTransform: 'uppercase', letterSpacing: '2px', fontWeight: 'bold' }}>Now</span>
                                        <div style={{ flex: 1, height: '1px', background: 'var(--color-accent)' }}></div>
                                    </div>
                                );
                            }

                            if (item.type === 'button') {
                                return (
                                    <button
                                        key="load-more"
                                        onClick={handleLoadMore}
                                        style={{
                                            margin: 'var(--space-xl) auto',
                                            display: 'flex',
                                            flexDirection: 'column',
                                            alignItems: 'center',
                                            background: 'none',
                                            border: 'none',
                                            cursor: 'pointer',
                                            color: 'var(--color-text-tertiary)'
                                        }}
                                    >
                                        <span style={{ marginBottom: '4px', fontSize: '12px' }}>Load Events</span>
                                        <ChevronDown />
                                    </button>
                                );
                            }

                            const task = item.data;
                            return (
                                <motion.div
                                    key={task.id}
                                    layout
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{
                                        opacity: item.isFuture ? 1 : 0.5,
                                        y: 0
                                    }}
                                    exit={{ opacity: 0, scale: 0.98 }}
                                    transition={{
                                        layout: { type: "tween", duration: 0.8, ease: "easeInOut" },
                                        opacity: { duration: 0.3 }
                                    }}
                                >
                                    <BalloonCard
                                        title={task.title}
                                        time={task.time}
                                        date={task.date}
                                        description={task.description}
                                        color={task.color}
                                        source={task.source}
                                        onClick={() => handleEditTask(task)}
                                        onComplete={() => handleCompleteTask(task)}
                                    />
                                </motion.div>
                            );
                        })}
                    </motion.div>
                </AnimatePresence>
            </main>

            <FloatingActionButton onClick={handleAddNew} />

            <SidePanel
                isOpen={isSettingsOpen}
                onClose={() => setIsSettingsOpen(false)}
                isDarkMode={isDarkMode}
                toggleTheme={toggleTheme}
            />

            <EventCreationModal
                isOpen={isModalOpen}
                onClose={() => {
                    setIsModalOpen(false);
                    setEditingTask(null);
                }}
                onSave={saveTask}
                initialData={editingTask}
            />

            <History
                isOpen={isHistoryOpen}
                onClose={() => setIsHistoryOpen(false)}
                onEditTask={handleEditTask}
            />
        </div>
    );
};

export default Home;
