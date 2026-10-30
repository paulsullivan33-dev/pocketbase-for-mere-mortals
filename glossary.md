# Glossary

**API** — the set of web addresses
(`/api/...`) a program calls to use the
backend: list this, create that, log in
here. Everything PocketBase does for
apps, it does through these.

**API rule** — one of five expressions
on a collection (list, view, create,
update, delete) deciding who may do
that thing. Locked means administrators
only; empty means public; an expression
means "only when this is true".

**Auth collection** — a collection whose
records are people who can log in. It
carries email and password fields and
the sign-up/login addresses. `users` is
the built-in one; `_superusers` is the
administrators' own.

**Base collection** — an ordinary data
collection: books, posts, scores.

**Collection** — a named kind of record
with named fields: a table, in database
language. Defined once, filled with
records.

**Filter** — an expression in a list
address (`?filter=...`) choosing among
the records the rules already allowed
you to see. It can narrow, never widen.

**Hook** — a JavaScript file in
`pb_hooks/` that the server runs at a
named moment — a record event, a custom
address, server start — to add behaviour
the product did not ship.

**Migration** — a JavaScript file in
`pb_migrations/` describing a change to
the collections, applied once, in order,
so a layout can be carried between
machines and reviewed like code.

**`pb_data`** — the folder beside the
binary holding everything: the SQLite
databases, uploaded files under
`storage/`, backups under `backups/`.
The folder is the backend.

**`pb_public`** — a folder of plain web
files the server hands out as-is: the
simplest possible home for a small
app's page.

**Record** — one entry in a collection:
one book, one user, one post. Every
record has an `id` and `created` /
`updated` stamps the server maintains.

**Realtime** — the server-sent events
stream at `/api/realtime`, over which
record changes are announced to
subscribers as they happen, filtered by
the same rules as the API.

**Relation** — a field whose value is
the `id` of a record in another
collection: a book's `owner` pointing at
a user. The link is by id, never by a
copied name.

**Superuser** — an administrator account,
kept in `_superusers`, made from the
command line, standing above all rules.
Not an app user.

**Token** — the signed string a login
hands back, sent as the `Authorization`
header afterwards. It is how the server
knows who `@request.auth.id` is.

**View collection** — a read-only
collection defined by a SQL query over
other collections. Named in this guide,
not exercised.
