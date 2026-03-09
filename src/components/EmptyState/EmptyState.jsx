import React from 'react';
import { motion } from 'framer-motion';
import styles from './EmptyState.module.css';

const EmptyState = ({ icon: Icon, title, message, actionLabel, onAction }) => {
    return (
        <motion.div
            className={styles.container}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
        >
            {Icon && (
                <div className={styles.iconWrapper}>
                    <Icon size={48} strokeWidth={1.5} />
                </div>
            )}
            <h3 className={styles.title}>{title}</h3>
            {message && <p className={styles.message}>{message}</p>}
            {actionLabel && onAction && (
                <button className={styles.action} onClick={onAction}>
                    {actionLabel}
                </button>
            )}
        </motion.div>
    );
};

export default EmptyState;
