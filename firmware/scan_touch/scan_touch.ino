// 1) integrite electrique de GPIO1..14  2) balayage touch des 14 canaux.
void setup() {
  Serial.begin(115200);
  delay(3000);
  Serial.println("\n>>> integrite des broches (attendu: pu=1 pd=0 = broche libre)");
  for (int g = 1; g <= 14; g++) {
    pinMode(g, INPUT_PULLUP);   delay(3); int pu = digitalRead(g);
    pinMode(g, INPUT_PULLDOWN); delay(3); int pd = digitalRead(g);
    pinMode(g, INPUT);
    const char *diag = "libre";
    if (pu == 0 && pd == 0) diag = "<-- TIRE A LA MASSE";
    else if (pu == 1 && pd == 1) diag = "<-- TIRE AU 3V3";
    Serial.printf("GPIO%-2d  pu=%d pd=%d  %s\n", g, pu, pd, diag);
  }
  Serial.println(">>> balayage touch (2 s max par canal si echec)");
}

void loop() {
  static int g = 1;
  uint32_t t = millis();
  uint32_t v = touchRead(g);
  Serial.printf("GPIO%-2d  raw=%-10lu  (%lu ms)%s\n", g, (unsigned long)v,
                (unsigned long)(millis() - t), v >= 4194303UL ? "  SATURE" : "  <== OK !");
  if (++g > 14) { Serial.println(">>> fin"); while (1) delay(1000); }
  delay(20);
}
