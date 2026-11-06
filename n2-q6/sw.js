// 第一次联网打开后缓存全部应用文件，之后断网也能继续使用。
const CACHE = 'jlpt-preview-n2-q6-2026-7-v4';
const CACHE_PREFIX = 'jlpt-preview-n2-q6-2026-7-';
const ASSETS = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith(CACHE_PREFIX) && key !== CACHE)
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  if (request.mode === 'navigate') {
    if (new URL(request.url).pathname.endsWith('/update.html')) {
      event.respondWith(fetch(request, { cache: 'no-store' }));
      return;
    }
    event.respondWith((async () => {
      const cache = await caches.open(CACHE);
      try {
        const response = await fetch(new Request(request, { cache: 'no-store' }));
        if (response && response.ok) cache.put('./index.html', response.clone());
        return response;
      } catch (error) {
        return (await cache.match('./index.html')) || Response.error();
      }
    })());
    return;
  }

  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const hit = await cache.match(request, { ignoreSearch: true });
    if (hit) return hit;

    try {
      const response = await fetch(request);
      if (response && response.ok) cache.put(request, response.clone());
      return response;
    } catch (error) {
      if (request.mode === 'navigate') return cache.match('./index.html');
      return Response.error();
    }
  })());
});
