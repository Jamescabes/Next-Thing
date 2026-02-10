import { Settings, History } from 'lucide-react';
import styles from './TopBar.module.css';

const TopBar = ({ onOpenSettings, onOpenHistory }) => {
    const now = new Date();

    // Format: "MONDAY"
    const dayName = now.toLocaleDateString('en-US', { weekday: 'long' });
    // Format: "Feb 10"
    const dateStr = now.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

    return (
        <div className={styles.container}>
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
            </div>

            <div className={styles.dateDisplay}>
                <div className={styles.day}>{dayName}</div>
                <div className={styles.date}>{dateStr}</div>
            </div>
        </div>
    );
};

export default TopBar;
