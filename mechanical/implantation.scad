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
variante   = "complete";      // "complete" | "modeste"
disposition = "fonctionnelle"; // "fonctionnelle" | "rangees"

// DISPOSITION FONCTIONNELLE — d'apres nidmi-seq-vst/CONCEPTION.md (§2), qui
// prime sur VISION_ERGO_HARMONIE.md §3 (restee a 5 encodeurs, perimee).
//   Six molettes : Row · Pas · Valeur · Velo · Duree · Master.
//   - Row et Pas = NAVIGATION ("ou je suis")        -> a GAUCHE de l'ecran
//   - Valeur, Velo, Duree = attributs du pas        -> a DROITE de l'ecran
//   - Master = transversal, "BPM, jamais prete"     -> ISOLE, coin haut droit
//     (l'isoler evite de le confondre avec les attributs du pas)
//   Huit boutons en trois groupes : 3 vues · SHIFT · 4 transport.
//   SHIFT est ecarte des autres : c'est un modificateur tenu au pouce pendant
//   qu'on joue, pas une commande qu'on choisit dans une liste.

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
n_enc     = 6;           // Row Pas Valeur Velo Duree Master (CONCEPTION.md §2)
enc_knob  = 20;
enc_pitch = 30;
enc_rangs = 2;           // disposition "rangees" seulement
n_gauche  = 2;           // Row, Pas
n_droite  = 3;           // Valeur, Velo, Duree   (Master est isole)

/* [Boutons PB86] — 3 vues + SHIFT + 4 transport */
n_vues    = 3;
n_transp  = 4;
jeu_grp   = 22;          // respiration entre groupes de boutons
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

fonc = disposition == "fonctionnelle";

// En fonctionnelle, les colonnes d'encodeurs encadrent l'ecran : la largeur
// restante pour l'ecran est bien plus grande qu'en rangees.
col_w    = enc_pitch;
col_g_h  = n_gauche * (enc_knob + 8);
col_d_h  = n_droite * (enc_knob + 8);

// En fonctionnelle l'ECRAN N'IMPOSE PLUS la largeur : c'est le clavier (ou la
// rangee de boutons) qui la fixe, et l'ecran REMPLIT ce qui reste entre les deux
// colonnes de molettes. C'est tout l'interet de les mettre de part et d'autre.
rang1_h = fonc ? max(scr_h, max(col_g_h, col_d_h)) : max(scr_h, enc_h);
// Boutons groupes par fonction : vues | SHIFT | transport
btn_grp_w = n_vues*btn_pitch + jeu_grp + btn_pitch + jeu_grp + n_transp*btn_pitch;
// Le ruban prend sa PROPRE rangee des qu'il ne tient pas a cote des boutons :
// l'y forcer elargissait la facade au-dela du clavier.
rang2_w = fonc ? btn_grp_w : n_btn * btn_pitch + jeu_rang + ruban_l;
rang2_h = max(btn_l, ruban_w) + 6;

avec_kb = variante == "complete";

// En "modeste" boutons et ruban ne partagent plus la largeur du clavier :
// on les empile pour garder un objet compact.
rang2_w_eff = fonc ? rang2_w : (avec_kb ? rang2_w : n_btn * btn_pitch);
rang3_w     = (fonc || !avec_kb) ? ruban_l : 0;
rang3_h     = (fonc || !avec_kb) ? ruban_w + 6 + jeu_rang : 0;

util_w = max(avec_kb ? kb_w + 2*kb_cache : 0, max(rang2_w_eff, rang3_w));
util_h = rang1_h + jeu_rang + rang2_h + rang3_h + (avec_kb ? jeu_kb + kb_h : 0);

// Largeur d'ecran DEDUITE de la place restante (fonctionnelle uniquement)
scr_w_auto = fonc ? util_w - 2*col_w - 2*jeu_rang : scr_w;
scr_h_auto = fonc ? rang1_h : scr_h;

F_W = util_w + 2*marge;
F_H = util_h + 2*marge;

// ---------------- ELEMENTS ----------------
module plaque() { color(C_PLAQUE) cube([F_W, F_H, 2]); }

module ecran(p, w, h) {
    marge_cadre = 10;
    translate(p) {
        color(C_ECRAN) cube([w, h, 3]);
        color(C_WIN) translate([marge_cadre, marge_cadre, 3])
            cube([w - 2*marge_cadre, h - 2*marge_cadre, 0.6]);
    }
}

module molette(x, y) {
    translate([x, y, 2]) color(C_ENC) cylinder(d = enc_knob, h = 9, $fn = 36);
}

module encodeurs(p) {
    for (i = [0 : n_enc-1]) {
        r = floor(i / enc_par_rang);
        c = i % enc_par_rang;
        molette(p[0] + c*enc_pitch + enc_pitch/2,
                p[1] + r*(enc_knob+8) + (enc_knob+8)/2);
    }
}

// Colonne de n molettes, centree verticalement dans la rangee
module colonne(x, y0, n) {
    h = n * (enc_knob + 8);
    for (i = [0 : n-1])
        molette(x + col_w/2, y0 + (rang1_h - h)/2 + i*(enc_knob+8) + (enc_knob+8)/2);
}

// Boutons groupes : vues | SHIFT | transport
module boutons_groupes(p) {
    x0 = p[0];
    for (i = [0 : n_vues-1])
        translate([x0 + i*btn_pitch + (btn_pitch-btn_w)/2, p[1], 2])
            color(C_BTN) cube([btn_w, btn_l, 5]);
    xs = x0 + n_vues*btn_pitch + jeu_grp;
    translate([xs + (btn_pitch-btn_w)/2, p[1], 2])
        color([0.85,0.30,0.20]) cube([btn_w, btn_l, 5]);   // SHIFT, ecarte
    xt = xs + btn_pitch + jeu_grp;
    for (i = [0 : n_transp-1])
        translate([xt + i*btn_pitch + (btn_pitch-btn_w)/2, p[1], 2])
            color(C_BTN) cube([btn_w, btn_l, 5]);
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
y_rang2 = y_rang3 + rang3_h;
y_rang1 = y_rang2 + rang2_h + jeu_rang;

plaque();
if (avec_kb) clavier([marge + (util_w - kb_w)/2, y_kb]);

if (fonc) {
    colonne(marge, y_rang1, n_gauche);                       // Row, Pas
    ecran([marge + col_w + jeu_rang, y_rang1], scr_w_auto, scr_h_auto);
    colonne(marge + col_w + jeu_rang + scr_w_auto + jeu_rang, y_rang1, n_droite);
    // MASTER isole, a l'extremite droite de la rangee de boutons : transversal,
    // "jamais prete". Le mettre la l'ecarte des attributs du pas sans couter de
    // profondeur, contrairement a une rangee dediee.
    molette(marge + util_w - enc_knob/2 - 4, y_rang2 + btn_l/2);
} else {
    ecran([marge, y_rang1 + (rang1_h - scr_h)/2], scr_w, scr_h);
    encodeurs([marge + scr_w + jeu_rang, y_rang1 + (rang1_h - enc_h)/2]);
}
if (fonc) boutons_groupes([marge, y_rang2]); else boutons([marge, y_rang2]);
if (fonc || !avec_kb) ruban([marge, y_rang3]);
else                  ruban([marge + n_btn*btn_pitch + jeu_rang, y_rang2 + 4]);
connectique();

echo(str("VARIANTE ", variante, "  ->  facade ", F_W, " x ", F_H, " mm"));
echo(str("  zone utile ", util_w, " x ", util_h,
         "   rangee haute ", rang1_h, " mm de profondeur"));
if (fonc) echo(str("  ECRAN deduit : ", scr_w_auto, " x ", scr_h_auto, " mm"));
