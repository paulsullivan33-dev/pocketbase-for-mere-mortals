# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The example app is an invented reading list with invented
   readers, and every password in the lab is a labelled
   throwaway.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 13 names what the tool
   cannot do: one server with no built-in scaling, SQLite's
   single writer, a security model that is only as good as its
   five rules per collection, a subset JavaScript for hooks,
   absolute administrators, and breaking changes between major
   versions.
8. **The ethics rule is in the text, early.** A backend holds
   other people's data and logins, so the guide puts custody
   first: chapter 1 and the README state that choosing this
   tool means *you* hold the data the hosted neighbours would
   hold for you — with the backups, the updates and the
   responsibility that follow — and chapter 7 shows the access
   rules doing the protecting before any recipe depends on
   them.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox (x86_64). The lab
ran **PocketBase 0.40.6** — the official release zip
`pocketbase_0.40.6_linux_amd64.zip` from the project's GitHub
releases — unmodified, serving only on `127.0.0.1:8090`. All
verification was done with `curl` against the real API; all
transcripts live in `pocketbase-lab/transcripts/`, and the
collection definition, realtime script, hook file and example
page the lab used are kept beside them in `pocketbase-lab/`.

Run for real, with transcripts as evidence:

- Download and unzip of the release, `--version` (0.40.6) and
  the full `--help` surface (t00).
- Superuser creation from the CLI, the `pb_data` folder it
  creates, server start on loopback, `/api/health`, and the
  admin page's served HTML with HTTP 200 (t01).
- Superuser login over the API and the six collections a fresh
  install starts with, including the built-in `users` auth
  collection (t02).
- Creation of the `books` collection through the API — six
  fields (text, text, select, number, relation, file) and all
  five API rules set to `owner = @request.auth.id` — and its
  stored form read back (t03).
- Public sign-up of a reader; three records created as that
  reader; the list envelope; a `status = 'reading'` filter;
  `sort=-rating`; and pagination at `perPage=2` across two
  pages (t04).
- The rules from the other side: a second reader lists zero
  records, receives 404 for the first reader's record on view
  and on update, receives 400 creating a record forged with
  the first reader's id as owner, an anonymous list is empty,
  and a wrong password is the flat 400 "Failed to
  authenticate." (t05).
- A PNG generated in the lab uploaded into the file field, the
  stored name it was given, the fetch over `/api/files/...`,
  and the SHA-256 of the downloaded file matching the upload
  exactly; the file's place under `pb_data/storage/` (t06).
- Realtime: an open SSE stream, its `PB_CONNECT` client id, a
  subscription to `books/*` accepted with 204, and the update
  and create events arriving on the stream when the changes
  were made in separate commands (t07, script kept as
  `pocketbase-lab/realtime-test.sh`).
- Migrations and hooks: the automatic migration the server had
  already written when the collection was created, a
  `migrate collections` snapshot file, and — after a restart
  with `pb_hooks/` in place — a hook-added `/lab-ping` route
  answering, and a record created without an author returning
  with the hook's `"Unknown"` filled in (t08).
- A whole-backend backup created and listed through the API,
  present on disk under `pb_data/backups/` (t09).
- The example reading-list page placed in `pb_public/` and
  served by the same server at `/` with HTTP 200; the page is
  a combination of the login and list calls proven in t04/t05
  (t10).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- Anything in the admin *screens* beyond their being served:
  the lab had no browser, so clicking through the dashboard,
  the settings screens and the restore-a-backup action were
  not exercised; the API equivalents were used and shown.
- Email: password-reset and verification messages and the
  SMTP settings behind them (no mail server in the lab), and
  OAuth2 sign-in with outside providers (needs provider
  accounts).
- Leaving loopback: binding a public address, the built-in
  Let's Encrypt certificate, reverse-proxy setups, and the
  `systemd` service unit of recipe 3. The lab's server never
  left `127.0.0.1`.
- The reading-list page *running* in a browser (it was served
  and its two API calls were proven separately), image
  thumbnails via `?thumb=`, S3-compatible file storage, view
  collections, the JavaScript client library's named methods,
  `./pocketbase update`, Docker and Go-library use, and the
  neighbour tools of chapter 12, which are characterised, not
  benchmarked.
- Hand-written migrations beyond the automatic diary and the
  collections snapshot (a field rename, for example) — taught
  from those two real artefacts.

Fixtures are this guide's own and deliberately generic: a
reading list, three real book titles with their real authors
(the kind of data the example exists to hold), two invented
readers at `example.org`, a 4×4 teal square as the uploaded
picture, and throwaway passwords labelled as such wherever
they appear. No real person's data, accounts or machines are
involved.
