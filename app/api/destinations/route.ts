import { NextRequest, NextResponse } from "next/server";
import dbConnect from "@/lib/db";
import Destination from "@/lib/models/Destination";

type DestinationPayload = {
  name?: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  isFavorite?: boolean;
  userId?: string;
};

function cleanPayload(payload: DestinationPayload) {
  return {
    name: payload.name?.trim(),
    address: payload.address?.trim() ?? "",
    latitude: Number(payload.latitude),
    longitude: Number(payload.longitude),
    isFavorite: Boolean(payload.isFavorite),
    userId: payload.userId?.trim() || "anonymous",
  };
}

export async function GET(request: NextRequest) {
  await dbConnect();

  const userId = request.nextUrl.searchParams.get("userId") || "anonymous";
  const destinations = await Destination.find({ userId })
    .sort({ createdAt: -1 })
    .limit(30)
    .lean();

  return NextResponse.json({ destinations });
}

export async function POST(request: NextRequest) {
  const payload = cleanPayload((await request.json()) as DestinationPayload);

  if (!payload.name || !Number.isFinite(payload.latitude) || !Number.isFinite(payload.longitude)) {
    return NextResponse.json(
      { error: "Name, latitude, and longitude are required." },
      { status: 400 }
    );
  }

  await dbConnect();

  const destination = await Destination.create(payload);

  return NextResponse.json({ destination }, { status: 201 });
}
