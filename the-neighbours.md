# The neighbours

**Outcome: given a project, you can say
which of PocketBase's neighbours fits it
better, and what you would gain and give
up by switching.** None of these were
run in this guide's lab; they are
characterised from their documentation
so the comparison is fair, and this
guide's claims about PocketBase itself
rest on the transcripts, not on this
chapter.

## Firebase — the hosted original

Google's Firebase is the service
PocketBase's shape imitates: database,
logins, file storage, and an API, but
running on Google's machines, set up by
clicking in a console, and paid for as
usage grows. Choose it when the backend
must simply exist — no server of yours
to patch, back up or keep awake — and
when its document database and its
pricing page both fit your project.
Give up: the machine. Your data lives
under another company's account, terms
and outages, leaving means exporting
and rewriting against a different API,
and a runaway client can turn "free
tier" into a bill. PocketBase is the
same shape of tool with the custody
reversed.

## Supabase — the hosted platform on Postgres

Supabase is a platform built on the
full-sized PostgreSQL database: hosted
or self-hosted, it adds logins, storage,
an API generated from your tables, and
realtime, much like PocketBase — and it
is the natural next step *up*. Choose it
when you expect real growth, need
Postgres' querying strength, or want a
team's worth of tooling around the
database. Give up: the single file. Even
self-hosted, Supabase is several
services in containers, with a real
database to administer; the distance
from "download, run" to "deployed" is
measured in evenings, not minutes.

## Appwrite — the self-hosted platform

Appwrite is the closest neighbour in
spirit: open source, self-hosted,
database + logins + storage + functions,
pitched at app builders. Choose it when
you want that breadth — multiple
projects in one install, a generous
permission model, SDKs for everything —
and you are comfortable running its
container stack. Give up: lightness.
PocketBase is one file on almost any
machine, including the smallest rented
server and a Pi; Appwrite asks more of
the machine and of you.

## Your own code — a small API you write yourself

The oldest neighbour: a few hundred
lines in Go, Python or Node that open a
database, check a password, and answer
requests. Choose it when your needs are
truly few and fixed, or truly strange —
either way, the four jobs of chapter 1
at a size no framework matches, in a
shape entirely yours. Give up: the
finished parts. Sign-up flows, password
resets, an admin page, rule-checked
realtime, migrations — you will write
and, more importantly, *secure* each
yourself. People reach for PocketBase
precisely after writing this once.

## Plain SQLite — just the database

The SQLite guide in this series covers
the engine PocketBase is built on, and
sometimes the engine alone is the right
answer: a single-user program, a data
file passed around, an embedded store
inside a bigger system. Choose it when
there are no accounts, no network, no
second program asking questions. Give
up: everything PocketBase wraps around
it — which, when you need any of it, is
the whole of this guide.

## The short version

Hosted and hands-off: Firebase. Room to
grow into a platform: Supabase. Broad
and self-hosted, with containers:
Appwrite. Tiny or peculiar: your own
code. No network at all: SQLite.
One file, your machine, this evening:
PocketBase.
