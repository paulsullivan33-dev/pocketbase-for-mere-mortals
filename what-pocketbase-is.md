# What PocketBase is

**Outcome: you can say what PocketBase
is, what jobs it takes off your hands,
and when it is the wrong tool — before
downloading anything.** The check is the
three questions at the end of this
chapter; if you can answer them, the
model is in place.

## The problem it removes

Write a small program that several
people use — a club's book swap list, a
family's recipe box, a team's rota — and
the interesting part of the program
quickly becomes the smaller part of the
work. First the data needs a home that
survives the program closing: a
database. Then each person needs an
account, a password stored safely, a way
back in when the password is forgotten.
Then someone wants to attach a photo,
and the photos need storing and serving.
And the program on a phone and the
program on a laptop both need to talk to
all of this, so you end up writing a web
API too — the set of addresses like
`GET /books` and `POST /books` that the
app calls. Four jobs, each with its own
software, its own setup, its own updates.

PocketBase does all four jobs in one
program:

- **A database.** Underneath, it is
  SQLite — the small, file-based database
  that lives in a single file and needs
  no separate server. PocketBase manages
  it for you; you define what to store,
  it stores it.
- **User accounts.** People can register,
  log in, and get a token — a temporary
  pass — that their app shows with each
  request. Passwords are stored hashed,
  which means scrambled in a way that
  cannot be unscrambled, only checked.
- **File storage.** Records can carry
  files — a book cover, an avatar, a
  scan — which PocketBase writes to disk
  and serves back over the web.
- **An API.** Every collection you define
  gets web addresses for listing,
  creating, changing and deleting its
  records, plus one for watching changes
  as they happen (realtime).

It also brings a fifth thing that ties
the four together: **an admin page** in
the browser, served by the same program,
where the person running the backend can
see and edit everything — and a set of
**API rules**, small expressions attached
to each collection that say who is
allowed to do what. "Only the book's
owner may see it" is one line, and
chapter 7 shows that line turning a
stranger away.

## One file, one folder

PocketBase itself is a single executable
file — about 34 MB for the version this
guide used. There is nothing to install
in the system sense: no package manager,
no database server to set up first.
Everything it creates lives in one
folder it makes next to itself, called
`pb_data`. Copy that folder and you have
copied the whole backend — data,
uploads, settings and all. Delete the
folder and the program, and the backend
is gone. That smallness is the point,
and also the limit: chapter 13 explains
what happens when one program and one
folder are no longer enough.

## Who runs it, and where

You run PocketBase on a machine that
stays on: a small server at home, a cheap
rented server, a Raspberry Pi. The apps
in front of it — web pages, phone apps,
scripts — talk to it over the network.
During this guide the server never
leaves the machine it runs on: every
check speaks to `127.0.0.1`, the address
a machine uses for itself, so you can
build the whole thing privately and only
open it to others when you choose to
(chapter 11 covers that step).

## The shape of the rest of the guide

Chapters 2 to 4 name the parts and get a
server running. Chapters 5 to 7 build
the example this guide uses throughout:
a **reading list**. Readers sign up,
keep a list of books with an author, a
status (want to read, reading, finished)
and a rating, and the rules make each
list private to its owner. Chapters 8,
9 and 10 add files, realtime and small
programs of your own inside the server.
Chapter 11 puts a page in front of it.
Chapters 12 and 13 step back: what else
could do this job, and where this one
stops.

## The check

You understand the model if you can
answer these:

1. Your app needs logins, a database,
   photo uploads and an API. How many
   programs does PocketBase ask you to
   run for all four? (One.)
2. Where does everything it stores live?
   (In one folder, `pb_data`, beside the
   program.)
3. A reader must never see another
   reader's list. Which feature enforces
   that? (The collection's API rules —
   proven in chapter 7.)
