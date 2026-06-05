"use client";

import { motion } from "framer-motion";
import { Navigation, Compass, MapPin, Bell, Shield, X, AlertCircle } from "lucide-react";
import { useEffect, useState, useRef } from "react";
import { Button } from "@/components/ui/button";
import MapBackground from "./map-background";

interface TrackingScreenProps {
  destination: string;
  address?: string;
  targetCoords: [number, number] | null;
  config: { distance: number; vibration: boolean; sound: boolean };
  onCancel: () => void;
  onArrive: () => void;
}

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number) {
  const R = 6371; // Earth's radius in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function deg2rad(deg: number) {
  return deg * (Math.PI / 180);
}

export function TrackingScreen({
  destination,
  address,
  targetCoords,
  config,
  onCancel,
  onArrive,
}: TrackingScreenProps) {
  const [currentDistance, setCurrentDistance] = useState<number | null>(3.4); // Start with simulated 3.4 km as per mockup
  const [speed, setSpeed] = useState<number>(35); // Simulated starting speed in km/h
  const [eta, setEta] = useState<number>(6); // Simulated starting ETA in mins
  const [accuracy, setAccuracy] = useState<string>("High");
  const [currentCoords, setCurrentCoords] = useState<[number, number]>([11.2721, 75.7912]); // Simulated starting coordinates
  const [gpsError, setGpsError] = useState<string | null>(null);

  const watchIdRef = useRef<number | null>(null);
  const simulationIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Real GPS Tracking Effect
  useEffect(() => {
    if (!targetCoords) return;

    if (!navigator.geolocation) {
      setGpsError("Geolocation is not supported by your browser.");
      return;
    }

    const handlePosition = (position: GeolocationPosition) => {
      const { latitude, longitude, speed: currentSpeed, accuracy: gpsAccuracy } = position.coords;
      const userCoords: [number, number] = [latitude, longitude];
      setCurrentCoords(userCoords);
      setGpsError(null);

      const dist = calculateDistance(latitude, longitude, targetCoords[0], targetCoords[1]);
      setCurrentDistance(dist);

      // Speed is returned in m/s, convert to km/h
      setSpeed(currentSpeed ? Math.round(currentSpeed * 3.6) : 24);
      
      // Rough ETA calculation: distance / speed
      const speedKmh = currentSpeed ? currentSpeed * 3.6 : 30;
      const calculatedEta = speedKmh > 5 ? Math.round((dist / speedKmh) * 60) : Math.round(dist * 2);
      setEta(calculatedEta > 0 ? calculatedEta : 1);

      setAccuracy(gpsAccuracy && gpsAccuracy < 15 ? "High" : "Medium");

      document.title = `${dist.toFixed(2)} km - ${destination}`;

      // Check arrival threshold
      if (dist <= config.distance) {
        onArrive();
      }
    };

    const handleError = (err: GeolocationPositionError) => {
      console.warn("GPS Error:", err);
      // Don't override mock data immediately unless permission is explicitly denied
      if (err.code === err.PERMISSION_DENIED) {
        setGpsError("Location permission denied. Utilizing simulated movement.");
      }
    };

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
  }, [targetCoords, config.distance]);

  // Simulated Movement for Demos
  const handleSimulateTrip = () => {
    if (simulationIntervalRef.current) return;
    if (!targetCoords) return;

    let simulatedDist = currentDistance ?? 3.4;
    setGpsError(null);

    simulationIntervalRef.current = setInterval(() => {
      if (simulatedDist <= config.distance) {
        clearInterval(simulationIntervalRef.current!);
        simulationIntervalRef.current = null;
        onArrive();
        return;
      }

      // Decrement simulated distance closer to target
      simulatedDist -= 0.15;
      if (simulatedDist < 0) simulatedDist = 0;

      // Calculate simulated coordinates incrementally closer to targetCoords
      const ratio = 1 - (simulatedDist / 3.4);
      const startCoords: [number, number] = [11.2721, 75.7912];
      const interpolatedLat = startCoords[0] + (targetCoords[0] - startCoords[0]) * ratio;
      const interpolatedLng = startCoords[1] + (targetCoords[1] - startCoords[1]) * ratio;

      setCurrentDistance(simulatedDist);
      setCurrentCoords([interpolatedLat, interpolatedLng]);
      setSpeed(42); // speed up simulation
      setEta(Math.max(1, Math.round(simulatedDist * 1.8)));
    }, 1000);
  };

  useEffect(() => {
    return () => {
      if (simulationIntervalRef.current) {
        clearInterval(simulationIntervalRef.current);
      }
    };
  }, []);

  // Calculate Progress Circle Stroke Offsets
  // 120px radius => 2 * pi * 120 = 753.98 circumference
  const radius = 100;
  const circumference = 2 * Math.PI * radius;
  const initialDist = 3.4;
  const progressPercent = currentDistance 
    ? Math.min(100, Math.max(0, ((initialDist - (currentDistance - config.distance)) / initialDist) * 100))
    : 0;
  const strokeDashoffset = circumference - (progressPercent / 100) * circumference;

  return (
    <div className="relative w-full h-full overflow-hidden bg-black text-white">
      
      {/* Full screen Mapbox route layout */}
      <div className="absolute inset-0 z-0">
        <MapBackground
          center={currentCoords}
          zoom={14}
          targetCenter={targetCoords}
          showRoute={true}
          pitch={45}
        />
        {/* Cinematic gradient vignette overlays */}
        <div className="absolute inset-0 bg-gradient-to-b from-black/70 via-black/20 to-black/85 pointer-events-none" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_20%,rgba(0,0,0,0.4)_75%)] pointer-events-none" />
      </div>

      {/* Interface Overlay */}
      <div className="relative z-10 flex h-full flex-col justify-between px-5 pt-7 pb-6">
        
        {/* Top Control Bar */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 rounded-full bg-blue-600/10 border border-blue-500/25 px-3 py-1 text-[11px] font-bold text-blue-400 tracking-widest uppercase shadow-[0_0_10px_rgba(59,130,246,0.15)]">
            <span className="size-1.5 rounded-full bg-blue-500 animate-pulse" />
            {gpsError ? "SIMULATOR ACTIVE" : "GPS ACTIVE"}
          </div>

          <button
            onClick={onCancel}
            className="flex items-center gap-1.5 px-4 h-9 rounded-full bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/20 text-xs font-bold text-slate-300 transition-all duration-300"
          >
            <X className="size-4" />
            Cancel
          </button>
        </div>

        {/* GPS Alert indicator if GPS fails */}
        {gpsError && (
          <div className="mt-3 flex items-start gap-2.5 rounded-2xl bg-amber-500/10 border border-amber-500/25 p-3 text-xs text-amber-300">
            <AlertCircle className="size-4 shrink-0 mt-0.5" />
            <p className="leading-tight">{gpsError}</p>
          </div>
        )}

        {/* Circular HUD Progress Ring */}
        <div className="my-auto flex flex-col items-center justify-center py-6">
          <div className="relative flex size-64 items-center justify-center">
            
            {/* Soft pulsing glow behind the circle */}
            <div className="absolute inset-4 rounded-full bg-blue-500/10 blur-2xl animate-pulse" />

            {/* SVG Circle Drawing */}
            <svg className="absolute w-full h-full transform -rotate-90">
              {/* Outer light track */}
              <circle
                cx="128"
                cy="128"
                r={radius}
                stroke="rgba(255, 255, 255, 0.05)"
                strokeWidth="6"
                fill="transparent"
              />
              {/* Glowing active progress stroke */}
              <motion.circle
                cx="128"
                cy="128"
                r={radius}
                stroke="#2563eb"
                strokeWidth="7"
                fill="transparent"
                strokeDasharray={circumference}
                animate={{ strokeDashoffset }}
                transition={{ duration: 0.8, ease: "easeOut" }}
                strokeLinecap="round"
                className="filter drop-shadow-[0_0_12px_rgba(59,130,246,0.65)]"
              />
            </svg>

            {/* In-Ring Stats Display */}
            <div className="flex flex-col items-center justify-center text-center z-10">
              <span className="text-5xl font-black font-mono tracking-tighter text-white select-none">
                {currentDistance !== null ? currentDistance.toFixed(2) : "--"}
              </span>
              <span className="text-[11px] font-bold text-blue-400 uppercase tracking-widest mt-2 select-none">
                Km Remaining
              </span>
              <span className="text-[10px] text-slate-500 font-medium tracking-wide mt-1.5 select-none">
                Alarm: {config.distance.toFixed(1)} km out
              </span>
            </div>
            
          </div>

          {/* Quick Simulation Trigger Button (Sleek indicator) */}
          <button
            onClick={handleSimulateTrip}
            className="mt-4 flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-cyan-500/10 border border-cyan-500/25 text-[10px] font-bold text-cyan-400 hover:bg-cyan-500/20 transition-all duration-300"
          >
            <Compass className="size-3.5 animate-spin" style={{ animationDuration: '4s' }} />
            Simulate Ride
          </button>
        </div>

        {/* Bottom Panel Card */}
        <div className="space-y-4">
          <div className="rounded-3xl glass-panel-heavy p-5 shadow-[0_12px_40px_rgba(0,0,0,0.6)] space-y-4">
            
            {/* Destination Description header */}
            <div className="flex items-center gap-3">
              <div className="flex size-9 items-center justify-center rounded-xl bg-blue-600/20 border border-blue-500/30 text-blue-400 shrink-0">
                <MapPin className="size-4.5 fill-blue-400/25" />
              </div>
              <div className="min-w-0">
                <h3 className="text-base font-bold text-white truncate leading-none">
                  {destination}
                </h3>
                {address && address !== destination && (
                  <p className="text-xs text-slate-400 truncate mt-1">
                    {address}
                  </p>
                )}
              </div>
            </div>

            {/* Dashboard stats row */}
            <div className="grid grid-cols-3 gap-2 text-center pt-4 border-t border-white/5">
              <div>
                <span className="block text-[10px] font-semibold text-slate-500 uppercase tracking-wider">Speed</span>
                <span className="block text-lg font-black text-white font-mono mt-1">
                  {speed} <span className="text-xs font-normal text-slate-400">km/h</span>
                </span>
              </div>
              
              <div className="border-x border-white/5">
                <span className="block text-[10px] font-semibold text-slate-500 uppercase tracking-wider">ETA</span>
                <span className="block text-lg font-black text-white font-mono mt-1">
                  {eta} <span className="text-xs font-normal text-slate-400">min</span>
                </span>
              </div>
              
              <div>
                <span className="block text-[10px] font-semibold text-slate-500 uppercase tracking-wider">Accuracy</span>
                <span className="block text-lg font-bold text-emerald-400 mt-1 flex items-center justify-center gap-1">
                  <span className="size-1.5 rounded-full bg-emerald-400" />
                  {accuracy}
                </span>
              </div>
            </div>

          </div>

          {/* iOS Home Indicator */}
          <div className="mx-auto h-1 w-32 rounded-full bg-white/20" />
        </div>

      </div>
    </div>
  );
}
