import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, User, Moon, Sun, LogOut } from 'lucide-react';
import styles from './SidePanel.module.css'; // We'll create this next

const SidePanel = ({ isOpen, onClose, isDarkMode, toggleTheme }) => {
    return (
        <AnimatePresence>
            {isOpen && (
                <>
                    <motion.div
                        className={styles.backdrop}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                    />
                    <motion.div
                        className={styles.panel}
                        initial={{ x: '-100%' }}
                        animate={{ x: 0 }}
                        exit={{ x: '-100%' }}
                        transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                    >
                        <div className={styles.header}>
                            <div className={styles.userInfo}>
                                <div className={styles.avatar}>
                                    <User size={24} />
                                </div>
                                <div className={styles.userDetails}>
                                    <span className={styles.userName}>User Name</span>
                                    <span className={styles.userEmail}>user@example.com</span>
                                </div>
                            </div>
                            <button onClick={onClose} className={styles.closeButton}>
                                <X size={24} />
                            </button>
                        </div>

                        <div className={styles.content}>
                            <div className={styles.section}>
                                <h3>Appearance</h3>
                                <button className={styles.menuItem} onClick={toggleTheme}>
                                    {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
                                    <span>{isDarkMode ? 'Light Mode' : 'Dark Mode'}</span>
                                </button>
                            </div>

                            <div className={styles.section}>
                                <h3>Account</h3>
                                <button className={styles.menuItem}>
                                    <LogOut size={20} />
                                    <span>Log Out</span>
                                </button>
                            </div>
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
};

export default SidePanel;
