"use client";

import { motion } from "framer-motion";
import { X, Navigation } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";

interface TrackingScreenProps {
    destination: string;
    config: { distance: number; vibration: boolean; sound: boolean };
    onCancel: () => void;
    onArrive: () => void; // Manually trigger arrival for demo
}

export function TrackingScreen({ destination, config, onCancel, onArrive }: TrackingScreenProps) {
    const [currentDistance, setCurrentDistance] = useState(15.0); // Demo start distance

    // Demo effect: decrease distance
    useEffect(() => {
        const interval = setInterval(() => {
            setCurrentDistance((prev) => {
                const next = Math.max(prev - 0.1, 0); // Decrase by 100m
                if (next <= config.distance) {
                    clearInterval(interval);
                    onArrive();
                }
                return next;
            });
        }, 1000); // Fast for demo
        return () => clearInterval(interval);
    }, [config.distance, onArrive]);

    const progress = Math.min(100, Math.max(0, ((15 - currentDistance) / (15 - config.distance)) * 100));

    return (
        <div className="flex flex-col h-full w-full bg-black text-white relative overflow-hidden">
            {/* Background Gradient */}
            <div className="absolute inset-0 bg-gradient-to-b from-slate-900 to-black pointer-events-none" />

            {/* Top Bar */}
            <div className="relative z-10 flex justify-between items-center p-6">
                <div className="flex items-center gap-2 text-white/70">
                    <Navigation className="w-4 h-4 fill-current" />
                    <span className="text-xs font-medium uppercase tracking-widest">Tracking Active</span>
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
                            stroke="#3b82f6"
                            strokeWidth="4"
                            fill="transparent"
                            strokeDasharray={2 * Math.PI * 120}
                            initial={{ strokeDashoffset: 2 * Math.PI * 120 }}
                            animate={{ strokeDashoffset: 2 * Math.PI * 120 * (1 - progress / 100) }}
                            strokeLinecap="round"
                            className="filter drop-shadow-[0_0_10px_rgba(59,130,246,0.5)]"
                        />
                    </svg>

                    <div className="absolute inset-0 flex flex-col items-center justify-center">
                        <span className="text-6xl font-light tracking-tighter font-mono">
                            {currentDistance.toFixed(1)}
                        </span>
                        <span className="text-sm text-blue-400 font-medium uppercase mt-2">Km Remaining</span>
                    </div>
                </div>

                <div className="text-center space-y-2">
                    <h2 className="text-2xl font-medium tracking-tight">{destination}</h2>
                    <p className="text-white/50 text-sm">
                        Alarm set for {config.distance} km mark
                    </p>
                </div>
            </div>

            {/* Simulated GPS Data */}
            <div className="p-6 relative z-10 grid grid-cols-2 gap-4 text-center border-t border-white/5">
                <div>
                    <div className="text-xs text-white/40 uppercase mb-1">Speed</div>
                    <div className="text-xl font-mono">120 <span className="text-xs text-white/40">km/h</span></div>
                </div>
                <div>
                    <div className="text-xs text-white/40 uppercase mb-1">ETA</div>
                    <div className="text-xl font-mono">18:45</div>
                </div>
            </div>
        </div>
    );
}
