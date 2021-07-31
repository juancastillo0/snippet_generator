'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/assets/images/GitHub-Mark-64px.png": "438c17272c5f0e9f4a6da34d3e4bc5bd",
"assets/AssetManifest.json": "afa4391c2be4c0ec3cf6e9f2ddf15747",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/google_fonts/NunitoSans-BoldItalic.ttf": "655ce9395fcf8c21f45cfeca5bb280a4",
"assets/google_fonts/NunitoSans-ExtraBold.ttf": "505a059580cfbeaccdcb7a489bb67ec9",
"assets/google_fonts/OFL.txt": "4e3d9becbf87c0341298fadf87ae4d36",
"assets/google_fonts/NunitoSans-Black.ttf": "d95152ab5a160491d28b3fce25bf4ff2",
"assets/google_fonts/Cousine-BoldItalic.ttf": "1038b5579146b28e9e4dc98c8fc5d1d9",
"assets/google_fonts/Cousine-Bold.ttf": "06dae6a1a3247bd76125cfe3b3480557",
"assets/google_fonts/Cousine-Italic.ttf": "177a3d2157da07498e805683e8cdaa8d",
"assets/google_fonts/NunitoSans-SemiBold.ttf": "bd318b58018198a57723f311627492ac",
"assets/google_fonts/LICENSE.txt": "3b83ef96387f14655fc854ddc3c6bd57",
"assets/google_fonts/Cousine-Regular.ttf": "64a889644e439ac4806c8e41bc9d1c83",
"assets/google_fonts/NunitoSans-ExtraLightItalic.ttf": "cf8d9c6c81866d3bdfc1f08d6ea80d8d",
"assets/google_fonts/NunitoSans-Italic.ttf": "2d517b40dabe232416b73e3a721dc950",
"assets/google_fonts/NunitoSans-Light.ttf": "74d36921be67fb8482bfd7324bd86790",
"assets/google_fonts/NunitoSans-LightItalic.ttf": "d395ff0f45e6b030608de646ec278a35",
"assets/google_fonts/NunitoSans-SemiBoldItalic.ttf": "b16342e303cde3bafe2d8746be885ca2",
"assets/google_fonts/NunitoSans-ExtraBoldItalic.ttf": "2ae455ab84d04fec2d436151e712848f",
"assets/google_fonts/NunitoSans-BlackItalic.ttf": "75ec9078a3f7472f3cdee1d312a390a2",
"assets/google_fonts/NunitoSans-Bold.ttf": "08e53a516d2ba719d98da46c49b3c369",
"assets/google_fonts/NunitoSans-Regular.ttf": "4c8f447011eef80831b45edb1e5971e0",
"assets/google_fonts/NunitoSans-ExtraLight.ttf": "6aea75496b0ccb484d81a97920d2e64c",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/NOTICES": "67359bf1eeae5c1e0b4d5d13bc79db03",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"canvaskit_0.27.0/full/canvaskit.js": "6e6d7a4be45a3ce9474c851c1361c566",
"canvaskit_0.27.0/full/canvaskit.wasm": "839bccd1dc1e0376519953a273d84559",
"canvaskit_0.27.0/profiling/canvaskit.js": "e688a5e10b47ff2872abb8b530cb79f5",
"canvaskit_0.27.0/profiling/canvaskit.wasm": "fe6eecbad0854ed2cfadd652e9709484",
"canvaskit_0.27.0/canvaskit.js": "5a041372c2d254ef7b0d6545c87e7fc6",
"canvaskit_0.27.0/canvaskit.wasm": "a4a607e2d11af93cba9b1cba37cad5bd",
"manifest.json": "16a28f96f9b8bcebc47bd6476d94c2ee",
"canvaskit_0.28.1/full/canvaskit.js": "a14485d0b10aab99a2c105b164f8d0f0",
"canvaskit_0.28.1/full/canvaskit.wasm": "bc173722c9a25e0d9217e419e454bf96",
"canvaskit_0.28.1/profiling/canvaskit.js": "7e671cf059b389ce2e723ba2106bd0f3",
"canvaskit_0.28.1/profiling/canvaskit.wasm": "3d45442c520e5c8f13dcacd24c64ce0f",
"canvaskit_0.28.1/canvaskit.js": "310f62861c06dbb592838bee033072eb",
"canvaskit_0.28.1/canvaskit.wasm": "94da52ff225af2ee7b498ca694692a1f",
"version.json": "479ca84fb350de76102ed1d9911e3d0a",
"main.dart.js": "afac68a0ad6ac94fe69d2ea2122b5043",
"index.html": "16f1c4d0eadc9bb057ed1548a0706b3f",
"/": "16f1c4d0eadc9bb057ed1548a0706b3f"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = (self.location.origin + "/snippet_generator");
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = (self.location.origin + "/snippet_generator");
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
