const BASE_URL = 'https://www.googleapis.com/calendar/v3';

export async function fetchCalendarList(accessToken) {
    const resp = await fetch(`${BASE_URL}/users/me/calendarList`, {
        headers: { Authorization: `Bearer ${accessToken}` }
    });
    if (!resp.ok) throw new Error(`Calendar list failed: ${resp.status}`);
    const data = await resp.json();
    return data.items || [];
}

export async function fetchEvents(accessToken, calendarId = 'primary', options = {}) {
    const now = new Date();
    const sixMonthsAgo = new Date(now);
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
    const sixMonthsAhead = new Date(now);
    sixMonthsAhead.setMonth(sixMonthsAhead.getMonth() + 6);

    const timeMin = options.timeMin || sixMonthsAgo.toISOString();
    const timeMax = options.timeMax || sixMonthsAhead.toISOString();

    let allEvents = [];
    let pageToken = null;

    do {
        const url = new URL(`${BASE_URL}/calendars/${encodeURIComponent(calendarId)}/events`);
        url.searchParams.set('singleEvents', 'true');
        url.searchParams.set('orderBy', 'startTime');
        url.searchParams.set('maxResults', '250');
        url.searchParams.set('timeMin', timeMin);
        url.searchParams.set('timeMax', timeMax);
        url.searchParams.set('fields', 'items(id,summary,description,start,end,location,colorId,status),nextPageToken');
        if (pageToken) url.searchParams.set('pageToken', pageToken);

        const resp = await fetch(url.toString(), {
            headers: { Authorization: `Bearer ${accessToken}` }
        });

        if (!resp.ok) throw new Error(`Fetch events failed: ${resp.status}`);

        const data = await resp.json();
        allEvents.push(...(data.items || []));
        pageToken = data.nextPageToken;
    } while (pageToken);

    return allEvents;
}
