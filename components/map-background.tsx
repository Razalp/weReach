"use client";

import { MapContainer, TileLayer, Marker, useMap } from "react-leaflet";
import L from "leaflet";
import { useEffect } from "react";

// Fix for default marker icons in Next.js
const icon = L.icon({
    iconUrl: "/marker-icon.png",
    shadowUrl: "/marker-shadow.png",
    iconSize: [25, 41],
    iconAnchor: [12, 41],
});
// Since we don't have local assets, we'll use CDN for now or just generic circle markers
const DefaultIcon = L.icon({
    iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

interface MapBackgroundProps {
    center?: [number, number];
    zoom?: number;
    children?: React.ReactNode;
    scrollWheelZoom?: boolean;
    zoomControl?: boolean;
    dragging?: boolean;
    doubleClickZoom?: boolean;
}

function ChangeView({ center, zoom }: MapBackgroundProps) {
    const map = useMap();
    useEffect(() => {
        if (center) map.setView(center, zoom || 13);
    }, [center, zoom, map]);
    return null;
}

export default function MapBackground({
    center = [48.8566, 2.3522],
    zoom = 13,
    children,
    scrollWheelZoom = false,
    zoomControl = false,
    dragging = true, // Default to true as before
    doubleClickZoom = false
}: MapBackgroundProps) {
    return (
        <MapContainer
            center={center}
            zoom={zoom}
            style={{ height: "100%", width: "100%" }}
            zoomControl={zoomControl}
            attributionControl={false}
            dragging={dragging}
            doubleClickZoom={doubleClickZoom}
            scrollWheelZoom={scrollWheelZoom}
        >
            <TileLayer
                url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
            />
            <ChangeView center={center} zoom={zoom} />
            {children}
        </MapContainer>
    );
}
