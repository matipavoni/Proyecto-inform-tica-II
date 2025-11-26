class UtilSerial {
  Serial p;

  UtilSerial(Serial puerto) {
    this.p = puerto;
  }

  void enviarSerial(char c) {
    p.write(c);
    p.write('\n');
  }
}
