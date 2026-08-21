// =====================================================================
//  NiDMI Seq — BOITE, premier jet
//
//  Coupe d'AVANT EN ARRIERE, prise au milieu de l'instrument (donc a travers
//  l'ecran). On ne cherche pas une solution : on met le clavier dans une
//  enveloppe et on regarde l'encombrement.
//
//  Dessin GROSSIER et volontairement incomplet. Tout est parametrique et les
//  totaux sortent en echo.
// =====================================================================

// 🟡 PERIME SUR UN POINT (2026-08-21) : le ruban n'a plus de rangee propre.
//    Il vit sur le DOS DU PEIGNE, dans la meme piece de plexi que les touches.
//    => supprimer ruban_p et un jeu_rang : la facade passe de 240,4 a ~216,4 mm.
//    Le reste de l'etude (hauteur interieure ~29 mm, volume fragmente) tient.

etiquettes = true;

/* [Facade — de implantation.scad] */
F_prof   = 242;      // profondeur de facade (clavier a 76 mm de profondeur)
marge    = 12;
jeu_rang = 8;

/* [Elements, dans l'ordre avant -> arriere] */
kb_prof  = 76;       // clavier : 52 de touche + 2.2 de fente + 18 de dos + jeux
kb_haut  = 15.3;     // empilement sous la face touchee
kb_noire = 3;        // relief des noires, AU-DESSUS de la face

ruban_p  = 16;

scr_prof = 108.36;   // CrowPanel Advance 7,0"
scr_haut = 16;       // <- le composant le plus epais de la facade

/* [Boitier] */
e_paroi  = 2.5;
e_fond   = 2.5;
h_int    = 22;       // HAUTEUR INTERIEURE — c'est LA variable a eprouver

/* [Ce qu'il reste a loger dessous, et qu'on n'a pas encore place] */
pcb_princ_h = 1.6;   // PCB principal
esp_h       = 3;     // ESP32-S3 (x2 : B et C ; le cerveau est le CrowPanel)
conn_h      = 8;     // connecteurs, borniers, cablage

C_BOITE = [0.42, 0.44, 0.47];
C_KB    = [0.80, 0.88, 0.93];
C_NOIRE = [0.10, 0.10, 0.12];
C_SCR   = [0.12, 0.13, 0.16];
C_RUB   = [0.45, 0.65, 0.55];
C_LIBRE = [0.95, 0.85, 0.55, 0.55];
C_TXT   = [0.15, 0.15, 0.15];

module txt(p,s,t=3,al="left") color(C_TXT) translate(p) text(s,size=t,halign=al,valign="center");
module trait(a,b) color([0.5,0.5,0.55]) hull(){translate(a) circle(0.25,$fn=8); translate(b) circle(0.25,$fn=8);}

// Reperes : y = 0 a l'avant, z = 0 au niveau de la FACE TOUCHEE
y_kb  = marge;
y_rub = y_kb  + kb_prof + jeu_rang;
y_scr = y_rub + ruban_p + jeu_rang;
y_fin = y_scr + scr_prof + marge;

// ---------------- BOITIER ----------------
color(C_BOITE) {
    translate([-e_paroi, -h_int-e_fond]) square([y_fin+2*e_paroi, e_fond]);   // fond
    translate([-e_paroi, -h_int-e_fond]) square([e_paroi, h_int+e_fond+kb_noire+2]);
    translate([y_fin, -h_int-e_fond])    square([e_paroi, h_int+e_fond+kb_noire+2]);
}

// ---------------- ELEMENTS ----------------
color(C_KB)    translate([y_kb, -kb_haut]) square([kb_prof, kb_haut]);
color(C_NOIRE) translate([y_kb+kb_prof*0.45, 0]) square([kb_prof*0.45, kb_noire]);
color(C_RUB)   translate([y_rub, -3]) square([ruban_p, 3]);
color(C_SCR)   translate([y_scr, -scr_haut]) square([scr_prof, scr_haut]);

// Volume encore LIBRE sous les elements — c'est ce qu'il reste pour tout le reste
if (h_int > kb_haut)
    color(C_LIBRE) translate([y_kb, -h_int]) square([kb_prof, h_int-kb_haut]);
if (h_int > scr_haut)
    color(C_LIBRE) translate([y_scr, -h_int]) square([scr_prof, h_int-scr_haut]);
color(C_LIBRE) translate([y_rub, -h_int]) square([ruban_p, h_int-3]);

// ---------------- COTES ----------------
if (etiquettes) {
    txt([0, kb_noire+16], "BOITE — coupe avant/arriere, au milieu de l'instrument", 5);
    txt([0, kb_noire+10], "premier jet : on met le clavier dans une enveloppe et on regarde", 3);

    trait([y_kb+kb_prof/2, -kb_haut],[y_kb+kb_prof/2, -h_int-14]);
    txt([y_kb+kb_prof/2, -h_int-16.5], str("CLAVIER  ", kb_prof, " x ", kb_haut, " mm"), 3, "center");
    trait([y_scr+scr_prof/2, -scr_haut],[y_scr+scr_prof/2, -h_int-14]);
    txt([y_scr+scr_prof/2, -h_int-16.5], str("ECRAN CrowPanel  ", scr_prof, " x ", scr_haut, " mm"), 3, "center");
    trait([y_rub+ruban_p/2, -3],[y_rub+ruban_p/2, -h_int-6]);
    txt([y_rub+ruban_p/2, -h_int-8.5], "ruban", 3, "center");

    txt([y_fin+e_paroi+4, -h_int/2], str("hauteur interieure ", h_int, " mm"), 3);
    txt([y_fin+e_paroi+4, -h_int/2-5], str("hors tout ", h_int+e_fond+kb_noire, " mm"), 3);
    txt([2, -h_int+3], "en jaune : ce qui reste LIBRE sous les elements", 3);
}

echo(str("profondeur interieure = ", y_fin, " mm   (facade ", F_prof, ")"));
echo(str("hauteur interieure ", h_int, "  -> libre sous clavier : ", h_int-kb_haut,
         " mm ;  sous ecran : ", h_int-scr_haut, " mm"));
echo(str("a loger dessous : PCB principal ", pcb_princ_h, " + ESP32 ", esp_h,
         " + connecteurs ", conn_h, " = ", pcb_princ_h+esp_h+conn_h, " mm minimum"));
echo(str("=> hauteur interieure MINIMALE ~ ",
         max(kb_haut, scr_haut) + pcb_princ_h + esp_h + conn_h, " mm"));
