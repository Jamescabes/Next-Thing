import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, MapPin } from 'lucide-react';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import ColorPicker from '../ColorPicker/ColorPicker';
import styles from './EventCreationModal.module.css';

const EventCreationModal = ({ isOpen, onClose, onSave, initialData }) => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [location, setLocation] = useState('');
    const [date, setDate] = useState('');
    const [time, setTime] = useState('');
    const [color, setColor] = useState('');

    // Hydrate form when initialData changes (Edit Mode)
    useEffect(() => {
        if (initialData) {
            setTitle(initialData.title || '');
            setDescription(initialData.description || '');
            setLocation(initialData.location || '');
            setDate(initialData.date || new Date().toISOString().split('T')[0]);
            setTime(initialData.time || '12:00');
            setColor(initialData.color || '');
        } else {
            // Reset for new event
            setTitle('');
            setDescription('');
            setLocation('');
            setDate(new Date().toISOString().split('T')[0]);
            setTime('12:00');
            setColor('');
        }
    }, [initialData, isOpen]);

    const handleQuickDate = (daysToAdd) => {
        const date = new Date();
        date.setDate(date.getDate() + daysToAdd);
        // Default to morning for quick add? Or keep current time? 
        // Let's set a default time like 9:00 AM or just keep it blank/current.
        // The modal uses 'time' state.

        const dateStr = date.toISOString().split('T')[0];
        setDate(dateStr);
        // We do NOT call onSave here anymore.
    };

    const handleSave = (e) => {
        e.preventDefault();
        if (!title) return;

        onSave({
            id: initialData ? initialData.id : Date.now(),
            title,
            description,
            location,
            date,
            time,
            color,
            isCompleted: initialData ? initialData.isCompleted : 0
        });

        onClose();
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    className={styles.overlay}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                >
                    <motion.div
                        className={styles.modal}
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                    >
                        <div className={styles.header}>
                            <button onClick={onClose} className={styles.closeButton}>
                                <X size={24} />
                            </button>
                            <span className={styles.modalTitle}>{initialData ? 'Edit Event' : 'New Event'}</span>
                            <button onClick={handleSave} className={styles.saveButton} disabled={!title}>
                                Save
                            </button>
                        </div>

                        <div className={styles.formContainer}>
                            <div className={styles.inputGroup}>
                                <label className={styles.label}>What's Next?</label>
                                <input
                                    type="text"
                                    className={styles.titleInput}
                                    value={title}
                                    onChange={(e) => setTitle(e.target.value)}
                                    onKeyDown={(e) => e.key === 'Enter' && handleSave(e)}
                                    autoFocus={!initialData}
                                />
                            </div>

                            <DateTimePicker
                                date={date}
                                time={time}
                                onDateChange={setDate}
                                onTimeChange={setTime}
                            />

                            <ColorPicker
                                selectedColor={color}
                                onSelectColor={setColor}
                            />

                            <div className={styles.metaInputs}>
                                <div className={styles.inputRow}>
                                    <MapPin size={20} className={styles.icon} />
                                    <input type="text" placeholder="Location" className={styles.subInput} value={location} onChange={(e) => setLocation(e.target.value)} />
                                </div>
                            </div>

                            <div className={styles.inputGroup}>
                                <label className={styles.label}>Notes</label>
                                <textarea
                                    className={styles.textArea}
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    rows={4}
                                />
                            </div>

                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default EventCreationModal;
