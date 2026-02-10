import React from 'react';
import { Plus } from 'lucide-react';
import { motion } from 'framer-motion';
import styles from './FloatingActionButton.module.css';

const FloatingActionButton = ({ onClick }) => {
    return (
        <motion.button
            className={styles.fab}
            onClick={onClick}
            initial={{ scale: 0, rotate: 180 }}
            animate={{ scale: 1, rotate: 0 }}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            transition={{ type: "spring", stiffness: 260, damping: 20 }}
            aria-label="Add Event"
        >
            <Plus size={32} strokeWidth={2.5} />
        </motion.button>
    );
};

export default FloatingActionButton;
