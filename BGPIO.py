from fastapi import FastAPI
import RPi.GPIO as GPIO
from pydantic import BaseModel
from typing import List
from contextlib import asynccontextmanager

# --- Configuration GPIO ---
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# --- Classe de gestion des relais ---
class RelayController:
    def __init__(self, pins, active_low=True):
        self.pins = pins
        self.active_low = active_low
        self.ACTIVE = GPIO.LOW if active_low else GPIO.HIGH
        self.INACTIVE = GPIO.HIGH if active_low else GPIO.LOW

        for pin in self.pins:
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, self.INACTIVE)

    def control(self, pin, state):
        if pin not in self.pins:
            return {"error": f"GPIO {pin} non déclaré."}

        if state == "on":
            GPIO.output(pin, self.ACTIVE)
            print(f"GPIO {pin}: HIGH (ON)")
        elif state == "off":
            GPIO.output(pin, self.INACTIVE)
            print(f"GPIO {pin}: LOW (OFF)")
        else:
            return {"error": "État invalide (utilise 'on' ou 'off')."}

        return {"gpio": pin, "state": state}

    def all_on(self):
        for pin in self.pins:
            GPIO.output(pin, self.ACTIVE)
            print(f"GPIO {pin}: HIGH (ON)")
        return {"message": "Tous les relais activés."}

    def all_off(self):
        for pin in self.pins:
            GPIO.output(pin, self.INACTIVE)
            print(f"GPIO {pin}: LOW (OFF)")
        return {"message": "Tous les relais désactivés."}

# --- Initialisation des relais (à adapter à ton câblage) ---
# active_low=False car les relais s'activent avec GPIO.HIGH (comme dans le script standalone)
relais = RelayController([17, 27, 22, 23], active_low=False)

# --- Lifespan event handler for GPIO cleanup ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: GPIO already initialized in RelayController
    yield
    # Shutdown: cleanup GPIO
    GPIO.cleanup()

# --- Application FastAPI ---
app = FastAPI(
    title="Relay API", 
    description="API REST pour contrôler les relais du Raspberry Pi", 
    version="1.0",
    lifespan=lifespan
)

# --- Modèle de données ---
class RelayCommand(BaseModel):
    gpio: int
    state: str  # "on" ou "off"

# --- Routes principales ---
@app.get("/")
def root():
    return {"message": "API relais opérationnelle ✅", "pins": relais.pins}

@app.post("/relay")
def control_relay(cmd: RelayCommand):
    """Active ou désactive un relais spécifique."""
    return relais.control(cmd.gpio, cmd.state.lower())

@app.post("/relay/all_on")
def turn_all_on():
    """Active tous les relais."""
    return relais.all_on()

@app.post("/relay/all_off")
def turn_all_off():
    """Désactive tous les relais."""
    return relais.all_off()

# --- Point d'entrée principal ---
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
