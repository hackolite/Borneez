import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { Power } from "lucide-react";
import { cn } from "@/lib/utils";

interface RelayCardProps {
  gpio: number;
  name: string;
  state: "on" | "off";
  lastUpdated?: string;
  onToggle: (gpio: number, newState: "on" | "off") => void;
  isLoading?: boolean;
}

export function RelayCard({
  gpio,
  name,
  state,
  lastUpdated,
  onToggle,
  isLoading = false,
}: RelayCardProps) {
  const isActive = state === "on";

  return (
    <Card
      className={cn(
        "p-8 transition-all duration-300 relative overflow-visible",
        isActive && "ring-2 ring-primary/50"
      )}
      data-testid={`card-relay-${gpio}`}
    >
      {isActive && (
        <div className="absolute inset-0 bg-primary/5 rounded-lg pointer-events-none animate-pulse" />
      )}

      <div className="relative z-10 flex flex-col gap-6">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <div
              className={cn(
                "w-12 h-12 rounded-lg flex items-center justify-center transition-colors",
                isActive ? "bg-primary/20" : "bg-muted"
              )}
            >
              <Power
                className={cn(
                  "w-6 h-6 transition-colors",
                  isActive ? "text-primary" : "text-muted-foreground"
                )}
              />
            </div>
            <div>
              <div className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                GPIO
              </div>
              <div className="text-3xl font-mono font-bold" data-testid={`text-gpio-${gpio}`}>
                {gpio}
              </div>
            </div>
          </div>

          <Badge
            variant={isActive ? "default" : "secondary"}
            className="uppercase text-xs font-semibold tracking-wider px-3 py-1"
            data-testid={`badge-status-${gpio}`}
          >
            {isActive ? "ACTIVE" : "INACTIVE"}
          </Badge>
        </div>

        <div className="space-y-4">
          <div>
            <div className="text-xl font-semibold" data-testid={`text-name-${gpio}`}>
              {name}
            </div>
            {lastUpdated && (
              <div className="text-xs font-mono text-muted-foreground mt-1" data-testid={`text-updated-${gpio}`}>
                {lastUpdated}
              </div>
            )}
          </div>

          <div className="flex items-center justify-between pt-4 border-t">
            <span className="text-sm font-medium text-muted-foreground">
              Control
            </span>
            <Switch
              checked={isActive}
              onCheckedChange={(checked) => {
                onToggle(gpio, checked ? "on" : "off");
              }}
              disabled={isLoading}
              className="data-[state=checked]:bg-primary"
              data-testid={`switch-relay-${gpio}`}
            />
          </div>
        </div>
      </div>
    </Card>
  );
}
