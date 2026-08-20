// =====================================================================
//  NiDMI Seq — COUPE TRANSVERSALE d'une cellule de clavier
//
//  Dessin de PRINCIPE, dessine explicitement en 2D (et non decoupe dans un
//  modele 3D) pour que ce qu'on voit soit exactement ce qu'on a voulu montrer.
//
//  Vue : coupe en travers du clavier. On voit deux blanches et la noire posee
//  a cheval entre elles.
//
//  !! LES COUCHES MINCES SONT EXAGEREES pour rester lisibles : l'ITO fait
//     0,125 mm reel, le fond sombre ~0,05. Les cotes REELLES sont ecrites en
//     regard. Tout le reste est a l'echelle.
//
//  Rendu : voir README.md
// =====================================================================

/* [Affichage] */
etiquettes = true;
exag_mince = 20;        // facteur d'exageration des couches minces

/* [Empilement — cotes reelles en mm] */
e_avant    = 2.0;      // plaque avant PMMA : la surface touchee
e_ito      = 0.125;    // film ITO/PET, colle au dos de la plaque avant
e_entrefer = 1.5;      // ENTREFER : preserve la reflexion totale du guide
e_guide    = 10.0;     // guide de lumiere, LED en tranche
e_fond     = 0.05;     // fond sombre absorbant (peinture ou film)
e_mousse   = 3.0;      // mousse de repartition
e_arriere  = 2.0;      // plaque arriere, vissee en peripherie

e_noire    = 3.0;      // touche noire posee sur la plaque avant (relief)
d_fil      = 0.6;      // broche de resistance servant de bus bar
p_rainure  = 0.4;      // rainure de separation, cote doigt
p_grav     = 0.6;      // profondeur des points de gravure

/* [Geometrie laterale] */
pas_w      = 18.5;     // pas des blanches
larg_noire = 10.8;
n_pas      = 3;        // nombre de pas montres
L          = n_pas * pas_w;

// ---------------- COULEURS ----------------
C_PMMA   = [0.86, 0.91, 0.94];
C_ITO    = [0.35, 0.75, 0.55];
C_AIR    = [1.00, 1.00, 1.00, 0.0];
C_GUIDE  = [0.80, 0.88, 0.93];
C_FOND   = [0.12, 0.12, 0.14];
C_MOUSSE = [0.75, 0.65, 0.55];
C_ARR    = [0.45, 0.47, 0.50];
C_NOIRE  = [0.10, 0.10, 0.12];
C_FIL    = [0.72, 0.45, 0.20];
C_GARDE  = [0.20, 0.30, 0.75];
C_ITO_N  = [0.60, 0.30, 0.70];   // electrode de la NOIRE — couleur franchement
                                 // distincte : une nuance de vert etait illisible
C_TXT    = [0.15, 0.15, 0.15];

function ep(e) = e < 0.5 ? e * exag_mince : e;   // couches minces exagerees

// Cotes empilees depuis le HAUT (y = 0 = surface touchee, vers le bas negatif)
y_avant    = 0;
y_ito      = y_avant    - e_avant;
y_entrefer = y_ito      - ep(e_ito);
y_guide    = y_entrefer - e_entrefer;
y_fond     = y_guide    - e_guide;
y_mousse   = y_fond     - ep(e_fond);
y_arriere  = y_mousse   - e_mousse;
y_bas      = y_arriere  - e_arriere;

module couche(y, e, coul) { color(coul) translate([0, y - e]) square([L, e]); }

module texte(p, s, taille = 1.5, al = "left")
    color(C_TXT) translate(p) text(s, size = taille, halign = al, valign = "center");

module trait(p1, p2) color([0.55,0.55,0.58])
    hull() { translate(p1) circle(0.06, $fn=8); translate(p2) circle(0.06, $fn=8); }

// ---------------- COUCHES ----------------
// Plaque avant, avec les rainures de separation cote doigt
color(C_PMMA) difference() {
    translate([0, y_avant - e_avant]) square([L, e_avant]);
    for (i = [1 : n_pas-1])
        translate([i*pas_w - 0.6, y_avant - p_rainure]) square([1.2, p_rainure + 0.1]);
}

// ITO au dos de la plaque avant — la couche qui doit etre PRES DU DOIGT.
// ELLE N'EST PAS CONTINUE : une electrode par touche, separee par un intervalle
// ou passe la GARDE A LA MASSE. C'est l'electrode qui separe les touches, pas la
// matiere — le PMMA, lui, reste un bloc plein.
j_elec = 2.4;
x_n0 = pas_w - larg_noire/2;              // bord gauche de la noire
x_n1 = x_n0 + larg_noire;                 // bord droit

// Electrodes des BLANCHES : elles s'ARRETENT de part et d'autre de la noire,
// exactement comme les talons de blanche s'arretent de part et d'autre d'une
// touche noire sur un piano. Sinon toucher la noire declencherait les blanches.
module elec(x0, x1)
    color(C_ITO) translate([x0, y_ito - ep(e_ito)]) square([x1 - x0, ep(e_ito)]);

elec(j_elec/2,            x_n0 - j_elec/2);          // blanche 0, tronquee
elec(x_n1 + j_elec/2,     2*pas_w - j_elec/2);       // blanche 1, tronquee
elec(2*pas_w + j_elec/2,  3*pas_w - j_elec/2);       // blanche 2, entiere

// Electrode de la NOIRE : dans le meme plan, dans l'intervalle laisse libre.
color(C_ITO_N) translate([x_n0 + j_elec/2, y_ito - ep(e_ito)])
    square([larg_noire - j_elec, ep(e_ito)]);

// Gardes a la masse dans chaque intervalle
for (x = [x_n0, x_n1, 2*pas_w])
    color(C_GARDE) translate([x, y_ito - ep(e_ito)/2]) circle(d = d_fil, $fn = 20);

// Entrefer : rien a dessiner, mais il loge les fils de bus bar
for (i = [0 : n_pas-1])
    color(C_FIL) translate([i*pas_w + 1.2, y_entrefer - d_fil/2]) circle(d = d_fil, $fn = 20);
for (i = [1 : n_pas])
    color(C_FIL) translate([i*pas_w - 1.2, y_entrefer - d_fil/2]) circle(d = d_fil, $fn = 20);

// Guide de lumiere, avec les points de gravure creuses au DOS
color(C_GUIDE) difference() {
    translate([0, y_guide - e_guide]) square([L, e_guide]);
    for (x = [2 : 2.6 : L-2])
        translate([x, y_guide - e_guide]) circle(d = p_grav*1.6, $fn = 16);
}

couche(y_fond,   ep(e_fond), C_FOND);
couche(y_mousse, e_mousse,   C_MOUSSE);
couche(y_arriere, e_arriere, C_ARR);

// Touche noire : son PROPRE guide de lumiere, avec sa gravure sur la face
// INFERIEURE et sa LED injectee par la tranche arriere (hors de ce plan de
// coupe : l'injection se voit en coupe longitudinale, pas transversale).
x_noire = pas_w - larg_noire/2;
color(C_NOIRE) difference() {
    translate([x_noire, 0]) square([larg_noire, e_noire]);
    for (x = [x_noire + 1.2 : 1.8 : x_noire + larg_noire - 1])
        translate([x, 0]) circle(d = 0.5, $fn = 12);
}

// ---------------- ETIQUETTES ----------------
if (etiquettes) {
    xr = L + 3;
    lignes = [
        [y_avant - e_avant/2,        str("plaque avant PMMA  ", e_avant, " mm  — surface touchee")],
        [y_ito - ep(e_ito)/2,        str("ITO + bus bar      ", e_ito, " mm  (grossi x", exag_mince, ")")],
        [y_entrefer - e_entrefer/2,  str("ENTREFER           ", e_entrefer, " mm  — garde la reflexion totale")],
        [y_guide - e_guide/2,        str("guide de lumiere   ", e_guide, " mm  — LED en tranche, gravure au dos")],
        [y_fond - ep(e_fond)/2,      str("fond sombre        ", e_fond, " mm  (grossi)")],
        [y_mousse - e_mousse/2,      str("mousse             ", e_mousse, " mm  — repartit la pression")],
        [y_arriere - e_arriere/2,    str("plaque arriere     ", e_arriere, " mm  — vissee en peripherie")]
    ];
    for (l = lignes) { trait([L, l[0]], [xr - 0.8, l[0]]); texte([xr, l[0]], l[1]); }

    texte([x_noire + larg_noire/2, e_noire + 2.4],
          str("NOIRE ", e_noire, " mm — guide autonome, gravure au dos"), 1.5, "center");
    trait([x_noire + larg_noire/2, e_noire], [x_noire + larg_noire/2, e_noire + 1.9]);

    // cotes doigt -> electrode, les deux valeurs du montage
    // Reperage explicite des deux electrodes, avec traits de rappel
    y_e = y_ito - ep(e_ito)/2;
    trait([x_noire + larg_noire/2, y_e], [x_noire + larg_noire/2, y_e - 4.5]);
    texte([x_noire + larg_noire/2, y_e - 5.6],
          str("electrode de la NOIRE (violet) — doigt a ", e_noire + e_avant, " mm"),
          1.5, "center");
    trait([2*pas_w + pas_w/2, y_e], [2*pas_w + pas_w/2, y_e - 8.5]);
    texte([2*pas_w + pas_w/2, y_e - 9.6],
          str("electrode d'une BLANCHE (vert) — doigt a ", e_avant, " mm"), 1.5, "center");
    texte([0, e_noire + 6], "COUPE EN TRAVERS DU CLAVIER — deux blanches, une noire", 2.2);
    texte([0, y_bas - 3],
          "l'entrefer sert deux fois : reflexion totale du guide, et logement des fils de bus bar", 1.5);
    texte([0, y_bas - 5.6],
          "electrode DECOUPEE par touche (vert) ; garde a la masse entre cellules (bleu) ; le PMMA reste plein", 1.5);
    texte([0, y_bas - 8.0],
          "les electrodes des blanches s'ARRETENT de part et d'autre de la noire — sinon la toucher les declencherait", 1.5);
    texte([0, y_bas - 10.4],
          "couches minces exagerees pour la lisibilite ; cotes reelles en regard", 1.3);
}
