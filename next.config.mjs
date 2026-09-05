import withPWA from 'next-pwa'

const isDev = process.env.NODE_ENV === 'development'

/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: false,
  },
  images: {
    unoptimized: true,
  },
  // Proxy all /api/* requests to the PHP backend (avoids CORS in production)
  async rewrites() {
    const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost/flowtive-central'
    return [
      {
        source: '/backend/:path*',
        destination: `${backendUrl}/api/:path*`,
      },
    ]
  },
}

export default withPWA({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: isDev,                  // No SW in dev — avoids cache confusion
  runtimeCaching: [
    {
      // Cache API responses for 5 minutes (network-first)
      urlPattern: /^https?:\/\/.*\/api\/.*/i,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'flowtive-api-cache',
        expiration: { maxEntries: 100, maxAgeSeconds: 300 },
        networkTimeoutSeconds: 10,
      },
    },
    {
      // Cache static assets forever (cache-first)
      urlPattern: /\.(?:js|css|woff2?|png|jpg|jpeg|svg|ico)$/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'flowtive-static-cache',
        expiration: { maxEntries: 200, maxAgeSeconds: 86400 * 30 },
      },
    },
    {
      // Cache pages (stale-while-revalidate)
      urlPattern: /^https?:\/\/.*/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'flowtive-page-cache',
        expiration: { maxEntries: 50, maxAgeSeconds: 3600 },
      },
    },
  ],
})(nextConfig)
