import { type Relay } from "@shared/schema";

export interface IStorage {
  getRelays(): Promise<Relay[]>;
  getRelay(gpio: number): Promise<Relay | undefined>;
  updateRelayState(gpio: number, state: "on" | "off"): Promise<Relay>;
  updateAllRelaysState(state: "on" | "off"): Promise<Relay[]>;
  getApiEndpoint(): Promise<string>;
  setApiEndpoint(endpoint: string): Promise<void>;
}

export class MemStorage implements IStorage {
  private relays: Map<number, Relay>;
  private apiEndpoint: string;

  constructor() {
    this.relays = new Map();
    this.apiEndpoint = process.env.RELAY_API_ENDPOINT || "";
    
    // Initialize with default GPIO pins
    const defaultPins = [17, 27, 22, 23];
    defaultPins.forEach((pin, index) => {
      this.relays.set(pin, {
        gpio: pin,
        name: `Relay ${index + 1}`,
        state: "off",
        lastUpdated: new Date().toLocaleTimeString(),
      });
    });
  }

  async getRelays(): Promise<Relay[]> {
    return Array.from(this.relays.values());
  }

  async getRelay(gpio: number): Promise<Relay | undefined> {
    return this.relays.get(gpio);
  }

  async updateRelayState(gpio: number, state: "on" | "off"): Promise<Relay> {
    const relay = this.relays.get(gpio);
    if (!relay) {
      throw new Error(`GPIO ${gpio} not found`);
    }
    const updated = {
      ...relay,
      state,
      lastUpdated: new Date().toLocaleTimeString(),
    };
    this.relays.set(gpio, updated);
    return updated;
  }

  async updateAllRelaysState(state: "on" | "off"): Promise<Relay[]> {
    const updated: Relay[] = [];
    const entries = Array.from(this.relays.entries());
    for (const [gpio, relay] of entries) {
      const updatedRelay = {
        ...relay,
        state,
        lastUpdated: new Date().toLocaleTimeString(),
      };
      this.relays.set(gpio, updatedRelay);
      updated.push(updatedRelay);
    }
    return updated;
  }

  async getApiEndpoint(): Promise<string> {
    return this.apiEndpoint;
  }

  async setApiEndpoint(endpoint: string): Promise<void> {
    this.apiEndpoint = endpoint;
  }
}

export const storage = new MemStorage();
