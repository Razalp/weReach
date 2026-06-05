import { NextRequest, NextResponse } from "next/server";

type GeocodeFeature = {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  provider: "maptiler" | "nominatim";
};

type MapTilerFeature = {
  id: string;
  place_name?: string;
  text?: string;
  place_name_en?: string;
  center?: [number, number];
};

type NominatimFeature = {
  place_id: number;
  display_name: string;
  lat: string;
  lon: string;
};

export async function GET(request: NextRequest) {
  const query = request.nextUrl.searchParams.get("query")?.trim();

  if (!query || query.length < 2) {
    return NextResponse.json({ features: [] });
  }

  const maptilerKey =
    process.env.MAPTILER_API_KEY ||
    process.env.NEXT_PUBLIC_MAPTILER_API_KEY ||
    "5zb1feaRYKBB80htJSWW";

  // Primary: MapTiler Geocoding API (free tier)
  try {
    const url = new URL(
      `https://api.maptiler.com/geocoding/${encodeURIComponent(query)}.json`
    );
    url.searchParams.set("key", maptilerKey);
    url.searchParams.set("limit", "6");
    url.searchParams.set("language", "en");

    const response = await fetch(url, { next: { revalidate: 60 } });

    if (response.ok) {
      const data = (await response.json()) as { features?: MapTilerFeature[] };
      const features: GeocodeFeature[] = (data.features ?? [])
        .filter((f) => f.center)
        .map((f) => ({
          id: f.id,
          name: f.text || f.place_name_en?.split(",")[0] || f.place_name?.split(",")[0] || "Unknown",
          address: f.place_name_en || f.place_name || "",
          latitude: f.center![1],
          longitude: f.center![0],
          provider: "maptiler",
        }));

      return NextResponse.json({ features });
    }
  } catch (err) {
    console.warn("MapTiler geocoding failed, falling back to Nominatim:", err);
  }

  // Fallback: OpenStreetMap Nominatim (always free)
  try {
    const url = new URL("https://nominatim.openstreetmap.org/search");
    url.searchParams.set("format", "json");
    url.searchParams.set("q", query);
    url.searchParams.set("limit", "6");

    const response = await fetch(url, {
      headers: { "User-Agent": "weReach/1.0 (travel alarm app)" },
      next: { revalidate: 60 },
    });

    if (!response.ok) throw new Error("Nominatim failed");

    const data = (await response.json()) as NominatimFeature[];
    const features: GeocodeFeature[] = data.map((f) => ({
      id: String(f.place_id),
      name: f.display_name.split(",")[0],
      address: f.display_name,
      latitude: Number(f.lat),
      longitude: Number(f.lon),
      provider: "nominatim",
    }));

    return NextResponse.json({ features });
  } catch (err) {
    console.error("All geocoding providers failed:", err);
    return NextResponse.json({ error: "Search unavailable." }, { status: 503 });
  }
}
