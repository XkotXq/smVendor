// Serves the web build statically: `node tool/serve_web.cjs`, then open
// http://localhost:8765 (or the machine's LAN address from a tablet).
//
// Lives here rather than inside build/web because `flutter build web` wipes
// that directory, which took the script with it every time.
//
// A plain static server on purpose: `flutter run -d chrome|edge|web-server`
// hangs on this machine at "Waiting for connection from debug service", so
// build-then-serve is the documented route (see AGENTS.md, "Running it").
const http = require("http");
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..", "build", "web");
const port = Number(process.env.PORT ?? 8765);

const MIME = {
  ".html": "text/html",
  ".js": "application/javascript",
  ".mjs": "application/javascript",
  ".json": "application/json",
  ".css": "text/css",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".wasm": "application/wasm",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".webmanifest": "application/manifest+json",
};

if (!fs.existsSync(path.join(root, "index.html"))) {
  console.error("No build found in " + root + "\nRun: flutter build web --dart-define=API_TOKEN=...");
  process.exit(1);
}

http
  .createServer((req, res) => {
    let urlPath = decodeURIComponent(req.url.split("?")[0]);
    if (urlPath === "/") urlPath = "/index.html";
    const filePath = path.join(root, urlPath);
    if (!filePath.startsWith(root)) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    fs.readFile(filePath, (err, data) => {
      if (err) {
        // SPA-style fallback - Flutter web's own router handles the path.
        fs.readFile(path.join(root, "index.html"), (err2, data2) => {
          if (err2) {
            res.writeHead(404);
            res.end("Not found");
            return;
          }
          // Never cached: the whole point of serving this is to look at the
          // build that was just made, and a stale index.html pins the app to
          // an old main.dart.js for as long as the tab lives.
          res.writeHead(200, { "Content-Type": "text/html", "Cache-Control": "no-store" });
          res.end(data2);
        });
        return;
      }
      const ext = path.extname(filePath);
      const headers = { "Content-Type": MIME[ext] || "application/octet-stream" };
      if (ext === ".html" || ext === ".json" || ext === ".webmanifest") headers["Cache-Control"] = "no-store";
      res.writeHead(200, headers);
      res.end(data);
    });
  })
  .listen(port, () => {
    console.log("Serving smVendor web build at http://localhost:" + port);
  });
