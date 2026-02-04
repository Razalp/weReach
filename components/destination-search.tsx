"use client";

import { motion } from "framer-motion";
import { MapPin, Search } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

interface DestinationSearchProps {
    onSelect: (destination: string) => void;
}

export function DestinationSearch({ onSelect }: DestinationSearchProps) {
    const [query, setQuery] = useState("");
    const [isFocused, setIsFocused] = useState(false);

    // Mock suggestions for demo
    const suggestions = [
        "Paris, France",
        "Kyoto, Japan",
        "New York, USA",
        "London, UK",
    ].filter((s) => s.toLowerCase().includes(query.toLowerCase()) && query.length > 0);

    return (
        <div className="flex flex-col items-center justify-center w-full h-full p-6 space-y-8 bg-gradient-to-b from-background to-secondary/20">
            <motion.div
                initial={{ opacity: 0, y: -20 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-center space-y-2"
            >
                <div className="w-16 h-16 bg-primary/5 rounded-full flex items-center justify-center mx-auto mb-6 text-primary">
                    <MapPin className="w-8 h-8" />
                </div>
                <h1 className="text-3xl font-semibold tracking-tight text-foreground/90">
                    Where to?
                </h1>
                <p className="text-muted-foreground text-sm">
                    Enter your destination to start tracking.
                </p>
            </motion.div>

            <motion.div
                layout
                className={`w-full relative transition-all duration-300 ${isFocused ? "shadow-lg ring-1 ring-primary/20" : "shadow-sm"
                    } rounded-2xl bg-card overflow-hidden`}
            >
                <div className="flex items-center px-4 h-14">
                    <Search className="w-5 h-5 text-muted-foreground mr-3" />
                    <Input
                        value={query}
                        onChange={(e) => setQuery(e.target.value)}
                        onFocus={() => setIsFocused(true)}
                        onBlur={() => setTimeout(() => setIsFocused(false), 200)}
                        placeholder="Search city, station, or place..."
                        className="border-none shadow-none focus-visible:ring-0 h-full text-base bg-transparent p-0 placeholder:text-muted-foreground/50"
                    />
                </div>

                {/* Suggestions */}
                {suggestions.length > 0 && isFocused && (
                    <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: "auto" }}
                        className="border-t border-border/50"
                    >
                        {suggestions.map((item, index) => (
                            <button
                                key={index}
                                onClick={() => onSelect(item)}
                                className="w-full text-left px-4 py-3 text-sm hover:bg-secondary/50 transition-colors flex items-center space-x-3"
                            >
                                <div className="w-8 h-8 rounded-full bg-secondary/80 flex items-center justify-center text-muted-foreground">
                                    <MapPin className="w-3.5 h-3.5" />
                                </div>
                                <span>{item}</span>
                            </button>
                        ))}
                    </motion.div>
                )}
            </motion.div>

            {query && !suggestions.length && (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                    <Button onClick={() => onSelect(query)} className="w-full rounded-full h-12 text-base font-medium shadow-soft">
                        Track "{query}"
                    </Button>
                </motion.div>
            )}
        </div>
    );
}
