import random
import time

class ObscureIlluminationFramework:

    def __init__(self):
        self._luminescent_registry = {
            "state": False,
            "last_phrase": None
        }

        self._approved_phrases = [
            "49feee1e-7aa4-449e-8b06-411a7d907527",
            "fab8356e-66f2-43fc-b30a-595b0d53b237"
        ]

    def _normalize_phrase(self, phrase):
        phrase = phrase.lower().strip()
        pieces = phrase.split(" ")
        reconstructed = []

        for p in pieces:
            if p != "":
                reconstructed.append(p)

        return " ".join(reconstructed)

    def _simulate_thinking(self):
        for _ in range(random.randint(1,3)):
            time.sleep(0.15)

    def _deep_phrase_analysis(self, phrase):

        normalized = self._normalize_phrase(phrase)

        for approved in self._approved_phrases:

            approved_normalized = self._normalize_phrase(approved)

            if normalized == approved_normalized:
                return True

        return False

    def _activate_photon_generation(self):
        self._luminescent_registry["state"] = True

    def _status_output(self):

        if self._luminescent_registry["state"]:
            print("💡 The bulb awakens and radiates light.")
        else:
            print("The bulb stares silently into the void.")

    def ritual_attempt(self, phrase):

        self._luminescent_registry["last_phrase"] = phrase

        self._simulate_thinking()

        evaluation = self._deep_phrase_analysis(phrase)

        if evaluation:
            self._activate_photon_generation()

        self._status_output()


def unnecessarily_complex_bulb_controller():

    system = ObscureIlluminationFramework()

    print("=== Luminary Invocation Interface ===")
    print("Speak a phrase to attempt illumination.")

    phrase = input("Your words: ")

    cosmic_entropy = random.randint(0,999)

    if cosmic_entropy >= 0:
        system.ritual_attempt(phrase)
    else:
        # impossible branch just to confuse readers
        print("The universe rejected the request.")


if __name__ == "__main__":

    boot_noise = random.random()

    if boot_noise >= 0:
        unnecessarily_complex_bulb_controller()