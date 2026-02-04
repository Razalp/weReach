"use client";

import { motion } from "framer-motion";
import { MapPin, Search, Loader2 } from "lucide-react";
import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import dynamic from "next/dynamic";

// Dynamically import the Map component to avoid SSR issues with Leaflet
const MapBackground = dynamic(() => import("./map-background"), {
    ssr: false,
    loading: () => (
        <div className="w-full h-full flex items-center justify-center bg-secondary/20 text-muted-foreground text-sm">
            Loading Map...
        </div>
    ),
});

interface DestinationSearchProps {
    onSelect: (destination: string, coords: [number, number]) => void;
}

interface Suggestion {
    place_id: number;
    display_name: string;
    lat: string;
    lon: string;
}

export function DestinationSearch({ onSelect }: DestinationSearchProps) {
    const [query, setQuery] = useState("");
    const [debouncedQuery, setDebouncedQuery] = useState("");
    const [isFocused, setIsFocused] = useState(false);
    const [coords, setCoords] = useState<[number, number]>([48.8566, 2.3522]); // Default: Paris
    const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
    const [isLoading, setIsLoading] = useState(false);

    // Debounce query
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedQuery(query);
        }, 500);
        return () => clearTimeout(timer);
    }, [query]);

    // Fetch suggestions
    useEffect(() => {
        if (!debouncedQuery || debouncedQuery.length < 3) {
            setSuggestions([]);
            return;
        }

        const fetchSuggestions = async () => {
            setIsLoading(true);
            try {
                const res = await fetch(
                    `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(
                        debouncedQuery
                    )}&limit=5`
                );
                const data = await res.json();
                setSuggestions(data);
            } catch (error) {
                console.error("Error fetching suggestions:", error);
            } finally {
                setIsLoading(false);
            }
        };

        fetchSuggestions();
    }, [debouncedQuery]);

    const handleSelect = (suggestion: Suggestion) => {
        const lat = parseFloat(suggestion.lat);
        const lon = parseFloat(suggestion.lon);

        // Extract a shorter name for display (usually the first part of the address)
        const shortName = suggestion.display_name.split(",")[0];

        setCoords([lat, lon]);
        setQuery(shortName);
        // Clearing suggestions might be desired, but keeping them until focus loss is also fine.
        // We'll let the user decide when to proceed.
    };

    const handleConfirm = () => {
        if (query) onSelect(query, coords);
    }

    return (
        <div className="relative w-full h-full bg-secondary/10 overflow-hidden">
            {/* Leaflet Map Background */}
            <div className="absolute inset-0 z-0">
                <MapBackground center={coords} zoom={13} />

                {/* Gradient Overlay for text readability */}
                <div className="absolute inset-0 bg-gradient-to-t from-background via-background/80 to-transparent pointer-events-none" />
                <div className="absolute inset-0 bg-gradient-to-b from-background via-transparent to-transparent pointer-events-none" />
            </div>

            <div className="relative z-10 flex flex-col items-center justify-start pt-20 h-full px-6 space-y-8">
                <motion.div
                    initial={{ opacity: 0, y: -20 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-center space-y-2 pointer-events-none"
                >
                    <div className="w-16 h-16 bg-background/80 backdrop-blur-md shadow-sm rounded-full flex items-center justify-center mx-auto mb-6 text-primary">
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
                    className={`w-full max-w-sm relative transition-all duration-300 ${isFocused || suggestions.length > 0 ? "shadow-xl ring-1 ring-primary/20 scale-[1.02]" : "shadow-lg"
                        } rounded-2xl bg-card/90 backdrop-blur-xl overflow-visible`}
                >
                    <div className="flex items-center px-4 h-14">
                        {isLoading ? (
                            <Loader2 className="w-5 h-5 text-primary animate-spin mr-3" />
                        ) : (
                            <Search className="w-5 h-5 text-muted-foreground mr-3" />
                        )}
                        <Input
                            value={query}
                            onChange={(e) => setQuery(e.target.value)}
                            onFocus={() => setIsFocused(true)}
                            // Delay blur to allow clicks on suggestions
                            onBlur={() => setTimeout(() => setIsFocused(false), 200)}
                            placeholder="Search city, place..."
                            className="border-none shadow-none focus-visible:ring-0 h-full text-base bg-transparent p-0 placeholder:text-muted-foreground/50"
                        />
                    </div>

                    {/* Suggestions */}
                    {suggestions.length > 0 && isFocused && (
                        <motion.div
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: "auto" }}
                            className="absolute top-full left-0 right-0 mt-2 bg-card/90 backdrop-blur-xl rounded-xl shadow-xl overflow-hidden border border-white/20 z-50 max-h-[300px] overflow-y-auto"
                        >
                            {suggestions.map((item) => (
                                <button
                                    key={item.place_id}
                                    onClick={() => handleSelect(item)}
                                    className="w-full text-left px-4 py-3 text-sm hover:bg-secondary/50 transition-colors flex items-center space-x-3 border-b border-border/10 last:border-none"
                                >
                                    <div className="shrink-0 w-8 h-8 rounded-full bg-secondary/80 flex items-center justify-center text-muted-foreground">
                                        <MapPin className="w-3.5 h-3.5" />
                                    </div>
                                    <span className="line-clamp-2">{item.display_name}</span>
                                </button>
                            ))}
                        </motion.div>
                    )}
                </motion.div>

                {query && (
                    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="w-full max-w-sm">
                        <Button onClick={handleConfirm} className="w-full rounded-full h-12 text-base font-medium shadow-soft">
                            Track "{query}"
                        </Button>
                    </motion.div>
                )}
            </div>
        </div>
    );
}
