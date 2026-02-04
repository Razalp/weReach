"use client";

import { AnimatePresence, motion } from "framer-motion";
import { useState } from "react";
import { AlertConfig } from "@/components/alert-config";
import { DestinationSearch } from "@/components/destination-search";
import { TrackingScreen } from "@/components/tracking-screen";
import { WakeUpAlert } from "@/components/wake-up-alert";

type ViewState = "search" | "config" | "tracking" | "alert";

export default function Home() {
  const [view, setView] = useState<ViewState>("search");
  const [destination, setDestination] = useState("");
  const [destinationCoords, setDestinationCoords] = useState<[number, number] | null>(null);
  const [config, setConfig] = useState({ distance: 1, vibration: true, sound: true });

  const handleDestinationSelect = (dest: string, coords: [number, number]) => {
    setDestination(dest);
    setDestinationCoords(coords);

    // Request notification permission if needed
    if (Notification.permission === "default") {
      Notification.requestPermission();
    }

    setView("config");
  };

  const handleStartTracking = (newConfig: { distance: number; vibration: boolean; sound: boolean }) => {
    setConfig(newConfig);
    setView("tracking");
  };

  const handleArrival = () => {
    setView("alert");
  };

  const handleDismiss = () => {
    setView("search");
    setDestination("");
  };

  return (
    <main className="w-full h-full relative overflow-hidden bg-background">
      <AnimatePresence mode="wait">
        {view === "search" && (
          <motion.div
            key="search"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="w-full h-full"
          >
            <DestinationSearch onSelect={handleDestinationSelect} />
          </motion.div>
        )}

        {view === "config" && (
          <motion.div
            key="config"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="w-full h-full"
          >
            <AlertConfig
              destination={destination}
              onStart={handleStartTracking}
              onBack={() => setView("search")}
            />
          </motion.div>
        )}

        {view === "tracking" && (
          <motion.div
            key="tracking"
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.05 }}
            className="w-full h-full"
          >
            <TrackingScreen
              destination={destination}
              targetCoords={destinationCoords}
              config={config}
              onCancel={() => setView("search")}
              onArrive={handleArrival}
            />
          </motion.div>
        )}

        {view === "alert" && (
          <motion.div
            key="alert"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="w-full h-full"
          >
            <WakeUpAlert
              destination={destination}
              onDismiss={handleDismiss}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </main>
  );
}
