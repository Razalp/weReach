"use client";

import { motion } from "framer-motion";
import { Navigation, ShieldAlert } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useEffect, useState, useRef } from "react";
import { playAlarmSound } from "@/lib/audio";

interface TrackingScreenProps {
    destination: string;
    targetCoords: [number, number] | null;
    config: { distance: number; vibration: boolean; sound: boolean };
    onCancel: () => void;
    onArrive: () => void;
}

// Haversine formula to calculate distance between two points in km
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number) {
    const R = 6371; // Radius of the earth in km
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c; // Distance in km
    return d;
}

function deg2rad(deg: number) {
    return deg * (Math.PI / 180);
}

export function TrackingScreen({ destination, targetCoords, config, onCancel, onArrive }: TrackingScreenProps) {
    const [currentDistance, setCurrentDistance] = useState<number | null>(null);
    const [speed, setSpeed] = useState<number | null>(null);
    const [error, setError] = useState<string | null>(null);
    const watchIdRef = useRef<number | null>(null);

    useEffect(() => {
        if (!targetCoords) {
            setError("Invalid destination coordinates.");
            return;
        }

        if (!navigator.geolocation) {
            setError("Geolocation is not supported by your browser.");
            return;
        }

        const handlePosition = (position: GeolocationPosition) => {
            const { latitude, longitude, speed: currentSpeed } = position.coords;
            const dist = calculateDistance(latitude, longitude, targetCoords[0], targetCoords[1]);

            setCurrentDistance(dist);
            setSpeed(currentSpeed ? currentSpeed * 3.6 : 0); // Convert m/s to km/h

            // Update Taskbar Title
            document.title = `${dist.toFixed(1)}km - ${destination}`;

            if (dist <= config.distance) {
                onArrive();
            }
        };

        const handleError = (err: GeolocationPositionError) => {
            console.warn("GPS Error:", err);
            // Don't show critical error immediately, maybe GPS is just warming up
            if (err.code === err.PERMISSION_DENIED) {
                setError("Location permission denied. Please enable GPS.");
            }
        };

        // Use watchPosition for real-time tracking
        // enableHighAccuracy: true is crucial for precise distance alerts
        watchIdRef.current = navigator.geolocation.watchPosition(handlePosition, handleError, {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0,
        });

        return () => {
            if (watchIdRef.current !== null) {
                navigator.geolocation.clearWatch(watchIdRef.current);
            }
        };
    }, [targetCoords, config.distance, onArrive]);

    // Calculate progress ring (clamped between 0 and 100)
    // We assume a 'start' distance of roughly current + 10km for visual context if we don't have a start point, 
    // or just make it relative to the alert distance.
    // Let's make the ring show "closeness" relative to a rough 50km outer bound or just dynamic.
    // Better yet: make 100% = 0km, 0% = >20km or start distance.
    // For simplicity: Max scale is 20km.
    const maxScale = 20;
    const progress = currentDistance
        ? Math.min(100, Math.max(0, ((maxScale - currentDistance) / (maxScale - config.distance)) * 100))
        : 0;

    return (
        <div className="flex flex-col h-full w-full bg-black text-white relative overflow-hidden">
            {/* Background Gradient */}
            <div className="absolute inset-0 bg-gradient-to-b from-slate-900 to-black pointer-events-none" />

            {/* Top Bar */}
            <div className="relative z-10 flex justify-between items-center p-6">
                <div className="flex items-center gap-2 text-white/70">
                    <Navigation className="w-4 h-4 fill-current animate-pulse" />
                    <span className="text-xs font-medium uppercase tracking-widest">GPS Active</span>
                </div>
                <Button
                    variant="secondary"
                    size="sm"
                    onClick={onCancel}
                    className="rounded-full bg-white/10 hover:bg-white/20 text-white border-none h-8 px-4 text-xs"
                >
                    Cancel
                </Button>
            </div>

            {/* Main Content */}
            <div className="flex-1 relative flex flex-col items-center justify-center p-8 z-10">

                {/* Ring */}
                <div className="relative w-64 h-64 flex items-center justify-center mb-12">
                    {/* Pulsing effect */}
                    <motion.div
                        animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.1, 0.3] }}
                        transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                        className="absolute inset-0 rounded-full bg-blue-500/20 blur-xl"
                    />

                    <svg className="w-full h-full transform -rotate-90">
                        <circle
                            cx="128"
                            cy="128"
                            r="120"
                            stroke="currentColor"
                            strokeWidth="2"
                            fill="transparent"
                            className="text-white/10"
                        />
                        <motion.circle
                            cx="128"
                            cy="128"
                            r="120"
                            stroke={error ? "#ef4444" : "#3b82f6"}
                            strokeWidth="4"
                            fill="transparent"
                            strokeDasharray={2 * Math.PI * 120}
                            initial={{ strokeDashoffset: 2 * Math.PI * 120 }}
                            animate={{ strokeDashoffset: 2 * Math.PI * 120 * (1 - progress / 100) }}
                            strokeLinecap="round"
                            className="filter drop-shadow-[0_0_10px_rgba(59,130,246,0.5)]"
                        />
                    </svg>

                    <div className="absolute inset-0 flex flex-col items-center justify-center cursor-pointer hover:scale-105 transition-transform" onClick={() => playAlarmSound(1000)}>
                        {error ? (
                            <div className="flex flex-col items-center text-red-500 gap-2">
                                <ShieldAlert className="w-12 h-12" />
                                <span className="text-xs font-mono max-w-[150px] text-center">{error}</span>
                            </div>
                        ) : (
                            <>
                                <span className="text-6xl font-light tracking-tighter font-mono">
                                    {currentDistance !== null ? currentDistance.toFixed(2) : "--"}
                                </span>
                                <span className="text-sm text-blue-400 font-medium uppercase mt-2">Km Remaining</span>
                                <span className="text-[10px] text-white/30 mt-1 uppercase tracking-widest">Click to Test Sound</span>
                            </>
                        )}
                    </div>
                </div>

                <div className="text-center space-y-2">
                    <h2 className="text-2xl font-medium tracking-tight h-8 truncate max-w-[300px]">{destination}</h2>
                    <p className="text-white/50 text-sm">
                        Alarm set for {config.distance} km mark
                    </p>
                </div>
            </div>

            {/* GPS Data */}
            <div className="p-6 relative z-10 grid grid-cols-2 gap-4 text-center border-t border-white/5">
                <div>
                    <div className="text-xs text-white/40 uppercase mb-1">Speed</div>
                    <div className="text-xl font-mono">{speed !== null ? Math.round(speed) : "--"} <span className="text-xs text-white/40">km/h</span></div>
                </div>
                <div>
                    <div className="text-xs text-white/40 uppercase mb-1">GPS Accuracy</div>
                    <div className="text-xl font-mono text-green-400">High</div>
                </div>
            </div>
        </div>
    );
}
