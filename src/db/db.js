import Dexie from 'dexie';

export const db = new Dexie('NextThingDB');

db.version(1).stores({
    tasks: '++id, title, description, date, time, color, isCompleted, [date+time]'
});

// Version 11: adds userId index to tasks (for per-user data), adds users table,
// and adds location + notes as stored fields (no index needed).
db.version(11).stores({
    tasks: '++id, title, description, notes, location, date, time, color, isCompleted, userId, [date+time]',
    users: '++id, &email, username'
});
