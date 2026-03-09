import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Calendar as CalendarIcon, List, ChevronLeft, ChevronRight, Inbox } from 'lucide-react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from '../../db/db';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameDay, parseISO, getDay, addMonths, subMonths } from 'date-fns';
import BalloonCard from '../BalloonCard/BalloonCard';
import DayCell from './DayCell';
import EmptyState from '../EmptyState/EmptyState';
import useFocusTrap from '../../hooks/useFocusTrap';
import styles from './History.module.css';

const History = ({ isOpen, onClose, onEditTask }) => {
    const [viewMode, setViewMode] = useState('list');
    const [limit, setLimit] = useState(30);

    const focusTrapRef = useFocusTrap(isOpen);

    const historyTasks = useLiveQuery(
        () => db.tasks
            .orderBy('date')
            .reverse()
            .limit(limit)
            .toArray(),
        [limit]
    );

    const [currentMonth, setCurrentMonth] = useState(new Date());
    const monthStart = startOfMonth(currentMonth);
    const monthEnd = endOfMonth(currentMonth);
    const daysInMonth = eachDayOfInterval({ start: monthStart, end: monthEnd });

    const allTasks = useLiveQuery(() => db.tasks.toArray()) || [];

    const handleLoadMore = () => {
        setLimit(prev => prev + 30);
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Escape') onClose();
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    className={styles.overlay}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    onKeyDown={handleKeyDown}
                >
                    <motion.div
                        ref={focusTrapRef}
                        className={styles.container}
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="history-title"
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: "spring", damping: 25, stiffness: 200 }}
                    >
                        <div className={styles.header}>
                            <h2 id="history-title" className={styles.title}>History</h2>
                            <div className={styles.toggles} role="tablist" aria-label="View mode">
                                <button
                                    role="tab"
                                    aria-selected={viewMode === 'list'}
                                    className={`${styles.toggle} ${viewMode === 'list' ? styles.active : ''}`}
                                    onClick={() => setViewMode('list')}
                                    aria-label="List view"
                                >
                                    <List size={20} />
                                </button>
                                <button
                                    role="tab"
                                    aria-selected={viewMode === 'calendar'}
                                    className={`${styles.toggle} ${viewMode === 'calendar' ? styles.active : ''}`}
                                    onClick={() => setViewMode('calendar')}
                                    aria-label="Calendar view"
                                >
                                    <CalendarIcon size={20} />
                                </button>
                            </div>
                            <button onClick={onClose} className={styles.closeButton} aria-label="Close history">
                                <X size={24} />
                            </button>
                        </div>

                        <div className={styles.content}>
                            {viewMode === 'list' ? (
                                <div className={styles.listView}>
                                    {(!historyTasks || historyTasks.length === 0) ? (
                                        <EmptyState
                                            icon={Inbox}
                                            title="No events yet"
                                            message="Events you create will appear here."
                                        />
                                    ) : (
                                        <>
                                            {historyTasks.map(task => (
                                                <BalloonCard
                                                    key={task.id}
                                                    title={task.title}
                                                    time={task.time}
                                                    date={task.date}
                                                    description={task.description}
                                                    color={task.color}
                                                    source={task.source}
                                                    onClick={() => {
                                                        onEditTask(task);
                                                        onClose();
                                                    }}
                                                />
                                            ))}
                                            <button onClick={handleLoadMore} className={styles.loadMore}>
                                                Load More
                                            </button>
                                        </>
                                    )}
                                </div>
                            ) : (
                                <div className={styles.calendarView}>
                                    <div className={styles.monthNav}>
                                        <button
                                            onClick={() => setCurrentMonth(prev => subMonths(prev, 1))}
                                            className={styles.navButton}
                                            aria-label="Previous month"
                                        >
                                            <ChevronLeft size={20} />
                                        </button>
                                        <div className={styles.monthLabel} aria-live="polite">
                                            {format(currentMonth, 'MMMM yyyy')}
                                        </div>
                                        <button
                                            onClick={() => setCurrentMonth(prev => addMonths(prev, 1))}
                                            className={styles.navButton}
                                            aria-label="Next month"
                                        >
                                            <ChevronRight size={20} />
                                        </button>
                                    </div>
                                    <div className={styles.grid} role="grid" aria-label="Calendar">
                                        {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(d => (
                                            <div key={d} className={styles.weekdayHeader} role="columnheader">{d}</div>
                                        ))}
                                        {Array.from({ length: (getDay(monthStart) + 6) % 7 }, (_, i) => (
                                            <div key={`empty-${i}`} className={styles.emptyCell} />
                                        ))}
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
