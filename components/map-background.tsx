"use client";

import MapboxMap from "./mapbox-map";

interface MapBackgroundProps {
  center?: [number, number];
  zoom?: number;
  targetCenter?: [number, number] | null;
  showRoute?: boolean;
  interactive?: boolean;
  pitch?: number;
}

export default function MapBackground({
  center = [48.8566, 2.3522],
  zoom = 13,
  targetCenter = null,
  showRoute = false,
  interactive = true,
  pitch = 45,
}: MapBackgroundProps) {
  return (
    <MapboxMap
      center={center}
      zoom={zoom}
      targetCenter={targetCenter}
      showRoute={showRoute}
      interactive={interactive}
      pitch={pitch}
    />
  );
}
