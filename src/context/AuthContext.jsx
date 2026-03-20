import React, { createContext, useContext, useState, useEffect } from 'react';
import { db } from '../db/db';
import { hashPassword } from '../utils/crypto';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

const SESSION_KEY = 'nt_session_userId';

export const AuthProvider = ({ children }) => {
    const [currentUser, setCurrentUser] = useState(null);
    const [isLoading, setIsLoading] = useState(true);

    // Restore session from localStorage on mount
    useEffect(() => {
        const restoreSession = async () => {
            const storedId = localStorage.getItem(SESSION_KEY);
            if (storedId) {
                try {
                    const user = await db.users.get(Number(storedId));
                    if (user) {
                        setCurrentUser({ id: user.id, username: user.username, email: user.email });
                    } else {
                        localStorage.removeItem(SESSION_KEY);
                    }
                } catch {
                    localStorage.removeItem(SESSION_KEY);
                }
            }
            setIsLoading(false);
        };
        restoreSession();
    }, []);

    const signUp = async ({ username, email, password }) => {
        const existing = await db.users.where('email').equals(email.toLowerCase()).first();
        if (existing) throw new Error('An account with this email already exists.');

        const passwordHash = await hashPassword(password);
        const id = await db.users.add({
            username: username.trim(),
            email: email.toLowerCase().trim(),
            passwordHash,
            createdAt: new Date()
        });

        const user = { id, username: username.trim(), email: email.toLowerCase().trim() };
        localStorage.setItem(SESSION_KEY, String(id));
        setCurrentUser(user);
        return user;
    };

    const logIn = async ({ email, password }) => {
        const user = await db.users.where('email').equals(email.toLowerCase()).first();
        if (!user) throw new Error('No account found with this email.');

        const passwordHash = await hashPassword(password);
        if (passwordHash !== user.passwordHash) throw new Error('Incorrect password.');

        const session = { id: user.id, username: user.username, email: user.email };
        localStorage.setItem(SESSION_KEY, String(user.id));
        setCurrentUser(session);
        return session;
    };

    const logOut = () => {
        localStorage.removeItem(SESSION_KEY);
        setCurrentUser(null);
    };

    const deleteAccount = async () => {
        if (!currentUser) return;
        // Delete all tasks belonging to this user
        await db.tasks.where('userId').equals(currentUser.id).delete();
        // Delete the user record
        await db.users.delete(currentUser.id);
        localStorage.removeItem(SESSION_KEY);
        setCurrentUser(null);
    };

    return (
        <AuthContext.Provider value={{ currentUser, isLoading, signUp, logIn, logOut, deleteAccount }}>
            {children}
        </AuthContext.Provider>
    );
};
