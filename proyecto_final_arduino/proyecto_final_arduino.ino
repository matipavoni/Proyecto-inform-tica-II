#include "MiLibreria.h"
MiLibreria miLib;
// ---------------------------
//  Piano electrónico con grabación
// ---------------------------
// Pines
int buzzer = 2;
int teclas[7] = {13, 12, 11, 10, 9, 8, 7};
int subirOctava = 4;
int bajarOctava = 5;
int grabarBtn = 3;
int led = 6;

// Notas base (Do - Si)
float notasBase[7] = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88};

// Variables generales
int octava = 0;
unsigned long ultimaAccion = 0;
const unsigned long debounceTiempo = 200;
unsigned long tonoInicio = 0;
const unsigned long duracionTono = 200;
bool tonoActivo = false;
unsigned long tiempoBloqueoGrabar = 0;
bool bloqueoGrabar = false;

// ---------------------------
// Clase para manejar grabaciones
// ---------------------------
class Grabacion {
public:
	int notas[100];                 
	unsigned long duracion[100];    
	int cantidad;
	bool grabando;
	unsigned long inicioNota;
	
	Grabacion() {
		cantidad = 0;
		grabando = false;
	}
	
	void iniciarGrabacion() {
		cantidad = 0;
		grabando = true;
		Serial.println("START_REC");  
	}
	
	void detenerGrabacion() {
		grabando = false;
		Serial.println("END_REC");    
		for (int i = 0; i < cantidad; i++) {
			Serial.print("NOTE,");
			Serial.print(notas[i]);
			Serial.print(",");
			Serial.println(duracion[i]);
		}
	}
	
	void registrarNota(int indiceNota, unsigned long dur) {
		if (grabando && cantidad < 100) {
			notas[cantidad] = indiceNota;
			duracion[cantidad] = dur;
			cantidad++;
		}
	}
};

// Instancia global de grabación
Grabacion rec;

// ---------------------------
// Máquina de estados
// ---------------------------
Estado estadoActual = ESPERA;

// ---------------------------
// Setup
// ---------------------------
void setup() {
	pinMode(buzzer, OUTPUT);
	pinMode(led, OUTPUT);
	pinMode(grabarBtn, INPUT_PULLUP);
	
	for (int i = 0; i < 7; i++) {
		pinMode(teclas[i], INPUT_PULLUP);
	}
	
	pinMode(subirOctava, INPUT_PULLUP);
	pinMode(bajarOctava, INPUT_PULLUP);
	
	Serial.begin(9600);
}

// ---------------------------
// Loop principal
// ---------------------------
void loop() {
	unsigned long ahora = millis();
	if (octava == 0) {
		digitalWrite(led, HIGH);   // LED prendido en octava base
	} else {
		digitalWrite(led, LOW);    // LED apagado en cualquier otra octava
	}
	
	switch (estadoActual)// maquina de estados
	{
		
	case ESPERA:
		if (digitalRead(grabarBtn) == LOW && !bloqueoGrabar) {
	rec.iniciarGrabacion();
	estadoActual = GRABANDO;
	bloqueoGrabar = true;
	tiempoBloqueoGrabar = ahora;
	break;
}
miLib.leerCambioOctava(ahora, octava, ultimaAccion, debounceTiempo,estadoActual, subirOctava, bajarOctava);
miLib.leerTeclas(ahora, teclas, notasBase, octava,estadoActual, tonoActivo, tonoInicio, buzzer);
		break;
		
	case REPRODUCIENDO:
		if (tonoActivo && (ahora - tonoInicio > duracionTono)) {
			noTone(buzzer);
			tonoActivo = false;
			estadoActual = ESPERA;
		}
		break;
		
	case CAMBIO_OCTAVA:
		estadoActual = ESPERA;
		break;
		
	case GRABANDO:
		if (digitalRead(grabarBtn) == LOW && !bloqueoGrabar) {
	rec.detenerGrabacion();
	estadoActual = ESPERA;
	bloqueoGrabar = true;
	tiempoBloqueoGrabar = ahora;
	break;
}
		
		for (int i = 0; i < 7; i++) {
			if (digitalRead(teclas[i]) == LOW && !tonoActivo) {
				float freq = notasBase[i] * pow(2, octava);
				tone(buzzer, freq);
				tonoActivo = true;
				tonoInicio = ahora;
				rec.registrarNota(i, duracionTono);
				Serial.print("Nota ");
				Serial.println(i);
			}
		}
		
		if (tonoActivo && (ahora - tonoInicio > duracionTono)) {
			noTone(buzzer);
			tonoActivo = false;
		}
		break;
	}
	
	// -----------------------------------
	// --- TECLADO POR SERIAL (1 a 7) ---
	// -----------------------------------
	if (Serial.available() > 0) {
		char tecla = Serial.read();
		
		if (tecla >= '1' && tecla <= '7') {
			int indice = tecla - '1';   // convierte '1'..'7' ? 0..6
			
			float freq = notasBase[indice] * pow(2, octava);
			tone(buzzer, freq);
			delay(duracionTono);
			noTone(buzzer);
			
			if (estadoActual == GRABANDO) {
				rec.registrarNota(indice, duracionTono);
			}
			
			Serial.print("Tecla serial: ");
			Serial.println(tecla);
		}
	}
	if (bloqueoGrabar && (ahora - tiempoBloqueoGrabar >= 200)) {
	bloqueoGrabar = false;
}
}

// ---------------------------
// Funciones auxiliares
// ---------------------------
void leerCambioOctava(unsigned long ahora) {
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

void leerTeclas(unsigned long ahora) {
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
