class PianoUI {

  int teclaW, teclaH, x, y;

  PianoUI(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.teclaW = w;
    this.teclaH = h;
  }

  void dibujar() {
    for (int i = 0; i < 7; i++) {
      int xx = x + i * teclaW;
      fill(255);
      rect(xx, y, teclaW, teclaH);
      fill(0);
      text("Nota " + (i+1), xx + teclaW/2, y + teclaH - 30);
    }
  }

  int detectarClick(int mx, int my) {
    for (int i = 0; i < 7; i++) {
      int xx = x + i * teclaW;
      if (mx > xx && mx < xx + teclaW && my > y && my < y + teclaH)
        return i;
    }
    return -1;
  }
}