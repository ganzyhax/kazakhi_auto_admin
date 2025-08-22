'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "0ade00116a773f5e7f4b65f0c2d7ade8",
"version.json": "7288e6731fd346eade32a7903bfb6e29",
"index.html": "191cf02fb3529f83db6d31c61ead3927",
"/": "191cf02fb3529f83db6d31c61ead3927",
"main.dart.js": "727bfefad45a76540b5dbcb2b6f903ee",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "ff4b9ecc6f6a4b08aa368908b2ec9209",
"assets/AssetManifest.json": "86299f8e53d4a351a16f71b9c42bcf84",
"assets/NOTICES": "b0760a187245400390a27043c75ef215",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "b92d3daf6c6b5930c3b7c610bfe6d499",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "3f063d98ed17b348f409b1f3ca8a7af9",
"assets/fonts/MaterialIcons-Regular.otf": "4f0f8e14a9e6ad4661439d7dad3488c8",
"assets/assets/images/tg.png": "ea93f70a4e4766a572fc738928abdda2",
"assets/assets/images/car_home.png": "9d6a3789b58ed9f03fb380ecfd5c6b42",
"assets/assets/images/ar.png": "2850d7df0e7396ca8a3a4f81c140306f",
"assets/assets/images/tr.png": "90dd1c61f81f6a38e4145afa97fceeaf",
"assets/assets/images/logo_bg.jpg": "5afb77e29ec2af2a42dea9df3a083d1f",
"assets/assets/images/pl.png": "b44343f8081737a4dc8d63bb4522d252",
"assets/assets/images/en.png": "756b8fc61f04c9d22e57145b0b9e6672",
"assets/assets/images/ru.png": "7121b498dd598b2a193366bd2f4775aa",
"assets/assets/images/ka.png": "7e7c6bd93c8de8078d000ff94316d640",
"assets/assets/images/black_car.png": "72ef026a10aaace1611d7a39e19e2eb0",
"assets/assets/images/car_crash.png": "e5e42af31147c406a1e0c84714e3b031",
"assets/assets/images/hy.png": "151ba78ed32207115222f64184d89805",
"assets/assets/images/ky.png": "cac87ebcff0d2e183e02afbf9821702c",
"assets/assets/images/logo_white.jpg": "647667d35b89194f0ac68a0a790bcca9",
"assets/assets/images/kk.png": "3e5106b11cd7038d8ba46536722e3a1b",
"assets/assets/images/play_market.png": "9e5cad97543c1b67a134f053ee58ee61",
"assets/assets/images/vin_info.png": "2baaf676c44af0b537fe040d541b194f",
"assets/assets/images/uk.png": "a6c51c334d91147c266ab594c48d951a",
"assets/assets/images/az.png": "5980af6e48f00032f264971b9e26040c",
"assets/assets/images/be.png": "bfcb1d12dcd1642c48b62f51720b58d5",
"assets/assets/images/app_store.png": "0a170404b3867dc22d090907dcd5f63b",
"assets/assets/images/uz.png": "802da170bbdb54cce0a781ffa3df8990",
"assets/assets/images/tk.png": "6ccdc3a7477f22bd4756512a3472bf83",
"assets/assets/icons/list.svg": "107dbe69aece164ce6d186d18e3018f9",
"assets/assets/icons/car_nav.svg": "79d240780fdc74021246b0729f1507dd",
"assets/assets/icons/speed.svg": "55ad8c26268570a0a0883219195d90db",
"assets/assets/icons/user_nav.svg": "c56e1732f7585a752d53a4722de49300",
"assets/assets/icons/instagram.svg": "2fa21f6fce030076be9d89dd85496a56",
"assets/assets/icons/kuzov.svg": "17e58d6817ff7bd014a5e3d19bbc8f71",
"assets/assets/icons/engine_main.svg": "d2270234398a732b98a483e5843c2f2f",
"assets/assets/icons/engine.svg": "171a892b0a5a8fddd05d5cddf361e870",
"assets/assets/icons/static.svg": "a677479331f0238f009fd8f51a72310d",
"assets/assets/icons/open_book.svg": "b0ca9c43d14f67f2d62161f9bade89f5",
"assets/assets/icons/files_nav.svg": "873023a6a71933196ad4c133def6db68",
"assets/assets/icons/images.svg": "887494e71f0587f1276c579b18b47331",
"assets/assets/icons/wheels.svg": "b248b12f4e95fd071690273a4c55c008",
"assets/assets/icons/car_with_man.svg": "4ae50ce7f97314513ad0edd9193b6f09",
"assets/assets/icons/clearvin_icon.svg": "04950972b3d311d98797fe8b423aa68f",
"assets/assets/icons/whatsapp.svg": "afd827ab4873518fed0e74b66535a53e",
"assets/assets/icons/peoples.svg": "26adf775dfba08faccc7e1c37f2c7009",
"assets/assets/icons/crash.svg": "112882e752a6c99b8cee1bedd5780fc0",
"assets/assets/icons/car.svg": "533daf978b31cf4b0e4661677e35c381",
"assets/assets/icons/handshake.svg": "da4273a0e70eaf1f1537c9989f20dffd",
"assets/assets/icons/history.svg": "369913997365519d1239aad849d744bf",
"assets/assets/icons/price.svg": "878ab90d50d2e07b2be07f3cf85dc12b",
"assets/assets/files/single.html": "f3b4cfa7268d82638c8ea53733f6535c",
"assets/assets/files/preview.pdf": "41c066ab174040e473cf82f1b55fe87a",
"assets/assets/translations/hy.json": "7820168dd1d019249afc50c1064eb14e",
"assets/assets/translations/tr.json": "a3ce2a9307109e13578080eca7395434",
"assets/assets/translations/kk.json": "f316d0585892cb174d3c4cf430290575",
"assets/assets/translations/ru.json": "826fdd60a6a22c57765014c52e560598",
"assets/assets/translations/pl.json": "040cad92fba395b211a39a3c7c7ccfdb",
"assets/assets/translations/uk.json": "a0838f67e21ab1867356ef139cfbb46a",
"assets/assets/translations/ky.json": "338283a23107a4b0809e3865f2e205a8",
"assets/assets/translations/az.json": "91a9424810bb13b88edec480a53d6631",
"assets/assets/translations/be.json": "7d5058fd7face743b99b7dfd6bdae801",
"assets/assets/translations/en.json": "c0a29bb8435128d1c4146ef2a34ba5b7",
"assets/assets/translations/ka.json": "b3de913604bc71be8ae1e2a9924e66ff",
"assets/assets/translations/uz.json": "1973439092f42a437f14b18ea7aa138c",
"assets/assets/translations/ar.json": "ddf4efe5d8182e9b56191387048a4763",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
  var origin = self.location.origin;
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
