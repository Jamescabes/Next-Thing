import { Settings, History } from 'lucide-react';
import SearchBar from '../SearchBar/SearchBar';
import styles from './TopBar.module.css';

const TopBar = ({
    onOpenSettings,
    onOpenHistory,
    searchQuery = '',
    onSearchChange,
    isSearchOpen = false,
    onSearchToggle
}) => {
    const now = new Date();

    const dayName = now.toLocaleDateString('en-US', { weekday: 'long' });
    const dateStr = now.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

    return (
        <nav className={styles.container} aria-label="Main navigation">
            <div className={styles.controls}>
                <button
                    className={styles.settingsButton}
                    onClick={onOpenSettings}
                    aria-label="Settings"
                >
                    <Settings size={20} strokeWidth={2} />
                </button>
                <button
                    className={styles.settingsButton}
                    onClick={onOpenHistory}
                    aria-label="History"
                >
                    <History size={20} strokeWidth={2} />
                </button>
                {onSearchToggle && (
                    <SearchBar
                        isOpen={isSearchOpen}
                        query={searchQuery}
                        onChange={onSearchChange}
                        onToggle={onSearchToggle}
                    />
                )}
            </div>

            <div className={styles.dateDisplay} aria-label={`${dayName}, ${dateStr}`}>
                <div className={styles.day}>{dayName}</div>
                <div className={styles.date}>{dateStr}</div>
            </div>
        </nav>
    );
};

export default TopBar;
