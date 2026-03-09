import React, { useState, useMemo, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, CalendarDays } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../db/db';
import TopBar from '../components/TopBar/TopBar';
import BalloonCard from '../components/BalloonCard/BalloonCard';
import FloatingActionButton from '../components/FloatingActionButton/FloatingActionButton';
import SidePanel from '../components/SidePanel/SidePanel';
import EventCreationModal from '../components/EventCreationModal/EventCreationModal';
import History from '../components/History/History';
import EmptyState from '../components/EmptyState/EmptyState';
import Onboarding from '../components/Onboarding/Onboarding';
import { useTasks } from '../context/TaskContext';
import styles from './Home.module.css';

const Home = () => {
    const { saveTask, toggleComplete, deleteTask, isDarkMode, toggleTheme } = useTasks();
    const [isSettingsOpen, setIsSettingsOpen] = useState(false);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isHistoryOpen, setIsHistoryOpen] = useState(false);
    const [editingTask, setEditingTask] = useState(null);
    const [pastLimit, setPastLimit] = useState(10);
    const [now, setNow] = useState(new Date());

    // Search state
    const [searchQuery, setSearchQuery] = useState('');
    const [isSearchOpen, setIsSearchOpen] = useState(false);

    // Delete flow state
    const [deleteTarget, setDeleteTarget] = useState(null);
    const [toast, setToast] = useState(null);

    // Update 'now' every minute
    useEffect(() => {
        const timer = setInterval(() => setNow(new Date()), 60000);
        return () => clearInterval(timer);
    }, []);

    // -- Timeline Query --
    const allTasks = useLiveQuery(
        () => db.tasks.orderBy('[date+time]').reverse().toArray()
    ) || [];

    // Filter AND Split Data
    const timelineItems = useMemo(() => {
        const activeTasks = allTasks.filter(t => !t.isCompleted);

        // Apply search filter
        const filtered = searchQuery
            ? activeTasks.filter(t =>
                t.title?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                t.description?.toLowerCase().includes(searchQuery.toLowerCase())
            )
            : activeTasks;

        const future = [];
        const past = [];

        filtered.forEach(task => {
            const taskDate = new Date(`${task.date}T${task.time}`);

            if (!isNaN(taskDate.getTime())) {
                if (taskDate > now) {
                    future.push(task);
                } else {
                    past.push(task);
                }
            } else {
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
        const hasContent = future.length > 0 || visiblePast.length > 0;

        return {
            items: [
                ...future.map(t => ({ id: t.id, type: 'task', data: t, isFuture: true })),
                { id: 'now-marker', type: 'separator' },
                ...visiblePast.map(t => ({ id: t.id, type: 'task', data: t, isFuture: false })),
                ...(past.length > pastLimit ? [{ id: 'load-more', type: 'button' }] : [])
            ],
            hasContent
        };
    }, [allTasks, now, pastLimit, searchQuery]);

    const handleEditTask = (task) => {
        setIsHistoryOpen(false);
        setTimeout(() => {
            setEditingTask(task);
            setIsModalOpen(true);
        }, 100);
    };

    const handleAddNew = () => {
        setEditingTask(null);
        setIsModalOpen(true);
    };

    const handleCompleteTask = (task) => {
        toggleComplete(task);
    };

    const handleDeleteRequest = (task) => {
        setDeleteTarget(task);
    };

    const handleConfirmDelete = async () => {
        if (!deleteTarget) return;
        const taskToDelete = { ...deleteTarget };
        await deleteTask(deleteTarget.id);
        setDeleteTarget(null);

        // Show undo toast
        setToast({
            message: `"${taskToDelete.title}" deleted`,
            onUndo: async () => {
                const { id, ...taskWithoutId } = taskToDelete;
                await db.tasks.add({ ...taskWithoutId });
                setToast(null);
            }
        });
    };

    const handleLoadMore = () => {
        setPastLimit(prev => prev + 30);
    };

    return (
        <div className={styles.page}>
            <h1 className="sr-only">Next Thing Calendar</h1>

            <Onboarding />

            <TopBar
                onOpenSettings={() => setIsSettingsOpen(true)}
                onOpenHistory={() => setIsHistoryOpen(true)}
                searchQuery={searchQuery}
                onSearchChange={setSearchQuery}
                isSearchOpen={isSearchOpen}
                onSearchToggle={() => setIsSearchOpen(prev => !prev)}
            />

            <main className={styles.main}>
                <AnimatePresence mode='wait'>
                    {!timelineItems.hasContent && !searchQuery ? (
                        <EmptyState
                            key="empty"
                            icon={CalendarDays}
                            title="No upcoming events"
                            message="Your timeline is empty. Create your first event to get started."
                            actionLabel="Create Event"
                            onAction={handleAddNew}
                        />
                    ) : !timelineItems.hasContent && searchQuery ? (
                        <EmptyState
                            key="no-results"
                            title="No results"
                            message={`Nothing matches "${searchQuery}"`}
                        />
                    ) : (
                        <motion.div
                            key="main-timeline"
                            className={styles.timeline}
                        >
                            {timelineItems.items.map((item) => {
                                if (item.type === 'separator') {
                                    return (
                                        <div key="now-marker" className={styles.nowMarker}>
                                            <div className={styles.nowLine} />
                                            <span className={styles.nowLabel}>Now</span>
                                            <div className={styles.nowLine} />
                                        </div>
                                    );
                                }

                                if (item.type === 'button') {
                                    return (
                                        <button
                                            key="load-more"
                                            onClick={handleLoadMore}
                                            className={styles.loadMoreButton}
                                        >
                                            <span className={styles.loadMoreLabel}>Load Events</span>
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
                                            onDelete={() => handleDeleteRequest(task)}
                                        />
                                    </motion.div>
                                );
                            })}
                        </motion.div>
                    )}
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

            {/* Confirm Delete Dialog */}
            <AnimatePresence>
                {deleteTarget && (
                    <motion.div
                        className={styles.dialogBackdrop}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={() => setDeleteTarget(null)}
                    >
                        <motion.div
                            role="dialog"
                            aria-modal="true"
                            aria-labelledby="confirm-delete-title"
                            className={styles.dialogBox}
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.9, opacity: 0 }}
                            onClick={e => e.stopPropagation()}
                        >
                            <h2 id="confirm-delete-title" className={styles.dialogTitle}>
                                Delete Event
                            </h2>
                            <p className={styles.dialogMessage}>
                                Are you sure you want to delete &quot;{deleteTarget.title}&quot;? You can undo this action.
                            </p>
                            <div className={styles.dialogActions}>
                                <button
                                    onClick={() => setDeleteTarget(null)}
                                    className={styles.dialogCancel}
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={handleConfirmDelete}
                                    className={styles.dialogConfirm}
                                >
                                    Delete
                                </button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Undo Toast */}
            <AnimatePresence>
                {toast && (
                    <Toast
                        message={toast.message}
                        onUndo={toast.onUndo}
                        onDismiss={() => setToast(null)}
                    />
                )}
            </AnimatePresence>
        </div>
    );
};

// Inline Toast component
const Toast = ({ message, onUndo, onDismiss }) => {
    useEffect(() => {
        const timer = setTimeout(onDismiss, 5000);
        return () => clearTimeout(timer);
    }, [onDismiss]);

    return (
        <motion.div
            role="status"
            aria-live="polite"
            className={styles.toast}
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
        >
            <span className={styles.toastMessage}>{message}</span>
            {onUndo && (
                <button onClick={onUndo} className={styles.toastUndo}>
                    Undo
                </button>
            )}
        </motion.div>
    );
};

export default Home;
