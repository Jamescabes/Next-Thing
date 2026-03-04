import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown } from 'lucide-react';
import { format } from 'date-fns';
import styles from './DayCell.module.css';

const EVENTS_PER_PAGE = 3;

const DayCell = ({ day, events, onEventClick }) => {
    const [page, setPage] = useState(0);
    const [isHovered, setIsHovered] = useState(false);

    const totalPages = Math.ceil(events.length / EVENTS_PER_PAGE);
    const hasMore = totalPages > 1;

    const visibleEvents = events.slice(page * EVENTS_PER_PAGE, (page + 1) * EVENTS_PER_PAGE);

    const handleNextPage = (e) => {
        e.stopPropagation();
        if (page < totalPages - 1) {
            setPage(prev => prev + 1);
        } else {
            setPage(0); // Loop back to start
        }
    };

    return (
        <div
            className={styles.cell}
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
        >
            <span className={styles.dayNumber}>{format(day, 'd')}</span>

            <div className={styles.eventsContainer}>
                <AnimatePresence mode='wait'>
                    <motion.div
                        key={page}
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: -20, opacity: 0 }}
                        transition={{ duration: 0.2 }}
                        className={styles.eventList}
                    >
                        {visibleEvents.map(event => (
                            <div
                                key={event.id}
                                className={styles.eventBar}
                                style={{ backgroundColor: event.color || '#eee' }}
                                onClick={(e) => {
                                    e.stopPropagation();
                                    onEventClick(event);
                                }}
                            >
                                <span className={styles.eventTitle}>{event.title}</span>
                            </div>
                        ))}
                    </motion.div>
                </AnimatePresence>
            </div>

            {events.length > EVENTS_PER_PAGE && isHovered && (
                <motion.div
                    className={styles.scrollIndicator}
                    onClick={handleNextPage}
                    initial={{ opacity: 0 }}
                    animate={{
                        opacity: 1,
                        y: [0, 4, 0]
                    }}
                    transition={{
                        y: {
                            repeat: Infinity,
                            duration: 1.5,
                            ease: "easeInOut"
                        }
                    }}
                >
                    <ChevronDown size={16} />
                </motion.div>
            )}
        </div>
    );
};

export default DayCell;
