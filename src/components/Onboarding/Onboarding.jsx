import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CalendarDays } from 'lucide-react';
import styles from './Onboarding.module.css';

const STORAGE_KEY = 'hasSeenOnboarding';

const Onboarding = () => {
    const [isVisible, setIsVisible] = useState(false);

    useEffect(() => {
        const hasSeen = localStorage.getItem(STORAGE_KEY);
        if (!hasSeen) {
            setIsVisible(true);
        }
    }, []);

    const handleDismiss = () => {
        localStorage.setItem(STORAGE_KEY, 'true');
        setIsVisible(false);
    };

    return (
        <AnimatePresence>
            {isVisible && (
                <motion.div
                    className={styles.overlay}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    role="dialog"
                    aria-modal="true"
                    aria-labelledby="onboarding-title"
                >
                    <motion.div
                        className={styles.card}
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0.9, opacity: 0 }}
                        transition={{ delay: 0.1 }}
                    >
                        <div className={styles.iconWrapper}>
                            <CalendarDays size={56} strokeWidth={1.5} />
                        </div>
                        <h1 id="onboarding-title" className={styles.title}>
                            Welcome to Next Thing
                        </h1>
                        <p className={styles.subtitle}>
                            Your minimal, beautiful calendar. Create events, sync with Google Calendar, and stay focused on what&apos;s next.
                        </p>
                        <button className={styles.button} onClick={handleDismiss}>
                            Get Started
                        </button>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default Onboarding;
