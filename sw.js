
const CACHE_NAME = "sale-central-shell-v1";

const APP_FILES = [
  "./",
  "./index.html",
  "./manifest.webmanifest"
];

const CDN_FILES = [
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2",
  "https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js",
  "https://unpkg.com/html5-qrcode"
];

self.addEventListener("install", (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(APP_FILES);

    await Promise.allSettled(
      CDN_FILES.map((url) => cache.add(url))
    );

    await self.skipWaiting();
  })());
});

self.addEventListener("activate", (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();

    await Promise.all(
      keys
        .filter(
          (key) =>
            key.startsWith("sale-central-") &&
            key !== CACHE_NAME
        )
        .map((key) => caches.delete(key))
    );

    await self.clients.claim();
  })());
});

self.addEventListener("fetch", (event) => {
  const request = event.request;

  if (request.method !== "GET") return;

  const url = new URL(request.url);

  if (url.origin === self.location.origin) {
    event.respondWith((async () => {
      try {
        const response = await fetch(request);

        if (response && response.ok) {
          const cache = await caches.open(CACHE_NAME);
          cache.put(request, response.clone());
        }

        return response;
      } catch (error) {
        const cached = await caches.match(request);

        if (cached) return cached;

        if (request.mode === "navigate") {
          return (
            (await caches.match("./index.html")) ||
            new Response(
              "Sale Central is not available offline yet. Open it online once first.",
              {
                status: 503,
                headers: {
                  "Content-Type": "text/plain; charset=utf-8"
                }
              }
            )
          );
        }

        return new Response("", {
          status: 503,
          statusText: "Offline"
        });
      }
    })());

    return;
  }

  if (CDN_FILES.some((item) => url.href.startsWith(item))) {
    event.respondWith((async () => {
      const cache = await caches.open(CACHE_NAME);
      const cached = await cache.match(request);

      if (cached) return cached;

      try {
        const response = await fetch(request);

        if (response && response.ok) {
          cache.put(request, response.clone());
        }

        return response;
      } catch (error) {
        return cached || new Response("", {
          status: 503,
          statusText: "Offline"
        });
      }
    })());
  }
});
