import { db } from '../db/db';

const GOOGLE_COLOR_MAP = {
    '1':  'var(--color-balloon-blue)',
    '2':  'var(--color-balloon-green)',
    '3':  'var(--color-balloon-pink)',
    '4':  'var(--color-balloon-red)',
    '5':  'var(--color-balloon-yellow)',
    '6':  'var(--color-balloon-red)',
    '7':  'var(--color-balloon-blue)',
    '8':  'var(--color-balloon-green)',
    '9':  'var(--color-balloon-blue)',
    '10': 'var(--color-balloon-green)',
    '11': 'var(--color-balloon-red)',
};

function mapGoogleEventToTask(event) {
    let date, time;

    if (event.start.dateTime) {
        const dt = new Date(event.start.dateTime);
        date = dt.toISOString().split('T')[0];
        time = dt.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    } else if (event.start.date) {
        date = event.start.date;
        time = '00:00';
    }

    return {
        title: event.summary || '(No title)',
        description: event.description || '',
        location: event.location || '',
        date,
        time,
        color: GOOGLE_COLOR_MAP[event.colorId] || '',
        isCompleted: 0,
        googleEventId: event.id,
        source: 'google',
    };
}

export async function syncGoogleEvents(events, userEmail, calendarId = 'primary') {
    const existingGoogleTasks = await db.tasks
        .where('source')
        .equals('google')
        .toArray();

    const existingByGoogleId = new Map(
        existingGoogleTasks.map(t => [t.googleEventId, t])
    );

    const toAdd = [];
    const toUpdate = [];
    const toDelete = [];

    for (const event of events) {
        if (event.status === 'cancelled') {
            const existing = existingByGoogleId.get(event.id);
            if (existing) toDelete.push(existing.id);
            continue;
        }

        const mapped = mapGoogleEventToTask(event);
        const existing = existingByGoogleId.get(event.id);

        if (existing) {
            toUpdate.push({ key: existing.id, changes: mapped });
        } else {
            toAdd.push(mapped);
        }
    }

    await db.transaction('rw', db.tasks, db.googleSyncMeta, async () => {
        if (toAdd.length > 0) await db.tasks.bulkAdd(toAdd);
        for (const { key, changes } of toUpdate) {
            await db.tasks.update(key, changes);
        }
        if (toDelete.length > 0) await db.tasks.bulkDelete(toDelete);

        const existingMeta = await db.googleSyncMeta
            .where('userEmail')
            .equals(userEmail)
            .first();

        if (existingMeta) {
            await db.googleSyncMeta.update(existingMeta.id, {
                lastSyncTime: new Date().toISOString(),
                calendarId,
            });
        } else {
            await db.googleSyncMeta.add({
                userEmail,
                lastSyncTime: new Date().toISOString(),
                calendarId,
            });
        }
    });

    return { added: toAdd.length, updated: toUpdate.length, deleted: toDelete.length };
}
