# YPV Backend

Implements the API documented in `../flutter_app/API_CONTRACT.md` for the Yoga
Prana Vidya app: Node.js + Express + TypeScript, Postgres via Prisma.

## Dev-only shortcuts (do not ship as-is)

- **OTP delivery**: no SMS/email provider is configured. OTPs are logged to
  the server console *and* returned in the `/auth/otp/request` response body
  (`{ requestId, otp }`) purely so you can test without a console open.
  Remove the `otp` field from that response before any real deployment.
- **Student trainer assignment**: a student who self-registers (`/auth/register/student`)
  is auto-assigned to the first trainer found in the database, since there's
  no trainer-invite/assignment flow yet.

## Setup

```bash
cp .env.example .env
docker compose up -d        # starts Postgres on localhost:5432
npm install
npx prisma migrate dev --name init
npm run seed                # seeds workshop/level option lists
npm run dev                 # starts the API on http://localhost:8000
```

The Flutter app's default `API_BASE_URL` is `http://localhost:8000/api`, so
no extra flags are needed to point it at this server.

## Manual smoke test

```bash
# 1. Request an OTP (phone or email)
curl -s -X POST localhost:8000/api/auth/otp/request \
  -H 'Content-Type: application/json' \
  -d '{"identifier":"+919876543210","channel":"phone"}'
# => { "requestId": "...", "otp": "123456" }

# 2. Verify it (use the requestId + otp from step 1)
curl -s -X POST localhost:8000/api/auth/otp/verify \
  -H 'Content-Type: application/json' \
  -d '{"requestId":"...","otp":"123456"}'
# => { "accessToken": "...", "refreshToken": "...", "role": null, "userId": "..." }

# 3. Register as a trainer (role was null => new user)
curl -s -X POST localhost:8000/api/auth/register/trainer \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <accessToken>' \
  -d '{"name":"Priya Sharma","phone":"+919876543210","level":"Level 2"}'

# 4. Fetch the trainer profile
curl -s localhost:8000/api/trainer/me -H 'Authorization: Bearer <accessToken>'

# 5. Add a student
curl -s -X POST localhost:8000/api/trainer/students \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <accessToken>' \
  -d '{"name":"Aisha Nair","email":"aisha@example.com","workshopName":"Yoga Level 1","completionDate":"12 Mar 2024","certificateNumber":"YPV-2024-001"}'

# 6. List students
curl -s localhost:8000/api/trainer/students -H 'Authorization: Bearer <accessToken>'
```

## Scripts

- `npm run dev` — start with hot reload (tsx watch)
- `npm run build` / `npm start` — compile to `dist/` and run the compiled server
- `npm run typecheck` — `tsc --noEmit`
- `npm run prisma:migrate` — run Prisma migrations
- `npm run seed` — seed workshop/level option lists
