import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { relayCommandSchema } from "@shared/schema";
import { z } from "zod";

export async function registerRoutes(app: Express): Promise<Server> {
  // Helper function to make requests to external FastAPI with timeout
  const callExternalApi = async (
    endpoint: string,
    method: string = "GET",
    body?: any
  ) => {
    const apiEndpoint = await storage.getApiEndpoint();
    if (!apiEndpoint) {
      throw new Error(
        "API endpoint not configured. Please configure the endpoint in the dashboard."
      );
    }

    const url = `${apiEndpoint}${endpoint}`;
    
    // Create an AbortController for timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout
    
    const options: RequestInit = {
      method,
      headers: {
        "Content-Type": "application/json",
      },
      signal: controller.signal,
    };

    if (body) {
      options.body = JSON.stringify(body);
    }

    try {
      const response = await fetch(url, options);
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        throw new Error(`API request failed: ${response.statusText}`);
      }
      return response.json();
    } catch (error: any) {
      clearTimeout(timeoutId);
      
      // Handle specific error types
      if (error.name === 'AbortError') {
        throw new Error('Request timeout: Unable to reach GPIO controller. Please check if the backend is running.');
      }
      
      // Handle connection errors
      if (error.code === 'ECONNREFUSED' || error.cause?.code === 'ECONNREFUSED') {
        throw new Error('Connection refused: GPIO controller is not reachable. Please verify the endpoint URL and ensure the backend is running.');
      }
      
      if (error.code === 'ENOTFOUND' || error.cause?.code === 'ENOTFOUND') {
        throw new Error('Host not found: Invalid GPIO controller endpoint. Please check the endpoint URL.');
      }
      
      // Re-throw the original error if it's not a connection issue
      throw error;
    }
  };

  // Get current API endpoint
  app.get("/api/config/endpoint", async (req, res) => {
    try {
      const endpoint = await storage.getApiEndpoint();
      res.json({ endpoint });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  // Update API endpoint
  app.post("/api/config/endpoint", async (req, res) => {
    try {
      const { endpoint } = req.body;
      if (!endpoint || typeof endpoint !== "string") {
        return res.status(400).json({ error: "Invalid endpoint" });
      }
      await storage.setApiEndpoint(endpoint);
      res.json({ success: true, endpoint });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  // Get all relays status (proxied from external API)
  app.get("/api/relays", async (req, res) => {
    try {
      const apiEndpoint = await storage.getApiEndpoint();
      
      if (!apiEndpoint) {
        // Return local state if no endpoint configured
        const relays = await storage.getRelays();
        return res.json(relays);
      }

      // Return local cached state (updated by control operations)
      // The FastAPI controller doesn't provide a status endpoint for all relays
      // so we track state locally based on control commands
      const relays = await storage.getRelays();
      res.json(relays);
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  // Get API status (test connection)
  app.get("/api/status", async (req, res) => {
    try {
      const apiEndpoint = await storage.getApiEndpoint();
      
      if (!apiEndpoint) {
        return res.status(500).json({
          error: "API endpoint not configured",
          connected: false,
        });
      }

      // Try to connect to external API
      const result = await callExternalApi("/");
      
      // Extract pins if available, otherwise use default
      const pins = result?.pins || [17, 27, 22, 23];
      
      res.json({ 
        connected: true,
        message: result?.message || "API connected",
        pins
      });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Connection failed",
        connected: false,
      });
    }
  });

  // Control individual relay
  app.post("/api/relay", async (req, res) => {
    try {
      const validated = relayCommandSchema.parse(req.body);

      // Call external API
      const result = await callExternalApi("/relay", "POST", validated);

      // Update local state only if external call succeeded
      const updatedRelay = await storage.updateRelayState(
        validated.gpio,
        validated.state
      );

      res.json({ ...result, relay: updatedRelay });
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({ error: "Invalid request data", details: error.errors });
      } else {
        res.status(500).json({
          error: error instanceof Error ? error.message : "Failed to control relay",
        });
      }
    }
  });

  // Turn all relays on
  app.post("/api/relay/all_on", async (req, res) => {
    try {
      // Call external API
      const result = await callExternalApi("/relay/all_on", "POST");

      // Update local state
      const updatedRelays = await storage.updateAllRelaysState("on");

      res.json({ ...result, relays: updatedRelays });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Failed to activate all relays",
      });
    }
  });

  // Turn all relays off
  app.post("/api/relay/all_off", async (req, res) => {
    try {
      // Call external API
      const result = await callExternalApi("/relay/all_off", "POST");

      // Update local state
      const updatedRelays = await storage.updateAllRelaysState("off");

      res.json({ ...result, relays: updatedRelays });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : "Failed to deactivate all relays",
      });
    }
  });

  const httpServer = createServer(app);

  return httpServer;
}
