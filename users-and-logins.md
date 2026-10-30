# Users and logins

**Outcome: two readers exist, both can
log in, and the rules demonstrably keep
each reader's books from the other —
list, view, change and forge all turned
away.** This is the chapter the whole
design was for; it is mostly other
people failing, on purpose, in recorded
ways.

## Readers are records in an auth collection

Chapter 4 made a *superuser*. Readers
are different: they live in the built-in
`users` collection, which is an **auth**
collection — a collection whose records
are people who can log in. Signing up is
creating a record in it, and unusually
for a collection, creating records here
is public by design, because a sign-up
page must work for people who do not
have an account yet:

```bash
curl -s -X POST http://127.0.0.1:8090/api/collections/users/records \
  -H 'Content-Type: application/json' \
  -d '{"email":"ada@example.org",
       "password":"ada-lab-pass-123",
       "passwordConfirm":"ada-lab-pass-123",
       "name":"Ada Reader"}'
```

The answer shows Ada's `id`
(`dvlvswu2mrth2do`, the same id chapter
6's books used as `owner`) and
`verified: false`. Two details worth
knowing. The `passwordConfirm` field is
required — the API asks for the password
twice, as sign-up forms do. And the
response's `email` reads as `null` even
though one was sent: the `users`
collection protects email addresses by
default, so only the account's owner
(and superusers) ever receive them back.
A stranger who somehow learned Ada's id
could not use the API to learn her
address. Passwords never come back at
all — they are stored as hashes, and
nothing in any response in this guide
contains one.

## Logging in

```bash
curl -s -X POST http://127.0.0.1:8090/api/collections/users/auth-with-password \
  -H 'Content-Type: application/json' \
  -d '{"identity":"ada@example.org","password":"ada-lab-pass-123"}'
```

The answer is a `token` plus Ada's
record. Every request in chapters 6, 8
and 9 that wears `Authorization: <Ada's
token>` is PocketBase knowing it is her:
the token is signed, carries her id, and
is what `@request.auth.id` in the rules
reads. A wrong password is a flat
refusal, recorded in transcript `t05`:

```json
{"data":{},"message":"Failed to authenticate.","status":400}
```

No hint about whether the account
exists — deliberately. The same
collection family offers more this guide
does not run: asking for a password
reset or an email confirmation sends
*email*, which needs a mail server
PocketBase is told about in its
settings; signing in with an outside
provider (Google, GitHub and others)
needs accounts with those providers.
Both are documented-only here, labelled
as such, and the settings themselves
live in the admin page under Settings —
the shape is "PocketBase sends mail
through your SMTP server", the details
are the project's to document.

## Ben, and the sound of the rules working

Now a second reader, Ben, signs up and
logs in the same way, and runs the
addresses of chapter 6 wearing *his*
token. Transcript `t05` is the evidence;
here is its whole story:

**Ben lists books.** The answer is a
well-formed envelope saying nothing:

```json
{"totalItems":0,"items":[]}
```

Not an error — Ada's books are simply
not in Ben's world. The list rule
filtered them out before counting.

**Ben asks for Ada's book by id.** He
has its id (it leaked in a screenshot,
say); knowledge is not permission:

```json
{"data":{},"message":"The requested resource wasn't found.","status":404}
```

404, not 403. PocketBase does not admit
the book exists. From the outside, "not
yours" and "not there" are the same
answer, so ids are not a way to probe
what other people have.

**Ben tries to change Ada's book** (a
`PATCH` setting its rating to 1). Same
404, same silence; the rating is still 5
when Ada next looks.

**Ben tries to create a book owned by
Ada** — sending `owner` set to her id,
which the create rule
`owner = @request.auth.id` evaluates
with *Ben* as the requester:

```json
{"data":{},"message":"Failed to create record.","status":400}
```

**A logged-out visitor lists books.**
The same empty envelope as Ben's. To
the rules, a visitor and the wrong user
are equally not-the-owner.

Five refusals, zero special cases in any
code you wrote — the privacy of the
whole app is one expression, repeated
five times, evaluated by the server on
every request. That is the PocketBase
bargain at its best, and it is why
chapter 5 spent so long on one line.

## What the token does not do

A token proves who is asking; it does
not encrypt anything, and on an open
network it can be overheard like a
password — which is why chapter 11's
step onto the internet goes through
HTTPS. Tokens also expire, and an app
must be ready to send its user back to
the login form when the API answers 401.
Neither behaviour is a defect; they are
the shape of every token system, and
PocketBase's is a small, standard one.
