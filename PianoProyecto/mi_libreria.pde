// ===================================================
// CLASE MI LIBRERIA
// Maneja el envío de comandos y notas al Arduino
// ===================================================
class MiLibreria {
  Serial puertoSerial;
  
  // Constructor
  MiLibreria(Serial puerto) {
    this.puertoSerial = puerto;
  }
  
  // Envía una nota o comando al Arduino
  void enviarNota(String nota) {
    puertoSerial.write(nota + "\n");
  }
}
