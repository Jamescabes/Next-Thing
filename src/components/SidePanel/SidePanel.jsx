import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, User, Moon, Sun, LogOut, Trash2, AlertTriangle } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import styles from './SidePanel.module.css';

const SidePanel = ({ isOpen, onClose, isDarkMode, toggleTheme }) => {
    const { currentUser, logOut, deleteAccount } = useAuth();
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);

    const handleLogOut = () => {
        onClose();
        logOut();
    };

    const handleDeleteAccount = async () => {
        setIsDeleting(true);
        await deleteAccount();
        // AuthContext sets currentUser to null, App re-renders to Login
    };

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
                                    <span className={styles.userName}>{currentUser?.username || 'User'}</span>
                                    <span className={styles.userEmail}>{currentUser?.email || ''}</span>
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
                                <button className={styles.menuItem} onClick={handleLogOut}>
                                    <LogOut size={20} />
                                    <span>Log Out</span>
                                </button>
                                <button
                                    className={`${styles.menuItem} ${styles.danger}`}
                                    onClick={() => setShowDeleteConfirm(true)}
                                >
                                    <Trash2 size={20} />
                                    <span>Delete Account</span>
                                </button>
                            </div>
                        </div>

                        {/* Delete Account confirmation */}
                        <AnimatePresence>
                            {showDeleteConfirm && (
                                <motion.div
                                    className={styles.confirmOverlay}
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    exit={{ opacity: 0 }}
                                >
                                    <div className={styles.confirmBox}>
                                        <AlertTriangle size={32} className={styles.warningIcon} />
                                        <h3 className={styles.confirmTitle}>Delete Account?</h3>
                                        <p className={styles.confirmText}>
                                            This will permanently delete your account and all your events. This cannot be undone.
                                        </p>
                                        <div className={styles.confirmActions}>
                                            <button
                                                className={styles.cancelBtn}
                                                onClick={() => setShowDeleteConfirm(false)}
                                                disabled={isDeleting}
                                            >
                                                Cancel
                                            </button>
                                            <button
                                                className={styles.deleteBtn}
                                                onClick={handleDeleteAccount}
                                                disabled={isDeleting}
                                            >
                                                {isDeleting ? 'Deleting...' : 'Delete'}
                                            </button>
                                        </div>
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
};

export default SidePanel;
