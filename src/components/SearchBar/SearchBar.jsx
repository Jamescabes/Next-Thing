import React, { useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, X } from 'lucide-react';
import styles from './SearchBar.module.css';

const SearchBar = ({ isOpen, query, onChange, onToggle }) => {
    const inputRef = useRef(null);

    useEffect(() => {
        if (isOpen && inputRef.current) {
            inputRef.current.focus();
        }
    }, [isOpen]);

    return (
        <div className={styles.container}>
            <button
                className={styles.toggleBtn}
                onClick={onToggle}
                aria-label={isOpen ? 'Close search' : 'Search events'}
            >
                {isOpen ? <X size={20} /> : <Search size={20} />}
            </button>

            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        className={styles.inputWrapper}
                        initial={{ width: 0, opacity: 0 }}
                        animate={{ width: 180, opacity: 1 }}
                        exit={{ width: 0, opacity: 0 }}
                        transition={{ duration: 0.2 }}
                    >
                        <input
                            ref={inputRef}
                            type="text"
                            className={styles.input}
                            placeholder="Search..."
                            value={query}
                            onChange={(e) => onChange(e.target.value)}
                            aria-label="Search events"
                        />
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default SearchBar;
