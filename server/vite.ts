import express, { type Express } from "express";
import fs from "fs";
import path from "path";
import { createServer as createViteServer, createLogger } from "vite";
import { type Server } from "http";
import viteConfig from "../vite.config";
import { nanoid } from "nanoid";

const viteLogger = createLogger();

export function log(message: string, source = "express") {
  const formattedTime = new Date().toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  });

  console.log(`${formattedTime} [${source}] ${message}`);
}

export async function setupVite(app: Express, server: Server) {
  const serverOptions = {
    middlewareMode: true,
    hmr: { server },
    allowedHosts: true as const,
  };

  const vite = await createViteServer({
    ...viteConfig,
    configFile: false,
    customLogger: {
      ...viteLogger,
      error: (msg, options) => {
        viteLogger.error(msg, options);
        process.exit(1);
      },
    },
    server: serverOptions,
    appType: "custom",
  });

  app.use(vite.middlewares);
  app.use("*", async (req, res, next) => {
    const url = req.originalUrl;

    try {
      const clientTemplate = path.resolve(
        import.meta.dirname,
        "..",
        "client",
        "index.html",
      );

      // always reload the index.html file from disk incase it changes
      let template = await fs.promises.readFile(clientTemplate, "utf-8");
      template = template.replace(
        `src="/src/main.tsx"`,
        `src="/src/main.tsx?v=${nanoid()}"`,
      );
      const page = await vite.transformIndexHtml(url, template);
      res.status(200).set({ "Content-Type": "text/html" }).end(page);
    } catch (e) {
      vite.ssrFixStacktrace(e as Error);
      next(e);
    }
  });
}

export function serveStatic(app: Express) {
  const distPath = path.resolve(import.meta.dirname, "public");

  if (!fs.existsSync(distPath)) {
    log(`Build directory not found: ${distPath}`, "express");
    log("Frontend not built yet. Please run 'npm run build' first.", "express");
    
    // Serve a helpful error page instead of crashing
    app.use("*", (_req, res) => {
      res.status(503).send(`
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Borneez - Build Required</title>
            <style>
              body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
              }
              .container {
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                padding: 40px;
                max-width: 600px;
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
              }
              h1 {
                font-size: 2.5em;
                margin: 0 0 20px 0;
              }
              p {
                font-size: 1.2em;
                line-height: 1.6;
                margin: 15px 0;
              }
              code {
                background: rgba(0, 0, 0, 0.3);
                padding: 15px;
                border-radius: 8px;
                display: block;
                margin: 20px 0;
                font-family: 'Courier New', monospace;
                font-size: 0.9em;
              }
              .warning {
                background: rgba(255, 193, 7, 0.2);
                border-left: 4px solid #ffc107;
                padding: 15px;
                border-radius: 4px;
                margin: 20px 0;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>🚧 Build Required</h1>
              <p>The Borneez frontend application has not been built yet.</p>
              
              <div class="warning">
                <strong>⚠️ Action Required:</strong> Please build the application before starting in production mode.
              </div>
              
              <p>Run the following command on your Raspberry Pi:</p>
              <code>npm run build</code>
              
              <p>Then restart the server:</p>
              <code>sudo PORT=80 npm start</code>
              
              <p style="margin-top: 30px; font-size: 0.9em; opacity: 0.8;">
                For development mode (no build required), use:<br>
                <code style="font-size: 0.85em; margin-top: 10px;">./start-dev.sh</code>
              </p>
            </div>
          </body>
        </html>
      `);
    });
    return;
  }

  app.use(express.static(distPath));

  // fall through to index.html if the file doesn't exist
  app.use("*", (_req, res) => {
    res.sendFile(path.resolve(distPath, "index.html"));
  });
}
