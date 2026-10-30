# Your first backend

**Outcome: a running PocketBase server
with an administrator account, answering
its health check and serving its admin
page — the smallest complete backend,
ready to be given something to store.**
Three checks prove it: the server's own
startup lines, `/api/health`, and the
admin page's HTML.

## Make the administrator first

A fresh PocketBase has no accounts at
all — not even an administrator. You make
the first one from the command line,
before the server ever runs:

```bash
./pocketbase superuser create admin@example.org lab-admin-pass-123
```

```text
Successfully created new superuser "admin@example.org"!
```

(The password here and everywhere in
this guide's lab is a throwaway value on
a machine nobody else could reach; use
a real one of your own.) Two things to
notice. First, the command needed no
running server — it writes straight into
the data folder it creates on the spot:
after this one command, `pb_data/`
exists and holds `data.db` and
`auxiliary.db`. Second, this
administrator (a **superuser**, in
PocketBase's word) is not an app user.
Superusers run the backend itself and
stand above every rule; the readers of
chapter 7 are a different kind of
account, created later, in a different
collection. Keep the two apart in your
mind from the start.

If you ever lock yourself out, this same
command family is the way back in:
`superuser upsert` resets an existing
administrator's password from the
command line, no web access needed.

## Start the server

```bash
./pocketbase serve --http=127.0.0.1:8090
```

```text
Server started at http://127.0.0.1:8090
├─ REST API:  http://127.0.0.1:8090/api/
└─ Dashboard: http://127.0.0.1:8090/_/
```

`--http` is the address and port to
listen on. `127.0.0.1` means "this
machine only" — the safe place to learn,
and where this guide stays. Port `8090`
is PocketBase's default; plain `serve`
with no flag would bind there on all
interfaces, which is why the guide passes
the flag explicitly while experimenting.
Starting without `--http` on a server you
mean to share is covered in chapter 11.

The server runs in the foreground and
logs each request as it arrives — useful
while learning. The lab ran it in the
background so the same terminal could
hold the `curl` checks, which is the only
difference between its transcripts and
the commands printed here.

## Check one: the health address

```bash
curl -s http://127.0.0.1:8090/api/health
```

```json
{"message":"API is healthy.","code":200,"data":{}}
```

This address needs no login and reveals
nothing but up-ness; it exists so that
scripts, monitors and curious humans can
ask the question you just asked.

## Check two: the admin page

Open `http://127.0.0.1:8090/_/` in a
browser and the login form appears; sign
in with the administrator you just made.
The lab had no browser, so it fetched
the page itself (transcript `t01`):

```bash
curl -s http://127.0.0.1:8090/_/ | head -c 400
```

and received the HTML of the dashboard,
titled `PocketBase`, with HTTP 200. That
proves the page is served by this same
binary — there is no second program to
install for it. What you would see in
the browser: collections down the left,
and in a fresh install almost nothing
yet — the built-in collections
(`_superusers`, `users`, and four small
system ones that track login aids like
one-time passwords) and no data. Seeing
the built-ins listed over the API is
transcript `t02`, which also logs the
administrator in the programmatic way:

```bash
curl -s -X POST http://127.0.0.1:8090/api/collections/_superusers/auth-with-password \
  -H 'Content-Type: application/json' \
  -d '{"identity":"admin@example.org","password":"lab-admin-pass-123"}'
```

The answer carries a `token` and the
administrator's `record`. That token is
the key every later chapter uses when it
needs to act as the administrator over
the API — creating the collection in
chapter 5 is its first job.

## What you have, honestly

A server that answers, an admin page, an
administrator who can log in two ways —
and no app data, no users, and rules
that currently lock everything except
the built-ins' own sign-up and login
addresses. That is a complete backend
the way an empty notebook is a complete
book: the structure is real, and the
next three chapters fill it.
