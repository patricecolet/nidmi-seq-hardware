// =====================================================================
//  NiDMI Seq — Façade plexi + touches capacitives + LEDs (variante)
//  Modèle paramétrique OpenSCAD — vue de l'empilement
//
//  Empilement (de haut en bas) :
//    1. PLEXI         : couvercle, légendes + cellules gravées, fenêtre écran
//    2. GRILLE        : espaceur opaque = "light wells" (1 puits par cellule)
//    3. PCB           : électrodes capacitives (anneaux cuivre) + SK6812 au centre
//
//  Usage :
//    explode = 0   -> assemblé
//    explode = 25  -> vue éclatée (couches séparées en Z)
//
//  Rendu CLI :
//    openscad -o facade.png --imgsize=1400,1400 \
//             --camera=85,130,40,60,0,25,650 facade.scad
// =====================================================================

// ---------------- PARAMÈTRES (tout est ajustable ici) ----------------
explode      = 25;     // 0 = assemblé ; >0 = écarte les couches

// Façade
W            = 170;    // largeur façade (mm)
H            = 262;    // hauteur façade (mm)
margin       = 12;

// Épaisseurs
plexi_t      = 2;      // plexi acrylique
spacer_t     = 3;      // entrefer / hauteur des puits de lumière
pcb_t        = 1.6;

// Pads "pas" (grille 4x4)
pad_step     = 22;     // côté du pad capacitif
pitch_step   = 32;     // entraxe
ring_w       = 3;      // largeur de l'anneau cuivre
led_hole     = 6;      // trou central (SK6812)
led_size     = 3.5;    // boîtier SK6812 3535
led_h        = 1.6;    // hauteur LED

// Pads fonctions / transport
pad_fn       = 12;
n_fn         = 11;     // noires (fonctions)
n_transport  = 5;

// Encodeurs
enc_knob     = 20;
enc_shaft    = 7;

// Écran 3,2" (zone active ~49x65 -> fenêtre)
screen_w     = 50;
screen_h     = 66;

$fn          = 48;

// ---------------- COULEURS ----------------
C_PLEXI   = [0.55, 0.75, 0.95, 0.30];  // bleuté translucide
C_SPACER  = [0.20, 0.20, 0.22];         // gris foncé opaque
C_PCB     = [0.05, 0.35, 0.15];         // vert PCB
C_COPPER  = [0.80, 0.55, 0.20];
C_LED     = [0.95, 0.95, 0.85];
C_KNOB    = [0.10, 0.10, 0.12];

// ---------------- LAYOUT (positions des cellules) ----------------
// Grille 4x4 centrée horizontalement
gx0 = W/2 - 1.5*pitch_step;
gy_top = H - margin - screen_h - 18;        // sous la zone écran/encodeurs
step_pos = [ for (r=[0:3]) for (c=[0:3]) [ gx0 + c*pitch_step, gy_top - r*pitch_step ] ];

// Rangée fonctions (11 + Shift = 12 cellules)
fn_count  = n_fn + 1;
fn_pitch  = (W - 2*margin) / fn_count;
fn_y      = gy_top - 3*pitch_step - 30;
fn_pos    = [ for (i=[0:fn_count-1]) [ margin + fn_pitch*(i+0.5), fn_y ] ];

// Rangée transport (5 cellules centrées)
tr_pitch  = 24;
tr_y      = fn_y - 26;
tr_pos    = [ for (i=[0:n_transport-1]) [ W/2 + tr_pitch*(i-(n_transport-1)/2), tr_y ] ];

// Encodeurs : 2x2 en haut à droite
enc_pitch = 34;
enc_cx    = W - margin - enc_pitch - enc_knob/2;
enc_cy    = H - margin - enc_knob/2 - 6;
enc_pos   = [ for (r=[0:1]) for (c=[0:1]) [ enc_cx + c*enc_pitch, enc_cy - r*enc_pitch ] ];

// Écran : en haut à gauche
screen_cx = margin + screen_w/2;
screen_cy = H - margin - screen_h/2;

// ---------------- HAUTEURS EN Z (avec éclaté) ----------------
z_pcb    = 0;
z_spacer = pcb_t + explode;
z_plexi  = pcb_t + spacer_t + 2*explode;

// =====================================================================
//  MODULES
// =====================================================================

// --- PCB : substrat + anneaux cuivre + LEDs + corps encodeurs + écran
module layer_pcb() {
    translate([0,0,z_pcb]) {
        color(C_PCB) cube([W, H, pcb_t]);

        // pads "pas" : anneau cuivre + LED centrale
        for (p = step_pos) pad_ring(p, pad_step, z=pcb_t);
        // pads fonctions + shift
        for (p = fn_pos)   pad_ring(p, pad_fn, z=pcb_t);
        // pads transport
        for (p = tr_pos)   pad_ring(p, pad_fn, z=pcb_t);

        // corps des encodeurs
        for (p = enc_pos)
            color(C_KNOB) translate([p[0], p[1], pcb_t])
                cylinder(d=enc_knob, h=14);

        // module écran (boîte derrière la fenêtre)
        color([0.1,0.1,0.1]) translate([screen_cx-screen_w/2, screen_cy-screen_h/2, pcb_t])
            cube([screen_w, screen_h, 4]);
        color([0.15,0.15,0.2]) translate([screen_cx-screen_w/2+2, screen_cy-screen_h/2+2, pcb_t+4])
            cube([screen_w-4, screen_h-4, 0.5]);  // dalle
    }
}

// Un pad = anneau cuivre (carré évidé) + LED au centre
module pad_ring(p, size, z) {
    translate([p[0], p[1], z]) {
        color(C_COPPER) linear_extrude(0.2)
            difference() {
                square([size, size], center=true);
                square([size-2*ring_w, size-2*ring_w], center=true);
            }
        // LED SK6812 au centre
        color(C_LED) translate([-led_size/2,-led_size/2,0]) cube([led_size, led_size, led_h]);
    }
}

// --- GRILLE espaceur : plaque pleine - puits par cellule - trous enc/écran
module layer_spacer() {
    translate([0,0,z_spacer])
    color(C_SPACER) difference() {
        cube([W, H, spacer_t]);
        // puits de lumière (un par pad, légèrement plus grand que le pad)
        for (p = step_pos) well(p, pad_step+1);
        for (p = fn_pos)   well(p, pad_fn+1);
        for (p = tr_pos)   well(p, pad_fn+1);
        // passages encodeurs
        for (p = enc_pos)  translate([p[0],p[1],-1]) cylinder(d=enc_knob+2, h=spacer_t+2);
        // passage écran
        translate([screen_cx-screen_w/2-1, screen_cy-screen_h/2-1, -1])
            cube([screen_w+2, screen_h+2, spacer_t+2]);
    }
}

module well(p, size) {
    translate([p[0]-size/2, p[1]-size/2, -1]) cube([size, size, spacer_t+2]);
}

// --- PLEXI : dalle translucide + cellules gravées + fenêtre + perçages enc
module layer_plexi() {
    translate([0,0,z_plexi])
    color(C_PLEXI) difference() {
        cube([W, H, plexi_t]);
        // gravures de cellules (poches peu profondes en sous-face = repère/diffuseur)
        for (p = step_pos) engrave(p, pad_step+4);
        for (p = fn_pos)   engrave(p, pad_fn+3);
        for (p = tr_pos)   engrave(p, pad_fn+3);
        // perçages encodeurs (traversants)
        for (p = enc_pos)  translate([p[0],p[1],-1]) cylinder(d=enc_shaft, h=plexi_t+2);
        // fenêtre écran (traversante)
        translate([screen_cx-screen_w/2, screen_cy-screen_h/2, -1])
            cube([screen_w, screen_h, plexi_t+2]);
    }
}

module engrave(p, size) {
    translate([p[0]-size/2, p[1]-size/2, -0.01])
        cube([size, size, 0.4]);   // gravure 0,4 mm en sous-face
}

// =====================================================================
//  ASSEMBLAGE
// =====================================================================
layer_pcb();
layer_spacer();
layer_plexi();
