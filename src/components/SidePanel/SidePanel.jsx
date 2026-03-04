import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, User, Moon, Sun, LogOut, LogIn, RefreshCw } from 'lucide-react';
import { useGoogleAuth } from '../../context/GoogleAuthContext';
import styles from './SidePanel.module.css';

const SidePanel = ({ isOpen, onClose, isDarkMode, toggleTheme }) => {
    const {
        user,
        isLoading,
        syncStatus,
        syncResult,
        lastSyncTime,
        signIn,
        signOut,
        syncNow,
    } = useGoogleAuth();

    const getSyncLabel = () => {
        if (syncStatus === 'syncing') return 'Syncing...';
        if (syncStatus === 'success' && syncResult) return `Synced (${syncResult.added} new, ${syncResult.updated} updated)`;
        if (syncStatus === 'error') return 'Sync failed — retry?';
        return 'Sync Now';
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
                                {user ? (
                                    <>
                                        {user.picture ? (
                                            <img
                                                src={user.picture}
                                                alt={user.name}
                                                className={styles.avatarImg}
                                                referrerPolicy="no-referrer"
                                            />
                                        ) : (
                                            <div className={styles.avatar}>
                                                <User size={24} />
                                            </div>
                                        )}
                                        <div className={styles.userDetails}>
                                            <span className={styles.userName}>{user.name}</span>
                                            <span className={styles.userEmail}>{user.email}</span>
                                        </div>
                                    </>
                                ) : (
                                    <>
                                        <div className={styles.avatar}>
                                            <User size={24} />
                                        </div>
                                        <div className={styles.userDetails}>
                                            <span className={styles.userName}>Not signed in</span>
                                            <span className={styles.userEmail}>Sign in to sync</span>
                                        </div>
                                    </>
                                )}
                            </div>
                            <button onClick={onClose} className={styles.closeButton}>
                                <X size={24} />
                            </button>
                        </div>

                        <div className={styles.content}>
                            <div className={styles.section}>
                                <h3>Google Calendar</h3>
                                {user ? (
                                    <>
                                        <button
                                            className={styles.menuItem}
                                            onClick={() => syncNow()}
                                            disabled={syncStatus === 'syncing'}
                                        >
                                            <RefreshCw
                                                size={20}
                                                className={syncStatus === 'syncing' ? styles.spinning : ''}
                                            />
                                            <span>{getSyncLabel()}</span>
                                        </button>
                                        {lastSyncTime && (
                                            <span className={styles.syncTime}>
                                                Last: {lastSyncTime.toLocaleTimeString()}
                                            </span>
                                        )}
                                    </>
                                ) : (
                                    <button
                                        className={styles.menuItem}
                                        onClick={signIn}
                                        disabled={isLoading}
                                    >
                                        <LogIn size={20} />
                                        <span>{isLoading ? 'Signing in...' : 'Sign in with Google'}</span>
                                    </button>
                                )}
                            </div>

                            <div className={styles.section}>
                                <h3>Appearance</h3>
                                <button className={styles.menuItem} onClick={toggleTheme}>
                                    {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
                                    <span>{isDarkMode ? 'Light Mode' : 'Dark Mode'}</span>
                                </button>
                            </div>

                            {user && (
                                <div className={styles.section}>
                                    <h3>Account</h3>
                                    <button className={styles.menuItem} onClick={signOut}>
                                        <LogOut size={20} />
                                        <span>Sign Out</span>
                                    </button>
                                </div>
                            )}
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
};

export default SidePanel;
