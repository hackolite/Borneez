import { useState, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient, apiRequest } from "@/lib/queryClient";
import { RelayCard } from "@/components/relay-card";
import { MasterControl } from "@/components/master-control";
import { ApiConfigPanel } from "@/components/api-config-panel";
import { ConnectionStatus } from "@/components/connection-status";
import { ThemeToggle } from "@/components/theme-toggle";
import { useToast } from "@/hooks/use-toast";
import { Building2 } from "lucide-react";
import type { Relay } from "@shared/schema";

export default function Dashboard() {
  const { toast } = useToast();
  const [apiEndpoint, setApiEndpoint] = useState<string>(
    () => localStorage.getItem("api-endpoint") || ""
  );
  const [autoRefresh, setAutoRefresh] = useState<boolean>(
    () => localStorage.getItem("auto-refresh") === "true"
  );
  const [refreshInterval, setRefreshInterval] = useState<number>(
    () => parseInt(localStorage.getItem("refresh-interval") || "5000")
  );

  const { data: relays, isLoading: relaysLoading } = useQuery<Relay[]>({
    queryKey: ["/api/relays"],
    refetchInterval: autoRefresh ? refreshInterval : false,
  });

  const { data: statusData, isLoading: statusLoading, error: statusError } = useQuery<{ 
    connected: boolean;
    pins?: number[];
  }>({
    queryKey: ["/api/status"],
    refetchInterval: autoRefresh ? refreshInterval : false,
    retry: 1,
  });

  const controlRelayMutation = useMutation({
    mutationFn: async ({
      gpio,
      state,
    }: {
      gpio: number;
      state: "on" | "off";
    }) => {
      return apiRequest("POST", "/api/relay", { gpio, state });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/relays"] });
      toast({
        title: "Success",
        description: "Relay state updated successfully",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message || "Failed to control relay",
        variant: "destructive",
      });
    },
  });

  const allOnMutation = useMutation({
    mutationFn: async () => {
      return apiRequest("POST", "/api/relay/all_on", {});
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/relays"] });
      toast({
        title: "Success",
        description: "All relays activated",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message || "Failed to activate all relays",
        variant: "destructive",
      });
    },
  });

  const allOffMutation = useMutation({
    mutationFn: async () => {
      return apiRequest("POST", "/api/relay/all_off", {});
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/relays"] });
      toast({
        title: "Success",
        description: "All relays deactivated",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message || "Failed to deactivate all relays",
        variant: "destructive",
      });
    },
  });

  const testConnectionMutation = useMutation({
    mutationFn: async () => {
      const response = await apiRequest("GET", "/api/status");
      return response.json();
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["/api/status"] });
      toast({
        title: "Connection Successful",
        description: `Connected to relay controller with ${data.pins?.length || 0} relays`,
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Connection Failed",
        description: error.message || "Could not connect to API endpoint",
        variant: "destructive",
      });
    },
  });

  const saveConfigMutation = useMutation({
    mutationFn: async (endpoint: string) => {
      return apiRequest("POST", "/api/config/endpoint", { endpoint });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/relays"] });
    },
  });

  const handleSaveConfig = async (config: {
    endpoint: string;
    autoRefresh: boolean;
    refreshInterval: number;
  }) => {
    localStorage.setItem("api-endpoint", config.endpoint);
    localStorage.setItem("auto-refresh", config.autoRefresh.toString());
    localStorage.setItem("refresh-interval", config.refreshInterval.toString());
    setApiEndpoint(config.endpoint);
    setAutoRefresh(config.autoRefresh);
    setRefreshInterval(config.refreshInterval);

    // Also save to backend
    try {
      await saveConfigMutation.mutateAsync(config.endpoint);
      toast({
        title: "Configuration Saved",
        description: "API settings have been updated",
      });
    } catch (error) {
      toast({
        title: "Warning",
        description: "Settings saved locally, but could not sync to server",
        variant: "destructive",
      });
    }
  };

  const handleToggleRelay = (gpio: number, newState: "on" | "off") => {
    controlRelayMutation.mutate({ gpio, state: newState });
  };

  const connectionStatus = statusData?.connected
    ? "connected"
    : statusError
    ? "disconnected"
    : statusLoading
    ? "connecting"
    : "disconnected";

  const lastUpdated = new Date().toLocaleTimeString();

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-50 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Building2 className="w-7 h-7 text-primary" />
            <h1 className="text-2xl font-bold">HubCity Control</h1>
          </div>
          <div className="flex items-center gap-6">
            <ConnectionStatus
              status={connectionStatus}
              lastUpdated={connectionStatus === "connected" ? lastUpdated : undefined}
            />
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main className="container mx-auto px-6 py-12 max-w-7xl">
        <div className="space-y-8">
          <div>
            <h2 className="text-4xl font-bold mb-2">Relay Management</h2>
            <p className="text-muted-foreground text-lg">
              Urban infrastructure control dashboard
            </p>
          </div>

          <ApiConfigPanel
            endpoint={apiEndpoint}
            autoRefresh={autoRefresh}
            refreshInterval={refreshInterval}
            onSave={handleSaveConfig}
            onTest={() => testConnectionMutation.mutate()}
            isTestLoading={testConnectionMutation.isPending}
          />

          <MasterControl
            onAllOn={() => allOnMutation.mutate()}
            onAllOff={() => allOffMutation.mutate()}
            isLoading={
              allOnMutation.isPending || allOffMutation.isPending
            }
          />

          <div>
            <h3 className="text-2xl font-semibold mb-6">Active Relays</h3>
            {relaysLoading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="h-64 bg-card rounded-lg animate-pulse"
                  />
                ))}
              </div>
            ) : relays && relays.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {relays.map((relay) => (
                  <RelayCard
                    key={relay.gpio}
                    gpio={relay.gpio}
                    name={relay.name}
                    state={relay.state}
                    lastUpdated={relay.lastUpdated}
                    onToggle={handleToggleRelay}
                    isLoading={controlRelayMutation.isPending}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-16 bg-card rounded-lg border-2 border-dashed">
                <Building2 className="w-16 h-16 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-xl font-semibold mb-2">No Relays Found</h3>
                <p className="text-muted-foreground">
                  Configure your API endpoint to connect to your relay controller
                </p>
              </div>
            )}
          </div>
        </div>
      </main>

      <footer className="border-t mt-16">
        <div className="container mx-auto px-6 py-6">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-muted-foreground">
            <div className="font-mono">
              HubCity Control v1.0 • Urban Infrastructure Management
            </div>
            <div className="font-mono">
              Last Updated: {new Date().toLocaleString()}
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
