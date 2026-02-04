"use client";

import { motion } from "framer-motion";
import { BellOff, MapPin } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WakeUpAlertProps {
    destination: string;
    onDismiss: () => void;
}

export function WakeUpAlert({ destination, onDismiss }: WakeUpAlertProps) {
    return (
        <div className="flex flex-col h-full w-full bg-red-500 relative overflow-hidden items-center justify-between p-8">
            <motion.div
                className="absolute inset-0 bg-white"
                animate={{ opacity: [0, 0.2, 0] }}
                transition={{ duration: 0.5, repeat: Infinity, ease: "linear" }}
            />

            <div className="z-10 mt-12 text-center text-white space-y-6">
                <motion.div
                    animate={{ rotate: [-10, 10, -10] }}
                    transition={{ duration: 0.2, repeat: Infinity }}
                    className="w-24 h-24 bg-white text-red-600 rounded-full flex items-center justify-center mx-auto shadow-xl"
                >
                    <MapPin className="w-12 h-12 fill-current" />
                </motion.div>
                <h1 className="text-5xl font-black uppercase tracking-tighter leading-none">
                    Wake Up!
                </h1>
                <p className="text-xl font-medium text-white/90 max-w-[200px] mx-auto">
                    You are arriving at {destination}
                </p>
            </div>

            <div className="z-10 w-full mb-8">
                <Button
                    onClick={onDismiss}
                    className="w-full h-20 rounded-full bg-white text-red-600 hover:bg-white/90 text-2xl font-bold shadow-2xl animate-bounce"
                >
                    <BellOff className="mr-3 w-8 h-8" /> Stop Alarm
                </Button>
            </div>
        </div>
    );
}
