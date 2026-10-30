# Realtime

**Outcome: a change made in one command
arrives, by itself, in a window that did
nothing but listen — once when a record
is updated and once when one is created.**
Realtime is how an app shows Ada's second
device the rating she just changed on
her first, without her pressing refresh.

## How the stream works

Realtime in PocketBase is a **server-sent
events** stream: one long-lived HTTP
connection that the server writes small
messages into as things happen. The
dance has three steps, all visible in
the lab's script, `pocketbase-lab/
realtime-test.sh` (its full run is
transcript `t07`):

1. **Open the stream.**
   `GET /api/realtime`, wearing the
   token of whoever is listening. The
   first message is the server's hello:

   ```text
   event:PB_CONNECT
   data:{"clientId":"7s82G6S5LUUd7YdIB4maXwd2SiIphzquW7OivUqB"}
   ```

   That `clientId` is this connection's
   name — a temporary one, minted per
   connection.

2. **Say what to watch.** A `POST` to
   the same address names the client and
   its subscriptions:

   ```bash
   curl -s -X POST http://127.0.0.1:8090/api/realtime \
     -H "Authorization: $ADA_TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{"clientId":"<the id from step 1>",
          "subscriptions":["books/*"]}'
   ```

   The server answers `204` — received,
   nothing to show. A subscription is a
   collection name with a tail: `books/*`
   means "every record in books";
   `books/<record id>` watches one book;
   and a subscription can carry a filter
   (for example only books whose status
   changes to `finished`) — filters
   narrow the stream just as chapter 6's
   narrowed the lists.

3. **Changes arrive.** In the lab, one
   ordinary `PATCH` (Ada's book, rating
   5 → 4) and one `POST` (a new book)
   were run in other commands while the
   stream sat open. Both arrived:

   ```text
   event:books/*
   data:{"record":{...,"rating":4,...},"action":"update"}

   event:books/*
   data:{"record":{...,"title":"Realtime Test Book",...},"action":"create"}
   ```

   Each event carries the whole record
   after the change and an `action` —
   `create`, `update` or `delete`.

## The rules still apply — this is the point

Ada's stream heard about Ada's books
because the connection wears Ada's
token, and realtime subscriptions are
filtered by the same list and view rules
as everything else. Had Ben opened the
identical subscription with his token,
Ada's changes would not have crossed to
him; the stream is not a back door
around chapter 5. When you design an
app, that property is what makes
realtime safe to use for private data
without writing a second permission
system for it.

## In an app

A browser program does the same three
steps with its built-in event-stream
support, or with PocketBase's JavaScript
library doing them for it (chapter 11's
page uses plain requests instead, to
keep the moving parts visible). The
connection drops and reconnects as
networks do; on each reconnect the app
re-subscribes, and because a change
could have been missed while away, sane
apps re-fetch the list once after
reconnecting rather than trusting the
stream to be a complete history.
Realtime is a notification that
something changed — the record in the
event is a convenience, and the API
remains the source of truth.

## The check

Run the lab's script against your own
server and count: one `PB_CONNECT`,
then one event per change you make in a
second terminal — and none for changes
made to records your token cannot see.
