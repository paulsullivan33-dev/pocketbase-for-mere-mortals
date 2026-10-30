# Files

**Outcome: a picture is uploaded into a
book record, fetched back from its file
address, and proven identical to what
was sent — the SHA-256 hashes match.**
Files ride along with records, so this
chapter is short: one field, two calls,
one check.

## The file field, revisited

Chapter 5 gave `books` a `cover` field
of type **file**, with three settings
that matter:

- `maxSelect: 1` — one file per book in
  this field (a field can allow several;
  the record then holds a list of names).
- `maxSize: 5242880` — five megabytes at
  most, per file. Oversize uploads are
  refused by the field, before storage.
- `mimeTypes: ["image/jpeg","image/png"]`
  — only these kinds are accepted. A
  `.png` that is really something else
  is judged by its content, not its name.

Files are not stored *in* the database.
The record holds the stored file's name;
the bytes live under
`pb_data/storage/<collection>/<record>/`,
which chapter 2 promised and this
chapter visits below.

## Uploading is a form, not JSON

Everything so far was JSON. Files
cannot travel in JSON, so an upload is
sent as `multipart/form-data` — the same
encoding a browser uses for a file
picker — and `curl` speaks it with `-F`.
To set the cover on an existing book,
`PATCH` the record with the file under
the field's name:

```bash
curl -s -X PATCH http://127.0.0.1:8090/api/collections/books/records/i3sx61mdseu5sne \
  -H "Authorization: $ADA_TOKEN" \
  -F cover=@cover.png
```

```json
{"id":"i3sx61mdseu5sne","title":"The Left Hand of Darkness",
 "cover":"cover_ucg8essb2t.png"}
```

The same call can carry ordinary fields
as extra `-F` parts beside the file.
Uploading while *creating* a record is
the identical shape with `POST` to the
collection address.

Notice the stored name:
`cover_ucg8essb2t.png`. PocketBase kept
the original name and inserted a random
suffix before the extension. Two readers
uploading their own `cover.png` for two
books can therefore never collide, and
re-uploading to the same record replaces
the file under a fresh stored name while
the old bytes are cleaned up.

## Fetching it back, and the check

A file's address is built from three
pieces you already know:

```text
/api/files/<collection>/<record id>/<stored file name>
```

No token is needed in this lab because
downloading follows the record's
**view rule** — and here is a subtlety
worth pausing on. The file address is
checked against the rule of the record
it belongs to, so Ada's cover is exactly
as private as Ada's book: Ben asking for
this URL gets the same 404 as Ben asking
for the book. Then the check itself
(transcript `t06`):

```bash
sha256sum cover.png
# 53e633e0…  cover.png        (before upload)

curl -s -o fetched-cover.png \
  "http://127.0.0.1:8090/api/files/books/i3sx61mdseu5sne/cover_ucg8essb2t.png"
sha256sum fetched-cover.png
# 53e633e0…  fetched-cover.png   (after download)
```

Same hash, byte for byte: what the
server stored is what it served. The
lab's cover is a 4×4 teal square it
generated on the spot — the point is not
the picture but that *any* file can be
carried through and audited this way.

And the storage, as seen from the
server's side of the disk:

```bash
find pb_data/storage -type f
# pb_data/storage/pbc_2170393721/i3sx61mdseu5sne/cover_ucg8essb2t.png
# pb_data/storage/pbc_2170393721/i3sx61mdseu5sne/cover_ucg8essb2t.png.attrs
```

One folder per collection (named by its
id), one per record, the file itself
plus a small `.attrs` sidecar. Copying
`pb_data` copies these too — uploads are
part of the folder-is-the-backend story,
not a side system to remember.

## Two honest edges

**Thumbnails.** PocketBase can hand back
resized versions of images by adding
`?thumb=100x100` to a file address —
handy for covers in a list. The lab did
not exercise it; it is documented-only
here, mentioned so you know it exists.

**Where files can live instead.**
Settings offer S3-compatible storage in
place of the local `storage/` folder,
for backends whose uploads outgrow one
disk. Also documented-only here: the
lab's disk was the folder beside the
binary, and the checks above are that
setup's.
