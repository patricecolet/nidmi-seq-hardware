// =====================================================================
//  NiDMI Seq — Façade plexi (variante capacitive)  — LAYOUT VISION
//  Clavier PIANO 27 touches capacitives (16 blanches + 11 noires)
//  + 5 encodeurs + 8 boutons PB86 (corps 12×17 PCB-mount, cap illuminé,
//    LED intégrée mono/bi-couleur) + ruban capacitif
//  + écran 4,0" 480x320.  Source ergo : VST/VISION_ERGO_HARMONIE.md §3
//
//  Empilement : PLEXI / GRILLE espaceur (light wells) / PCB (électrodes
//  capacitives + SK6812).  explode = 0 assemblé, >0 éclaté.
//  show_dims = true -> côtes paramétriques (auto-lues des variables).
//
//  Rendus : voir README.md
// =====================================================================

// ---------------- PARAMÈTRES ----------------
explode    = 0;       // 0 = assemblé ; >0 = écarte les couches
show_dims  = true;    // côtes paramétriques (vue de dessus)

margin     = 12;

// Épaisseurs
plexi_t    = 2;
spacer_t   = 3;
pcb_t      = 1.6;

// --- Clavier piano ---
white_n    = 16;      // blanches (= 16 pas en vue PATTERN)
Ww         = 17;      // largeur blanche (-3 mm)
gap_w      = 1.5;     // jeu entre blanches
Wh         = 58;      // hauteur blanche
Wb         = 12;      // largeur noire
Bh         = 36;      // hauteur noire
key_clr    = 1.2;     // garde autour des noires (notch des blanches)

// --- Encodeurs (5, tous push) ---
n_enc      = 5;
enc_knob   = 20;
enc_shaft  = 7;
enc_pitch  = 40;

// --- Boutons de fonction (8 : PB86, corps 12×17 PCB-mount, cap illuminé) ---
//     ROW HARMONY PROJET SHIFT PLAY STOP REC EXPORT — mécaniques, LED mono/bi-couleur
n_btn      = 8;
btn_w      = 12;      // largeur corps/cap PB86
btn_l      = 17;      // longueur corps/cap PB86
btn_hole_w = 12.5;    // perçage plexi
btn_hole_l = 17.5;
btn_cap_h  = 10;      // hauteur du cap au-dessus du PCB
btn_pitch  = 24;

// --- Ruban capacitif (slider tactile natif ESP32-S3, sous le plexi) ---
ribbon_len = 180;
ribbon_w   = 10;

// --- Écran 4,0" 480x320 ILI9488 SPI (zone active ~85x56, paysage) ---
screen_w   = 85;
screen_h   = 56;

// LED
led_size   = 3.5;
led_h      = 1.6;

// --- Boîtier ---
show_box   = false;   // true = parois + fond (objet fermé)
box_wall   = 2.5;
box_cavity = 22;      // profondeur cavité sous le PCB (modules ESP32 + connecteurs)

$fn = 40;

// ---------------- COULEURS ----------------
C_PLEXI  = [0.55,0.75,0.95,0.30];
C_SPACER = [0.20,0.20,0.22];
C_PCB    = [0.05,0.35,0.15];
C_WHITE  = [0.85,0.85,0.88];   // électrode blanche
C_BLACK  = [0.15,0.15,0.18];   // électrode noire
C_COPPER = [0.80,0.55,0.20];
C_LED    = [0.95,0.95,0.85];
C_KNOB   = [0.10,0.10,0.12];
C_CAP    = [0.80,0.85,0.90,0.55];  // cap carré translucide (illuminé)
C_BOX    = [0.30,0.32,0.36];       // boîtier (parois + fond)
C_DIM    = [0.85,0.10,0.10];

// ---------------- GÉOMÉTRIE DÉRIVÉE ----------------
pitch_w  = Ww + gap_w;
kb_x0    = margin;                 // bord gauche 1ère blanche
kb_y0    = margin;                 // bas du clavier
kb_w     = white_n * pitch_w;      // largeur clavier

W = 2*margin + kb_w;               // largeur façade (calculée)
H = 172;                           // hauteur façade (bande ruban au-dessus du clavier)

function white_left(i)   = kb_x0 + i*pitch_w;
function white_cx(i)     = white_left(i) + Ww/2;
function has_black(i)    = let(n = i % 7) (n==0||n==1||n==3||n==4||n==5);  // C D F G A
// noires : [x centre, y bas]
black_list = [ for (i=[0:white_n-2]) if (has_black(i))
                 [ white_cx(i) + pitch_w/2, kb_y0 + Wh - Bh ] ];

// Zone haute (écran + encodeurs + boutons)
scr_cx = margin + screen_w/2;
scr_cy = H - margin - screen_h/2;
ctrl_x0 = margin + screen_w + 20;          // début zone contrôles (droite de l'écran)
enc_y  = H - margin - enc_knob/2 - 6;
enc_pos = [ for (j=[0:n_enc-1]) [ ctrl_x0 + enc_knob/2 + j*enc_pitch, enc_y ] ];
btn_y  = enc_y - 32;
btn_pos = [ for (j=[0:n_btn-1]) [ ctrl_x0 + btn_w/2 + j*btn_pitch, btn_y ] ];

// Ruban : bande horizontale au-dessus du clavier
ribbon_x = kb_x0;
ribbon_y = kb_y0 + Wh + 17;

// Hauteurs Z (éclaté)
z_pcb    = 0;
z_spacer = pcb_t + explode;
z_plexi  = pcb_t + spacer_t + 2*explode;
z_floor  = -box_cavity;            // dessus du fond du boîtier

// =====================================================================
//  FORMES 2D (réutilisées par les 3 couches)
// =====================================================================
module whites_2d() {
    difference() {
        for (i=[0:white_n-1]) translate([white_left(i), kb_y0]) square([Ww, Wh]);
        // notch : on creuse l'emprise des noires (+ garde)
        for (b=black_list)
            translate([b[0]-Wb/2-key_clr, b[1]-key_clr])
                square([Wb+2*key_clr, (kb_y0+Wh)-(b[1]-key_clr)+0.1]);
    }
}
module blacks_2d() { for (b=black_list) translate([b[0]-Wb/2, b[1]]) square([Wb, Bh]); }
module ribbon_2d() { translate([ribbon_x, ribbon_y-ribbon_w/2]) square([ribbon_len, ribbon_w]); }
module screen_2d() { translate([scr_cx-screen_w/2, scr_cy-screen_h/2]) square([screen_w, screen_h]); }

// =====================================================================
//  COUCHE PCB : électrodes + LEDs + encodeurs + écran
// =====================================================================
module layer_pcb() {
    translate([0,0,z_pcb]) {
        color(C_PCB) cube([W, H, pcb_t]);
        // électrodes capacitives
        color(C_WHITE) translate([0,0,pcb_t]) linear_extrude(0.25) whites_2d();
        color(C_BLACK) translate([0,0,pcb_t]) linear_extrude(0.5)  blacks_2d();
        // ruban capacitif (électrode)
        color(C_COPPER) translate([0,0,pcb_t]) linear_extrude(0.25) ribbon_2d();
        // LEDs par touche
        for (i=[0:white_n-1]) led([white_cx(i), kb_y0+11]);
        for (b=black_list)    led([b[0], b[1]+Bh/2]);
        // encodeurs
        for (p=enc_pos) color(C_KNOB) translate([p[0],p[1],pcb_t]) cylinder(d=enc_knob, h=14);
        // boutons PB86 : LED intégrée (mono/bi-couleur) sous cap 12×17 translucide
        for (p=btn_pos) {
            led(p);
            color(C_CAP) translate([p[0]-btn_w/2, p[1]-btn_l/2, pcb_t]) cube([btn_w, btn_l, btn_cap_h]);
        }
        // module écran
        color([0.1,0.1,0.1]) translate([scr_cx-screen_w/2, scr_cy-screen_h/2, pcb_t]) cube([screen_w, screen_h, 4]);
        color([0.15,0.15,0.22]) translate([scr_cx-screen_w/2+2, scr_cy-screen_h/2+2, pcb_t+4]) cube([screen_w-4, screen_h-4, 0.5]);
    }
}
module led(p) { color(C_LED) translate([p[0]-led_size/2, p[1]-led_size/2, pcb_t]) cube([led_size, led_size, led_h]); }

// =====================================================================
//  COUCHE GRILLE espaceur : puits de lumière + passages
// =====================================================================
module layer_spacer() {
    translate([0,0,z_spacer])
    color(C_SPACER) difference() {
        cube([W, H, spacer_t]);
        translate([0,0,-1]) linear_extrude(spacer_t+2) offset(r=1) whites_2d();
        translate([0,0,-1]) linear_extrude(spacer_t+2) offset(r=1) blacks_2d();
        translate([0,0,-1]) linear_extrude(spacer_t+2) offset(r=1) ribbon_2d();
        translate([0,0,-1]) linear_extrude(spacer_t+2) offset(r=1) screen_2d();
        for (p=enc_pos) translate([p[0],p[1],-1]) cylinder(d=enc_knob+2, h=spacer_t+2);
        for (p=btn_pos) translate([p[0]-btn_w/2-1, p[1]-btn_l/2-1, -1]) cube([btn_w+2, btn_l+2, spacer_t+2]);
    }
}

// =====================================================================
//  COUCHE PLEXI : dalle translucide + gravures + perçages + fenêtre
// =====================================================================
module layer_plexi() {
    translate([0,0,z_plexi])
    color(C_PLEXI) difference() {
        cube([W, H, plexi_t]);
        // gravures de repère (sous-face, peu profondes)
        translate([0,0,-0.01]) linear_extrude(0.4) offset(r=1.5) whites_2d();
        translate([0,0,-0.01]) linear_extrude(0.4) offset(r=1.5) blacks_2d();
        // gravure ruban (sous-face)
        translate([0,0,-0.01]) linear_extrude(0.4) offset(r=1.5) ribbon_2d();
        // perçages encodeurs + boutons (traversants)
        for (p=enc_pos) translate([p[0],p[1],-1]) cylinder(d=enc_shaft, h=plexi_t+2);
        for (p=btn_pos) translate([p[0]-btn_hole_w/2, p[1]-btn_hole_l/2, -1]) cube([btn_hole_w, btn_hole_l, plexi_t+2]);
        // fenêtre écran (traversante)
        translate([0,0,-1]) linear_extrude(plexi_t+2) screen_2d();
    }
}

// =====================================================================
//  BOÎTIER : parois + fond + connecteurs (tranche arrière)
// =====================================================================
module layer_box() {
    wall_top = pcb_t + spacer_t + plexi_t;   // hauteur sous le plexi (couvercle)
    color(C_BOX) difference() {
        union() {
            translate([0,0,z_floor-box_wall]) cube([W, H, box_wall]);            // fond
            translate([0,0,z_floor]) cube([W, H, wall_top - z_floor]);           // bloc parois
        }
        // cavité interne
        translate([box_wall, box_wall, z_floor]) cube([W-2*box_wall, H-2*box_wall, wall_top - z_floor + 1]);
        // évidement pour loger l'empilement plexi/spacer/PCB par le haut
        translate([box_wall, box_wall, pcb_t]) cube([W-2*box_wall, H-2*box_wall, spacer_t + plexi_t + 1]);
        // ---- Connecteurs sur la tranche arrière (+Y) ----
        // de gauche à droite : USB-C | MIDI IN | MIDI OUT | CV | GATE | CLK | RST
        conn_z = z_floor + 9;
        // USB-C (rectangulaire)
        translate([34, H-box_wall-1, conn_z-1.75]) cube([9, box_wall+2, 3.5]);
        // 6 jacks 3,5 mm (MIDI IN/OUT + CV/GATE/CLK/RST)
        for (x = [78, 106, 150, 178, 206, 234])
            translate([x, H-box_wall-1, conn_z]) rotate([-90,0,0]) cylinder(d=6, h=box_wall+2);
    }
}

// =====================================================================
//  CÔTES paramétriques (valeurs auto-lues des variables)
// =====================================================================
zdim = 20;   // plan des côtes, au-dessus de tout (encodeurs inclus)
module txt(p, s, sz=5, rot=0) color(C_DIM) translate([p[0],p[1],zdim]) rotate([0,0,rot]) linear_extrude(0.6) text(s, size=sz, halign="center", valign="center");
module bar(x,y,dx,dy) color(C_DIM) translate([x,y,zdim]) cube([dx,dy,0.5]);

module cote_h(x1,x2,y,s) { bar(x1,y,x2-x1,0.5); bar(x1,y-2,0.5,4); bar(x2,y-2,0.5,4); txt([(x1+x2)/2, y+4], s); }
module cote_v(y1,y2,x,s) { bar(x,y1,0.5,y2-y1); bar(x-2,y1,4,0.5); bar(x-2,y2,4,0.5); txt([x-7,(y1+y2)/2], s, 5, 90); }

module cotes() {
    cote_h(0, W, -10, str("W = ", W, " mm"));
    cote_v(0, H, -10, str("H = ", H, " mm"));
    cote_h(kb_x0, kb_x0+kb_w, kb_y0+Wh+6, str("clavier = ", kb_w, " mm"));
    cote_h(white_left(0), white_left(0)+Ww, kb_y0+8, str(Ww));
    cote_h(white_left(0), white_left(1), kb_y0+18, str("pitch ", pitch_w));
    txt([black_list[0][0]+18, black_list[0][1]+Bh/2], str("noire ", Wb), 4);
    cote_v(scr_cy-screen_h/2, scr_cy+screen_h/2, scr_cx-screen_w/2-3, str(screen_h));
    cote_h(scr_cx-screen_w/2, scr_cx+screen_w/2, scr_cy+screen_h/2+3, str("ecran ", screen_w, "x", screen_h));
    cote_h(enc_pos[0][0], enc_pos[1][0], enc_y+enc_knob/2+4, str("enc ", enc_pitch));
    cote_h(ribbon_x, ribbon_x+ribbon_len, ribbon_y+ribbon_w/2+3, str("ruban ", ribbon_len));
}

// =====================================================================
//  ASSEMBLAGE
// =====================================================================
if (show_box) layer_box();
layer_pcb();
layer_spacer();
layer_plexi();
if (show_dims) cotes();
