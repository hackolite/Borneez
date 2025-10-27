import RPi.GPIO as GPIO
import time

# --- Configuration générale ---
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# --- Classe pour gérer plusieurs relais ---
class RelayController:
    def __init__(self, pins, active_low=True):
        """
        Initialise un contrôleur de relais.

        :param pins: liste des GPIO connectés aux relais (ex: [17, 27, 22, 23])
        :param active_low: True si le relais s'active à LOW (courant pour les relais 5V)
        """
        self.pins = pins
        self.active_low = active_low
        self.ACTIVE = GPIO.LOW if active_low else GPIO.HIGH
        self.INACTIVE = GPIO.HIGH if active_low else GPIO.LOW

        for pin in self.pins:
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, self.INACTIVE)

    def control(self, pin, state):
        """
        Active ou désactive un relais spécifique.

        :param pin: numéro du GPIO
        :param state: 'on' ou 'off'
        """
        if pin not in self.pins:
            print(f"Erreur : GPIO {pin} non déclaré dans la liste des relais.")
            return

        if state.lower() == "on":
            GPIO.output(pin, self.ACTIVE)
            print(f"Relais {pin} -> ON (fermé)")
        elif state.lower() == "off":
            GPIO.output(pin, self.INACTIVE)
            print(f"Relais {pin} -> OFF (ouvert)")
        else:
            print("Erreur : utiliser 'on' ou 'off'.")

    def all_on(self):
        """Allume tous les relais."""
        for pin in self.pins:
            GPIO.output(pin, self.ACTIVE)
        print("✅ Tous les relais sont activés.")

    def all_off(self):
        """Éteint tous les relais."""
        for pin in self.pins:
            GPIO.output(pin, self.INACTIVE)
        print("🛑 Tous les relais sont désactivés.")

    def cleanup(self):
        """Nettoie la configuration GPIO."""
        GPIO.cleanup()
        print("Nettoyage GPIO effectué.")

# --- Exemple d'utilisation ---
if __name__ == "__main__":
    try:
        relais = RelayController([17, 27, 22, 23])  # Liste des broches
        relais.control(17, "on")
        time.sleep(1)
        relais.control(17, "off")
        time.sleep(1)

        relais.all_on()
        time.sleep(2)
        relais.all_off()
    finally:
        relais.cleanup()
