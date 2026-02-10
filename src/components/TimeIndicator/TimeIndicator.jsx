import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import styles from './TimeIndicator.module.css';

const TimeIndicator = () => {
    const [time, setTime] = useState(new Date());

    useEffect(() => {
        const interval = setInterval(() => setTime(new Date()), 60000); // Update every minute
        return () => clearInterval(interval);
    }, []);

    const timeString = time.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    return (
        <div className={styles.container}>
            <motion.div
                className={styles.label}
                animate={{ opacity: [0.5, 1, 0.5] }}
                transition={{ duration: 2, repeat: Infinity }}
            >
                NOW {timeString}
            </motion.div>
            <div className={styles.line} />
        </div>
    );
};

export default TimeIndicator;
