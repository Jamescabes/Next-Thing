import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, MapPin, Info } from 'lucide-react';
import DateTimePicker from '../DateTimePicker/DateTimePicker';
import ColorPicker from '../ColorPicker/ColorPicker';
import useFocusTrap from '../../hooks/useFocusTrap';
import styles from './EventCreationModal.module.css';

const EventCreationModal = ({ isOpen, onClose, onSave, initialData }) => {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [location, setLocation] = useState('');
    const [date, setDate] = useState('');
    const [time, setTime] = useState('');
    const [color, setColor] = useState('');
    const [titleError, setTitleError] = useState('');

    const focusTrapRef = useFocusTrap(isOpen);

    const isGoogleEvent = initialData?.source === 'google';

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
            setTitle('');
            setDescription('');
            setLocation('');
            setDate(new Date().toISOString().split('T')[0]);
            setTime('12:00');
            setColor('');
        }
        setTitleError('');
    }, [initialData, isOpen]);

    const handleSave = (e) => {
        e.preventDefault();
        if (!title.trim()) {
            setTitleError('Title is required');
            return;
        }
        setTitleError('');

        onSave({
            id: initialData ? initialData.id : Date.now(),
            title: title.trim(),
            description,
            location,
            date,
            time,
            color,
            isCompleted: initialData ? initialData.isCompleted : 0
        });

        onClose();
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Escape') onClose();
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <motion.div
                    className={styles.overlay}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    onKeyDown={handleKeyDown}
                >
                    <motion.div
                        ref={focusTrapRef}
                        className={styles.modal}
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="modal-title"
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                    >
                        <div className={styles.header}>
                            <button onClick={onClose} className={styles.closeButton} aria-label="Close modal">
                                <X size={24} />
                            </button>
                            <span id="modal-title" className={styles.modalTitle}>
                                {initialData ? 'Edit Event' : 'New Event'}
                            </span>
                            {!isGoogleEvent && (
                                <button
                                    onClick={handleSave}
                                    className={styles.saveButton}
                                    disabled={!title.trim()}
                                >
                                    Save
                                </button>
                            )}
                            {isGoogleEvent && <div style={{ width: 40 }} />}
                        </div>

                        {isGoogleEvent && (
                            <div className={styles.googleBanner} role="status">
                                <Info size={16} />
                                <span>Imported from Google Calendar (read-only)</span>
                            </div>
                        )}

                        <div className={styles.formContainer}>
                            <div className={styles.inputGroup}>
                                <label htmlFor="event-title" className={styles.label}>What&apos;s Next?</label>
                                <input
                                    id="event-title"
                                    type="text"
                                    className={`${styles.titleInput} ${titleError ? styles.inputError : ''}`}
                                    value={title}
                                    onChange={(e) => { setTitle(e.target.value); setTitleError(''); }}
                                    onKeyDown={(e) => e.key === 'Enter' && handleSave(e)}
                                    autoFocus={!initialData}
                                    readOnly={isGoogleEvent}
                                    aria-required="true"
                                    aria-invalid={!!titleError}
                                    aria-describedby={titleError ? 'title-error' : undefined}
                                />
                                {titleError && (
                                    <span id="title-error" className={styles.errorMsg} role="alert">
                                        {titleError}
                                    </span>
                                )}
                            </div>

                            <DateTimePicker
                                date={date}
                                time={time}
                                onDateChange={isGoogleEvent ? () => {} : setDate}
                                onTimeChange={isGoogleEvent ? () => {} : setTime}
                            />

                            {!isGoogleEvent && (
                                <ColorPicker
                                    selectedColor={color}
                                    onSelectColor={setColor}
                                />
                            )}

                            <div className={styles.metaInputs}>
                                <div className={styles.inputRow}>
                                    <MapPin size={20} className={styles.icon} />
                                    <input
                                        type="text"
                                        placeholder="Location"
                                        className={styles.subInput}
                                        value={location}
                                        onChange={(e) => setLocation(e.target.value)}
                                        readOnly={isGoogleEvent}
                                        aria-label="Location"
                                    />
                                </div>
                            </div>

                            <div className={styles.inputGroup}>
                                <label htmlFor="event-notes" className={styles.label}>Notes</label>
                                <textarea
                                    id="event-notes"
                                    className={styles.textArea}
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    rows={4}
                                    readOnly={isGoogleEvent}
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
