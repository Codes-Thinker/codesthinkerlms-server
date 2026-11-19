# codesthinkerlms-server

Codes Thinker LMS API (NestJS + Prisma). This repo is the backend-only deploy target for EC2.

## Setup

```bash
npm install
cp .env.example .env
# fill DATABASE_URL and other secrets
npx prisma generate
npx prisma migrate deploy
npm run build
npm start
```

## Scripts

- `npm run dev` — build + watch
- `npm start` — build + run
- `npm run prisma:migrate` — local migrations
- `npm run prisma:deploy` — production migrations
- `npm run db:seed` — seed data
