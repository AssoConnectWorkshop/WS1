import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  turbopack: {},
  images: {
    formats: ["image/avif", "image/webp"],
  },
  experimental: {
    // Pas encore dans les types de cette version de Next ; flag reconnu au runtime (cf. build log).
    nodeMiddleware: true,
  } as NextConfig["experimental"],
};

export default nextConfig;
