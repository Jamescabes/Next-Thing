import Dexie from 'dexie';

export const db = new Dexie('NextThingDB');

db.version(1).stores({
    tasks: '++id, title, description, date, time, color, isCompleted, [date+time]' // Indicies for sorting/querying
});
