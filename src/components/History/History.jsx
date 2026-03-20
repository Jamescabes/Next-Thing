import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Calendar as CalendarIcon, List, ChevronLeft, ChevronRight } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../../db/db';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, parseISO, addMonths, subMonths } from 'date-fns';
import BalloonCard from '../BalloonCard/BalloonCard';
import DayCell from './DayCell';
import styles from './History.module.css';

const History = ({ isOpen, onClose, onEditTask }) => {
    const [viewMode, setViewMode] = useState('list'); // 'list' or 'calendar'
    const [limit, setLimit] = useState(30);
    const [currentMonth, setCurrentMonth] = useState(new Date());

    // -- List Data: completed tasks only, ordered by date descending --
    const historyTasks = useLiveQuery(
        () => db.tasks
            .orderBy('date')
            .reverse()
            .filter(t => !!t.isCompleted)
            .limit(limit)
            .toArray(),
        [limit]
    );

    // -- Calendar Data: all tasks for the current month --
    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(currentMonth);
    const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd });

    const monthStartStr = format(monthStart, 'yyyy-MM-dd');
    const monthEndStr = format(monthEnd, 'yyyy-MM-dd');

    const monthTasks = useLiveQuery(
        () => db.tasks
            .where('date')
            .between(monthStartStr, monthEndStr, true, true)
            .toArray(),
        [monthStartStr, monthEndStr]
    ) || [];

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
                                    {historyTasks?.length === 0 && (
                                        <p className={styles.emptyState}>No completed events yet.</p>
                                    )}
                                    {historyTasks?.map(task => (
                                        <BalloonCard
                                            key={task.id}
                                            title={task.title}
                                            time={task.time}
                                            date={task.date}
                                            description={task.description}
                                            color={task.color}
                                            onClick={() => {
                                                onEditTask(task);
                                                onClose();
                                            }}
                                        />
                                    ))}
                                    {historyTasks?.length >= limit && (
                                        <button onClick={handleLoadMore} className={styles.loadMore}>
                                            Load More (Batch 30)
                                        </button>
                                    )}
                                </div>
                            ) : (
                                <div className={styles.calendarView}>
                                    <div className={styles.monthNav}>
                                        <button
                                            className={styles.monthNavBtn}
                                            onClick={() => setCurrentMonth(m => subMonths(m, 1))}
                                        >
                                            <ChevronLeft size={20} />
                                        </button>
                                        <span className={styles.monthLabel}>
                                            {format(currentMonth, 'MMMM yyyy')}
                                        </span>
                                        <button
                                            className={styles.monthNavBtn}
                                            onClick={() => setCurrentMonth(m => addMonths(m, 1))}
                                        >
                                            <ChevronRight size={20} />
                                        </button>
                                    </div>
                                    <div className={styles.grid}>
                                        {daysInMonth.map(day => {
                                            const dayTasks = monthTasks.filter(t => isSameDay(parseISO(t.date), day));
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
