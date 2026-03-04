import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import * as googleAuth from '../services/googleAuth';
import * as googleCalendar from '../services/googleCalendar';
import { syncGoogleEvents } from '../services/syncService';

const GoogleAuthContext = createContext();
export const useGoogleAuth = () => useContext(GoogleAuthContext);

export const GoogleAuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const [syncStatus, setSyncStatus] = useState('idle');
    const [syncResult, setSyncResult] = useState(null);
    const [lastSyncTime, setLastSyncTime] = useState(null);

    useEffect(() => {
        googleAuth.initGoogleAuth().catch(() => {
            console.warn('Google Identity Services not available');
        });
    }, []);

    const performSync = useCallback(async (token, email) => {
        setSyncStatus('syncing');
        try {
            const accessToken = token || await googleAuth.getAccessToken();
            const userEmail = email || user?.email;
            const events = await googleCalendar.fetchEvents(accessToken);
            const result = await syncGoogleEvents(events, userEmail);
            setSyncResult(result);
            setSyncStatus('success');
            setLastSyncTime(new Date());
            setTimeout(() => setSyncStatus('idle'), 3000);
        } catch (err) {
            console.error('Sync failed:', err);
            setSyncStatus('error');
            setTimeout(() => setSyncStatus('idle'), 5000);
        }
    }, [user]);

    const handleSignIn = useCallback(async () => {
        setIsLoading(true);
        try {
            const result = await googleAuth.signIn();
            setUser(result.user);
            await performSync(result.accessToken, result.user.email);
        } catch (err) {
            console.error('Sign in failed:', err);
        } finally {
            setIsLoading(false);
        }
    }, [performSync]);

    const handleSignOut = useCallback(() => {
        googleAuth.signOut();
        setUser(null);
        setSyncStatus('idle');
        setSyncResult(null);
        setLastSyncTime(null);
    }, []);

    return (
        <GoogleAuthContext.Provider value={{
            user,
            isLoading,
            syncStatus,
            syncResult,
            lastSyncTime,
            signIn: handleSignIn,
            signOut: handleSignOut,
            syncNow: performSync,
        }}>
            {children}
        </GoogleAuthContext.Provider>
    );
};
