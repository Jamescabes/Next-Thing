import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../context/AuthContext';
import styles from './Login.module.css';

const Login = () => {
    const { logIn, signUp } = useAuth();
    const [mode, setMode] = useState('login'); // 'login' | 'signup'
    const [form, setForm] = useState({ username: '', email: '', password: '', confirmPassword: '' });
    const [error, setError] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleChange = (e) => {
        setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
        setError('');
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setIsSubmitting(true);

        try {
            if (mode === 'signup') {
                if (!form.username.trim()) throw new Error('Username is required.');
                if (!form.email.trim()) throw new Error('Email is required.');
                if (form.password.length < 6) throw new Error('Password must be at least 6 characters.');
                if (form.password !== form.confirmPassword) throw new Error('Passwords do not match.');
                await signUp({ username: form.username, email: form.email, password: form.password });
            } else {
                if (!form.email.trim()) throw new Error('Email is required.');
                if (!form.password) throw new Error('Password is required.');
                await logIn({ email: form.email, password: form.password });
            }
        } catch (err) {
            setError(err.message);
        } finally {
            setIsSubmitting(false);
        }
    };

    const switchMode = (newMode) => {
        setMode(newMode);
        setError('');
        setForm({ username: '', email: '', password: '', confirmPassword: '' });
    };

    return (
        <div className={styles.page}>
            <div className={styles.brand}>
                <h1 className={styles.logo}>Next Thing</h1>
                <p className={styles.tagline}>Your timeline, your way.</p>
            </div>

            <div className={styles.card}>
                <div className={styles.tabs}>
                    <button
                        className={`${styles.tab} ${mode === 'login' ? styles.activeTab : ''}`}
                        onClick={() => switchMode('login')}
                    >
                        Log In
                    </button>
                    <button
                        className={`${styles.tab} ${mode === 'signup' ? styles.activeTab : ''}`}
                        onClick={() => switchMode('signup')}
                    >
                        Sign Up
                    </button>
                </div>

                <AnimatePresence mode="wait">
                    <motion.form
                        key={mode}
                        className={styles.form}
                        onSubmit={handleSubmit}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -8 }}
                        transition={{ duration: 0.15 }}
                    >
                        {mode === 'signup' && (
                            <div className={styles.field}>
                                <label className={styles.label}>Username</label>
                                <input
                                    className={styles.input}
                                    type="text"
                                    name="username"
                                    value={form.username}
                                    onChange={handleChange}
                                    placeholder="Your name"
                                    autoComplete="name"
                                    autoFocus
                                />
                            </div>
                        )}

                        <div className={styles.field}>
                            <label className={styles.label}>Email</label>
                            <input
                                className={styles.input}
                                type="email"
                                name="email"
                                value={form.email}
                                onChange={handleChange}
                                placeholder="you@example.com"
                                autoComplete="email"
                                autoFocus={mode === 'login'}
                            />
                        </div>

                        <div className={styles.field}>
                            <label className={styles.label}>Password</label>
                            <input
                                className={styles.input}
                                type="password"
                                name="password"
                                value={form.password}
                                onChange={handleChange}
                                placeholder={mode === 'signup' ? 'At least 6 characters' : '••••••••'}
                                autoComplete={mode === 'signup' ? 'new-password' : 'current-password'}
                            />
                        </div>

                        {mode === 'signup' && (
                            <div className={styles.field}>
                                <label className={styles.label}>Confirm Password</label>
                                <input
                                    className={styles.input}
                                    type="password"
                                    name="confirmPassword"
                                    value={form.confirmPassword}
                                    onChange={handleChange}
                                    placeholder="Repeat your password"
                                    autoComplete="new-password"
                                />
                            </div>
                        )}

                        {error && <p className={styles.error}>{error}</p>}

                        <button
                            type="submit"
                            className={styles.submitButton}
                            disabled={isSubmitting}
                        >
                            {isSubmitting
                                ? (mode === 'login' ? 'Logging in...' : 'Creating account...')
                                : (mode === 'login' ? 'Log In' : 'Create Account')
                            }
                        </button>
                    </motion.form>
                </AnimatePresence>
            </div>
        </div>
    );
};

export default Login;
