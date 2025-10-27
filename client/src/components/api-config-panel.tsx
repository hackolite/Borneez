import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import { Settings, ChevronDown, Save } from "lucide-react";
import { cn } from "@/lib/utils";

interface ApiConfigPanelProps {
  endpoint: string;
  autoRefresh: boolean;
  refreshInterval: number;
  onSave: (config: {
    endpoint: string;
    autoRefresh: boolean;
    refreshInterval: number;
  }) => void;
  onTest?: () => void;
  isTestLoading?: boolean;
}

export function ApiConfigPanel({
  endpoint,
  autoRefresh,
  refreshInterval,
  onSave,
  onTest,
  isTestLoading = false,
}: ApiConfigPanelProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [localEndpoint, setLocalEndpoint] = useState(endpoint);
  const [localAutoRefresh, setLocalAutoRefresh] = useState(autoRefresh);
  const [localInterval, setLocalInterval] = useState(
    refreshInterval.toString()
  );

  const handleSave = () => {
    onSave({
      endpoint: localEndpoint,
      autoRefresh: localAutoRefresh,
      refreshInterval: parseInt(localInterval),
    });
  };

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <Card className="overflow-visible">
        <CollapsibleTrigger asChild>
          <button
            className="w-full p-6 flex items-center justify-between hover-elevate active-elevate-2 transition-all"
            data-testid="button-api-config-toggle"
          >
            <div className="flex items-center gap-3">
              <Settings className="w-5 h-5 text-muted-foreground" />
              <div className="text-left">
                <h3 className="text-lg font-semibold">API Configuration</h3>
                <p className="text-sm text-muted-foreground font-mono">
                  {endpoint || "No endpoint configured"}
                </p>
              </div>
            </div>
            <ChevronDown
              className={cn(
                "w-5 h-5 transition-transform text-muted-foreground",
                isOpen && "rotate-180"
              )}
            />
          </button>
        </CollapsibleTrigger>

        <CollapsibleContent>
          <div className="px-6 pb-6 space-y-6 border-t pt-6">
            <div className="space-y-2">
              <Label htmlFor="api-endpoint" className="text-sm font-medium">
                API Endpoint
              </Label>
              <Input
                id="api-endpoint"
                type="url"
                value={localEndpoint}
                onChange={(e) => setLocalEndpoint(e.target.value)}
                placeholder="http://raspberrypi.local:8000"
                className="font-mono text-sm"
                data-testid="input-api-endpoint"
              />
              <p className="text-xs text-muted-foreground">
                FastAPI relay controller endpoint URL
              </p>
            </div>

            <div className="flex items-center justify-between">
              <div className="space-y-1">
                <Label htmlFor="auto-refresh" className="text-sm font-medium">
                  Auto-Refresh Status
                </Label>
                <p className="text-xs text-muted-foreground">
                  Automatically poll relay states
                </p>
              </div>
              <Switch
                id="auto-refresh"
                checked={localAutoRefresh}
                onCheckedChange={setLocalAutoRefresh}
                data-testid="switch-auto-refresh"
              />
            </div>

            {localAutoRefresh && (
              <div className="space-y-2">
                <Label htmlFor="refresh-interval" className="text-sm font-medium">
                  Refresh Interval
                </Label>
                <Select
                  value={localInterval}
                  onValueChange={setLocalInterval}
                >
                  <SelectTrigger id="refresh-interval" data-testid="select-interval">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="2000">2 seconds</SelectItem>
                    <SelectItem value="5000">5 seconds</SelectItem>
                    <SelectItem value="10000">10 seconds</SelectItem>
                    <SelectItem value="30000">30 seconds</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}

            <div className="flex gap-3 pt-4">
              <Button
                onClick={handleSave}
                className="flex-1 gap-2"
                data-testid="button-save-config"
              >
                <Save className="w-4 h-4" />
                Save Configuration
              </Button>
              {onTest && (
                <Button
                  variant="outline"
                  onClick={onTest}
                  disabled={isTestLoading || !localEndpoint}
                  data-testid="button-test-connection"
                >
                  {isTestLoading ? "Testing..." : "Test Connection"}
                </Button>
              )}
            </div>
          </div>
        </CollapsibleContent>
      </Card>
    </Collapsible>
  );
}
