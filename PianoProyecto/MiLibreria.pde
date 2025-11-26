class MiLibreria {
  Serial p;

  MiLibreria(Serial puerto) {
    this.p = puerto;
  }

  void enviarNota(String s) {
    p.write(s + "\n");
  }
}
