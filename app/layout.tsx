import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "weReach",
  description: "Destination alarm and GPS arrival tracking app.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "weReach",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#F7FBF8",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body
        className={`${geistSans.variable} ${geistMono.variable} min-h-screen overflow-hidden bg-[#090d16] text-foreground antialiased`}
      >
        {/* Sleek desktop grid overlay */}
        <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff03_1px,transparent_1px),linear-gradient(to_bottom,#ffffff03_1px,transparent_1px)] bg-[size:24px_24px] pointer-events-none z-0" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.06),transparent_60%)] pointer-events-none z-0" />
        
        <div className="relative z-10 mx-auto flex h-[100dvh] w-full max-w-md flex-col overflow-hidden bg-background shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8)] transition-all duration-300 md:my-[5vh] md:h-[90vh] md:rounded-[2.5rem] md:border md:border-white/10">
           {children}
        </div>
      </body>
    </html>
  );
}
