"use client";

import { motion } from "framer-motion";
import { ArrowLeft, Bell, BellRing, Volume2, ShieldAlert, Route, Sparkles, Navigation, Info } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import MapBackground from "./map-background";

interface AlertConfigProps {
  destination: string;
  address?: string;
  onStart: (config: { distance: number; vibration: boolean; sound: boolean }) => void;
  onBack: () => void;
}

export function AlertConfig({ destination, address, onStart, onBack }: AlertConfigProps) {
  const [distance, setDistance] = useState(1.5); // Default radius in km
  const [vibration, setVibration] = useState(true);
  const [sound, setSound] = useState(true);

  // Mock static coordinates for Kozhikode for the background preview
  const previewCoords: [number, number] = [11.2588, 75.7804];

  return (
    <div className="relative w-full h-full overflow-hidden bg-black text-white">
      {/* Blurred Map Background */}
      <div className="absolute inset-0 z-0 opacity-40 blur-md">
        <MapBackground center={previewCoords} zoom={13} pitch={45} />
      </div>
      <div className="absolute inset-0 bg-gradient-to-b from-black/85 via-black/50 to-black/95 z-0" />

      {/* Main Overlay Content */}
      <div className="relative z-10 flex h-full flex-col px-5 pt-7 pb-6 justify-between overflow-y-auto no-scrollbar">
        
        {/* Header Section */}
        <div className="flex items-center justify-between">
          <button
            onClick={onBack}
            className="flex size-10 items-center justify-center rounded-full bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/20 transition-all duration-300"
          >
            <ArrowLeft className="size-5 text-slate-300" />
          </button>
          
          <div className="rounded-full bg-blue-500/10 border border-blue-500/25 px-3 py-1 text-xs font-bold text-blue-400 tracking-wide flex items-center gap-1.5 shadow-[0_0_10px_rgba(59,130,246,0.15)]">
            <span className="size-1.5 rounded-full bg-blue-400 animate-ping" />
            Alert setup
          </div>
        </div>

        {/* Middle Content Stack */}
        <div className="my-auto space-y-6">
          
          {/* Destination Details Preview Card */}
          <motion.div
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-4 rounded-3xl glass-panel-heavy p-5"
          >
            <div className="flex items-center gap-3">
              <div className="flex size-10 items-center justify-center rounded-xl bg-blue-600/20 border border-blue-500/30 text-blue-400">
                <Route className="size-5" />
              </div>
              <span className="text-xs font-bold text-slate-400 tracking-widest uppercase">Destination Selected</span>
            </div>

            <div>
              <h2 className="text-2xl font-black text-white tracking-tight leading-tight">
                {destination}
              </h2>
              {address && address !== destination && (
                <p className="mt-1.5 text-sm text-slate-400 leading-snug">
                  {address}
                </p>
              )}
            </div>

            {/* Glowing coordinate stats */}
            <div className="flex items-center gap-3 pt-2 border-t border-white/5 text-xs text-slate-500 font-mono">
              <span>LAT: 11.2588° N</span>
              <span className="text-white/10">|</span>
              <span>LNG: 75.7804° E</span>
            </div>
          </motion.div>

          {/* Config Settings Card */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="space-y-6 rounded-3xl glass-panel p-5 shadow-[0_8px_30px_rgba(0,0,0,0.5)]"
          >
            {/* Apple-style alert radius slider */}
            <div className="space-y-4">
              <div className="flex justify-between items-end">
                <label className="text-sm font-bold text-slate-300">Alert Radius</label>
                <div className="flex items-baseline gap-1">
                  <span className="text-4xl font-black text-blue-400 blue-glow-text font-mono">
                    {distance.toFixed(1)}
                  </span>
                  <span className="text-sm font-bold text-slate-400 uppercase">km</span>
                </div>
              </div>

              {/* Thick Apple Slider custom implementation */}
              <div className="relative w-full py-4 flex items-center">
                <input
                  type="range"
                  min="0.5"
                  max="10.0"
                  step="0.5"
                  value={distance}
                  onChange={(e) => setDistance(parseFloat(e.target.value))}
                  className="w-full h-3 rounded-full bg-slate-800 outline-none appearance-none cursor-pointer accent-blue-500
                    [&::-webkit-slider-runnable-track]:bg-slate-800 [&::-webkit-slider-runnable-track]:h-3 [&::-webkit-slider-runnable-track]:rounded-full
                    [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:size-6 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-white [&::-webkit-slider-thumb]:border [&::-webkit-slider-thumb]:border-blue-500 [&::-webkit-slider-thumb]:shadow-[0_0_10px_rgba(59,130,246,0.5)] [&::-webkit-slider-thumb]:-mt-1.5"
                />
              </div>

              <div className="flex items-center gap-2 rounded-2xl bg-blue-500/5 border border-blue-500/10 px-4 py-3 text-xs text-slate-400 leading-normal">
                <Info className="size-4 text-blue-400 shrink-0" />
                <p>
                  Alarm triggers when you enter a <span className="font-bold text-white">{distance.toFixed(1)} km</span> radius around the destination.
                </p>
              </div>
            </div>

            {/* Toggle Switches (Glass style) */}
            <div className="space-y-4 pt-2 border-t border-white/5">
              
              {/* Sound alarm Toggle */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex size-9 items-center justify-center rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-400">
                    <Volume2 className="size-4" />
                  </div>
                  <div>
                    <span className="block text-sm font-bold text-white leading-none">Sound Alarm</span>
                    <span className="block text-[11px] text-slate-400 mt-1">Play high-frequency alarm tone</span>
                  </div>
                </div>
                <Switch 
                  checked={sound} 
                  onCheckedChange={setSound} 
                  className="data-[state=checked]:bg-blue-600 data-[state=unchecked]:bg-slate-800"
                />
              </div>

              {/* Vibration Toggle */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex size-9 items-center justify-center rounded-xl bg-cyan-500/10 border border-cyan-500/20 text-cyan-400">
                    <BellRing className="size-4" />
                  </div>
                  <div>
                    <span className="block text-sm font-bold text-white leading-none">Vibration Alert</span>
                    <span className="block text-[11px] text-slate-400 mt-1">Vibrate device motor periodically</span>
                  </div>
                </div>
                <Switch 
                  checked={vibration} 
                  onCheckedChange={setVibration} 
                  className="data-[state=checked]:bg-cyan-500 data-[state=unchecked]:bg-slate-800"
                />
              </div>

            </div>
          </motion.div>
        </div>

        {/* Start Tracking Button */}
        <motion.div
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          className="space-y-4"
        >
          <button
            onClick={() => onStart({ distance, vibration, sound })}
            className="w-full h-14 rounded-full glowing-btn-blue flex items-center justify-between px-6 shadow-[0_4px_30px_rgba(37,99,235,0.4)]"
          >
            <div className="flex items-center gap-2">
              <Navigation className="size-4 text-blue-200 fill-blue-200/20 rotate-45" />
              <span className="text-base font-bold text-white tracking-wide">Start Tracking</span>
            </div>
            <Sparkles className="size-4 text-white" />
          </button>
          
          <div className="mx-auto h-1 w-32 rounded-full bg-white/20" />
        </motion.div>
        
      </div>
    </div>
  );
}
