// Banc "cellule complete" : 4 canaux tactiles + 4 LED appairees (touche N <-> LED N).
// Cible ESP32-S3. Sortie CSV compatible avec scripts/touch_scope.py et touch_log.py.
//
//   CABLAGE
//     electrodes ITO -> GPIO 8, 9, 10, 12   (seuls canaux touch valides sur cette
//                                            carte ; cf. firmware/scan_touch)
//     LED n :  GPIO 15/16/17/18 --[ 100 ohm ]--> anode ; cathode --> GND commun
//
//   Les LED ORANGES/ROUGES/VERTES traditionnelles (seuil ~2 V) se pilotent ainsi
//   directement : (3,3 - 2,0) / 100 = ~13 mA, dans les clous du GPIO.
//   Une BLEUE ou une BLANCHE (seuil ~3 V) n'y arriverait pas : il ne resterait que
//   ~2 mA. Pour celles-la il faut le rail 5 V et un montage ou le GPIO tire le
//   courant (5 V --[R]-- anode [LED] cathode -- GPIO, logique inversee).
//
//   SORTIE SERIE (115200)
//     "# ..."                     entete et evenements
//     "t_ms,ch,raw,delta,snr"     une ligne par canal, ~10 fois par seconde
//
//   COMMANDES (un caractere, sauf la luminosite)
//     b  recalibrer la ligne de base (main eloignee)
//     i  reimprimer l'entete canal->GPIO (sans toucher a la ligne de base)
//     f  LED en FIXE          r  LED en RAMPE 5 s      c  LED en CLIGNOTEMENT
//     t  LED REACTIVES AU TOUCHER (LED n suit la touche n)
//     x  LED eteintes         h  aide
//     L<0-255> + retour ligne : luminosite maximale (ex. "L128")

#include "soc/soc_caps.h"

#if SOC_TOUCH_SENSOR_VERSION == 2   // ESP32-S3 / S2 : la valeur MONTE au toucher
  static const int TOUCH_SIGN = +1;
#else                               // ESP32 classique : elle DESCEND
  static const int TOUCH_SIGN = -1;
#endif

static const uint8_t PINS_TOUCH[] = {8, 9, 10, 12};
static const uint8_t PINS_LED[]   = {15, 16, 17, 18};
static const int     NCH          = sizeof(PINS_TOUCH) / sizeof(PINS_TOUCH[0]);

static const uint32_t CHG_TIMES  = 500;
static const int      OVERSAMPLE = 16;
static const int      BASE_N     = 200;
static const uint32_t WARMUP_MS  = 2000;
static const uint32_t PERIOD_MS  = 100;    // cadence d'emission du CSV
static const uint32_t RAMPE_MS   = 5000;   // periode complete de la rampe
static const uint32_t CLIGN_MS   = 600;    // periode du clignotement

// Seuil de detection, exprime en POURCENTAGE DE LA LIGNE DE BASE.
//
// Un seuil en counts absolus ne marche pas ici : le contact vaut +425 % de la base
// dans le cas defavorable (operateur flottant) et jusqu'a +4000 % relie a la masse,
// alors que le bruit vaut quelques dizaines de counts. Un seuil calé sur le bruit
// (8 sigma ~ 280 counts, soit 0,7 % de la base) est franchi par la derive thermique
// et par une main qui passe a 20 cm — l'electrode detecte la PROXIMITE bien avant
// le contact. En relatif, contact et approche se separent sans ambiguite.
// Reglable par "S<n>", n en DIXIEMES DE POUR CENT (S50 = 5 %). Le dixieme de %
// est necessaire : toute la discrimination entre contact et approche se joue
// sous 10 % de la base, un pas de 1 % n'y laisserait que dix positions utiles.
static float SEUIL_PCT = 0.05f;            // 5 % de la base
static const float SEUIL_SIGMA = 8.0f;     // plancher de bruit, jamais dominant
static const float SEUIL_MINI  = 150.0f;
static const float HYSTERESIS  = 0.6f;     // relachement a 60 % du seuil

// Suivi de ligne de base. La base derive en permanence avec la TEMPERATURE et
// l'HYGROMETRIE : sur quelques heures l'ecart depasse largement le bruit, et un
// seuil calcule une fois pour toutes finit par declencher tout seul. On reajuste
// donc la base en continu, avec une constante de temps longue (~60 s), et
// UNIQUEMENT quand le canal n'est pas touche — sinon un doigt maintenu serait
// absorbe dans la base et la touche se relacherait d'elle-meme.
static const float    TRACK_ALPHA = 0.0017f;   // ~60 s a 10 mesures/s
// Un contact tres long peut signifier que la base a ete prise alors qu'un objet
// etait a proximite — mais sur un instrument il peut tout aussi bien s'agir d'une
// NOTE TENUE, d'une pedale ou d'un bourdon. On se contente donc de SIGNALER, une
// seule fois, sans jamais relacher : une note qui s'arrete toute seule est bien
// pire qu'un avertissement, et un re-etalonnage automatique absorberait la valeur
// touchee dans la base, faussant la detection au relachement.
static const uint32_t BLOQUE_MS   = 60000;

enum ModeLed { LED_ETEINT, LED_FIXE, LED_RAMPE, LED_CLIGNOTE, LED_TACTILE };
static ModeLed mode       = LED_TACTILE;
static uint8_t luminosite = 200;

static float    base[NCH], sigma[NCH], seuil[NCH];
static bool     touche[NCH];
static uint32_t debutTouche[NCH];
static bool     signale[NCH];       // avertissement "contact tres long" deja emis

static void printMeta();

static float readAvg(uint8_t pin) {
  uint32_t acc = 0;
  for (int i = 0; i < OVERSAMPLE; i++) acc += touchRead(pin);
  return (float)acc / OVERSAMPLE;
}

// La calibration bloque la boucle ~7 s. Sans signal visuel, les LED restent
// figees dans leur dernier etat et l'utilisateur croit que la commande n'a rien
// fait. On les fait donc clignoter ensemble pendant toute l'operation : c'est un
// motif qu'aucun mode normal ne produit.
static void ledsOccupees() {
  uint8_t v = (millis() / 200) % 2 ? luminosite / 3 : 0;
  for (int c = 0; c < NCH; c++) analogWrite(PINS_LED[c], v);
}

static void calibrate() {
  Serial.println(F("# prechauffage... (LED clignotantes = calibration en cours)"));
  for (int c = 0; c < NCH; c++) analogWrite(PINS_LED[c], 0);
  uint32_t tw = millis();
  while (millis() - tw < WARMUP_MS) {
    for (int c = 0; c < NCH; c++) (void)readAvg(PINS_TOUCH[c]);
    ledsOccupees();
    delay(5);
  }
  Serial.println(F("# calibration : NE PAS TOUCHER — ni electrodes, ni pinces, ni fils"));
  for (int c = 0; c < NCH; c++) {
    double s = 0, s2 = 0;
    for (int i = 0; i < BASE_N; i++) {
      float v = readAvg(PINS_TOUCH[c]);
      s += v; s2 += (double)v * v;
      ledsOccupees();
      delay(2);
    }
    base[c] = s / BASE_N;
    double var = s2 / BASE_N - (double)base[c] * base[c];
    sigma[c] = var > 0.25 ? sqrt(var) : 0.5f;
    seuil[c] = max(max(SEUIL_PCT * base[c], SEUIL_SIGMA * sigma[c]), SEUIL_MINI);
    touche[c] = false;
    debutTouche[c] = 0;
    signale[c] = false;
  }
  for (int c = 0; c < NCH; c++) analogWrite(PINS_LED[c], 0);
  Serial.println(F("# calibration terminee"));
  printMeta();
}

static void printMeta() {
  Serial.println(F("# ch,gpio,base,sigma"));
  bool sature = false;
  for (int c = 0; c < NCH; c++) {
    Serial.printf("# %d,%u,%.1f,%.2f\n", c, PINS_TOUCH[c], base[c], sigma[c]);
    if (base[c] >= 4194303.0f - 1.0f) sature = true;
  }
  Serial.printf("# seuil = %.2f %% de la base\n", SEUIL_PCT * 100.0f);
  for (int c = 0; c < NCH; c++)
    Serial.printf("# seuil ch%d = %.0f counts (LED %u)\n", c, seuil[c], PINS_LED[c]);
  if (sature) {
    Serial.println(F("# !! canal sature (0x3FFFFF) : la mesure n'aboutit pas."));
    Serial.println(F("#    -> electrode absente, broche tiree, ou canal non valide."));
  }
  Serial.println(F("# t_ms,ch,raw,delta,snr"));
}

// Recalcule les seuils depuis les bases deja mesurees : pas besoin de refaire une
// calibration pour changer la sensibilite en cours d'essai.
static void majSeuils() {
  for (int c = 0; c < NCH; c++) {
    seuil[c] = max(max(SEUIL_PCT * base[c], SEUIL_SIGMA * sigma[c]), SEUIL_MINI);
    touche[c] = false;
  }
  Serial.printf("# seuil = %.2f %% de la base\n", SEUIL_PCT * 100.0f);
  for (int c = 0; c < NCH; c++)
    Serial.printf("# seuil ch%d = %.0f counts\n", c, seuil[c]);
}

static void aide() {
  Serial.println(F("# b=recalibrer  i=entete  h=aide"));
  Serial.println(F("# LED : f=fixe  r=rampe 5s  c=clignote  t=tactile  x=eteint"));
  Serial.println(F("# luminosite : L0..L255 suivi d'un retour ligne (ex. L128)"));
  Serial.println(F("# seuil      : S1..S2000 = DIXIEMES de % de la base (S50 = 5 %)"));
  Serial.println(F("#   plancher : le seuil ne descend jamais sous max(8 sigma, 150"));
  Serial.println(F("#   counts) — en dessous, le curseur n'a plus d'effet"));
  Serial.println(F("# la ligne de base suit les derives (temperature, hygrometrie),"));
  Serial.println(F("# sauf pendant un contact : une note tenue n'est JAMAIS relachee"));
  Serial.println(F("# d'office — un contact > 60 s est seulement signale"));
}

// Niveau commun aux LED non tactiles, calcule sur l'horloge : aucun delay, la
// boucle doit rester libre pour echantillonner le tactile.
static uint8_t niveauCommun() {
  uint32_t t = millis();
  switch (mode) {
    case LED_FIXE:  return luminosite;
    case LED_RAMPE: {                       // triangle : montee puis descente
      uint32_t p = t % RAMPE_MS;
      uint32_t demi = RAMPE_MS / 2;
      uint32_t v = (p < demi) ? p : (RAMPE_MS - p);
      return (uint32_t)luminosite * v / demi;
    }
    case LED_CLIGNOTE: return (t % CLIGN_MS) < (CLIGN_MS / 2) ? luminosite : 0;
    default: return 0;
  }
}

static void majLeds() {
  if (mode == LED_TACTILE) {
    for (int c = 0; c < NCH; c++) analogWrite(PINS_LED[c], touche[c] ? luminosite : 0);
  } else {
    uint8_t v = niveauCommun();
    for (int c = 0; c < NCH; c++) analogWrite(PINS_LED[c], v);
  }
}

static void nommerMode() {
  const char *n = mode == LED_FIXE     ? "fixe"
                : mode == LED_RAMPE    ? "rampe 5 s"
                : mode == LED_CLIGNOTE ? "clignotement"
                : mode == LED_TACTILE  ? "tactile (LED n suit touche n)"
                                       : "eteint";
  Serial.printf("# mode LED : %s, luminosite %u\n", n, luminosite);
}

// "L128\n" -> luminosite 128. Accumule les chiffres jusqu'au retour ligne.
static void lireCommandes() {
  static char quoi   = 0;              // 'L' luminosite, 'S' seuil, 0 = aucun
  static int  valeur = 0;
  while (Serial.available()) {
    int c = Serial.read();
    if (quoi) {
      if (c >= '0' && c <= '9') { valeur = min(valeur * 10 + (c - '0'), 9999); continue; }
      if (quoi == 'L') { luminosite = (uint8_t)min(valeur, 255); nommerMode(); }
      else             { SEUIL_PCT = constrain(valeur, 1, 2000) / 1000.0f; majSeuils(); }
      quoi = 0;
      continue;                        // le caractere de fin est consomme
    }
    switch (c) {
      case 'L': case 'l': quoi = 'L'; valeur = 0; break;
      case 'S': quoi = 'S'; valeur = 0; break;
      case 'b': case 'B': calibrate();                  break;
      case 'i': case 'I': printMeta();                  break;
      case 'h': case 'H': aide();                       break;
      case 'f': case 'F': mode = LED_FIXE;     nommerMode(); break;
      case 'r': case 'R': mode = LED_RAMPE;    nommerMode(); break;
      case 'c': case 'C': mode = LED_CLIGNOTE; nommerMode(); break;
      case 't': case 'T': mode = LED_TACTILE;  nommerMode(); break;
      case 'x': case 'X': mode = LED_ETEINT;   nommerMode(); break;
      default: break;
    }
  }
}

void setup() {
  Serial.begin(115200);
  delay(400);
  Serial.println(F("\n# --- banc cellules : 4 touch + 4 LED ---"));
#if SOC_TOUCH_SENSOR_VERSION == 2
  Serial.println(F("# touch v2 (S2/S3) : valeur croissante au toucher"));
  touchSetConfig(CHG_TIMES, TOUCH_VOLT_LIM_L_0V5, TOUCH_VOLT_LIM_H_2V2);
#else
  Serial.println(F("# touch v1 (ESP32) : valeur decroissante au toucher"));
#endif
  for (int c = 0; c < NCH; c++) { pinMode(PINS_LED[c], OUTPUT); analogWrite(PINS_LED[c], 0); }
  aide();
  calibrate();
  nommerMode();
}

void loop() {
  lireCommandes();
  majLeds();                       // rafraichi a chaque tour : rampe fluide

  static uint32_t dernier = 0;
  if (millis() - dernier < PERIOD_MS) { delay(2); return; }
  dernier = millis();

  uint32_t t = millis();
  for (int c = 0; c < NCH; c++) {
    float raw   = readAvg(PINS_TOUCH[c]);
    float delta = TOUCH_SIGN * (raw - base[c]);

    // Hysteresis : on declenche au seuil, on relache plus bas, pour eviter le
    // battement quand le doigt effleure la limite.
    bool avant = touche[c];
    if (!touche[c] && delta > seuil[c])                 touche[c] = true;
    else if (touche[c] && delta < seuil[c] * HYSTERESIS) touche[c] = false;
    if (touche[c] != avant) {
      if (touche[c]) { debutTouche[c] = t; signale[c] = false; }
      Serial.printf("# ch%d %s\n", c, touche[c] ? "TOUCHE" : "relache");
    }

    if (!touche[c]) {
      // Derive lente absorbee ; le seuil suit la base puisqu'il en est un %.
      base[c] += (raw - base[c]) * TRACK_ALPHA;
      seuil[c] = max(max(SEUIL_PCT * base[c], SEUIL_SIGMA * sigma[c]), SEUIL_MINI);
    } else if (!signale[c] && t - debutTouche[c] > BLOQUE_MS) {
      // On SIGNALE seulement : ce peut etre une note tenue tout a fait legitime.
      signale[c] = true;
      Serial.printf("# ch%d touche depuis %lu s — note tenue, ou base prise pres "
                    "d'un objet ? recalibrer (b) si le canal semble bloque\n",
                    c, (unsigned long)(BLOQUE_MS / 1000));
    }

    Serial.printf("%lu,%d,%.1f,%.1f,%.1f\n", t, c, raw, delta, delta / sigma[c]);
  }
}
