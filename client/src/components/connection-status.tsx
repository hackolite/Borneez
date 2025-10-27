import { cn } from "@/lib/utils";
import { CheckCircle2, XCircle, Loader2 } from "lucide-react";

interface ConnectionStatusProps {
  status: "connected" | "disconnected" | "connecting";
  lastUpdated?: string;
}

export function ConnectionStatus({
  status,
  lastUpdated,
}: ConnectionStatusProps) {
  return (
    <div className="flex items-center gap-2" data-testid="status-connection">
      {status === "connected" && (
        <>
          <div className="relative">
            <CheckCircle2 className="w-4 h-4 text-green-500" />
            <div className="absolute inset-0 bg-green-500 rounded-full animate-ping opacity-25" />
          </div>
          <div className="text-sm">
            <span className="font-medium text-green-500">Connected</span>
            {lastUpdated && (
              <span className="text-xs text-muted-foreground ml-2 font-mono">
                {lastUpdated}
              </span>
            )}
          </div>
        </>
      )}
      {status === "disconnected" && (
        <>
          <XCircle className="w-4 h-4 text-destructive" />
          <span className="text-sm font-medium text-destructive">
            Disconnected
          </span>
        </>
      )}
      {status === "connecting" && (
        <>
          <Loader2 className="w-4 h-4 text-primary animate-spin" />
          <span className="text-sm font-medium text-primary">Connecting...</span>
        </>
      )}
    </div>
  );
}
