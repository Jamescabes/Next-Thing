import React from 'react';
import { motion } from 'framer-motion';
import { Clock, Check, Trash2 } from 'lucide-react';
import styles from './BalloonCard.module.css';

const GoogleBadge = () => (
    <span className={styles.googleBadge} title="Imported from Google Calendar">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <rect x="3" y="3" width="18" height="18" rx="2" fill="#4285F4"/>
            <rect x="3" y="3" width="9" height="9" fill="#EA4335"/>
            <rect x="12" y="12" width="9" height="9" fill="#34A853"/>
            <rect x="3" y="12" width="9" height="9" fill="#FBBC05"/>
        </svg>
    </span>
);

const BalloonCard = ({
    title,
    time,
    date,
    description,
    isNext = false,
    color,
    source,
    onClick,
    onComplete,
    onDelete
}) => {
    const handleComplete = (e) => {
        e.stopPropagation();
        onComplete && onComplete();
    };

    const handleDelete = (e) => {
        e.stopPropagation();
        onDelete && onDelete();
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
                {onDelete && (
                    <button
                        className={styles.deleteBtn}
                        onClick={handleDelete}
                        aria-label="Delete event"
                    >
                        <Trash2 size={14} strokeWidth={2.5} />
                    </button>
                )}
                <button
                    className={styles.checkbox}
                    onClick={handleComplete}
                    aria-label="Mark complete"
                >
                    <Check size={16} strokeWidth={3} />
                </button>
            </div>

            <div className={styles.header}>
                <div className={styles.time}>
                    {source === 'google' && <GoogleBadge />}
                    <Clock size={16} />
                    <span>{time}</span>
                    {date && <span className={styles.dateSeparator}>&bull;</span>}
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
