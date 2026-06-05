weReach is a Next.js destination alarm app with GPS tracking, Mapbox-powered search/map tiles, and MongoDB-backed saved destinations.

## Getting Started

Create `.env` from `.env.example` and add your keys:

```bash
MONGODB_URI=mongodb+srv://USER:PASSWORD@CLUSTER.mongodb.net/wereach
MAPBOX_ACCESS_TOKEN=pk_your_mapbox_token_here
NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN=pk_your_mapbox_token_here
```

Then run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## API

- `GET /api/geocode?query=place` searches destinations with Mapbox, falling back to OpenStreetMap when no token is configured.
- `GET /api/destinations` lists saved destinations for the anonymous user.
- `POST /api/destinations` saves `{ name, address, latitude, longitude, isFavorite? }`.
- `PATCH /api/destinations/:id` updates a saved destination.
- `DELETE /api/destinations/:id` removes a saved destination.

The app saves selected destinations automatically. If MongoDB is not configured yet, tracking still opens and the failed save is logged in the browser console.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
