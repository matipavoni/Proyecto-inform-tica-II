class Melodia {
  ArrayList<String> notas = new ArrayList<String>();

  void agregar(String s) {
    notas.add(s);
  }

  void limpiar() {
    notas.clear();
  }

  void guardarAppend(String archivo) {
    PrintWriter pw = createWriter(archivo);
    for (String n : notas)
      pw.println(n);
    pw.flush();
    pw.close();
  }

  void cargar(String archivo) {
    String[] lineas = loadStrings(archivo);
    if (lineas != null)
      for (String l : lineas) notas.add(l);
  }
}