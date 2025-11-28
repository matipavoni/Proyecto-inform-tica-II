// ===================================================
// CLASE UTILIDAD SERIAL
// Funciones auxiliares para comunicación serial
// ===================================================
class UtilidadSerial {
  Serial puertoSerial;
  
  // Constructor
  UtilidadSerial(Serial puerto) {
    this.puertoSerial = puerto;
  }
  
  // Envía un carácter individual al Arduino
  void enviarCaracter(char caracter) {
    puertoSerial.write(caracter);
    puertoSerial.write('\n');
  }
}
