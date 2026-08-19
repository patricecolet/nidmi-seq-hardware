// Banc d'identification de LED inconnues (ESP32-S3).
//
// MODE AUTO AU DEMARRAGE : la sequence tourne en boucle sans rien demander, pour
// pouvoir recabler / ressouder / retourner la LED en regardant le resultat en
// direct. C'est le mode a utiliser tant qu'on ne sait pas ce qu'on a.
//
//   CABLAGE DU MODE AUTO — la LED se met ENTRE LES DEUX BROCHES :
//
//       GPIO15 ---[ resistance 100-220 ohm ]---[ LED ]--- GPIO17
//
//   Rien a la masse, rien au 3V3. Le banc alterne le sens en permanence :
//   la LED s'allume forcement dans une des deux phases, DANS N'IMPORTE QUEL SENS.
//   Plus de question de polarite — et le serie annonce quelle phase eclaire,
//   ce qui donne l'anode.
//
// Commandes serie (115200), si on veut sortir de l'auto :
//   s = ALLUMAGE FIXE (pour observer une diffusion) : appuis successifs =
//       sens 1 -> sens 2 -> eteint. C'est le mode a utiliser des que la LED est
//       identifiee et qu'on veut regarder la lumiere, pas la faire clignoter.
//   m = SONDE Vf : mesure en continu la tension de seuil de la LED touchee, et
//       annonce la famille de couleur. Sert a TRIER un lot de LED inconnues.
//
//       CABLAGE DE LA SONDE :
//           GPIO15 ---[ 100 ohm ]---+--- pointe 1 --> anode LED
//                                   |
//                                 GPIO3 (mesure)      cathode LED --> GND (pointe 2)
//
//       Le seuil depend de la chimie de la puce, donc de la couleur :
//         ~1,8-2,2 V  rouge          ~2,2-2,6 V  jaune / vert traditionnel
//         ~2,7-3,1 V  BLEU, BLANC, vert InGaN (meme puce bleue ; l'oeil separe
//                     le blanc du bleu, le phosphore faisant le reste)
//       LED a l'envers ou pointe qui ne touche pas = circuit ouvert = ~3,3 V.
//
//   a = revenir au mode auto (defaut)
//   1 = LED simple, rampe sur PIN_SIMPLE (anode via resistance, cathode a GND)
//   2 = adressable SK6812/WS2812 sur PIN_DATA (VDD 5 V, masse commune)
//   3 = RGB 4 pattes, un canal a la fois
//   0 = tout eteindre        h = aide
//
// Reconnaitre une LED a 2 pattes, en mode auto :
//   Les deux sens ont une signature visuelle : sens 1 = UN ECLAIR LONG (anode du
//   cote GPIO15), sens 2 = TROIS CLIGNOTEMENTS COURTS (anode du cote GPIO17).
//   Le motif qui allume la LED donne donc directement le sens, sans port serie.
//
//   - allumee dans UNE SEULE phase, couleur fixe ....... monochrome
//   - allumee dans LES DEUX phases, couleur differente . bicolore antiparallele
//   - allumee et changeant de couleur TOUTE SEULE ...... RGB auto-clignotante
//     (un CI est integre, la sequence est figee, il n'y a rien a piloter)
//   - rien dans aucune phase .......................... continuite a verifier
//     AVANT de suspecter la LED : resistance et deux liaisons a l'ohmmetre.
//     Ces boitiers minuscules se soudent mal sur du fil volant.
//
// !! Tension selon la couleur. Rouge/jaune/vert traditionnel : seuil ~2 V, 3,3 V
//    suffit. Blanche/bleue/verte InGaN : seuil ~3,0-3,2 V — en 3,3 V il ne reste
//    presque rien aux bornes de la resistance, la LED reste quasi eteinte et on
//    croit a tort qu'elle est morte. Pour celles-la, passer au 5 V.

// Broches libres : 4/5 = I2C, 8/9/10/12 = electrodes touch, 19/20 = USB.
static const uint8_t PIN_A      = 15;   // mode auto + bicolore : un cote de la LED
static const uint8_t PIN_B      = 17;   // mode auto + bicolore : l'autre cote
static const uint8_t PIN_SIMPLE = 15;   // mode 1 : anode via resistance
static const uint8_t PIN_DATA   = 16;   // mode 2 : DIN adressable
static const uint8_t PIN_R = 15, PIN_G = 16, PIN_BL = 17;   // mode 3
static const uint8_t PIN_MESURE = 3;    // mode m : ADC1, broche libre sur la carte
static bool sonde = false;

static const bool RGB_CATHODE_COMMUNE = true;

// Mode par defaut : lumiere continue, sens indifferent — c'est celui qui sert a
// TRIER un lot a l'oeil. L'alternance rapide (4 ms) fait que la LED est allumee
// la moitie du temps quel que soit son sens de branchement, et l'oeil la voit fixe.
static bool modeCouleur = false;
static bool autoMode = true;
static uint8_t fixe = 0;   // 0 = eteint, 1 = sens 1, 2 = sens 2

static void aide() {
  Serial.println(F("\n--- banc LED ---"));
  Serial.println(F("CABLAGE AUTO : GPIO15 --[100-220 ohm]--[LED]-- GPIO17"));
  Serial.println(F("               rien a la masse ; le sens n'a pas d'importance"));
  Serial.println(F("c = COULEUR : lumiere continue, sens indifferent — pour trier un lot"));
  Serial.println(F("a = SENS/POLARITE (defaut) : eclair long = anode cote GPIO15,"));
  Serial.println(F("                    3 clignotements = anode cote GPIO17"));
  Serial.println(F("s = allumage FIXE   0 = eteindre   h = aide"));
  Serial.println(F("m = sonde Vf (tri d'un lot) : 15 --[100 ohm]--+-- anode ; GPIO3 sur le +"));
  Serial.println(F("1 = LED simple sur 15    2 = adressable sur 16   3 = RGB 4 pattes"));
}

static void toutEteindre() {
  for (uint8_t p : {PIN_A, PIN_B, PIN_DATA, PIN_G}) {
    pinMode(p, OUTPUT);
    digitalWrite(p, LOW);
  }
  neopixelWrite(PIN_DATA, 0, 0, 0);
}

// Une phase : `haut` a 3,3 V, `bas` a 0 -> le courant va de `haut` vers `bas`.
// Les deux sens ont une SIGNATURE VISUELLE differente, pour qu'on lise l'anode
// sans avoir besoin du port serie :
//   sens 1 = UN ECLAIR LONG        -> anode du cote GPIO15
//   sens 2 = TROIS CLIGNOTEMENTS   -> anode du cote GPIO17
static void phase(uint8_t haut, uint8_t bas, int impulsions, int duree) {
  pinMode(haut, OUTPUT);
  pinMode(bas, OUTPUT);
  digitalWrite(bas, LOW);
  for (int i = 0; i < impulsions; i++) {
    digitalWrite(haut, HIGH);
    delay(duree);
    digitalWrite(haut, LOW);
    if (i + 1 < impulsions) delay(duree);
  }
}

// Allumage continu pleine puissance, pour observer une diffusion.
static void allumageFixe() {
  fixe = (fixe + 1) % 3;
  autoMode = false;
  pinMode(PIN_A, OUTPUT);
  pinMode(PIN_B, OUTPUT);
  if (fixe == 0) {
    digitalWrite(PIN_A, LOW); digitalWrite(PIN_B, LOW);
    Serial.println(F("fixe : eteint"));
  } else if (fixe == 1) {
    digitalWrite(PIN_A, HIGH); digitalWrite(PIN_B, LOW);
    Serial.println(F("fixe : sens 1 (GPIO15 -> GPIO17)"));
  } else {
    digitalWrite(PIN_A, LOW); digitalWrite(PIN_B, HIGH);
    Serial.println(F("fixe : sens 2 (GPIO17 -> GPIO15)"));
  }
  Serial.println(F("  bleue/blanche faiblarde ? c'est le seuil ~3 V : passer au 5 V"));
  Serial.println(F("  (5 V --[100 ohm]-- anode [LED] cathode -- GND, sans GPIO)"));
}

// Nomme la famille de couleur d'apres la tension de seuil mesuree.
static const char *famille(int mv) {
  if (mv > 3150) return "rien (circuit ouvert, LED a l'envers, ou pointe qui ne touche pas)";
  if (mv > 2650) return "BLEU / BLANC / vert InGaN";
  if (mv > 2250) return "jaune / vert traditionnel";
  if (mv > 1550) return "ROUGE";
  if (mv > 300)  return "infrarouge, ou LED speciale";
  return "court-circuit";
}

static void sondeVf() {
  pinMode(PIN_A, OUTPUT);
  digitalWrite(PIN_A, HIGH);          // alimente la maille via la resistance
  int somme = 0;
  for (int i = 0; i < 16; i++) somme += analogReadMilliVolts(PIN_MESURE);
  int mv = somme / 16;

  // N'annonce que les changements, sinon le port serie devient illisible.
  static int dernier = -9999;
  if (abs(mv - dernier) > 60) {
    dernier = mv;
    Serial.printf("Vf = %d mV  ->  %s\n", mv, famille(mv));
  }
  delay(120);
}

// Alternance rapide des deux sens : allume n'importe quelle LED, dans n'importe
// quel sens, sans clignotement perceptible.
static void couleurContinue() {
  pinMode(PIN_A, OUTPUT);
  pinMode(PIN_B, OUTPUT);
  digitalWrite(PIN_B, LOW);  digitalWrite(PIN_A, HIGH); delay(4);
  digitalWrite(PIN_A, LOW);  digitalWrite(PIN_B, HIGH); delay(4);
  digitalWrite(PIN_B, LOW);
}

static void ledSimple() {
  Serial.println(F("LED simple : rampe sur GPIO15 (cathode a GND)"));
  for (int v = 0;   v <= 255; v += 5) { analogWrite(PIN_SIMPLE, v); delay(12); }
  for (int v = 255; v >= 0;   v -= 5) { analogWrite(PIN_SIMPLE, v); delay(12); }
  analogWrite(PIN_SIMPLE, 0);
}

static void adressable() {
  const char *noms[] = {"ROUGE", "VERT", "BLEU", "BLANC"};
  const uint8_t rgb[][3] = {{60,0,0}, {0,60,0}, {0,0,60}, {60,60,60}};
  for (int i = 0; i < 4; i++) {
    Serial.printf("  %s\n", noms[i]);
    neopixelWrite(PIN_DATA, rgb[i][0], rgb[i][1], rgb[i][2]);
    delay(1200);
  }
  neopixelWrite(PIN_DATA, 0, 0, 0);
  Serial.println(F("  couleurs dans le desordre ? ordre GRB au lieu de RGB."));
}

static void rgbQuatrePattes() {
  const uint8_t pins[] = {PIN_R, PIN_G, PIN_BL};
  const int on = RGB_CATHODE_COMMUNE ? HIGH : LOW;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) { pinMode(pins[j], OUTPUT); digitalWrite(pins[j], !on); }
    digitalWrite(pins[i], on);
    Serial.printf("  GPIO%u allumee -> note la couleur\n", pins[i]);
    delay(1500);
  }
  for (int j = 0; j < 3; j++) digitalWrite(pins[j], !on);
}

void setup() {
  Serial.begin(115200);
  delay(600);
  toutEteindre();
  aide();
  Serial.println(F("\n>>> MODE SENS actif. Regarde QUEL motif allume ta LED :"));
  Serial.println(F("      UN ECLAIR LONG      -> anode du cote GPIO15"));
  Serial.println(F("      TROIS CLIGNOTEMENTS -> anode du cote GPIO17"));
  Serial.println(F("    les deux, couleurs differentes -> bicolore antiparallele"));
  Serial.println(F("    aucun -> verifier la continuite avant de suspecter la LED"));
  Serial.println(F("    ('c' = mode couleur : lumiere continue, sens indifferent) <<<"));
}

void loop() {
  if (Serial.available()) {
    int c = Serial.read();
    if (c == 'c' || c == 'C') {
      modeCouleur = true; autoMode = false; sonde = false;
      Serial.println(F("mode couleur : lumiere continue, sens indifferent"));
    }
    else if (c == 'a' || c == 'A') {
      autoMode = true; modeCouleur = false; sonde = false;
      Serial.println(F("mode sens : eclair long = anode cote GPIO15, 3 clignotements = GPIO17"));
    }
    else if (c == '0') {
      autoMode = false; modeCouleur = false; sonde = false;
      toutEteindre(); Serial.println(F("eteint"));
    }
    else if (c == 's' || c == 'S') { modeCouleur = false; allumageFixe(); }
    else if (c == 'm' || c == 'M') {
      autoMode = false; modeCouleur = false; sonde = true;
      Serial.println(F("sonde Vf : touche une LED avec les deux pointes"));
      Serial.println(F("  anode sur la pointe alimentee, cathode a la masse ;"));
      Serial.println(F("  si ca annonce 'rien', retourne la LED."));
    }
    else if (c == 'h' || c == 'H') aide();
    else if (c == '1')        { autoMode = false; modeCouleur = false; ledSimple(); }
    else if (c == '2')        { autoMode = false; modeCouleur = false; adressable(); }
    else if (c == '3')        { autoMode = false; modeCouleur = false; rgbQuatrePattes(); }
  }
  if (sonde)      { sondeVf();         return; }
  if (modeCouleur){ couleurContinue(); return; }
  if (!autoMode)  { delay(20);         return; }

  static uint32_t cycle = 0;
  Serial.printf("cycle %lu : eclair long (anode cote GPIO%u), "
                "puis 3 clignotements (anode cote GPIO%u)\n",
                (unsigned long)++cycle, PIN_A, PIN_B);
  phase(PIN_A, PIN_B, 1, 1200);   // sens 1 : un eclair long
  delay(500);
  phase(PIN_B, PIN_A, 3, 130);    // sens 2 : trois clignotements courts
  delay(1000);
}
