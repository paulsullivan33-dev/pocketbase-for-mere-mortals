/// <reference path="../pb_data/types.d.ts" />

// A tiny custom route, added without touching the PocketBase binary.
// Visit http://127.0.0.1:8090/lab-ping to see it answer.
routerAdd("GET", "/lab-ping", (e) => {
  return e.json(200, {
    message: "pong, from a hook file in pb_hooks",
  });
});

// A record hook: a book saved with no author gets "Unknown"
// filled in just before it is stored.
onRecordCreate((e) => {
  if (!e.record.getString("author")) {
    e.record.set("author", "Unknown");
  }
  e.next();
}, "books");
