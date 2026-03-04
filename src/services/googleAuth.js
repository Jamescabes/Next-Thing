const SCOPES = 'https://www.googleapis.com/auth/calendar.readonly';

let tokenClient = null;
let accessToken = null;
let tokenExpiresAt = null;

function waitForGIS(timeout = 10000) {
    return new Promise((resolve, reject) => {
        if (window.google?.accounts?.oauth2) {
            resolve();
            return;
        }
        const start = Date.now();
        const interval = setInterval(() => {
            if (window.google?.accounts?.oauth2) {
                clearInterval(interval);
                resolve();
            } else if (Date.now() - start > timeout) {
                clearInterval(interval);
                reject(new Error('Google Identity Services failed to load'));
            }
        }, 100);
    });
}

export async function initGoogleAuth() {
    await waitForGIS();
    // tokenClient is initialized lazily in signIn
}

export function signIn() {
    return new Promise(async (resolve, reject) => {
        try {
            await waitForGIS();

            tokenClient = window.google.accounts.oauth2.initTokenClient({
                client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
                scope: SCOPES,
                callback: async (response) => {
                    if (response.error) {
                        reject(new Error(response.error));
                        return;
                    }
                    accessToken = response.access_token;
                    tokenExpiresAt = Date.now() + (response.expires_in * 1000);

                    // Fetch user profile
                    try {
                        const profileRes = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
                            headers: { Authorization: `Bearer ${accessToken}` }
                        });
                        const profile = await profileRes.json();
                        resolve({
                            accessToken,
                            user: {
                                email: profile.email,
                                name: profile.name,
                                picture: profile.picture,
                            }
                        });
                    } catch (err) {
                        resolve({ accessToken, user: { email: 'Unknown', name: 'User', picture: null } });
                    }
                },
            });

            tokenClient.requestAccessToken();
        } catch (err) {
            reject(err);
        }
    });
}

export function signOut() {
    if (accessToken) {
        window.google.accounts.oauth2.revoke(accessToken);
    }
    accessToken = null;
    tokenExpiresAt = null;
    tokenClient = null;
}

export async function getAccessToken() {
    if (accessToken && tokenExpiresAt && Date.now() < tokenExpiresAt - 60000) {
        return accessToken;
    }

    // Try silent refresh
    return new Promise((resolve, reject) => {
        if (!tokenClient) {
            reject(new Error('Not signed in'));
            return;
        }

        const originalCallback = tokenClient.callback;
        tokenClient.callback = (response) => {
            tokenClient.callback = originalCallback;
            if (response.error) {
                reject(new Error('Token refresh failed: ' + response.error));
                return;
            }
            accessToken = response.access_token;
            tokenExpiresAt = Date.now() + (response.expires_in * 1000);
            resolve(accessToken);
        };

        tokenClient.requestAccessToken({ prompt: '' });
    });
}

export function isSignedIn() {
    return !!accessToken && Date.now() < (tokenExpiresAt || 0);
}
