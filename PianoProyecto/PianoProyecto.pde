import processing.serial.*;

// ===================================================
// VARIABLES GLOBALES
// ===================================================
Serial puerto;
MiLibreria bibliotecaSerial;
UtilidadSerial utilidadSerial;
boolean estaGrabando = false;

// Almacenamiento de melodías
Melodia melodiaTemporal = new Melodia();      // Melodía que se está grabando
Melodia melodiaGuardada = new Melodia();      // Melodía cargada desde archivo
String nombreArchivo = "melodias.txt";

PianoUI pianoVirtual;

// ===================================================
// ESTADOS DEL SISTEMA
// ===================================================
final int ESTADO_INACTIVO = 0;
final int ESTADO_GRABANDO = 1;
final int ESTADO_REPRODUCIENDO = 2;
int estadoActual = ESTADO_INACTIVO;

// ===================================================
// MELODÍAS PREDEFINIDAS
// ===================================================
// Melodía ascendente: Do-Re-Mi-Fa-Sol-La-Si con variaciones
String[] melodiaPredefinida1 = {
  "NOTE,0,300", "NOTE,1,300", "NOTE,2,300",
  "NOTE,3,300", "NOTE,4,300", "NOTE,5,300",
  "NOTE,6,600", "NOTE,4,400", "NOTE,2,400"
};

// Melodía descendente: Si-La-Sol-Fa-Mi-Re-Do con variaciones
String[] melodiaPredefinida2 = {
  "NOTE,6,300", "NOTE,5,300", "NOTE,4,300",
  "NOTE,3,300", "NOTE,2,300", "NOTE,1,300",
  "NOTE,0,600", "NOTE,2,400", "NOTE,4,400"
};

// ===================================================
// CONFIGURACIÓN INICIAL
// ===================================================
void setup() {
  size(800, 700);
  
  // Configurar comunicación serial con Arduino
  puerto = new Serial(this, "COM3", 9600);
  puerto.bufferUntil('\n');  // Leer hasta encontrar salto de línea
  
  // Inicializar clases de manejo de datos
  bibliotecaSerial = new MiLibreria(puerto);
  utilidadSerial = new UtilidadSerial(puerto);
  
  // Prueba inicial de comunicación
  bibliotecaSerial.enviarNota("A");
  utilidadSerial.enviarCaracter('B');
  
  // Crear interfaz del piano virtual
  // Parámetros: x, y, anchoTecla, altoTecla
  pianoVirtual = new PianoUI(50, 350, 90, 250);
  
  // Cargar melodías guardadas previamente
  melodiaGuardada.cargarDesdeArchivo(nombreArchivo);
  
  // Configurar alineación de texto
  textAlign(CENTER, CENTER);
}

// ===================================================
// BUCLE PRINCIPAL DE DIBUJO
// ===================================================
void draw() {
  // Fondo gris oscuro
  background(40);
  
  // Dibujar interfaz de usuario
  dibujarInterfaz();
  
  // Dibujar piano virtual
  pianoVirtual.dibujar();
}

// ---------------------------------------------------
// Dibuja el menú y la información en pantalla
// ---------------------------------------------------
void dibujarInterfaz() {
  fill(255);
  
  // Título principal
  textSize(26);
  text("MENU DE MELODIAS", width/2, 40);
  
  // Estado de grabación
  textSize(20);
  String textoEstado = estaGrabando ? "ACTIVA" : "INACTIVA";
  text("Grabación: " + textoEstado, width/2, 120);
  
  // Instrucciones
  text("P → Reproducir melodía guardada", width/2, 170);
  text("A → Reproducir melodía 1", width/2, 200);
  text("S → Reproducir melodía 2", width/2, 230);
  text("PIANO VIRTUAL", width/2, 280);
}

// ===================================================
// EVENTOS DE INTERACCIÓN
// ===================================================

// ---------------------------------------------------
// Maneja los clicks del mouse sobre el piano virtual
// ---------------------------------------------------
void mousePressed() {
  // Detectar qué tecla del piano fue clickeada
  int numeroNota = pianoVirtual.detectarClick(mouseX, mouseY);
  
  if (numeroNota >= 0) {
    // Convertir número de nota (0-6) a carácter ('1'-'7')
    char caracterNota = char('1' + numeroNota);
    utilidadSerial.enviarCaracter(caracterNota);
  }
}

// ---------------------------------------------------
// Maneja las teclas presionadas del teclado
// ---------------------------------------------------
void keyPressed() {
  // Teclas numéricas 1-7: tocar notas individuales
  if (key >= '1' && key <= '7') {
    utilidadSerial.enviarCaracter(key);
  }
  
  // Tecla P: reproducir melodía guardada
  if (key == 'p' || key == 'P') {
    estadoActual = ESTADO_REPRODUCIENDO;
    reproducirListaNotas(melodiaGuardada.notas);
    estadoActual = ESTADO_INACTIVO;
  }
  
  // Tecla A: reproducir primera melodía predefinida
  if (key == 'a' || key == 'A') {
    reproducirArregloNotas(melodiaPredefinida1);
  }
  
  // Tecla S: reproducir segunda melodía predefinida
  if (key == 's' || key == 'S') {
    reproducirArregloNotas(melodiaPredefinida2);
  }
}

// ===================================================
// COMUNICACIÓN SERIAL (recibir datos de Arduino)
// ===================================================
void serialEvent(Serial p) {
  // Leer línea completa desde Arduino
  String lineaRecibida = trim(p.readStringUntil('\n'));
  
  if (lineaRecibida == null) return;
  
  // Comando: iniciar grabación
  if (lineaRecibida.equals("START_REC")) {
    estadoActual = ESTADO_GRABANDO;
    estaGrabando = true;
    melodiaTemporal.limpiarMelodia();
  }
  // Comando: finalizar grabación
  else if (lineaRecibida.equals("END_REC")) {
    estadoActual = ESTADO_INACTIVO;
    estaGrabando = false;
    
    // Guardar melodía grabada al archivo
    melodiaTemporal.guardarEnArchivo(nombreArchivo);
    
    // Recargar melodías desde archivo
    melodiaGuardada.cargarDesdeArchivo(nombreArchivo);
  }
  // Si está grabando, agregar la nota recibida
  else if (estaGrabando) {
    melodiaTemporal.agregarNota(lineaRecibida);
  }
}

// ===================================================
// FUNCIONES DE REPRODUCCIÓN
// ===================================================

// ---------------------------------------------------
// Reproduce un arreglo de notas (String[])
// ---------------------------------------------------
void reproducirArregloNotas(String[] arregloNotas) {
  for (String nota : arregloNotas) {
    bibliotecaSerial.enviarNota(nota);
    delay(300);  // Pausa de 300ms entre notas
  }
}

// ---------------------------------------------------
// Reproduce una lista de notas (ArrayList<String>)
// ---------------------------------------------------
void reproducirListaNotas(ArrayList<String> listaNotas) {
  for (String nota : listaNotas) {
    bibliotecaSerial.enviarNota(nota);
    delay(300);  // Pausa de 300ms entre notas
  }
}

// ===================================================
// CLASE MELODIA
// Maneja el almacenamiento y persistencia de melodías
// ===================================================
class Melodia {
  // Lista dinámica que almacena las notas de la melodía
  ArrayList<String> notas = new ArrayList<String>();
  
  // Agrega una nota a la melodía actual
  void agregarNota(String nota) {
    notas.add(nota);
  }
  
  // Limpia todas las notas de la melodía
  void limpiarMelodia() {
    notas.clear();
  }
  
  // Guarda la melodía actual en un archivo de texto
  void guardarEnArchivo(String nombreArchivo) {
    PrintWriter escritorArchivo = createWriter(nombreArchivo);
    
    for (String nota : notas) {
      escritorArchivo.println(nota);
    }
    
    escritorArchivo.flush();
    escritorArchivo.close();
  }
  
  // Carga una melodía desde un archivo de texto
  void cargarDesdeArchivo(String nombreArchivo) {
    notas.clear();
    
    String[] lineasArchivo = loadStrings(nombreArchivo);
    
    if (lineasArchivo != null) {
      for (String linea : lineasArchivo) {
        notas.add(linea);
      }
    }
  }
}

// ===================================================
// CLASE PIANO 
// Interfaz gráfica de un piano virtual de 7 teclas
// ===================================================
class PianoUI {
  // Dimensiones y posición del piano
  int anchoTecla, altoTecla;
  int posicionX, posicionY;
  
  final int NUMERO_TECLAS = 7;
  
  // Constructor
  PianoUI(int x, int y, int ancho, int alto) {
    this.posicionX = x;
    this.posicionY = y;
    this.anchoTecla = ancho;
    this.altoTecla = alto;
  }
  
  // Dibuja el piano completo en pantalla
  void dibujar() {
    for (int i = 0; i < NUMERO_TECLAS; i++) {
      // Calcular posición X de esta tecla
      int posXTecla = posicionX + i * anchoTecla;
      
      // Dibujar rectángulo blanco (la tecla)
      fill(255);
      stroke(0);
      strokeWeight(2);
      rect(posXTecla, posicionY, anchoTecla, altoTecla);
      
      // Dibujar etiqueta de la nota en negro
      fill(0);
      textSize(16);
      text("Nota " + (i + 1), 
           posXTecla + anchoTecla/2, 
           posicionY + altoTecla - 30);
    }
  }
  
  // Detecta si el click del mouse está sobre alguna tecla
  // Retorna: número de tecla (0-6) o -1 si no clickeó ninguna
  int detectarClick(int mouseX, int mouseY) {
    for (int i = 0; i < NUMERO_TECLAS; i++) {
      int posXTecla = posicionX + i * anchoTecla;
      
      boolean dentroEnX = mouseX > posXTecla && mouseX < posXTecla + anchoTecla;
      boolean dentroEnY = mouseY > posicionY && mouseY < posicionY + altoTecla;
      
      if (dentroEnX && dentroEnY) {
        return i;
      }
    }
    
    return -1;
  }
}
