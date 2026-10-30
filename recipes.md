# Recipes

**Outcome: three complete, reusable
setups — a web page that uses the
backend, a backup taken and listed over
the API, and the shape of a production
run (service, real address, HTTPS) with
its unverified parts labelled.** Each
recipe says which of its steps this
guide's lab ran.

## Recipe 1: a reading-list page in one HTML file

*Ran for real: the page was served by
PocketBase; the two API calls it makes
are the ones chapters 6 and 7 proved.*

Any folder named `pb_public` beside the
binary is served as plain web files by
the same server, at the same address as
the API. Put this page there as
`index.html` — it is kept in the lab as
`pocketbase-lab/reading-list-page.html`
— and `http://127.0.0.1:8090/` stops
being an error and becomes your app:

```html
<script>
  const base = "http://127.0.0.1:8090";

  const login = await fetch(base + "/api/collections/users/auth-with-password", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({identity: "ada@example.org",
                           password: "ada-lab-pass-123"})
  });
  const {token} = await login.json();

  const res = await fetch(base + "/api/collections/books/records?sort=title", {
    headers: {"Authorization": token}
  });
  const data = await res.json();
  // draw data.items; the rules already removed everyone else's
</script>
```

That is the whole pattern of programming
against PocketBase: log in once, keep
the token, ask the API for things. The
page hard-codes Ada's login because it
is a teaching page — a real one collects
email and password from a form and
stores the token in the browser's
storage. Nothing else about it changes:
PocketBase also publishes a JavaScript
library that wraps these calls in named
functions (`pb.collection('books')
.getList(...)`), which most apps use;
the requests underneath are the ones
you have already seen and checked. The
lab fetched the page back from the
server (HTTP 200, transcript `t10`); it
had no browser to click it with, and the
page's behaviour follows from the two
proven calls it combines — that is the
honest status of this recipe.

## Recipe 2: back the whole backend up

*Ran for real (transcript `t09`).*

Because the folder is the backend, a
script that copies `pb_data` while the
server is stopped is already a backup.
PocketBase also offers one through the
API, safe to take while running:

```bash
curl -s -X POST http://127.0.0.1:8090/api/backups \
  -H "Authorization: $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name":"lab-backup.zip"}'          # answers 204

curl -s http://127.0.0.1:8090/api/backups \
  -H "Authorization: $ADMIN_TOKEN"
# [{"key":"lab-backup.zip","size":231181,…}]
```

The zip lands in `pb_data/backups/` and
holds the databases and the storage
folder together. Restoring is an admin
page action (Settings → Backups) or the
same API in reverse, and the settings
can also schedule automatic backups on
a timer and keep only the newest few.
The discipline matters more than the
mechanism: take the zip *off* the
machine on a schedule, and once —
once is enough to learn it — restore
one onto a spare folder and start the
server against it, so the first restore
you ever do is not the one you need.

## Recipe 3: run it for real

*Documented-only: the lab's server never
left loopback, and its machine runs no
service manager. The steps are the
project's documented production shape.*

Three changes take chapter 4's learner
server to a real one:

1. **Start it at boot, keep it up.** Run
   it under the machine's service
   manager — on Linux, a small `systemd`
   unit whose whole content is the serve
   command and the working directory.
   The systemd guide in this series
   covers writing units; PocketBase's
   own docs carry a ready example.
2. **Bind a real address.** `serve
   --http=yourserver:8090`, or just
   `serve yourserver.example.org` —
   with a domain name and ports 80/443
   free, PocketBase fetches and renews a
   Let's Encrypt certificate itself and
   serves HTTPS directly. That one-flag
   trick is the project's; the lab did
   not claim a domain to prove it with,
   so verify it against the current docs
   when you use it.
3. **Or put a proxy in front.** Many
   people instead bind PocketBase to
   loopback as this guide does and let
   Caddy or nginx (both have guides in
   this series) face the internet and
   forward. Either way: **do not expose
   plain HTTP**. Tokens and passwords
   cross the wire on every login
   (chapter 7), and HTTPS is what keeps
   them private in transit.

Then the settings page earns a visit:
set the application's name and URL (the
reset-password emails build their links
from it), configure SMTP if readers will
ever forget passwords, and re-check that
no collection rule is an empty string
you did not mean — public is a choice,
not a default to drift into.
