"use client";

import { motion } from "framer-motion";
import { ArrowRight, Bell, Moon } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { Card } from "@/components/ui/card";

interface AlertConfigProps {
    destination: string;
    onStart: (config: { distance: number; vibration: boolean; sound: boolean }) => void;
    onBack: () => void;
}

export function AlertConfig({ destination, onStart, onBack }: AlertConfigProps) {
    const [distance, setDistance] = useState([1]); // km
    const [vibration, setVibration] = useState(true);
    const [sound, setSound] = useState(true);

    return (
        <div className="flex flex-col h-full w-full p-6 bg-secondary/10">
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="flex-1 flex flex-col justify-center space-y-8"
            >
                <div className="text-center space-y-1">
                    <p className="text-sm text-muted-foreground uppercase tracking-wider font-medium">Destination</p>
                    <h2 className="text-3xl font-bold tracking-tight text-foreground">{destination}</h2>
                </div>

                <Card className="p-6 border-none shadow-sm bg-card/50 backdrop-blur-sm space-y-8">
                    <div className="space-y-4">
                        <div className="flex justify-between items-center">
                            <label className="text-sm font-medium">Alert Radius</label>
                            <span className="text-2xl font-bold text-primary">{distance[0]} <span className="text-sm text-muted-foreground font-normal">km</span></span>
                        </div>
                        <Slider
                            value={distance}
                            onValueChange={setDistance}
                            max={10}
                            min={0.5}
                            step={0.5}
                            className="py-4"
                        />
                        <p className="text-xs text-muted-foreground text-center">
                            We'll wake you up when you are {distance[0]}km away.
                        </p>
                    </div>

                    <div className="space-y-4">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-primary/10 rounded-full text-primary">
                                    <Bell className="w-4 h-4" />
                                </div>
                                <span className="text-sm font-medium">Sound Alarm</span>
                            </div>
                            <Switch checked={sound} onCheckedChange={setSound} />
                        </div>
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-primary/10 rounded-full text-primary">
                                    <Moon className="w-4 h-4" />
                                </div>
                                <span className="text-sm font-medium">Vibration</span>
                            </div>
                            <Switch checked={vibration} onCheckedChange={setVibration} />
                        </div>
                    </div>
                </Card>
            </motion.div>

            <motion.div
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                className="mt-6 flex gap-4"
            >
                <Button variant="ghost" onClick={onBack} className="flex-1 h-14 rounded-full text-base">
                    Back
                </Button>
                <Button
                    onClick={() => onStart({ distance: distance[0], vibration, sound })}
                    className="flex-[2] h-14 rounded-full text-base shadow-soft group"
                >
                    Start Tracking <ArrowRight className="ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </Button>
            </motion.div>
        </div>
    );
}
