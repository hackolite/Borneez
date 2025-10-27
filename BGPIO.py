from fastapi import FastAPI
import RPi.GPIO as GPIO
from pydantic import BaseModel
from typing import List

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
        elif state == "off":
            GPIO.output(pin, self.INACTIVE)
        else:
            return {"error": "État invalide (utilise 'on' ou 'off')."}

        return {"gpio": pin, "state": state}

    def all_on(self):
        for pin in self.pins:
            GPIO.output(pin, self.ACTIVE)
        return {"message": "Tous les relais activés."}

    def all_off(self):
        for pin in self.pins:
            GPIO.output(pin, self.INACTIVE)
        return {"message": "Tous les relais désactivés."}

# --- Initialisation des relais (à adapter à ton câblage) ---
relais = RelayController([17, 27, 22, 23])

# --- Application FastAPI ---
app = FastAPI(title="Relay API", description="API REST pour contrôler les relais du Raspberry Pi", version="1.0")

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

@app.on_event("shutdown")
def cleanup_gpio():
    GPIO.cleanup()
