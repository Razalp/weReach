import { NextRequest, NextResponse } from "next/server";
import mongoose from "mongoose";
import dbConnect from "@/lib/db";
import Destination from "@/lib/models/Destination";

type RouteContext = {
  params: Promise<{ id: string }>;
};

type DestinationUpdatePayload = {
  name?: string;
  address?: string;
  latitude?: number;
  longitude?: number;
  isFavorite?: boolean;
};

function isValidId(id: string) {
  return mongoose.Types.ObjectId.isValid(id);
}

export async function PATCH(request: NextRequest, context: RouteContext) {
  const { id } = await context.params;

  if (!isValidId(id)) {
    return NextResponse.json({ error: "Invalid destination id." }, { status: 400 });
  }

  const payload = (await request.json()) as DestinationUpdatePayload;
  const update: DestinationUpdatePayload = {};

  if (typeof payload.name === "string") update.name = payload.name.trim();
  if (typeof payload.address === "string") update.address = payload.address.trim();
  if (typeof payload.isFavorite === "boolean") update.isFavorite = payload.isFavorite;
  if (typeof payload.latitude === "number") update.latitude = payload.latitude;
  if (typeof payload.longitude === "number") update.longitude = payload.longitude;

  await dbConnect();

  const destination = await Destination.findByIdAndUpdate(id, update, {
    new: true,
    runValidators: true,
  });

  if (!destination) {
    return NextResponse.json({ error: "Destination not found." }, { status: 404 });
  }

  return NextResponse.json({ destination });
}

export async function DELETE(_request: NextRequest, context: RouteContext) {
  const { id } = await context.params;

  if (!isValidId(id)) {
    return NextResponse.json({ error: "Invalid destination id." }, { status: 400 });
  }

  await dbConnect();

  const destination = await Destination.findByIdAndDelete(id);

  if (!destination) {
    return NextResponse.json({ error: "Destination not found." }, { status: 404 });
  }

  return NextResponse.json({ ok: true });
}
