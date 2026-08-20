// =====================================================================
//  NiDMI Seq — IMPLANTATION DE FAÇADE, deux variantes
//
//    variante = "complete" : l'instrument complet, clavier 27 touches inclus.
//                            Profondeur libre : on privilegie le confort et la
//                            tenue de l'objet plutot qu'une cote imposee.
//    variante = "modeste"  : sans clavier. Le sequenceur seul — ecran,
//                            encodeurs, boutons, ruban. Les notes viennent d'un
//                            clavier MIDI externe.
//
//  Le clavier est IMPORTE de clavier_piano.scad (geometrie de facteur de piano),
//  il n'est pas redessine ici.
//
//  Toutes les cotes de facade sont CALCULEES depuis les composants : changer une
//  dimension de composant recalcule l'objet. Les totaux sortent en echo.
//
//  Rendus : voir README.md
// =====================================================================

use <clavier_piano.scad>

/* [Variante] */
variante = "complete";   // "complete" | "modeste"

/* [Marges et jeux] */
marge    = 12;
jeu_rang = 8;            // entre deux rangees
jeu_kb   = 10;           // au-dessus du clavier

/* [Clavier — doit suivre clavier_piano.scad] */
kb_w     = 294.8;
kb_h     = 58;
kb_cache = 2;            // debord des caches de part et d'autre

/* [Ecran 4,0" — cote INCERTAINE, a mesurer sur l'exemplaire reel] */
scr_w     = 108;
scr_h     = 62;
scr_win_w = 84;          // fenetre active visible
scr_win_h = 56;

/* [Encodeurs] */
n_enc     = 6;           // 6 demandes par la conception (BOM §3)
enc_knob  = 20;
enc_pitch = 30;          // 33 ne passait pas en une rangee : 108+198 > 296
enc_rangs = 2;           // 2 rangees de 3 : libere de la largeur pour l'ecran

/* [Boutons PB86] */
n_btn     = 8;
btn_w     = 12;
btn_l     = 17;
btn_pitch = 20;

/* [Ruban capacitif] */
ruban_l   = 136;         // reduit de 180 : boutons + ruban ne tenaient pas
ruban_w   = 10;

/* [Connectique — tranche arriere] */
jack_d    = 6;           // PJ-320A
n_jack    = 5;           // MIDI IN/OUT + CV GATE CLK RST
usb_w     = 9;

// ---------------- COULEURS ----------------
C_PLAQUE = [0.90, 0.90, 0.88];
C_ECRAN  = [0.10, 0.11, 0.14];
C_WIN    = [0.20, 0.45, 0.70];
C_ENC    = [0.35, 0.36, 0.40];
C_BTN    = [0.80, 0.55, 0.20];
C_RUBAN  = [0.45, 0.65, 0.55];
C_KB     = [0.75, 0.80, 0.85];
C_NOIR   = [0.12, 0.12, 0.14];
C_CONN   = [0.30, 0.32, 0.34];

// ---------------- LARGEURS DE RANGEE ----------------
enc_par_rang = ceil(n_enc / enc_rangs);
enc_w  = enc_par_rang * enc_pitch;
enc_h  = enc_rangs * (enc_knob + 8);

rang1_w = scr_w + jeu_rang + enc_w;                // ecran + encodeurs
rang1_h = max(scr_h, enc_h);
rang2_w = n_btn * btn_pitch + jeu_rang + ruban_l;  // boutons + ruban
rang2_h = max(btn_l, ruban_w) + 6;

avec_kb = variante == "complete";

// En "modeste" boutons et ruban ne partagent plus la largeur du clavier :
// on les empile pour garder un objet compact.
rang2_w_eff = avec_kb ? rang2_w : n_btn * btn_pitch;
rang3_w     = avec_kb ? 0 : ruban_l;
rang3_h     = avec_kb ? 0 : ruban_w + 6 + jeu_rang;

util_w = max(avec_kb ? kb_w + 2*kb_cache : 0, max(rang1_w, max(rang2_w_eff, rang3_w)));
util_h = rang1_h + jeu_rang + rang2_h + rang3_h
         + (avec_kb ? jeu_kb + kb_h : 0);

F_W = util_w + 2*marge;
F_H = util_h + 2*marge;

// ---------------- ELEMENTS ----------------
module plaque() { color(C_PLAQUE) cube([F_W, F_H, 2]); }

module ecran(p) {
    translate(p) {
        color(C_ECRAN) cube([scr_w, scr_h, 3]);
        color(C_WIN) translate([(scr_w-scr_win_w)/2, (scr_h-scr_win_h)/2, 3])
            cube([scr_win_w, scr_win_h, 0.6]);
    }
}

module encodeurs(p) {
    for (i = [0 : n_enc-1]) {
        r = floor(i / enc_par_rang);
        c = i % enc_par_rang;
        translate([p[0] + c*enc_pitch + enc_pitch/2,
                   p[1] + r*(enc_knob+8) + (enc_knob+8)/2, 2])
            color(C_ENC) cylinder(d = enc_knob, h = 9, $fn = 36);
    }
}

module boutons(p) {
    for (i = [0 : n_btn-1])
        translate([p[0] + i*btn_pitch + (btn_pitch-btn_w)/2, p[1], 2])
            color(C_BTN) cube([btn_w, btn_l, 5]);
}

module ruban(p) { translate(p) color(C_RUBAN) cube([ruban_l, ruban_w, 1.5]); }

module clavier(p) {
    translate([p[0], p[1], 2]) {
        color(C_KB) linear_extrude(4) whites_2d();
        color(C_NOIR) translate([0, 0, 4]) linear_extrude(2.5) noires_2d();
    }
}

// Connectique sur la tranche arriere
module connectique() {
    pas = (F_W - 2*marge) / (n_jack + 2);
    for (i = [0 : n_jack-1])
        translate([marge + pas*(i+1), F_H, 1]) rotate([-90,0,0])
            color(C_CONN) cylinder(d = jack_d, h = 4, $fn = 24);
    translate([marge + pas*(n_jack+1) - usb_w/2, F_H, 0])
        color(C_CONN) cube([usb_w, 4, 3.5]);
}

// ---------------- ASSEMBLAGE ----------------
y_kb    = marge;
y_rang3 = marge + (avec_kb ? kb_h + jeu_kb : 0);
y_rang2 = y_rang3 + (avec_kb ? 0 : ruban_w + 6 + jeu_rang);
y_rang1 = y_rang2 + rang2_h + jeu_rang;

plaque();
if (avec_kb) clavier([marge + (util_w - kb_w)/2, y_kb]);

ecran([marge, y_rang1 + (rang1_h - scr_h)/2]);
encodeurs([marge + scr_w + jeu_rang, y_rang1 + (rang1_h - enc_h)/2]);
boutons([marge, y_rang2]);
if (avec_kb) ruban([marge + n_btn*btn_pitch + jeu_rang, y_rang2 + 4]);
else         ruban([marge, y_rang3]);
connectique();

echo(str("VARIANTE ", variante, "  ->  facade ", F_W, " x ", F_H, " mm"));
echo(str("  zone utile ", util_w, " x ", util_h,
         "   rangee ecran+encodeurs ", rang1_w, " x ", rang1_h));
