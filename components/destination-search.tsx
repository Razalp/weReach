"use client";

import { motion, AnimatePresence } from "framer-motion";
import {
  Search,
  Navigation,
  Compass,
  Train,
  Plane,
  Building2,
  Home as HomeIcon,
  Briefcase,
  GraduationCap,
  Sparkles,
  ArrowRight,
  Bookmark,
  MapPin,
  Loader2,
  MoreVertical,
} from "lucide-react";
import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import MapBackground from "./map-background";

interface DestinationSearchProps {
  onSelect: (destination: string, coords: [number, number], address?: string) => void;
}

interface Suggestion {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  provider: "mapbox" | "nominatim";
}

export function DestinationSearch({ onSelect }: DestinationSearchProps) {
  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [isFocused, setIsFocused] = useState(false);
  const [coords, setCoords] = useState<[number, number]>([11.2588, 75.7804]); // Kozhikode default coordinates
  const [targetCoords, setTargetCoords] = useState<[number, number] | null>(null);
  const [selectedPlace, setSelectedPlace] = useState<{
    name: string;
    address: string;
    latitude: number;
    longitude: number;
    distance: string;
  } | null>(null);
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [isBookmarked, setIsBookmarked] = useState(false);

  // Debounce query
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, 400);
    return () => clearTimeout(timer);
  }, [query]);

  // Fetch suggestions
  useEffect(() => {
    if (!debouncedQuery || debouncedQuery.length < 2) {
      setSuggestions([]);
      return;
    }

    const fetchSuggestions = async () => {
      setIsLoading(true);
      setError("");
      try {
        const res = await fetch(`/api/geocode?query=${encodeURIComponent(debouncedQuery)}`);
        const data = (await res.json()) as { features?: Suggestion[]; error?: string };

        if (!res.ok) {
          throw new Error(data.error || "Search failed");
        }

        setSuggestions(data.features ?? []);
      } catch (error) {
        console.error("Error fetching suggestions:", error);
        setError("Search is unavailable right now.");
      } finally {
        setIsLoading(false);
      }
    };

    fetchSuggestions();
  }, [debouncedQuery]);

  const handleSelectSuggestion = (item: Suggestion) => {
    const newCoords: [number, number] = [item.latitude, item.longitude];
    setCoords(newCoords);
    setTargetCoords(newCoords);
    setQuery(item.name);
    setSuggestions([]);
    
    // Simulate a premium Dribbble mock distance
    const mockDist = (Math.random() * 12 + 1).toFixed(1);
    
    setSelectedPlace({
      name: item.name,
      address: item.address,
      latitude: item.latitude,
      longitude: item.longitude,
      distance: `${mockDist} km away`,
    });
    setIsBookmarked(false);
  };

  const handleLocateMe = () => {
    if (navigator.geolocation) {
      setIsLoading(true);
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const userCoords: [number, number] = [
            position.coords.latitude,
            position.coords.longitude,
          ];
          setCoords(userCoords);
          setIsLoading(false);
        },
        (error) => {
          console.warn("Geolocation error:", error);
          setIsLoading(false);
        },
        { enableHighAccuracy: true }
      );
    }
  };

  const handleRecentClick = (place: {
    name: string;
    lat: number;
    lng: number;
    dist: string;
    address: string;
  }) => {
    const newCoords: [number, number] = [place.lat, place.lng];
    setCoords(newCoords);
    setTargetCoords(newCoords);
    setQuery(place.name);
    setSelectedPlace({
      name: place.name,
      address: place.address,
      latitude: place.lat,
      longitude: place.lng,
      distance: place.dist,
    });
    setIsBookmarked(true);
  };

  const handleFavoriteClick = (fav: {
    name: string;
    lat: number;
    lng: number;
    dist: string;
    address: string;
  }) => {
    const newCoords: [number, number] = [fav.lat, fav.lng];
    setCoords(newCoords);
    setTargetCoords(newCoords);
    setQuery(fav.name);
    setSelectedPlace({
      name: fav.name,
      address: fav.address,
      latitude: fav.lat,
      longitude: fav.lng,
      distance: fav.dist,
    });
    setIsBookmarked(true);
  };

  const handleContinue = () => {
    if (!selectedPlace) return;
    onSelect(
      selectedPlace.name,
      [selectedPlace.latitude, selectedPlace.longitude],
      selectedPlace.address
    );
  };

  // Mock static data to match reference screen design exactly
  const recents = [
    {
      name: "Kozhikode Railway Station",
      lat: 11.2588,
      lng: 75.7804,
      dist: "3.4 km away",
      address: "Link Road, Kozhikode, Kerala, 673001",
      icon: Train,
      color: "bg-blue-500/20 text-blue-400 border-blue-500/20",
    },
    {
      name: "Kochi Airport",
      lat: 10.152,
      lng: 76.392,
      dist: "87.6 km away",
      address: "Nedumbassery, Kochi, Kerala, 683111",
      icon: Plane,
      color: "bg-purple-500/20 text-purple-400 border-purple-500/20",
    },
    {
      name: "Bangalore Majestic",
      lat: 12.978,
      lng: 77.573,
      dist: "245 km away",
      address: "Majestic Bus Station, Bengaluru, Karnataka",
      icon: Building2,
      color: "bg-orange-500/20 text-orange-400 border-orange-500/20",
    },
  ];

  const favorites = [
    {
      name: "Home",
      lat: 11.285,
      lng: 75.815,
      dist: "11.2 km away",
      address: "Hillview Villa, Kozhikode, Kerala",
      icon: HomeIcon,
      color: "bg-green-500/20 text-green-400 border-green-500/20",
    },
    {
      name: "Office",
      lat: 11.242,
      lng: 75.771,
      dist: "18.7 km away",
      address: "Cyberpark Phase 1, Kozhikode",
      icon: Briefcase,
      color: "bg-yellow-500/20 text-yellow-400 border-yellow-500/20",
    },
    {
      name: "College",
      lat: 11.321,
      lng: 75.933,
      dist: "9.8 km away",
      address: "National Institute of Technology Calicut",
      icon: GraduationCap,
      color: "bg-indigo-500/20 text-indigo-400 border-indigo-500/20",
    },
  ];

  return (
    <div className="relative w-full h-full overflow-hidden bg-black text-white">
      {/* Full-screen Mapbox Map */}
      <div className="absolute inset-0 z-0">
        <MapBackground center={coords} zoom={13} targetCenter={targetCoords} pitch={45} />
        {/* Soft, dark gradient overlays for premium cinematic feel */}
        <div className="absolute inset-0 bg-gradient-to-b from-black/80 via-black/20 to-black/90 pointer-events-none" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(59,130,246,0.15),transparent_45%)] pointer-events-none" />
      </div>

      {/* Main Content Container */}
      <div className="relative z-10 flex h-full flex-col px-5 pt-7 pb-6 overflow-y-auto no-scrollbar justify-between">
        
        {/* Top Header Section */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* Sparkling Blue Logo */}
            <div className="relative flex size-10 items-center justify-center rounded-2xl bg-blue-600/30 border border-blue-500/30 shadow-[0_0_15px_rgba(59,130,246,0.3)]">
              <Sparkles className="size-5 text-blue-400 fill-blue-400/20 animate-pulse" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight leading-none text-white font-sans flex items-center gap-1.5">
                Wereach
              </h1>
              <p className="mt-1 text-xs text-slate-400 font-medium tracking-wide">Don&apos;t miss your stop</p>
            </div>
          </div>

          {/* Compass Icon Button */}
          <button 
            onClick={handleLocateMe}
            className="flex size-10 items-center justify-center rounded-full bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/20 transition-all duration-300"
          >
            <Compass className="size-5 text-slate-300" />
          </button>
        </div>

        {/* Floating Search Bar */}
        <div className="relative mt-5 w-full">
          <div className="flex h-14 items-center gap-2 rounded-2xl glass-panel px-4 shadow-[0_4px_30px_rgba(0,0,0,0.4)]">
            {isLoading ? (
              <Loader2 className="size-5 animate-spin text-blue-400 shrink-0" />
            ) : (
              <Search className="size-5 text-slate-400 shrink-0" />
            )}
            
            <Input
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                if (!e.target.value) setSelectedPlace(null);
              }}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setTimeout(() => setIsFocused(false), 200)}
              placeholder="Where are you going?"
              className="h-full border-none bg-transparent p-0 text-base shadow-none text-white placeholder:text-slate-500 focus-visible:ring-0 focus-visible:ring-offset-0"
            />
            
            {/* Glowing GPS Target Button */}
            <button
              onClick={handleLocateMe}
              className="flex size-9 items-center justify-center rounded-full bg-blue-600/10 border border-blue-500/30 text-blue-400 shadow-[0_0_10px_rgba(59,130,246,0.2)] hover:bg-blue-600/25 transition-all duration-300"
            >
              <Navigation className="size-4 fill-blue-400/20 rotate-45" />
            </button>
          </div>

          {/* Autocomplete Search suggestions dropdown */}
          <AnimatePresence>
            {suggestions.length > 0 && isFocused && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="absolute left-0 right-0 top-full z-50 mt-2 max-h-[260px] overflow-y-auto rounded-2xl border border-white/10 bg-slate-950/95 backdrop-blur-xl shadow-2xl"
              >
                {suggestions.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => handleSelectSuggestion(item)}
                    className="flex w-full items-center gap-3 border-b border-white/5 px-4 py-3 text-left transition-colors last:border-none hover:bg-white/5"
                  >
                    <div className="flex size-8 shrink-0 items-center justify-center rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-400">
                      <MapPin className="size-4" />
                    </div>
                    <span className="min-w-0">
                      <span className="block truncate text-sm font-semibold text-white">{item.name}</span>
                      <span className="block truncate text-xs text-slate-400 mt-0.5">{item.address}</span>
                    </span>
                  </button>
                ))}
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Dynamic bottom pane stack */}
        <div className="mt-auto space-y-5">
          
          {/* Selected Destination Card (Slide-up) */}
          <AnimatePresence mode="wait">
            {selectedPlace && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 20 }}
                className="rounded-3xl glass-panel-heavy p-4 shadow-[0_12px_40px_rgba(0,0,0,0.6)]"
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex gap-3 min-w-0">
                    {/* Glowing marker indicator icon */}
                    <div className="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-cyan-600/20 border border-cyan-500/30 text-cyan-400 shadow-[0_0_15px_rgba(6,182,212,0.2)]">
                      <MapPin className="size-5 fill-cyan-400/25" />
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-base font-bold text-white truncate leading-tight">
                        {selectedPlace.name}
                      </h3>
                      <p className="text-xs text-slate-400 truncate mt-1">
                        {selectedPlace.address}
                      </p>
                      <p className="text-xs font-semibold text-blue-400 mt-1.5 flex items-center gap-1">
                        <span className="inline-block size-1.5 rounded-full bg-blue-400 animate-pulse" />
                        {selectedPlace.distance}
                      </p>
                    </div>
                  </div>

                  {/* Bookmark Button */}
                  <button 
                    onClick={() => setIsBookmarked(!isBookmarked)}
                    className={`flex size-9 shrink-0 items-center justify-center rounded-xl border transition-all duration-300 ${
                      isBookmarked 
                        ? "bg-blue-600/20 border-blue-500/40 text-blue-400 shadow-[0_0_10px_rgba(59,130,246,0.2)]" 
                        : "bg-white/5 border-white/10 text-slate-400 hover:text-white"
                    }`}
                  >
                    <Bookmark className={`size-4 ${isBookmarked ? "fill-blue-400" : ""}`} />
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Recent Places Section */}
          <div className="space-y-2.5">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold tracking-wider text-slate-400 uppercase">Recent Places</h2>
              <button className="text-xs font-bold text-blue-400 hover:underline">See all</button>
            </div>
            
            {/* Horizontal Scroll view */}
            <div className="flex gap-3 overflow-x-auto pb-1.5 no-scrollbar">
              {recents.map((place, idx) => {
                const IconComponent = place.icon;
                return (
                  <button
                    key={idx}
                    onClick={() => handleRecentClick(place)}
                    className="flex flex-col justify-between items-start text-left shrink-0 w-36 h-28 p-3.5 rounded-2xl glass-panel hover:bg-slate-900/50 transition-all duration-300"
                  >
                    <div className={`flex size-8 items-center justify-center rounded-xl border ${place.color}`}>
                      <IconComponent className="size-4" />
                    </div>
                    <div className="min-w-0 w-full mt-2">
                      <p className="text-xs font-bold text-white truncate leading-none">{place.name}</p>
                      <p className="text-[10px] text-slate-400 truncate mt-1">{place.dist}</p>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Favorites Section */}
          <div className="space-y-2.5">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold tracking-wider text-slate-400 uppercase">Favorites</h2>
              <button className="text-xs font-bold text-blue-400 hover:underline">Edit</button>
            </div>

            {/* Horizontal Scroll view */}
            <div className="flex gap-3 overflow-x-auto pb-1.5 no-scrollbar">
              {favorites.map((fav, idx) => {
                const IconComponent = fav.icon;
                return (
                  <button
                    key={idx}
                    onClick={() => handleFavoriteClick(fav)}
                    className="flex items-center justify-between text-left shrink-0 w-44 p-3 rounded-2xl glass-panel hover:bg-slate-900/50 transition-all duration-300"
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <div className={`flex size-8 items-center justify-center rounded-xl border shrink-0 ${fav.color}`}>
                        <IconComponent className="size-4" />
                      </div>
                      <div className="min-w-0">
                        <p className="text-xs font-bold text-white truncate">{fav.name}</p>
                        <p className="text-[10px] text-slate-400 truncate mt-0.5">{fav.dist}</p>
                      </div>
                    </div>
                    <MoreVertical className="size-3.5 text-slate-500 shrink-0" />
                  </button>
                );
              })}
            </div>
          </div>

          {/* Continue / Action Button */}
          <button
            disabled={!selectedPlace}
            onClick={handleContinue}
            className={`w-full h-14 rounded-full glowing-btn-blue flex items-center justify-between px-6 transition-all duration-300 ${
              selectedPlace 
                ? "opacity-100 scale-100 cursor-pointer" 
                : "opacity-45 scale-[0.98] cursor-not-allowed"
            }`}
          >
            <div className="flex items-center gap-2">
              <Sparkles className="size-4 text-blue-200 fill-blue-200/20" />
              <span className="text-base font-bold text-white tracking-wide">Continue</span>
            </div>
            <ArrowRight className="size-5 text-white" />
          </button>
        </div>

        {/* Apple iOS home indicator bar wrapper */}
        <div className="mx-auto mt-2 h-1 w-32 rounded-full bg-white/20" />
      </div>
    </div>
  );
}
