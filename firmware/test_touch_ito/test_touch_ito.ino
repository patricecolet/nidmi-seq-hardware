// Banc de mesure capacitif — électrode ITO derrière membrane plexi.
// Cible : ESP32-S3-WROOM-1 N16R8 (touch v2). Compile aussi sur ESP32 classique (touch v1).
//
// Sortie série 115200 :
//   - toutes les PERIOD_MS : une ligne CSV  t_ms,ch,raw,delta,snr  par canal
//   - commande 'b' + Entrée : refait la ligne de base (main loin de la façade !)
//   - commande 'h' : rappel des commandes
//
// Convention : delta est TOUJOURS positif au toucher (le signe brut est inversé
// entre touch v1 et v2, on le normalise ici).

#include "soc/soc_caps.h"

#if SOC_TOUCH_SENSOR_VERSION == 2   // ESP32-S3 / S2 : la valeur MONTE au toucher
  static const int TOUCH_SIGN = +1;
  // GPIO1..14 sont tous touch-capables, mais ils ne se valent pas : certains
  // saturent des la broche nue. Verifier avec scan_touch avant de figer un
  // brochage (cf. docs/ESSAI_ITO_ESP32.md).
  static const uint8_t PINS[] = {8, 9, 10, 12};   // TOUCH8/9/10/12, mesures valides
#else                            // ESP32 classique : la valeur DESCEND au toucher
  static const int TOUCH_SIGN = -1;
  static const uint8_t PINS[] = {4, 13, 14, 27};   // T0, T4, T6, T7 (pas de strapping)
#endif

// Cycles de charge/decharge par mesure (touch v2). Le defaut du core est 500 :
// sur une broche nue ou une petite electrode, la mesure n'aboutit pas et le
// driver rend 0x3FFFFF (=4194303) avec un bruit nul -> signe caracteristique.
// Baisser si ca sature, monter pour gagner en resolution sur grande electrode.
static const uint32_t CHG_TIMES = 500;

static const int    NCH        = sizeof(PINS) / sizeof(PINS[0]);
static const int    OVERSAMPLE = 16;    // moyennage par point de mesure
static const int    BASE_N     = 200;   // échantillons pour base + bruit
static const int    PERIOD_MS  = 100;

static void printMeta();

static float base[NCH];   // ligne de base (repos)
static float sigma[NCH];  // écart-type du bruit au repos

static float readAvg(uint8_t pin) {
  uint32_t acc = 0;
  for (int i = 0; i < OVERSAMPLE; i++) acc += touchRead(pin);
  return (float)acc / OVERSAMPLE;
}

// Les premieres lectures d'un canal sont invalides : le filtre de lissage du
// driver doit converger, et un canal fraichement cree rend 0x3FFFFF en attendant.
// Sans ce prechauffage la ligne de base est calculee sur des valeurs fantomes.
static const uint32_t WARMUP_MS = 2000;

static void warmup() {
  uint32_t t = millis();
  while (millis() - t < WARMUP_MS) {
    for (int c = 0; c < NCH; c++) (void)readAvg(PINS[c]);
    delay(5);
  }
}

static void calibrate() {
  Serial.println(F("# prechauffage..."));
  warmup();
  Serial.println(F("# calibration : NE PAS TOUCHER la facade..."));
  for (int c = 0; c < NCH; c++) {
    double s = 0, s2 = 0;
    for (int i = 0; i < BASE_N; i++) {
      float v = readAvg(PINS[c]);
      s += v; s2 += (double)v * v;
      delay(2);
    }
    base[c]  = s / BASE_N;
    double var = s2 / BASE_N - (double)base[c] * base[c];
    // Plancher a 0.5 count : un canal parfaitement stable sur la fenetre de
    // calibration donnerait sigma=0, donc un SNR infini et trompeur.
    sigma[c] = var > 0.25 ? sqrt(var) : 0.5f;
  }
  printMeta();
}

// Entete decrivant les canaux. Reimprimee sur demande ('i') : un client qui se
// connecte apres la calibration ne l'a jamais vue, et sans elle il ne sait pas
// quel canal correspond a quel GPIO.
static void printMeta() {
  Serial.println(F("# ch,gpio,base,sigma"));
  bool sature = false;
  for (int c = 0; c < NCH; c++) {
    Serial.printf("# %d,%u,%.1f,%.2f\n", c, PINS[c], base[c], sigma[c]);
    if (base[c] >= 4194303.0f - 1.0f) sature = true;
  }
  if (sature) {
    Serial.println(F("# !! canal sature (0x3FFFFF) : la mesure capacitive n'aboutit pas."));
    Serial.println(F("#    -> electrode absente/trop petite, ou CHG_TIMES trop grand."));
  }
  Serial.println(F("# t_ms,ch,raw,delta,snr"));
}

void setup() {
  Serial.begin(115200);
  delay(400);
  Serial.println(F("\n# --- banc capacitif ITO / plexi ---"));
#if SOC_TOUCH_SENSOR_VERSION == 2
  Serial.println(F("# touch v2 (S2/S3) : valeur croissante au toucher"));
  // A appeler AVANT le premier touchRead (sinon le core refuse : deja initialise).
  touchSetConfig(CHG_TIMES, TOUCH_VOLT_LIM_L_0V5, TOUCH_VOLT_LIM_H_2V2);
  Serial.printf("# chg_times=%lu\n", (unsigned long)CHG_TIMES);
#else
  Serial.println(F("# touch v1 (ESP32) : valeur decroissante au toucher"));
#endif
  Serial.printf("# %d canaux, oversample=%d\n", NCH, OVERSAMPLE);
  calibrate();
}

void loop() {
  if (Serial.available()) {
    int c = Serial.read();
    if (c == 'b' || c == 'B') calibrate();
    else if (c == 'i' || c == 'I') printMeta();
    else if (c == 'h' || c == 'H') Serial.println(F("# b=recalibrer  i=entete  h=aide"));
  }

  uint32_t t = millis();
  for (int c = 0; c < NCH; c++) {
    float raw   = readAvg(PINS[c]);
    float delta = TOUCH_SIGN * (raw - base[c]);
    Serial.printf("%lu,%d,%.1f,%.1f,%.1f\n", t, c, raw, delta, delta / sigma[c]);
  }
  delay(PERIOD_MS);
}
