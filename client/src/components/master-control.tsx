import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Power, PowerOff } from "lucide-react";

interface MasterControlProps {
  onAllOn: () => void;
  onAllOff: () => void;
  isLoading?: boolean;
}

export function MasterControl({
  onAllOn,
  onAllOff,
  isLoading = false,
}: MasterControlProps) {
  return (
    <Card className="p-6">
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
        <div className="flex-1">
          <h3 className="text-lg font-semibold mb-1">Master Control</h3>
          <p className="text-sm text-muted-foreground">
            Control all relays simultaneously
          </p>
        </div>
        <div className="flex gap-4">
          <Button
            size="lg"
            onClick={onAllOn}
            disabled={isLoading}
            className="flex-1 sm:flex-none px-8 gap-2"
            data-testid="button-all-on"
          >
            <Power className="w-5 h-5" />
            ALL ON
          </Button>
          <Button
            size="lg"
            variant="secondary"
            onClick={onAllOff}
            disabled={isLoading}
            className="flex-1 sm:flex-none px-8 gap-2"
            data-testid="button-all-off"
          >
            <PowerOff className="w-5 h-5" />
            ALL OFF
          </Button>
        </div>
      </div>
    </Card>
  );
}
