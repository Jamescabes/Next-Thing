import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { WifiOff } from 'lucide-react';
import useOnlineStatus from '../../hooks/useOnlineStatus';
import styles from './OfflineIndicator.module.css';

const OfflineIndicator = () => {
    const isOnline = useOnlineStatus();

    return (
        <AnimatePresence>
            {!isOnline && (
                <motion.div
                    className={styles.banner}
                    role="alert"
                    aria-live="assertive"
                    initial={{ y: -60, opacity: 0 }}
                    animate={{ y: 0, opacity: 1 }}
                    exit={{ y: -60, opacity: 0 }}
                >
                    <WifiOff size={16} />
                    <span>You are offline</span>
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default OfflineIndicator;
