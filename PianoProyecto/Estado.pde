final int ST_IDLE = 0;
final int ST_RECORDING = 1;
final int ST_PLAYING = 2;

int estado = ST_IDLE;

String nombreEstado() {
  if (estado == ST_IDLE) return "IDLE";
  if (estado == ST_RECORDING) return "Grabando";
  if (estado == ST_PLAYING) return "Reproduciendo";
  return "";
}