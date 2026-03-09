import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, User, Moon, Sun, LogOut, LogIn, RefreshCw } from 'lucide-react';
import { useGoogleAuth } from '../../context/GoogleAuthContext';
import useFocusTrap from '../../hooks/useFocusTrap';
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

    const focusTrapRef = useFocusTrap(isOpen);

    const getSyncLabel = () => {
        if (syncStatus === 'syncing') return 'Syncing...';
        if (syncStatus === 'success' && syncResult) return `Synced (${syncResult.added} new, ${syncResult.updated} updated)`;
        if (syncStatus === 'error') return 'Sync failed — retry?';
        return 'Sync Now';
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Escape') onClose();
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
                        ref={focusTrapRef}
                        className={styles.panel}
                        role="dialog"
                        aria-modal="true"
                        aria-label="Settings panel"
                        initial={{ x: '-100%' }}
                        animate={{ x: 0 }}
                        exit={{ x: '-100%' }}
                        transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                        onKeyDown={handleKeyDown}
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
                                            <div className={styles.avatar} aria-hidden="true">
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
                                        <div className={styles.avatar} aria-hidden="true">
                                            <User size={24} />
                                        </div>
                                        <div className={styles.userDetails}>
                                            <span className={styles.userName}>Not signed in</span>
                                            <span className={styles.userEmail}>Sign in to sync</span>
                                        </div>
                                    </>
                                )}
                            </div>
                            <button onClick={onClose} className={styles.closeButton} aria-label="Close settings">
                                <X size={24} />
                            </button>
                        </div>

                        <div className={styles.content}>
                            <section className={styles.section} aria-labelledby="google-section">
                                <h3 id="google-section">Google Calendar</h3>
                                {user ? (
                                    <>
                                        <button
                                            className={styles.menuItem}
                                            onClick={() => syncNow()}
                                            disabled={syncStatus === 'syncing'}
                                            aria-label={getSyncLabel()}
                                        >
                                            <RefreshCw
                                                size={20}
                                                className={syncStatus === 'syncing' ? styles.spinning : ''}
                                                aria-hidden="true"
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
                                        <LogIn size={20} aria-hidden="true" />
                                        <span>{isLoading ? 'Signing in...' : 'Sign in with Google'}</span>
                                    </button>
                                )}
                            </section>

                            <section className={styles.section} aria-labelledby="appearance-section">
                                <h3 id="appearance-section">Appearance</h3>
                                <button
                                    className={styles.menuItem}
                                    onClick={toggleTheme}
                                    aria-label={isDarkMode ? 'Switch to light mode' : 'Switch to dark mode'}
                                >
                                    {isDarkMode ? <Sun size={20} aria-hidden="true" /> : <Moon size={20} aria-hidden="true" />}
                                    <span>{isDarkMode ? 'Light Mode' : 'Dark Mode'}</span>
                                </button>
                            </section>

                            {user && (
                                <section className={styles.section} aria-labelledby="account-section">
                                    <h3 id="account-section">Account</h3>
                                    <button className={styles.menuItem} onClick={signOut}>
                                        <LogOut size={20} aria-hidden="true" />
                                        <span>Sign Out</span>
                                    </button>
                                </section>
                            )}
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
};

export default SidePanel;
