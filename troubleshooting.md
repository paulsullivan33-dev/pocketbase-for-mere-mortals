# Troubleshooting

**Outcome: the six failures a new
PocketBase operator meets first, each
with the observation that names it and
the fix that closes it.** Most are the
same few misunderstandings wearing
different coats: a rule doing exactly
what it says, a token being absent or
wrong, or two folders both claiming to
be the backend.

## "My app's list comes back empty" — the rule is filtering, as designed

You list records you know exist and get
`{"totalItems":0,"items":[]}`. Before
suspecting the data, ask *as whom* you
are asking. Lists are filtered by the
list rule silently: logged out, or
logged in as someone the rule excludes,
the answer is an empty list, not an
error. Check by listing once with the
superuser token — administrators see
everything. If the books appear, the
data was never missing; your request's
identity fails the rule, and the fix is
in the identity or the rule, never in
the records. (Chapter 7's Ben is the
worked example.)

## "The record wasn't found" for a record that exists — same lesson, one record

View, update and delete answer **404**
when the rule excludes the record, for
exactly the privacy reason chapter 7
gave: the server will not confirm that
other people's data exists. A 404 from
PocketBase therefore reads "not there,
*or not yours*". Test with the owner's
token, then with the superuser's, and
the two answers together tell you which
half you are in.

## "Failed to create record" (400) — the create rule or a field objected

Two different refusals share this
message. The `data` half of the response
says which:

- `data` names a field (a rating above
  its maximum, a status outside the
  select's values, a missing required
  field, an email already taken in an
  auth collection) — the *field*
  refused it. Fix the value.
- `data` is empty `{}` — every field was
  acceptable and the **create rule**
  refused it, as it did Ben's forged
  book in chapter 7. Check what your
  rule compares against `@request.auth`
  and what your request actually sent —
  usually an `owner` left out, or set to
  someone else.

## Logins fail for a user who definitely exists — identity, collection, expiry

Three checks, in order. First, you are
authenticating against the collection
the account lives in
(`/api/collections/users/auth-with-password`,
not `_superusers` — administrators and
readers are different collections, and
chapter 4's account cannot log in at the
readers' address, nor the reverse).
Second, the "identity" is the email
exactly as registered; third, if
requests *after* a successful login fail
with 401, the token has expired or was
never stored and sent — re-login and
confirm the app actually attaches the
`Authorization` header. A bad password
itself is the flat
`{"message":"Failed to authenticate."}`
of chapter 7, with no further detail,
by design.

## The admin page loads but the API seems down — or the reverse

Both are served by the one process, so
one being up and the other broken
usually means the *path* is wrong, not
the server: the admin page is `/_/`
(with both slashes), API addresses begin
`/api/`, and a stray reverse proxy or a
`pb_public` file can shadow what you
expected at `/`. `/api/health` divides
the question cleanly — if it answers,
the server and its API are alive and
your address is at fault.

## The hook does nothing — file, folder, or `e.next()`

When a hook from chapter 10 silently
does not run: the file must end in
`.pb.js`, live in `pb_hooks/` (or the
folder `--hooksDir` names — beside the
binary by default, *not* inside
`pb_data`), and the server must have
started since it was placed there if
watching was off. Inside the file, a
record hook that never calls `e.next()`
does not "pause" the operation, it
cancels it, which looks from the
client like a refusal with no message;
and a JavaScript error in a hook is
written to the server's log, not sent
to the API caller — run `serve --dev`
while developing hooks and keep the log
in view. That log is also where
PocketBase reports a malformed
migration, the other silent-file
failure: a broken file in
`pb_migrations/` stops startup with the
reason named, which is the server
protecting the layout you asked it to
keep.

## Two more quick ones

- **"Address already in use" on start:**
  another PocketBase (or anything else)
  already holds the port. Find it, stop
  it, or serve on another port — and
  remember two servers pointed at one
  `pb_data` is a confusion no project
  needs; one folder, one server.
- **Uploads rejected:** the file field's
  own limits answer first — size above
  `maxSize`, or a kind outside
  `mimeTypes`, judged by content rather
  than filename, so renaming a file to
  `.png` does not sneak it through.
