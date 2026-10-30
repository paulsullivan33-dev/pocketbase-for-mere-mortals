# The moving parts

**Outcome: given any behaviour of a
running PocketBase, you can name which
part produced it — the binary, the data
folder, a collection, a rule, the admin
page, the API, or a hook.** Knowing which
part holds what is what turns a surprise
into a named problem later.

## The binary

`pocketbase` is one executable file,
written in Go, containing everything:
the web server, the database engine
(SQLite), the admin page's code, and a
JavaScript engine for the small programs
of chapter 10. `./pocketbase --help`
(the lab's transcript `t00` keeps it)
lists its whole command surface:

- `serve` — start the server.
- `superuser` — manage the administrator
  accounts from the command line.
- `migrate` — run or create the layout
  snapshots of chapter 10.
- `update` — replace the binary with the
  newest release.

Flags set where things live: `--dir` for
the data folder, `--hooksDir` for hook
files, `--publicDir` for static web
files it should serve. The defaults are
sane and this guide mostly uses them.

## The data folder: `pb_data`

When the server first runs, it creates
`pb_data/` beside the binary:

- `data.db` — the SQLite database:
  your collections, records, users and
  settings.
- `auxiliary.db` — a second, small
  database for logs and housekeeping.
- `storage/` — uploaded files, in one
  subfolder per collection, named by
  record. Chapter 8 finds a book cover
  there with its checksum matching the
  upload.
- `backups/` — whole-backend backup zips,
  when you ask for them (chapter 11).
- `types.d.ts` — a file of type
  definitions for people writing hooks.

Backups are simple because of this
layout: the folder is the backend.

## Collections and records

A **collection** is PocketBase's word
for a table: a named kind of thing with
named fields. The reading list's
`books` collection has fields `title`
(text), `author` (text), `status` (one
of a fixed list), `rating` (a number),
`owner` (a link to a user) and `cover`
(a file). A **record** is one entry in a
collection — one book on one list. Every
record also gets system fields
PocketBase manages: an `id`, and
`created` / `updated` timestamps.

There are three kinds of collection:

- **Base** — ordinary data, like `books`.
- **Auth** — people who can log in. They
  carry extra fields (email, password
  hash, verified flag) and extra API
  addresses for registering and logging
  in. A fresh PocketBase already has one
  called `users`, and a hidden one,
  `_superusers`, for administrators.
- **View** — a read-only collection
  defined by a SQL query over others.
  This guide names it and moves on; it is
  documented-only here.

## API rules

Each base and auth collection carries
five rules — **list**, **view**,
**create**, **update**, **delete** — one
per thing the API lets you do. A rule is
either empty in one of two different
ways, or an expression:

- **Locked** (the rule is `null`): only
  administrators may do it.
- **Public** (the rule is an empty
  string): anyone may, even logged-out
  visitors.
- **An expression** like
  `owner = @request.auth.id`: it must be
  true for the record and the requester,
  or the request fails. For list and view
  it also *filters*: records the rule
  excludes simply do not appear, as if
  they were not there.

That last behaviour is the quiet
superpower of the tool, and chapter 7
proves it from three directions.

## The two faces: admin page and API

The server presents the same backend
twice. The **admin page** at `/_/` is
for the human running it: point, click,
see everything, because administrators
are above the rules. The **API** at
`/api/` is for programs — and for this
guide's checks, because `curl` output
can be kept as evidence in a way a
screenshot cannot. Everything the admin
page can do, it does by calling the API
itself; learning the API is learning the
whole tool. One health address,
`/api/health`, exists so scripts can ask
"are you up?" — chapter 4 uses it as the
first proof.

## Tokens

Logging in returns a **token**: a signed
string the app then sends in an
`Authorization` header with each
request. PocketBase reads it to know who
is asking — that is how `@request.auth.id`
in a rule gets its value. Tokens expire
(two weeks by default for ordinary
users) and are not stored server-side;
logging out is the app forgetting the
string. Administrators log in the same
way, against `_superusers`, and their
token lifts them above every rule.

## Realtime and hooks

Two extension points round out the
parts. **Realtime** is a standing
connection (an SSE stream, the same
one-way feed web browsers use for live
updates) over which the server announces
record changes to whoever is subscribed
and allowed to see them — chapter 9.
**Hooks** are small JavaScript files in
a `pb_hooks/` folder that the server
runs at named moments: when a record is
created, when a request arrives at an
address you invent, when mail is about
to be sent. They are how a backend grows
behaviour PocketBase did not ship —
chapter 10 adds two and watches both work.
