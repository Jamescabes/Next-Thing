import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, ChevronLeft, Calendar as CalendarIcon, Clock } from 'lucide-react';
import styles from './DateTimePicker.module.css';

const DateTimePicker = ({ date, time, onDateChange, onTimeChange }) => {
    const [mode, setMode] = useState('date'); // 'date' or 'time'

    const handleQuickDate = (daysToAdd) => {
        const d = new Date();
        d.setDate(d.getDate() + daysToAdd);
        onDateChange(d.toISOString().split('T')[0]);
    };

    // Parse time HH:mm
    const [hour, minute] = (time || '12:00').split(':');

    const handleHourChange = (newHour) => {
        onTimeChange(`${newHour.padStart(2, '0')}:${minute}`);
    };

    const handleMinuteChange = (newMinute) => {
        onTimeChange(`${hour}:${newMinute.padStart(2, '0')}`);
    };

    const hours = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'));
    const minutes = Array.from({ length: 12 }, (_, i) => String(i * 5).padStart(2, '0'));

    return (
        <div className={styles.container}>
            <div className={styles.tabs}>
                <button
                    className={`${styles.tab} ${mode === 'date' ? styles.active : ''}`}
                    onClick={() => setMode('date')}
                >
                    <CalendarIcon size={16} /> Date
                </button>
                <button
                    className={`${styles.tab} ${mode === 'time' ? styles.active : ''}`}
                    onClick={() => setMode('time')}
                >
                    <Clock size={16} /> Time
                </button>
            </div>

            <AnimatePresence mode="wait">
                {mode === 'date' ? (
                    <motion.div
                        key="date"
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className={styles.pickerBody}
                    >
                        <div className={styles.quickSelect}>
                            <button onClick={() => handleQuickDate(0)} className={styles.chip}>Today</button>
                            <button onClick={() => handleQuickDate(1)} className={styles.chip}>Tomorrow</button>
                            <button onClick={() => handleQuickDate(2)} className={styles.chip}>In 2 Days</button>
                        </div>
                        <div className={styles.centeredInput}>
                            <input
                                type="date"
                                value={date}
                                onChange={(e) => onDateChange(e.target.value)}
                                className={styles.nativeInput}
                            />
                        </div>
                    </motion.div>
                ) : (
                    <motion.div
                        key="time"
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className={styles.pickerBody}
                    >
                        <div className={styles.centeredDropdowns}>
                            <div className={styles.dropdownGroup}>
                                <select
                                    value={hour}
                                    onChange={(e) => handleHourChange(e.target.value)}
                                    className={styles.timeDropdown}
                                >
                                    {hours.map(h => <option key={h} value={h}>{h}</option>)}
                                </select>
                                <span className={styles.label}>Hr</span>
                            </div>
                            <span className={styles.separator}>:</span>
                            <div className={styles.dropdownGroup}>
                                <select
                                    value={minute}
                                    onChange={(e) => handleMinuteChange(e.target.value)}
                                    className={styles.timeDropdown}
                                >
                                    {minutes.map(m => <option key={m} value={m}>{m}</option>)}
                                </select>
                                <span className={styles.label}>Min</span>
                            </div>
                        </div>
                        <p className={styles.hint}>Select the time for your event</p>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default DateTimePicker;
