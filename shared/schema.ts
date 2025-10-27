import { z } from "zod";

// Relay data model
export const relaySchema = z.object({
  gpio: z.number(),
  name: z.string(),
  state: z.enum(["on", "off"]),
  lastUpdated: z.string().optional(),
});

export const relayCommandSchema = z.object({
  gpio: z.number(),
  state: z.enum(["on", "off"]),
});

export const apiConfigSchema = z.object({
  endpoint: z.string().url(),
  autoRefresh: z.boolean(),
  refreshInterval: z.number().min(1000).max(30000),
});

export type Relay = z.infer<typeof relaySchema>;
export type RelayCommand = z.infer<typeof relayCommandSchema>;
export type ApiConfig = z.infer<typeof apiConfigSchema>;

// API Response types
export type RelayResponse = {
  gpio: number;
  state: string;
  error?: string;
};

export type AllRelaysResponse = {
  message: string;
};

export type ApiStatusResponse = {
  message: string;
  pins: number[];
};
