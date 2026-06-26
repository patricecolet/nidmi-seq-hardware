// =====================================================================
//  NiDMI Seq — Étude d'UNE cellule touche dans le plexi épais
//  (branche etude/plexi-epais-grave)
//
//  Électrode au fond d'une poche fraisée au dos ; membrane fine devant ;
//  LED au centre. But : valider les épaisseurs à l'œil.
//
//  Deux variantes d'électrode (elec_mode) :
//    "ring" = anneau cuivre opaque + trou central, LED par le trou.
//    "ito"  = film ITO transparent PLEINE surface, la LED traverse
//             l'électrode (pas de trou, pas de hot-spot central) +
//             languette de contact vers la rainure (cf. CONCEPT_PLEXI_EPAIS).
//
//  cut = true  -> coupe (montre la section : membrane / poche / électrode / LED)
//  Rendu : openscad -o cellule.png --imgsize=1400,1000 \
//            --camera=0,0,5,68,0,40,90 cellule_plexi.scad
//  Variante ITO : ajouter  -D 'elec_mode="ito"'  (sortie cellule_ito.png).
// =====================================================================

/* [Cellule] */
cell      = 20;    // côté de la cellule (touche)
plexi_t   = 10;    // épaisseur du plexi
membrane  = 1.5;   // membrane avant (devant l'électrode)
wall      = 3;     // paroi plexi entre cellules / autour de la poche
led_win   = 6;     // fenêtre LED centrale (membrane percée — mode "ring")
elec_t    = 0.2;   // épaisseur électrode (cuivre ou ITO)
chan_w    = 3;     // rainure de câblage (au dos)

/* [Électrode] */
elec_mode = "ito"; // "ito" (pleine surface transparente) | "ring" (anneau cuivre)

/* [Affichage] */
cut       = true;  // coupe pour voir la section
show_dims = true;

led_sz = 3.5; led_h = 1.6;
$fn = 56;

pocket = cell - 2*wall;          // côté de la poche
pdepth = plexi_t - membrane;     // profondeur de poche (depuis le dos)

C_PLEXI  = [0.60,0.78,0.95,0.35];
C_COPPER = [0.80,0.55,0.20];
C_ITO    = [0.55,0.85,0.95,0.22];   // film ITO : quasi transparent (la LED traverse)
C_LED    = [0.95,0.95,0.85];
C_DIM    = [0.85,0.10,0.10];

is_ito = (elec_mode == "ito");

module cell_assembly() {
    // --- PLEXI ---
    color(C_PLEXI) difference() {
        translate([-cell/2,-cell/2,0]) cube([cell, cell, plexi_t]);
        // poche fraisée depuis le dos (z=0) jusqu'à pdepth
        translate([-pocket/2,-pocket/2,-0.01]) cube([pocket, pocket, pdepth+0.01]);
        // fenêtre LED : membrane percée au centre — uniquement en mode "ring"
        // (en "ito" la membrane reste PLEINE, la LED traverse l'ITO transparent)
        if (!is_ito)
            translate([0,0,pdepth-0.01]) cylinder(d=led_win, h=membrane+0.02);
        // rainure de câblage (bord -> poche, au dos)
        translate([-cell/2-0.01, -chan_w/2, 0]) cube([wall+0.02, chan_w, chan_w]);
    }
    // --- ÉLECTRODE (au sommet de la poche, derrière la membrane) ---
    if (is_ito) {
        // ITO PLEINE surface + languette de contact vers le bord (-x)
        color(C_ITO) translate([0,0,pdepth-elec_t]) linear_extrude(elec_t) {
            square([pocket, pocket], center=true);
            translate([-cell/2, -chan_w/2]) square([cell/2, chan_w]); // languette
        }
    } else {
        // anneau cuivre (trou central = passage LED)
        color(C_COPPER) translate([0,0,pdepth-elec_t]) linear_extrude(elec_t)
            difference() {
                square([pocket, pocket], center=true);
                circle(d=led_win+2);
            }
    }
    // --- LED au centre (émet vers la membrane) ---
    color(C_LED) translate([-led_sz/2,-led_sz/2, pdepth-led_h]) cube([led_sz, led_sz, led_h]);
}

// --- côtes (sur la face de coupe, plan XZ à y=0) ---
module dimZ(z1,z2,x,s) {
    color(C_DIM) {
        translate([x, 0, z1]) rotate([90,0,0]) cylinder(d=0.4, h=0.4);
        translate([x, 0, z2]) rotate([90,0,0]) cylinder(d=0.4, h=0.4);
        translate([x, 0.3, (z1+z2)/2]) rotate([90,0,0]) linear_extrude(0.4)
            text(s, size=1.6, halign="center", valign="center");
    }
}

if (cut) difference() {
    cell_assembly();
    translate([-cell, 0.001, -1]) cube([2*cell, cell+1, plexi_t+2]);   // enlève la moitié y>0
} else cell_assembly();

if (show_dims && cut) {
    dimZ(pdepth, plexi_t, cell/2+2, str("memb ", membrane));
    dimZ(0, plexi_t, -cell/2-2, str("plexi ", plexi_t));
    dimZ(pdepth-elec_t, pdepth, cell/2+5, is_ito ? "ITO" : "elec");
}
