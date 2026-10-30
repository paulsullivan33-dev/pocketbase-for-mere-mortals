# PocketBase for Mere Mortals

Almost every small program that more than
one person uses needs the same four
things behind it: somewhere to keep its
data, a way for people to log in, a place
to put uploaded files, and an API — a
set of web addresses the program itself
talks to. Assembling those four things
from separate parts is a project before
the project. **PocketBase** puts all four
in a single file you download and run.
It is a database, a login system, a file
store and a web API in one program, and
it keeps everything it owns in one
folder beside itself.

This guide explains what PocketBase is,
installs it, and then builds a complete
small backend with it: a reading list
that people sign up for, stock with
their own books, and cannot peek into
each other's shelves. Every claim is
checked against the real program with
`curl` as the guide goes — records are
created and queried, a second user is
turned away by the access rules in front
of you, a file is uploaded and fetched
back byte for byte, and a change made in
one command arrives live in another
through PocketBase's realtime stream.

The lab behind this guide ran the real
thing: **PocketBase 0.40.6**, the
official release binary, on a small
Linux machine, speaking only to
`127.0.0.1` — the machine itself. Against
it the lab created its administrator
from the command line, opened the admin
page the binary serves, logged in over
the API, defined a collection with
fields and rules, ran three books
through it, filtered and paged the
results, registered two readers, proved
the second reader could not see, change
or forge the first reader's books,
uploaded a picture and compared the hash
of what came back, subscribed to the
realtime feed and watched two changes
arrive as they happened, added two small
JavaScript hooks — a new web address and
a rule that fills in a missing author —
snapshotted the database layout as a
migration file, and took a backup
through the API.

What the lab could not do, it did not
fake. It never clicked through the admin
screens with a real browser; it fetched
the page the binary serves and then used
the same API those screens use, which is
where the proof lives anyway. It sent no
email (there was no mail server to send
through), signed nobody in with an
outside provider such as Google, and put
nothing on the public internet — the
steps for those are written from the
project's documentation and labelled as
such wherever they appear. `criteria.md`
keeps the full ledger of what was run
and what was only read.

## What this guide covers

- [**What PocketBase is**](what-pocketbase-is.md) —
  the mental model: one program, one
  folder, four jobs every small app needs
- [**The moving parts**](the-moving-parts.md) —
  the binary, the data folder, collections,
  records, the admin page and the API —
  and which part holds what
- [**Installing PocketBase**](installing-pocketbase.md) —
  the release download, and the version
  check that proves it runs
- [**Your first backend**](your-first-backend.md) —
  an administrator account, a running
  server, and the health check that
  proves it answers
- [**Collections and rules**](collections-and-rules.md) —
  defining a table with fields, and the
  access rules that decide who may do what
- [**Working with records**](working-with-records.md) —
  creating and listing data over the API,
  with filters, sorting and pages
- [**Users and logins**](users-and-logins.md) —
  signing readers up, logging them in,
  and watching the rules turn a stranger away
- [**Files**](files.md) — uploading a
  picture into a record and fetching it
  back, hash-checked
- [**Realtime**](realtime.md) — subscribing
  to changes and seeing them arrive the
  moment they happen
- [**Hooks and migrations**](hooks-and-migrations.md) —
  small JavaScript files that extend the
  server, and snapshots that carry your
  layout from machine to machine
- [**Recipes**](recipes.md) — a web page
  that talks to the backend, a backup
  taken through the API, and running
  PocketBase as a service
- [**The neighbours**](the-neighbours.md) —
  Firebase, Supabase, Appwrite, a folder
  of your own code, and plain SQLite:
  what each does that PocketBase doesn't,
  and vice versa
- [**Limits**](limits.md) — one server,
  one writer at a time, no built-in way
  to spread across machines, and the
  other edges, stated plainly
- [**Troubleshooting**](troubleshooting.md) —
  the 404 that means "not yours", the
  record that failed to create, the hook
  that did not load, and the other traps
  this guide's lab fell into
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Building the program you put in front of
PocketBase. This guide's backend serves a
reading list, and chapter 11 shows a
small page talking to it, but designing
and writing a whole app — screens,
navigation, offline behaviour — is a
project of its own. Scaling beyond one
machine is likewise out, because
PocketBase itself is: chapter 13 is
honest about where that ceiling sits.
And while PocketBase can send mail for
password resets and confirmations, this
guide does not run a mail server; that
part is described, not demonstrated.

## How to use this guide

Read chapter 1 for the model, and
chapter 2 before installing anything —
knowing which part holds what turns
later confusion into a named problem.
Chapters 3 and 4 get you a program, an
administrator and a running server in
one sitting. Chapters 5 to 7 build the
reading list and are the heart of the
guide; read those slowly. Chapters 8 to
10 each add one capability and can be
taken in any order once the list works.
The lab's transcripts live in
`pocketbase-lab/transcripts/`; the
collection definition it used is
`pocketbase-lab/books-collection.json`,
and the realtime and hook scripts are
`pocketbase-lab/realtime-test.sh` and
`pocketbase-lab/lab.pb.js`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [SQLite for Mere Mortals](https://paulsullivan33-dev.github.io/sqlite-for-mere-mortals/)
- [APIs for Mere Mortals](https://paulsullivan33-dev.github.io/api-for-mere-mortals/)
- [Go for Mere Mortals](https://paulsullivan33-dev.github.io/go-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/pocketbase-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/pocketbase-for-mere-mortals/blob/main/LICENSE-CODE).
