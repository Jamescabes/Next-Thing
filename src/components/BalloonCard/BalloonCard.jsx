import React from 'react';
import { motion } from 'framer-motion';
import { Clock, Check } from 'lucide-react';
import styles from './BalloonCard.module.css';

const BalloonCard = ({
    title,
    time,
    date,
    description,
    isNext = false,
    color,
    onClick,
    onComplete
}) => {
    const handleComplete = (e) => {
        e.stopPropagation();
        onComplete && onComplete();
    };

    return (
        <motion.div
            className={`${styles.card} ${isNext ? styles.prominent : ''}`}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.8, transition: { duration: 0.2 } }}
            whileTap={{ scale: 0.98 }}
            onClick={onClick}
            style={color ? { backgroundColor: color } : {}}
            layout
        >
            <div className={styles.actions}>
                <button
                    className={styles.checkbox}
                    onClick={handleComplete}
                    aria-label="Mark Complete"
                >
                    <Check size={16} strokeWidth={3} />
                </button>
            </div>

            <div className={styles.header}>
                <div className={styles.time}>
                    <Clock size={16} />
                    <span>{time}</span>
                    {/* Simple date check: If valid date string, format it. */}
                    {date && <span className={styles.dateSeparator}>•</span>}
                    {date && <span>{new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>}
                </div>
            </div>

            <h3 className={styles.title}>{title}</h3>

            {description && (
                <p className={styles.description}>{description}</p>
            )}
        </motion.div>
    );
};

export default BalloonCard;
