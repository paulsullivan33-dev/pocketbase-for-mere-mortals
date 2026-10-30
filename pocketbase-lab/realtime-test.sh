#!/bin/bash
# Realtime proof: subscribe to the books collection over SSE, then change a
# record and watch the event arrive on the open connection.
set -u
BASE=http://127.0.0.1:8090
ADA_TOKEN=$(cat .ada-token)
BOOK1=$(cat .book1-id)
RAW=realtime-raw.txt
: > "$RAW"

echo "# 1. Open the SSE stream in the background (curl -N $BASE/api/realtime)"
curl -sN --max-time 14 "$BASE/api/realtime" -H "Authorization: $ADA_TOKEN" >> "$RAW" &
CURL_PID=$!
sleep 2

CLIENT_ID=$(grep -o '"clientId":"[^"]*"' "$RAW" | head -1 | cut -d'"' -f4)
echo "# 2. PB_CONNECT arrived with clientId: $CLIENT_ID"
echo
echo "# 3. Tell the server what to watch: POST /api/realtime {clientId, subscriptions: [books/*]}"
curl -s -w " [HTTP %{http_code}]\n" -X POST "$BASE/api/realtime" \
  -H "Authorization: $ADA_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"clientId\":\"$CLIENT_ID\",\"subscriptions\":[\"books/*\"]}"
sleep 1

echo
echo "# 4. Change a record (rating 5 -> 4) with an ordinary PATCH"
curl -s -X PATCH "$BASE/api/collections/books/records/$BOOK1" \
  -H "Authorization: $ADA_TOKEN" -H 'Content-Type: application/json' \
  -d '{"rating":4}' | jq -c '{id, title, rating}'
sleep 2

echo
echo "# 5. Create a new record too"
curl -s -X POST "$BASE/api/collections/books/records" \
  -H "Authorization: $ADA_TOKEN" -H 'Content-Type: application/json' \
  -d "{\"title\":\"Realtime Test Book\",\"status\":\"reading\",\"owner\":\"$(cat .ada-id)\"}" | jq -c '{id, title}'
sleep 3

kill $CURL_PID 2>/dev/null
wait $CURL_PID 2>/dev/null
echo
echo "# 6. Everything the SSE stream delivered, verbatim:"
cat "$RAW"
