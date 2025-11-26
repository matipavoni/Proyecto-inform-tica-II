#ifndef MI_LIBRERIA_H
#define MI_LIBRERIA_H

#include <Arduino.h>

enum Estado { ESPERA, REPRODUCIENDO, CAMBIO_OCTAVA, GRABANDO };

class MiLibreria {
public:
    void leerCambioOctava(unsigned long ahora,
                          int &octava,
                          unsigned long &ultimaAccion,
                          const unsigned long debounceTiempo,
                          Estado &estadoActual,
                          int subirOctava,
                          int bajarOctava);

    void leerTeclas(unsigned long ahora,
                    int *teclas,
                    float *notasBase,
                    int &octava,
                    Estado &estadoActual,
                    bool &tonoActivo,
                    unsigned long &tonoInicio,
                    int buzzer);
};

#endif
