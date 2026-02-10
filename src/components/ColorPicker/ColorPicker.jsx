import React from 'react';
import { motion } from 'framer-motion';
import { Check, Plus } from 'lucide-react';
import styles from './ColorPicker.module.css';

const presetColors = [
    { name: 'Default', value: 'var(--color-balloon-bg)' },
    { name: 'Green', value: 'var(--color-balloon-green)' },
    { name: 'Yellow', value: 'var(--color-balloon-yellow)' },
    { name: 'Red', value: 'var(--color-balloon-red)' },
    { name: 'Blue', value: 'var(--color-balloon-blue)' },
    { name: 'Pink', value: 'var(--color-balloon-pink)' },
];

const ColorPicker = ({ selectedColor, onSelectColor }) => {
    return (
        <div className={styles.container}>
            <label className={styles.label}>Color</label>
            <div className={styles.swatches}>
                {presetColors.map((color) => (
                    <motion.button
                        key={color.name}
                        className={styles.swatch}
                        style={{ backgroundColor: color.value }}
                        onClick={() => onSelectColor(color.value)}
                        whileTap={{ scale: 0.9 }}
                        aria-label={color.name}
                    >
                        {selectedColor === color.value && <Check size={16} className={styles.checkIcon} />}
                    </motion.button>
                ))}

                {/* Custom Color Input */}
                <div className={styles.customWrapper}>
                    <input
                        type="color"
                        className={styles.colorInput}
                        onChange={(e) => onSelectColor(e.target.value)}
                        value={selectedColor && !selectedColor.startsWith('var') ? selectedColor : '#ffffff'}
                    />
                    <div className={styles.customOverlay}>
                        <Plus size={16} />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ColorPicker;
