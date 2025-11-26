#include "MiLibreria.h"

void MiLibreria::leerCambioOctava(unsigned long ahora,
                                  int &octava,
                                  unsigned long &ultimaAccion,
                                  const unsigned long debounceTiempo,
                                  Estado &estadoActual,
                                  int subirOctava,
                                  int bajarOctava)
{
    if (digitalRead(subirOctava) == LOW && (ahora - ultimaAccion > debounceTiempo)) {
        octava++;
        if (octava > 2) octava = 2;
        ultimaAccion = ahora;
        estadoActual = CAMBIO_OCTAVA;
    }

    if (digitalRead(bajarOctava) == LOW && (ahora - ultimaAccion > debounceTiempo)) {
        octava--;
        if (octava < -1) octava = -1;
        ultimaAccion = ahora;
        estadoActual = CAMBIO_OCTAVA;
    }
}

void MiLibreria::leerTeclas(unsigned long ahora,
                            int *teclas,
                            float *notasBase,
                            int &octava,
                            Estado &estadoActual,
                            bool &tonoActivo,
                            unsigned long &tonoInicio,
                            int buzzer)
{
    for (int i = 0; i < 7; i++) {
        if (digitalRead(teclas[i]) == LOW && !tonoActivo) {
            float freq = notasBase[i] * pow(2, octava);
            tone(buzzer, freq);
            tonoActivo = true;
            tonoInicio = ahora;
            Serial.print("Nota ");
            Serial.println(i);
            estadoActual = REPRODUCIENDO;
            break;
        }
    }
}