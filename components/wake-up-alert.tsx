"use client";

import { motion } from "framer-motion";
import { BellOff, MapPin, Sparkles, Navigation } from "lucide-react";
import { useEffect } from "react";
import { Button } from "@/components/ui/button";

interface WakeUpAlertProps {
  destination: string;
  onDismiss: () => void;
}

export function WakeUpAlert({ destination, onDismiss }: WakeUpAlertProps) {
  
  // Audio alarm generator
  useEffect(() => {
    const AudioContextConstructor =
      window.AudioContext ||
      (window as Window & { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;

    if (!AudioContextConstructor) return;

    const ctx = new AudioContextConstructor();
    let oscillator: OscillatorNode | null = null;
    let gainNode: GainNode | null = null;
    let isPlaying = true;

    // Elegant multi-tone ringing alarm sound loop
    const playAlarm = () => {
      if (!isPlaying) return;

      oscillator = ctx.createOscillator();
      gainNode = ctx.createGain();

      // Tesla-style high-tech warning sound pattern
      oscillator.type = "sine";
      oscillator.frequency.setValueAtTime(660, ctx.currentTime); // E5
      oscillator.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.35); // A5

      gainNode.gain.setValueAtTime(0.4, ctx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);

      oscillator.connect(gainNode);
      gainNode.connect(ctx.destination);

      oscillator.start();
      oscillator.stop(ctx.currentTime + 0.4);

      // Repeat
      setTimeout(playAlarm, 800);
    };

    playAlarm();

    return () => {
      isPlaying = false;
      if (oscillator) oscillator.disconnect();
      if (gainNode) gainNode.disconnect();
      if (ctx.state !== "closed") ctx.close();
    };
  }, []);

  return (
    <div className="relative flex flex-col h-full w-full bg-[#02050e] overflow-hidden items-center justify-between p-8 text-white select-none">
      
      {/* Cinematic Glowing Background Gradients */}
      <div className="absolute inset-0 z-0">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-80 h-80 rounded-full bg-blue-600/15 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-10 left-10 w-60 h-60 rounded-full bg-cyan-500/10 blur-[90px] pointer-events-none" />
      </div>

      {/* 3D Concentric Pulse Wave Rings */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 z-0 flex items-center justify-center pointer-events-none">
        <div className="absolute size-48 rounded-full border border-blue-500/30 bg-blue-500/5 pulse-wave" />
        <div className="absolute size-48 rounded-full border border-blue-400/20 bg-blue-400/5 pulse-wave-delayed-1" />
        <div className="absolute size-48 rounded-full border border-cyan-500/15 bg-cyan-500/5 pulse-wave-delayed-2" />
      </div>

      {/* Main UI Overlay */}
      <div className="relative z-10 flex flex-col items-center justify-between h-full w-full py-8">
        
        {/* Top Header Badge */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-center gap-2 rounded-full bg-blue-600/10 border border-blue-500/25 px-4 py-1.5 text-xs font-bold text-blue-400 tracking-widest uppercase shadow-[0_0_15px_rgba(59,130,246,0.2)]"
        >
          <Sparkles className="size-3.5 fill-blue-400/25 text-blue-400" />
          Stop Alert
        </motion.div>

        {/* Center Ring Icon */}
        <motion.div
          initial={{ scale: 0.85, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: "spring", stiffness: 100 }}
          className="relative size-32 rounded-full glass-panel-heavy border border-blue-500/40 shadow-[0_0_40px_rgba(59,130,246,0.3)] flex items-center justify-center"
        >
          <motion.div
            animate={{ 
              rotate: [-6, 6, -6, 6, 0],
              scale: [1, 1.05, 0.98, 1.03, 1]
            }}
            transition={{ 
              repeat: Infinity, 
              duration: 2.2, 
              ease: "easeInOut",
              repeatDelay: 0.8
            }}
          >
            <MapPin className="size-14 text-blue-400 fill-blue-400/25 filter drop-shadow-[0_0_10px_rgba(59,130,246,0.5)]" />
          </motion.div>
        </motion.div>

        {/* Breathing Text and Destination Details */}
        <div className="text-center space-y-4 max-w-[290px]">
          <motion.h1
            animate={{ opacity: [0.75, 1, 0.75] }}
            transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut" }}
            className="text-4xl font-black tracking-tight leading-none text-white font-sans uppercase"
          >
            You are arriving soon
          </motion.h1>
          
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="rounded-2xl bg-white/5 border border-white/10 px-4 py-3 shadow-[0_4px_20px_rgba(0,0,0,0.3)]"
          >
            <span className="block text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none">Arriving Station</span>
            <span className="block text-base font-bold text-white mt-1.5 line-clamp-2 leading-tight">
              {destination}
            </span>
          </motion.div>
        </div>

        {/* Stop Alarm Button */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="w-full"
        >
          <Button
            onClick={onDismiss}
            className="w-full h-16 rounded-full bg-white text-slate-950 hover:bg-slate-100 text-lg font-black tracking-wider uppercase shadow-[0_10px_35px_rgba(255,255,255,0.15)] flex items-center justify-center gap-3 active:scale-[0.98] transition-all"
          >
            <BellOff className="size-5 shrink-0" />
            Stop Alarm
          </Button>
        </motion.div>

      </div>

      {/* iOS indicator */}
      <div className="mx-auto h-1 w-32 rounded-full bg-white/20 z-10" />
    </div>
  );
}
