# Working with records

**Outcome: three books exist in the
collection, and you can list them, filter
them by a field, sort them, and page
through them — each answer shaped by a
few words added to the address.** These
four moves are most of what any app ever
asks a backend, so this chapter takes
them slowly. Everything runs as Ada, the
reader chapter 7 introduces properly;
here she simply signs up and logs in
with the auth addresses (transcript
`t04` has the calls), because the rules
from chapter 5 mean even *creating*
books requires being someone.

## Creating a record

```bash
curl -s -X POST http://127.0.0.1:8090/api/collections/books/records \
  -H "Authorization: $ADA_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"title":"The Left Hand of Darkness",
       "author":"Ursula K. Le Guin",
       "status":"finished","rating":5,
       "owner":"dvlvswu2mrth2do"}'
```

```json
{"id":"i3sx61mdseu5sne","title":"The Left Hand of Darkness",
 "status":"finished","rating":5,"owner":"dvlvswu2mrth2do"}
```

The pattern to memorise is the address:
`/api/collections/<name>/records` is the
collection's shelf; adding a record id
addresses one book on it. The answer is
the record as stored, including the id
PocketBase minted for it. Ada adds two
more books the same way — a field guide
she is `reading`, rated 4, and a book she
`want`s, unrated — three in all.
Mistakes are refused in plain shapes: a
`status` outside the select's list, a
rating of 9 against the field's maximum,
or a missing required `title` each come
back as a 400 with the failing field
named under `data`. Try one on purpose;
a refused record leaves no trace behind.

## Listing, and the shape of an answer

```bash
curl -s "http://127.0.0.1:8090/api/collections/books/records" \
  -H "Authorization: $ADA_TOKEN"
```

A list answer is never a bare list. It
arrives in an envelope:

```json
{"page":1,"perPage":30,"totalItems":3,"totalPages":1,
 "items":[ ...the three books... ]}
```

`totalItems` and `totalPages` describe
the whole shelf the requester may see —
remember, the rules have already
filtered it — and `items` is this page
of it. Your app will read those numbers
to draw its "page 2 of 5" lines; the
check here is that Ada's envelope says 3.

## Filtering

Add `?filter=` with an expression in the
same language the rules use:

```bash
curl -s "http://127.0.0.1:8090/api/collections/books/records?filter=(status='reading')" \
  -H "Authorization: $ADA_TOKEN"
```

One book matches: the field guide. The
filter vocabulary is wider than one
equals sign — `!=`, `>`, `<`, `~` (for
"contains this text"), and `&&` / `||`
to combine:

```text
filter=(rating>=4 && status!='want')     both conditions
filter=(title~'Guide')                   title containing Guide
filter=(author='Le Guin' || author~'Le Guin')
```

Filters and rules are separate sieves
and both always run: the rule decides
which records you may ever see, the
filter picks among those. No filter can
widen what the rule allowed — Ben's
chapter is next, and he filters all he
likes to no avail.

## Sorting and paging

`?sort=` orders the answer; a leading
minus reverses it:

```bash
curl -s ".../records?sort=-rating"     # 5, then 4, then the unrated 0
curl -s ".../records?sort=title"       # A Field Guide…, The Left…, The Making…
```

Paging is two numbers, `page` and
`perPage`. With three books and
`perPage=2`, page 1 holds two books and
reports `totalPages: 2`; page 2 holds
the remaining one (transcript `t04`
shows both envelopes). Defaults are
`page=1`, `perPage=30`, and there is a
ceiling (500) the server enforces
quietly by capping your request.

## Changing and deleting

One record at a time, addressed by id:

```bash
curl -s -X PATCH ".../records/i3sx61mdseu5sne" \
  -H "Authorization: $ADA_TOKEN" \
  -d '{"rating":4}'                       # change some fields
curl -s -X DELETE ".../records/i3sx61mdseu5sne" \
  -H "Authorization: $ADA_TOKEN"           # answers 204, empty
```

`PATCH` touches only the fields you
send. Both calls pass through the rules
again — Ada may do this to her book
because `owner = @request.auth.id`
holds for her. Hold onto that thought:
the next chapter logs in a second
reader and runs these same addresses
as someone the rule excludes, which is
where the design earns its keep.
