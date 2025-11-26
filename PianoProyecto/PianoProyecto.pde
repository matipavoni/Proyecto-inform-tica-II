import processing.serial.*;

Serial port;
MiLibreria miLib;
UtilSerial util;
boolean grabando = false;

// Melodía temporal y melodia guardada
Melodia melodiaTemp = new Melodia();
Melodia melodiaHistorial = new Melodia();

String archivo = "melodias.txt";

PianoUI piano;

// -----------------------
// MELODÍAS PREDEFINIDAS
// -----------------------
String[] melodia1 = {
  "NOTE,0,300","NOTE,1,300","NOTE,2,300",
  "NOTE,3,300","NOTE,4,300","NOTE,5,300",
  "NOTE,6,600","NOTE,4,400","NOTE,2,400"
};

String[] melodia2 = {
  "NOTE,6,300","NOTE,5,300","NOTE,4,300",
  "NOTE,3,300","NOTE,2,300","NOTE,1,300",
  "NOTE,0,600","NOTE,2,400","NOTE,4,400"
};

// ------------------------------------------------------------

void setup() {
  size(800, 700);
  port = new Serial(this, "COM5", 9600);

  // Inicialización de tus clases
  miLib = new MiLibreria(port);
  util  = new UtilSerial(port);

  // Prueba de envío
  miLib.enviarNota("A");
  util.enviarSerial('B');

  port.bufferUntil('\n');

  piano = new PianoUI(50, 350, 90, 250);
  melodiaHistorial.cargar(archivo);

  textAlign(CENTER, CENTER);
}

void draw() {
  background(40);

  fill(255);
  textSize(26);
  text("MENU DE MELODIAS", width/2, 40);

  textSize(20);
  text("Estado: " + nombreEstado(), width/2, 80);

  text("Grabación: " + (grabando ? "ACTIVA" : "INACTIVA"), width/2, 120);

  text("P → Reproducir melodía guardada", width/2, 170);
  text("A → Reproducir melodía 1", width/2, 200);
  text("S → Reproducir melodía 2", width/2, 230);

  text("PIANO VIRTUAL", width/2, 280);

  piano.dibujar();
}

// -----------------------------------------------------------
// CLICK DEL MOUSE
// -----------------------------------------------------------

void mousePressed() {
  int nota = piano.detectarClick(mouseX, mouseY);
  if (nota >= 0) {
    util.enviarSerial(char('1'+nota));
  }
}

// -----------------------------------------------------------
// TECLADO
// -----------------------------------------------------------

void keyPressed() {

  if (key >= '1' && key <= '7') {
    util.enviarSerial(key);
  }

  if (key == 'p' || key == 'P') {
    estado = ST_PLAYING;
    reproducirArray(melodiaHistorial.notas);
    estado = ST_IDLE;
  }

  if (key == 'a' || key == 'A')
    reproducirArray(melodia1);

  if (key == 's' || key == 'S')
    reproducirArray(melodia2);
}

// -----------------------------------------------------------
// SERIAL EVENT
// -----------------------------------------------------------

void serialEvent(Serial p) {
  String s = trim(p.readStringUntil('\n'));
  if (s == null) return;

  if (s.equals("START_REC")) {
    estado = ST_RECORDING;
    grabando = true;
    melodiaTemp.limpiar();
  }
  else if (s.equals("END_REC")) {
    estado = ST_IDLE;
    grabando = false;

    melodiaTemp.guardarAppend(archivo);
    melodiaHistorial.cargar(archivo);
  }
  else if (grabando) {
    melodiaTemp.agregar(s);
  }
}

// -----------------------------------------------------------
// REPRODUCCIÓN
// -----------------------------------------------------------

void reproducirArray(String[] arr) {
  for (String s : arr) {
    miLib.enviarNota(s);
    delay(300);
  }
}

void reproducirArray(ArrayList<String> arr) {
  for (String s : arr) {
    miLib.enviarNota(s);
    delay(300);
  }
}
