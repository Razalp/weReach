"use client";

import { useEffect, useRef } from "react";
import maplibregl from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

const FALLBACK_MAP_STYLE = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json";

// MapTiler beautiful dark style — no Mapbox token needed
const MAP_STYLE = process.env.NEXT_PUBLIC_MAP_STYLE_URL || FALLBACK_MAP_STYLE;

interface MapboxMapProps {
  center: [number, number]; // [lat, lng]
  zoom?: number;
  targetCenter?: [number, number] | null; // [lat, lng] for destination
  showRoute?: boolean;
  interactive?: boolean;
  pitch?: number;
}

export default function MapboxMap({
  center,
  zoom = 13,
  targetCenter = null,
  showRoute = false,
  interactive = true,
  pitch = 45,
}: MapboxMapProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const userMarkerRef = useRef<maplibregl.Marker | null>(null);
  const targetMarkerRef = useRef<maplibregl.Marker | null>(null);
  const routeReadyRef = useRef(false);

  // Initialize Map
  useEffect(() => {
    if (!mapContainerRef.current) return;

    // MapLibre expects [lng, lat]
    const map = new maplibregl.Map({
      container: mapContainerRef.current,
      style: MAP_STYLE,
      center: [center[1], center[0]],
      zoom: zoom,
      pitch: pitch,
      bearing: -10,
      interactive: interactive,
      attributionControl: false,
    });

    mapRef.current = map;

    const ensureRouteLayers = () => {
      if (map.getSource("route")) {
        routeReadyRef.current = true;
        return;
      }

      map.addSource("route", {
        type: "geojson",
        data: {
          type: "Feature",
          properties: {},
          geometry: {
            type: "LineString",
            coordinates: [],
          },
        },
      });

      // Outer glow layer
      map.addLayer({
        id: "route-glow",
        type: "line",
        source: "route",
        layout: {
          "line-join": "round",
          "line-cap": "round",
        },
        paint: {
          "line-color": "#60a5fa",
          "line-width": 10,
          "line-opacity": 0.22,
          "line-blur": 6,
        },
      });

      // Main neon blue route line
      map.addLayer({
        id: "route-line",
        type: "line",
        source: "route",
        layout: {
          "line-join": "round",
          "line-cap": "round",
        },
        paint: {
          "line-color": "#3b82f6",
          "line-width": 4,
          "line-opacity": 0.9,
        },
      });

      routeReadyRef.current = true;
    };

    map.on("load", ensureRouteLayers);
    map.on("style.load", ensureRouteLayers);
    map.on("error", (event) => {
      const status = event.error && "status" in event.error ? event.error.status : undefined;

      if (status === 401 || status === 403) {
        routeReadyRef.current = false;
        map.setStyle(FALLBACK_MAP_STYLE);
      }
    });

    return () => {
      map.remove();
      mapRef.current = null;
      routeReadyRef.current = false;
    };
  }, []); // Only run once on mount

  // Update center & user marker on coordinate changes
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    // Pulsing user location dot
    if (!userMarkerRef.current) {
      const el = document.createElement("div");
      el.style.cssText = `
        position: relative;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
      `;

      el.innerHTML = `
        <span style="
          position: absolute;
          width: 24px; height: 24px;
          border-radius: 50%;
          background: rgba(59,130,246,0.4);
          animation: ping 1.5s cubic-bezier(0,0,0.2,1) infinite;
        "></span>
        <span style="
          position: relative;
          width: 13px; height: 13px;
          border-radius: 50%;
          background: #3b82f6;
          border: 2.5px solid #fff;
          box-shadow: 0 0 10px rgba(59,130,246,0.8);
        "></span>
        <style>
          @keyframes ping {
            75%, 100% { transform: scale(2.2); opacity: 0; }
          }
        </style>
      `;

      userMarkerRef.current = new maplibregl.Marker({ element: el })
        .setLngLat([center[1], center[0]])
        .addTo(map);
    } else {
      userMarkerRef.current.setLngLat([center[1], center[0]]);
    }

    // Camera movement
    if (targetCenter) {
      const bounds = new maplibregl.LngLatBounds()
        .extend([center[1], center[0]])
        .extend([targetCenter[1], targetCenter[0]]);

      map.fitBounds(bounds, {
        padding: 70,
        maxZoom: 14,
        duration: 1500,
        pitch: pitch,
      });
    } else {
      map.flyTo({
        center: [center[1], center[0]],
        zoom: zoom,
        essential: true,
        duration: 1200,
      });
    }
  }, [center[0], center[1], targetCenter]);

  // Update Target Marker (Destination pin)
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    if (targetCenter) {
      if (!targetMarkerRef.current) {
        const el = document.createElement("div");
        el.style.cssText = `
          position: relative;
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
        `;

        el.innerHTML = `
          <div style="
            position: absolute;
            width: 32px; height: 32px;
            border-radius: 50%;
            background: rgba(6,182,212,0.25);
            animation: destPing 2s cubic-bezier(0,0,0.2,1) infinite;
          "></div>
          <div style="
            position: absolute;
            width: 18px; height: 18px;
            border-radius: 50%;
            background: rgba(6,182,212,0.35);
            filter: blur(3px);
          "></div>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" style="
            color: #22d3ee;
            position: relative;
            filter: drop-shadow(0 0 8px rgba(6,182,212,0.9));
          ">
            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
          </svg>
          <style>
            @keyframes destPing {
              75%, 100% { transform: scale(2); opacity: 0; }
            }
          </style>
        `;

        targetMarkerRef.current = new maplibregl.Marker({ element: el })
          .setLngLat([targetCenter[1], targetCenter[0]])
          .addTo(map);
      } else {
        targetMarkerRef.current.setLngLat([targetCenter[1], targetCenter[0]]);
      }
    } else {
      if (targetMarkerRef.current) {
        targetMarkerRef.current.remove();
        targetMarkerRef.current = null;
      }
    }
  }, [targetCenter]);

  // Update Route Polyline
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    const source = map.getSource("route") as maplibregl.GeoJSONSource;
    if (!source) return;

    if (showRoute && targetCenter) {
      source.setData({
        type: "Feature",
        properties: {},
        geometry: {
          type: "LineString",
          coordinates: [
            [center[1], center[0]],
            [targetCenter[1], targetCenter[0]],
          ],
        },
      });
      map.setLayoutProperty("route-line", "visibility", "visible");
      map.setLayoutProperty("route-glow", "visibility", "visible");
    } else {
      if (map.getLayer("route-line")) map.setLayoutProperty("route-line", "visibility", "none");
      if (map.getLayer("route-glow")) map.setLayoutProperty("route-glow", "visibility", "none");
    }
  }, [center[0], center[1], targetCenter, showRoute]);

  return <div ref={mapContainerRef} className="w-full h-full relative" />;
}
