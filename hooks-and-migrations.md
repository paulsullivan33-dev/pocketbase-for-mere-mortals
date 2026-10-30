# Hooks and migrations

**Outcome: the server gains two
behaviours it did not ship with — a web
address of your own, and a rule that
fills in a missing author — added by one
small JavaScript file, with no change to
the binary; and the collection layout
exists as a file you could carry to
another machine.** This is where a
PocketBase stops being only the product
and starts being the platform.

## Hooks: JavaScript the server runs for you

A **hook** is JavaScript in the
`pb_hooks/` folder that PocketBase runs
at a named moment. The moments cover
nearly everything: a record about to be
created, changed or deleted (per
collection, or all of them), a request
arriving, mail about to be sent, the
server starting. The lab's hook file,
kept at `pocketbase-lab/lab.pb.js`, uses
two of them:

```javascript
/// <reference path="../pb_data/types.d.ts" />

// A tiny custom route, added without touching the binary.
routerAdd("GET", "/lab-ping", (e) => {
  return e.json(200, {
    message: "pong, from a hook file in pb_hooks",
  });
});

// A record hook: a book with no author gets "Unknown".
onRecordCreate((e) => {
  if (!e.record.getString("author")) {
    e.record.set("author", "Unknown");
  }
  e.next();
}, "books");
```

`routerAdd` invents an address. The
server answers it the moment the file
exists (hook files are watched, and
edited files are reloaded without a
restart):

```bash
curl -s http://127.0.0.1:8090/lab-ping
# {"message":"pong, from a hook file in pb_hooks"}
```

`onRecordCreate` runs inside every
creation of a `books` record — after the
API rules and field checks, before the
record is stored. `e.next()` is the hook
saying "continue"; a hook that does not
call it stops the operation, which is
how validation hooks refuse things the
rules language cannot express. The
proof (transcript `t08`): creating a
book with no author at all —

```bash
curl -s -X POST .../api/collections/books/records \
  -H "Authorization: $ADA_TOKEN" \
  -d '{"title":"Authorless Book","owner":"<Ada's id>"}'
# {"title":"Authorless Book","author":"Unknown"}
```

— comes back with the hook's doing
already in it. From this one mechanism
grow most real extensions: sending a
welcome message when a user registers,
totalling an order when its lines
change, exposing a report at a custom
address. PocketBase's JavaScript is a
deliberate subset engine (it is the
goja interpreter, not Node — no npm
packages), and chapter 13 is honest
about that ceiling; for chores of this
size it is exactly enough.

The first line of the file — that
`/// <reference ...>` comment — points
an editor at the type definitions
PocketBase generated in `pb_data`, so
hook code can be written with real
autocomplete. It changes nothing at run
time.

## Migrations: the layout as a file

Chapter 5 created `books` by API call.
Machines set up by hand drift; teams and
future-you need the layout as something
reviewable and repeatable. That is a
**migration**: a JavaScript file, kept
in `pb_migrations/`, that describes a
change to the collections and is applied
once, in filename order, when the server
starts.

Because automatic migrations are on by
default, the lab found the folder
already held a file it never asked for
(transcript `t08`):

```text
pb_migrations/
  1793335626_created_books.js        written when the API created books
  1793335694_collections_snapshot.js written on request, below
```

The first is the server keeping its own
diary — every change made in the admin
page or by API is recorded as a
migration, so the folder is a history of
the layout. The second the lab made
deliberately:

```bash
./pocketbase migrate collections
# Do you really want to create migration
# "pb_migrations/1793335694_collections_snapshot.js"? (y/N) y
```

It writes one file holding **all**
current collections as data, wrapped in
a `migrate((app) => { ... })` function
that can rebuild them and a matching
function that removes them. Copy
`pb_migrations/` to a fresh machine
beside a fresh binary, start it, and the
server builds the same collections
before serving a single request — layout
travels separately from data, which is
what you want when data is private and
layout is not.

Hand-written migrations do the jobs a
snapshot cannot: rename a field without
losing its contents, split one
collection into two, seed reference data
every install needs. They are written
in the same JavaScript as hooks, with
the same `$app` object the snapshot
uses, and they run under the `migrate`
command as well as at startup. This
guide demonstrates the automatic diary
and the snapshot for real, and teaches
hand-written migrations from those two
artefacts; it does not pretend to have
run a rename.

## The check

Two addresses, two answers: `/lab-ping`
returns the hook's JSON, and a book
created without an author returns with
`Unknown` filled in. If either fails,
the hook file is the suspect — chapter
14 lists the usual causes, starting with
the folder name (`pb_hooks`, beside the
data folder's parent, or wherever
`--hooksDir` points).
