# Limits

**Outcome: you can name the walls a
PocketBase project will eventually hit,
and recognise them while there is still
time to choose differently.** None of
these are bugs; they are the price of
the design that makes chapters 3 to 10
so short, printed on the box.

## One server, one folder

PocketBase runs as a single process on
a single machine, and there is no
built-in way to run two copies sharing
the work. If the machine stops, the
backend stops; if the app outgrows the
machine, the move is to a *bigger*
machine, not a second one. For the
projects this guide is aimed at — club,
family, small team, one person's
several apps — that ceiling is years
away or never reached. For a product
expecting a crowd, it is the first
thing to weigh, and chapter 12's
platforms exist because of it.

## SQLite's one writer

The database underneath allows many
readers but **one writer at a time**.
Writes are fast and queued politely,
and PocketBase handles ordinary loads
without drama — but a backend whose
whole day is hundreds of simultaneous
writers will queue them into latency.
High-read, modest-write is the shape
this tool is for; write-heavy workloads
belong on a client-server database.

## Rules are the whole security model

Everything chapter 7 proved rests on
the API rules being written correctly.
There is no second layer: an empty-string
rule makes a collection public to the
internet, a `@request.auth.id` forgotten
on one of the five rules leaves exactly
that one door open, and hooks (chapter
10) run *inside* the server with its
powers — a careless hook can bypass
rules the careful way a careless
administrator can. The tool makes the
safe thing easy and the review small —
five expressions per collection — but it
cannot make it automatic. Read your
rules like you would read a lock.

## The JavaScript is a subset

Hooks run on an embedded interpreter
(goja), not Node.js: no npm packages, no
libraries beyond what PocketBase itself
exposes to scripts, and hook code shares
the server's one process. If the
extension you need is large, the
project's intended answer is to use
PocketBase as a **Go framework** —
importing it as a library into your own
Go program — which is a different book
from this guide, with builds and
deployments of your own to manage.

## Admins are absolute, and there is one class of them

Superusers can see and change
everything, always; there are no
read-only administrators, no per-
collection moderators among staff, and
no audit trail a superuser cannot
reach. Apps needing graded staff roles
must build them as ordinary users plus
rules — possible, but you design it —
or choose a platform that ships them.

## Smaller edges, stated plainly

- **Email depends on your SMTP server.**
  Resets and confirmations are only as
  reliable as the mail setup behind
  them, which is yours to provide.
- **Backups are whole, or nothing.**
  The built-in backup is the entire
  backend in a zip — simple, and coarse:
  there is no per-collection restore.
- **The admin page is the whole UI.**
  What your *users* see is your app to
  build; PocketBase gives them no
  screens of its own.
- **Young, single-maintainer-led
  project.** PocketBase is open source
  and widely used, but its history
  includes breaking changes between
  major versions (the administrator
  became the "superuser" not long ago).
  Pin your version, read the changelog
  before updating — `pb_data` copies
  make trying an update safe.
- **View collections and SQL are a
  side door, not the road.** PocketBase
  is not a general SQL workbench; the
  API is the interface it designs for.
