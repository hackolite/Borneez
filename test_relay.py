#!/usr/bin/env python3
"""
Script de test pour identifier le mode de votre module relais.
Ce script vous aide à déterminer si vous devez utiliser active_low=True ou active_low=False.

Usage:
    python3 test_relay.py [GPIO_PIN]
    
Exemple:
    python3 test_relay.py 17
"""

import sys
import time

try:
    import RPi.GPIO as GPIO
    MOCK_MODE = False
except (ImportError, RuntimeError):
    print("⚠️  RPi.GPIO non disponible - Mode simulation")
    print("   Pour tester sur Raspberry Pi, installez: sudo apt-get install python3-rpi.gpio\n")
    
    # Mock GPIO for testing
    class MockGPIO:
        BCM = "BCM"
        OUT = "OUT"
        LOW = 0
        HIGH = 1
        
        @staticmethod
        def setmode(mode):
            print(f"   [MOCK] GPIO.setmode({mode})")
        
        @staticmethod
        def setup(pin, mode):
            print(f"   [MOCK] GPIO.setup(pin={pin}, mode={mode})")
        
        @staticmethod
        def output(pin, state):
            state_str = "HIGH" if state == 1 else "LOW"
            print(f"   [MOCK] GPIO.output(pin={pin}, state={state_str})")
        
        @staticmethod
        def cleanup():
            print("   [MOCK] GPIO.cleanup()")
    
    GPIO = MockGPIO()
    MOCK_MODE = True


def test_relay(pin):
    """Teste le relais sur le GPIO spécifié."""
    print("=" * 70)
    print("🔌 TEST DE RELAIS GPIO")
    print("=" * 70)
    print(f"GPIO Pin: {pin}")
    if MOCK_MODE:
        print("Mode: SIMULATION (pas de matériel réel)")
    else:
        print("Mode: MATÉRIEL RÉEL")
    print("=" * 70)
    
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)
    
    print("\n📋 Instructions:")
    print("   Observez votre relais et notez quand il s'active (clic, LED, etc.)\n")
    
    try:
        # Test 1: GPIO.LOW
        print("🔴 Test 1/4: Envoi de GPIO.LOW (signal bas)...")
        GPIO.output(pin, GPIO.LOW)
        if not MOCK_MODE:
            input("   ➡️  Appuyez sur ENTRÉE pour continuer...")
        else:
            time.sleep(1)
        
        # Test 2: GPIO.HIGH
        print("\n🟢 Test 2/4: Envoi de GPIO.HIGH (signal haut)...")
        GPIO.output(pin, GPIO.HIGH)
        if not MOCK_MODE:
            input("   ➡️  Appuyez sur ENTRÉE pour continuer...")
        else:
            time.sleep(1)
        
        # Test 3: Cycle complet
        print("\n🔄 Test 3/4: Cycle LOW → HIGH → LOW → HIGH")
        for i in range(2):
            print(f"   Cycle {i+1}: LOW...")
            GPIO.output(pin, GPIO.LOW)
            time.sleep(1)
            print(f"   Cycle {i+1}: HIGH...")
            GPIO.output(pin, GPIO.HIGH)
            time.sleep(1)
        
        # Test 4: Retour à LOW
        print("\n⬇️  Test 4/4: Retour à LOW (désactivé)")
        GPIO.output(pin, GPIO.LOW)
        time.sleep(1)
        
    finally:
        GPIO.cleanup()
        print("\n✅ GPIO nettoyé")
    
    # Conclusion
    print("\n" + "=" * 70)
    print("📊 RÉSULTATS ET CONFIGURATION")
    print("=" * 70)
    print("\nQuand est-ce que votre relais s'est activé ?")
    print("\n1️⃣  Si le relais s'active avec GPIO.HIGH (signal haut):")
    print("   ➡️  Utilisez: active_low=False dans BGPIO.py")
    print("   ➡️  Ligne 49: relais = RelayController([...], active_low=False)")
    print("\n2️⃣  Si le relais s'active avec GPIO.LOW (signal bas):")
    print("   ➡️  Utilisez: active_low=True dans BGPIO.py")
    print("   ➡️  Ligne 49: relais = RelayController([...], active_low=True)")
    print("\n" + "=" * 70)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        try:
            pin = int(sys.argv[1])
        except ValueError:
            print("❌ Erreur: Le numéro de GPIO doit être un entier")
            sys.exit(1)
    else:
        # Par défaut, utilise le GPIO 17
        pin = 17
        print("ℹ️  Aucun GPIO spécifié, utilisation du GPIO 17 par défaut")
        print("   Pour changer: python3 test_relay.py <NUMERO_GPIO>\n")
    
    test_relay(pin)
