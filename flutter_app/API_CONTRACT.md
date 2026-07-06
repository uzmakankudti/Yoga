# YPV API Contract

Base URL is supplied to the app at build/run time via `--dart-define=API_BASE_URL=...`
(defaults to `http://localhost:8000/api` in `lib/config/env.dart`).

All request/response bodies are JSON. Authenticated endpoints require
`Authorization: Bearer <accessToken>`.

## Errors

Any non-2xx response should return:

```json
{ "message": "Human readable error message" }
```

The client surfaces `message` to the user; status code drives 401 refresh logic.

## Auth

### POST /auth/otp/request
Request: `{ "identifier": "+919876543210", "channel": "phone" }` (`channel` is `"phone"` or `"email"`)
Response: `{ "requestId": "abc123" }`

### POST /auth/otp/verify
Request: `{ "requestId": "abc123", "otp": "123456" }`
Response:
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "role": "trainer" | "student",
  "userId": "U001"
}
```
There is no self-registration: accounts are provisioned by an Admin (Trainers, Admins)
or by a Trainer (their own Students). If the identifier has no provisioned account,
this returns `404` with `{ "message": "No account found for this identifier. Please contact your administrator." }`.

### POST /auth/refresh
Request: `{ "refreshToken": "..." }`
Response: `{ "accessToken": "...", "refreshToken": "..." }`

### POST /auth/admin/login
Request: `{ "email": "admin@gmail.com", "password": "1234" }`
Real DB-backed multi-admin accounts (bcrypt-hashed passwords). A bootstrap admin
(`admin@gmail.com` / `1234`) is seeded if the `Admin` table is empty.
Response: `{ "accessToken": "...", "refreshToken": "...", "role": "admin", "userId": "<adminId>" }`

## Trainer (authenticated)

### GET /trainer/me
Response: `TrainerJSON`

### PATCH /trainer/me
Request: `{ "name"?: string, "phone"?: string, "email"?: string }`
Response: `TrainerJSON`

### GET /trainer/students?search=&workshop=
Response: `StudentJSON[]`

### GET /trainer/students/:id
Response: `StudentJSON`

### POST /trainer/students
Request: `{ "name": string, "email": string, "workshopName": string, "completionDate"?: string, "certificateNumber"?: string }`
`completionDate`/`certificateNumber` are optional, but must be provided together. If omitted, the student is created with `pendingWorkshop` set to `workshopName` and no `WorkshopRecord` yet — i.e. registered before completing their first workshop. If provided, behaves as a fully-completed registration (same as before).
Response: `StudentJSON`

### POST /trainer/students/:id/complete-workshop
Request: `{ "completionDate": string, "certificateNumber": string }`
Marks the student's current `pendingWorkshop` as completed: creates a `WorkshopRecord` from `pendingWorkshop` + the given fields, clears `pendingWorkshop`, updates `level`. `400` if the student has no pending workshop.
Response: `StudentJSON`

### POST /trainer/students/:id/upgrade
Request: `{ "workshopName": string, "completionDate": string, "certificateNumber": string }`
Response: `StudentJSON` — server appends a `WorkshopRecord` built from the given fields.
Tiered permission by the trainer's own `level`: a `"Level 1"` trainer (T1) can never
upgrade; a `"Level 2"` trainer (T2) may only upgrade a `"Level 1"` student to `"Level 2"`;
a `"Level 3"` trainer (T3) may upgrade `"Level 1"`→`"Level 2"` or `"Level 2"`→`"Level 3"`.
Any other trainer level is unrestricted. Disallowed attempts return `403` with a message
naming the restriction.

### GET /trainer/students/by-cert/:cert
Response: `StudentJSON` or `404`

## Student (authenticated)

### GET /student/me
Response: `StudentJSON`

### PATCH /student/me
Request: `{ "name"?: string, "phone"?: string, "email"?: string }`
Response: `StudentJSON`

## Admin (authenticated, admin role only)

### GET /admin/admins
Response: `AdminJSON[]`

### POST /admin/admins
Request: `{ "name": string, "email": string, "password": string }`
Response: `AdminJSON`. `409` if the email is already in use.

### PATCH /admin/admins/:id
Request: `{ "name"?: string, "email"?: string, "password"?: string }`
Response: `AdminJSON`

### DELETE /admin/admins/:id
Response: `{ "success": true }`. `409` if this is the last remaining admin account.

### GET /admin/trainers
Response: `TrainerJSON[]` — every trainer in the system.

### POST /admin/trainers
Request: `{ "name": string, "phone": string, "email": string, "level": string }`
Creates the `User` (role `TRAINER`) and `Trainer` record together — no OTP/self-registration step needed.
Response: `TrainerJSON`. `409` if the phone or email is already in use.

### PATCH /admin/trainers/:id
Request: `{ "name"?: string, "phone"?: string, "email"?: string, "level"?: string }`
Response: `TrainerJSON` — overrides any field directly, no restrictions.

### DELETE /admin/trainers/:id
Response: `{ "success": true }`. `409` if the trainer still has students assigned (reassign or delete them first).

### GET /admin/students
Response: `StudentJSON[]` — every student in the system, across all trainers.

### POST /admin/students
Request: `{ "name": string, "email": string, "phone"?: string, "workshopName"?: string, "trainerId": string }`
Creates the `User` (role `STUDENT`) and `Student` record together, assigned to `trainerId`.
Response: `StudentJSON`.

### PATCH /admin/students/:id
Request: `{ "name"?: string, "email"?: string, "phone"?: string, "level"?: string, "trainerId"?: string }`
`trainerId` reassigns the student to a different trainer.
Response: `StudentJSON` — overrides any field directly, no restrictions.

### DELETE /admin/students/:id
Response: `{ "success": true }`

## Config (authenticated)

### GET /config/workshops
Response: `string[]` — e.g. `["Yoga Level 1", "Yoga Level 2", ...]`

### GET /config/levels
Response: `string[]` — e.g. `["Level 1", "Level 2", "AUWA", ...]`

## Shapes

```ts
AdminJSON = {
  id: string,
  name: string,
  email: string,
}

TrainerJSON = {
  id: string,
  name: string,
  phone: string,
  email: string,
  level: string,
  registrationDate: string,
  studentCount: number,
}

WorkshopRecordJSON = {
  workshopName: string,
  completionDate: string,
  certificateNumber: string,
  trainerName: string,
}

StudentJSON = {
  id: string,
  name: string,
  email: string,
  phone: string,
  level: string,
  trainerName: string,
  workshopHistory: WorkshopRecordJSON[],
  pendingWorkshop: string | null,
}
```
