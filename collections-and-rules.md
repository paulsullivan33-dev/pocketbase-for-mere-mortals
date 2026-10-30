# Collections and rules

**Outcome: a `books` collection exists
with six fields and five rules, created
through the API and read back as the
server stored it — the shape of the
reading list, ready for data.** In the
admin page this is ten minutes of
pointing and clicking; this chapter does
it with one API call so the definition
itself can be kept, copied and checked.

## What a collection definition holds

Creating a collection means sending the
server a description: a name, a kind
(`base` here), the fields, and the five
API rules from chapter 2. The lab's
definition is kept in the repository as
`pocketbase-lab/books-collection.json`:

```json
{
  "name": "books",
  "type": "base",
  "fields": [
    {"name": "title",  "type": "text", "required": true, "min": 1, "max": 200},
    {"name": "author", "type": "text", "max": 120},
    {"name": "status", "type": "select", "maxSelect": 1,
     "values": ["want", "reading", "finished"]},
    {"name": "rating", "type": "number", "min": 0, "max": 5},
    {"name": "owner",  "type": "relation", "required": true,
     "collectionId": "_pb_users_auth_", "maxSelect": 1},
    {"name": "cover",  "type": "file", "maxSelect": 1, "maxSize": 5242880,
     "mimeTypes": ["image/jpeg", "image/png"]}
  ],
  "listRule":   "owner = @request.auth.id",
  "viewRule":   "owner = @request.auth.id",
  "createRule": "owner = @request.auth.id",
  "updateRule": "owner = @request.auth.id",
  "deleteRule": "owner = @request.auth.id"
}
```

Read the field types as a small
vocabulary PocketBase offers more of
(date, email, URL, checkbox, JSON, and
others), but these six carry the guide:

- **text** with `min`/`max` lengths, and
  `required` where a book without the
  field makes no sense.
- **select**: the value must be one of
  `values`; `maxSelect: 1` keeps it a
  single choice, not a list.
- **number** with a range: a rating
  below 0 or above 5 will be refused by
  the field itself, before any rule runs.
- **relation**: the value is the `id` of
  a record in another collection — here
  the built-in `users` collection, whose
  id is `_pb_users_auth_`. This is how
  "whose book is it" is stored: not a
  name typed again, but a link.
- **file**: an upload slot, capped in
  size and kind. Chapter 8 uses it.

## The rules are the design

All five rules say the same sentence:
`owner = @request.auth.id`. In words:
the book's owner must be whoever is
asking. Spelled out per rule, that one
sentence buys the whole privacy model of
the reading list —

- **list / view**: you can only ever
  receive your own books; other people's
  are filtered out before the answer is
  built, not hidden after it.
- **create**: the book you create must
  name *you* as owner. Claiming someone
  else fails the rule, so forged
  ownership is refused at the door —
  chapter 7 watches exactly that refusal.
- **update / delete**: only your own
  records can be changed or removed.

Notice what is *not* in the rules:
nothing about administrators. Superusers
are above rules entirely; the rules
govern the API's ordinary traffic, which
is the traffic your app will generate.

The two settings to keep distinct,
because mixing them up is the classic
beginner accident: a rule left **locked**
(`null`) means administrators only,
while a rule set to an **empty string**
means *public* — anyone on the internet
who can reach the server. The lab set
neither: every rule on `books` is the
owner expression. Chapter 14's
troubleshooting returns to the locked /
public mix-up, because its symptom —
"my app gets nothing" or "everyone gets
everything" — is so common.

## Creating it

```bash
curl -s -X POST http://127.0.0.1:8090/api/collections \
  -H "Authorization: $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d @books-collection.json
```

Only a superuser may create collections,
so this call wears the administrator
token from chapter 4. The server answers
with the collection as stored (transcript
`t03`): it has been given an id
(`pbc_2170393721` in the lab), your six
fields are there in order, and an `id`
field has been added at the front — every
collection gains one automatically, a
15-letter random identifier PocketBase
generates per record.

Two quiet things happened alongside.
First, the same definition could have
been built in the admin page, field by
field and rule by rule; the API and the
page are two hands on the same object,
and many people sketch in the page and
export the JSON when it matters. Second,
because automatic migrations are on by
default, the server wrote a migration
file recording this collection's
creation — chapter 10 picks that thread
up.

## The check

Read the collection back and compare:

```bash
curl -s http://127.0.0.1:8090/api/collections/books \
  -H "Authorization: $ADMIN_TOKEN" | jq '{name, listRule, fields: [.fields[].name]}'
```

The field names come back
`id, title, author, status, rating,
owner, cover` and the rule is the owner
expression. Shape first, data next:
chapter 6 puts books in.
