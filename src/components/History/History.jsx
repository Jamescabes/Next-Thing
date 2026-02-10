import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Calendar as CalendarIcon, List } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../../db/db';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, parseISO } from 'date-fns';
import BalloonCard from '../BalloonCard/BalloonCard';
import DayCell from './DayCell';
import styles from './History.module.css';

const History = ({ isOpen, onClose, onEditTask }) => {
    const [viewMode, setViewMode] = useState('list'); // 'list' or 'calendar'
    const [limit, setLimit] = useState(30);

    // -- List Data (Pagination) --
    // Fetch completed tasks or past events. User said "all past events", so maybe completed?
    // Let's assume history means completed or past date. 
    // For now, let's show ALL tasks, but typically history is completed.
    // Query: Tasks, ordered by date descending, limited.
    const historyTasks = useLiveQuery(
        () => db.tasks
            .orderBy('date')
            .reverse()
            .limit(limit)
            .toArray(),
        [limit]
    );

    // -- Calendar Data --
    const [currentMonth, setCurrentMonth] = useState(new Date());
    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(currentMonth);
    const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd });

    // Fetch tasks for this month to display in cells
    // Since Dexie is local, fetching all tasks is usually fast enough for a personal calendar,
    // but better to query range if possible. For simplicity here: fetch all and filter in JS 
    // (Optimization: In a real large DB, use a range query on date index).
    const allTasks = useLiveQuery(() => db.tasks.toArray()) || [];

    const handleLoadMore = () => {
        setLimit(prev => prev + 30);
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    className={styles.overlay}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                >
                    <motion.div
                        className={styles.container}
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: "spring", damping: 25, stiffness: 200 }}
                    >
                        <div className={styles.header}>
                            <h2 className={styles.title}>History</h2>
                            <div className={styles.toggles}>
                                <button
                                    className={`${styles.toggle} ${viewMode === 'list' ? styles.active : ''}`}
                                    onClick={() => setViewMode('list')}
                                >
                                    <List size={20} />
                                </button>
                                <button
                                    className={`${styles.toggle} ${viewMode === 'calendar' ? styles.active : ''}`}
                                    onClick={() => setViewMode('calendar')}
                                >
                                    <CalendarIcon size={20} />
                                </button>
                            </div>
                            <button onClick={onClose} className={styles.closeButton}>
                                <X size={24} />
                            </button>
                        </div>

                        <div className={styles.content}>
                            {viewMode === 'list' ? (
                                <div className={styles.listView}>
                                    {historyTasks?.map(task => (
                                        <BalloonCard
                                            key={task.id}
                                            title={task.title}
                                            time={task.date} // Showing date in history
                                            description={task.description}
                                            color={task.color}
                                            onClick={() => {
                                                onEditTask(task);
                                                onClose();
                                            }}
                                        // History items generally not 'completable' here, or already done
                                        />
                                    ))}
                                    <button onClick={handleLoadMore} className={styles.loadMore}>
                                        Load More (Batch 30)
                                    </button>
                                </div>
                            ) : (
                                <div className={styles.calendarView}>
                                    <div className={styles.monthLabel}>
                                        {format(currentMonth, 'MMMM yyyy')}
                                    </div>
                                    <div className={styles.grid}>
                                        {daysInMonth.map(day => {
                                            const dayTasks = allTasks.filter(t => isSameDay(parseISO(t.date), day));
                                            return (
                                                <DayCell
                                                    key={day.toString()}
                                                    day={day}
                                                    events={dayTasks}
                                                    onEventClick={(t) => {
                                                        onEditTask(t);
                                                        onClose();
                                                    }}
                                                />
                                            );
                                        })}
                                    </div>
                                </div>
                            )}
                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default History;
