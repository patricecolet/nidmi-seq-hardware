// =====================================================================
//  NiDMI Seq — Clavier piano 27 touches, géométrie de facteur de piano
//  16 blanches + 11 noires (do → ré, 2 octaves + 1 ton)
//
//  Empilement étudié ici (cf. docs/ETUDE_DIFFUSION_LED.md) :
//    - plaque ACRYLIQUE TRANSPARENTE découpée en 16 blanches séparées,
//      chacune servant de guide de lumière (gravure au dos, LED en tranche)
//    - plaque plus FINE et plus SOMBRE posée dessus, découpée en 11 noires
//    - PCB de tranche AVANT   : 16 LED, injection dans les blanches
//    - PCB de tranche ARRIÈRE : 11 LED, injection dans les noires (moins haut)
//    - caches avant / arrière : masquent les PCB et donnent l'illusion clavier
//
//  Rendus : voir README.md
// =====================================================================

/* [Affichage] */
explode       = 0;     // [0:40] 0 = assemblé ; >0 = écarte les couches en Z
show_dims     = true;
show_blanches = true;
show_noires   = true;
show_pcb      = true;
show_caches   = true;
vue_plan      = false; // true = vue a plat lisible : blanches OPAQUES, noires
                       // noires, sans PCB ni caches. Sert a verifier a l'oeil que
                       // les proportions sont celles d'un vrai piano.
coupe         = false; // true = coupe transversale : seul moyen de voir les PCB
                       // de tranche et les caches, qui sont justement faits pour
                       // etre invisibles une fois assembles.

/* [Géométrie clavier] */
white_n     = 16;      // blanches (do → ré sur 2 octaves + 1 ton)
pitch_w     = 18.5;    // PAS des blanches (entraxe). Piano réel : 23.5
gap_w       = 1.2;     // trait de découpe entre blanches
Wh          = 58;      // longueur d'une blanche
Bh          = 36;      // longueur d'une noire (piano réel : ~0,63 × blanche)
// Sur un piano a queue : 9.5/23.5 = 0.404. Mais les MINI-CLAVIERS du commerce
// (Akai, Arturia, Novation) elargissent leurs noires plus que la reduction ne le
// voudrait — une noire trop etroite se rate, d'autant plus en capacitif.
// 0.48 -> 8.9 mm au pas de 18.5. A recaler en mesurant un clavier reel.
black_ratio = 0.48;
// Convention de répartition des talons de blanche :
//   "groupes" — talons égaux DANS chaque groupe, mais différents d'un groupe a
//               l'autre (do-re-mi vs fa-sol-la-si). C'est la geometrie du piano :
//               offsets symetriques et sol# exactement sur la ligne de pas.
//   "egaux"   — les 7 talons de l'octave tous egaux. Egalement auto-coherent,
//               mais offsets non symetriques et sol# hors ligne.
tail_mode   = "groupes";
key_clr     = 0.8;     // garde autour des noires (creusée dans les blanches)

/* [Épaisseurs] */
t_blanches  = 10;      // guide de lumière
t_noires    = 5;       // plaque sombre posée dessus (5 mm : plus facile a sourcer)
t_pcb       = 1.6;
t_cache     = 2;

/* [PCB de tranche] */
pcb_h_blanc = 8;       // hauteur du PCB avant (dans les 10 mm du guide)
pcb_h_noir  = 3.5;     // hauteur du PCB arrière (moins large : plaque fine)
pcb_gap     = 1.0;     // jeu entre PCB et tranche (couplage LED)
led_size    = 3.5;     // SK6812 3535
led_h       = 1.6;
cache_ov    = 4;       // recouvrement du cache sur les touches

/* [Repère] */
kb_x0 = 0;
kb_y0 = 0;

// ---------------- COULEURS ----------------
C_ACRYL = (vue_plan || coupe) ? [0.90, 0.93, 0.92] : [0.80, 0.88, 0.95, 0.35];
C_NOIR  = (vue_plan || coupe) ? [0.08, 0.08, 0.09] : [0.13, 0.13, 0.16, 0.92];
C_PCB   = [0.05, 0.35, 0.18];
C_LED   = [1.00, 0.75, 0.25];
C_CACHE = [0.22, 0.22, 0.24];

// ---------------- GÉOMÉTRIE PIANO ----------------
// Sur un piano les noires ne sont PAS sur la limite entre deux blanches.
// Dans le groupe do-ré-mi (3 blanches, 2 noires) les talons de blanche sont
// égaux entre eux ; dans le groupe fa-sol-la-si (4 blanches, 3 noires) ils le
// sont aussi, mais d'une AUTRE valeur. D'où l'irrégularité : do# est décalé à
// gauche de sa limite, ré# à droite, sol# tombe exactement dessus.
Wb   = black_ratio * pitch_w;
tal_u = (7*pitch_w - 5*Wb) / 7;                                  // convention "egaux"
tal1 = tail_mode == "egaux" ? tal_u : (3*pitch_w - 2*Wb) / 3;
tal2 = tail_mode == "egaux" ? tal_u : (4*pitch_w - 3*Wb) / 4;
Ww   = pitch_w - gap_w;

function white_left(i) = kb_x0 + i*pitch_w;
function white_cx(i)   = white_left(i) + Ww/2;
function has_black(i)  = let(n = i % 7) (n==0 || n==1 || n==3 || n==4 || n==5);

// Depart du groupe fa-sol-la-si : la limite mi|fa tombe sur la ligne de pas en
// convention "groupes", mais sur le cumul des talons en convention "egaux".
grp2 = tail_mode == "egaux" ? 3*tal_u + 2*Wb : 3*pitch_w;

function black_cx(i) =
    let(o = floor(i/7), n = i % 7, x0 = kb_x0 + o*7*pitch_w)
      n==0 ? x0 + tal1 + Wb/2
    : n==1 ? x0 + 2*tal1 + 1.5*Wb
    : n==3 ? x0 + grp2 + tal2 + Wb/2
    : n==4 ? x0 + grp2 + 2*tal2 + 1.5*Wb
    :        x0 + grp2 + 3*tal2 + 2.5*Wb;

black_list = [ for (i = [0 : white_n-2]) if (has_black(i)) black_cx(i) ];

kb_w = white_n * pitch_w - gap_w;
by0  = kb_y0 + Wh - Bh;

// ---------------- 2D ----------------
module blacks_2d(clr = 0) {
    for (x = black_list)
        translate([x - Wb/2 - clr, by0 - clr])
            square([Wb + 2*clr, Bh + clr + 0.1]);
}

module whites_2d() {
    difference() {
        for (i = [0 : white_n-1])
            translate([white_left(i), kb_y0]) square([Ww, Wh]);
        blacks_2d(key_clr);
    }
}

// ---------------- 3D ----------------
module plaque_blanches() {
    color(C_ACRYL) linear_extrude(t_blanches) whites_2d();
}

module plaque_noires() {
    color(C_NOIR) translate([0, 0, t_blanches + explode])
        linear_extrude(t_noires) blacks_2d();
}

// PCB de tranche AVANT : injecte dans la tranche des blanches
module pcb_blanches() {
    y = kb_y0 - pcb_gap - t_pcb;
    color(C_PCB) translate([kb_x0, y, (t_blanches - pcb_h_blanc)/2 - explode])
        cube([kb_w, t_pcb, pcb_h_blanc]);
    for (i = [0 : white_n-1])
        color(C_LED) translate([white_cx(i) - led_size/2, y + t_pcb,
                                t_blanches/2 - led_size/2 - explode])
            cube([led_size, led_h, led_size]);
}

// PCB de tranche ARRIÈRE : injecte dans les noires — moins haut, la plaque
// sombre ne fait que t_noires
module pcb_noires() {
    y = kb_y0 + Wh + pcb_gap;
    color(C_PCB) translate([kb_x0, y, t_blanches + (t_noires - pcb_h_noir)/2 + explode])
        cube([kb_w, t_pcb, pcb_h_noir]);
    for (x = black_list)
        color(C_LED) translate([x - led_size/2, y - led_h,
                                t_blanches + t_noires/2 - min(led_size,t_noires)/2 + explode])
            cube([led_size, led_h, min(led_size, t_noires)]);
}

// Caches : masquent les PCB de tranche et dessinent le bord du clavier.
// PROFIL EN L — un mur vertical devant le PCB + une levre qui recouvre le dessus
// des touches. Un bloc plein occuperait le volume des touches et les masquerait.
module cache_avant() {
    y_mur = kb_y0 - (pcb_gap + t_pcb + t_cache);
    color(C_CACHE) translate([0, 0, 2*explode]) union() {
        translate([kb_x0 - t_cache, y_mur, -t_cache])
            cube([kb_w + 2*t_cache, t_cache, t_blanches + 2*t_cache]);
        translate([kb_x0 - t_cache, y_mur, t_blanches])
            cube([kb_w + 2*t_cache, (kb_y0 - y_mur) + cache_ov, t_cache]);
    }
}

module cache_arriere() {
    y_dos = kb_y0 + Wh;
    y_mur = y_dos + pcb_gap + t_pcb;
    h     = t_blanches + t_noires;
    color(C_CACHE) translate([0, 0, 2*explode]) union() {
        translate([kb_x0 - t_cache, y_mur, -t_cache])
            cube([kb_w + 2*t_cache, t_cache, h + 2*t_cache]);
        translate([kb_x0 - t_cache, y_dos - cache_ov, h])
            cube([kb_w + 2*t_cache, (y_mur + t_cache) - (y_dos - cache_ov), t_cache]);
    }
}

// ---------------- CÔTES ----------------
module txt(p, s, h=3.2) color([0.1,0.1,0.1])
    translate([p[0], p[1], t_blanches + t_noires + 6])
        linear_extrude(0.4) text(s, size=h, halign="center", valign="center");

function r2(x) = round(x*100)/100;

module cotes() {
    txt([kb_w/2, kb_y0 - 26], str("pas ", pitch_w, " mm   (piano reel 23.5)"), 4.2);
    txt([kb_w/2, kb_y0 - 33], str("talons : ", tail_mode, "   noire ", r2(Wb),
                                  "   do-re-mi ", r2(tal1),
                                  "   fa-sol-la-si ", r2(tal2)), 3.2);
    txt([kb_w/2, kb_y0 + Wh + 38], str(white_n, " blanches + ", len(black_list),
                                       " noires   largeur ", r2(kb_w), " mm"), 4.2);
    txt([kb_w/2, kb_y0 + Wh + 31],
        "decalage de chaque noire / ligne de pas (sol# = 0 sur un vrai piano)", 3.0);
    // Décalage par rapport à la LIGNE DE PAS (et non au trait de découpe) :
    // c'est la signature d'un clavier correct — do# a gauche, re# a droite,
    // sol# exactement sur la ligne.
    for (i = [0 : white_n-2]) if (has_black(i))
        txt([black_cx(i), by0 + Bh + 9], str(r2(black_cx(i) - white_left(i+1))), 2.6);
}

// ---------------- ASSEMBLAGE ----------------
coupe_x = black_cx(0);          // coupe passant par la 1re noire (do#)

module tout() {
    if (show_blanches) plaque_blanches();
    if (show_noires)   plaque_noires();
    if (show_pcb && !vue_plan)    { pcb_blanches(); pcb_noires(); }
    if (show_caches && !vue_plan) { cache_avant(); cache_arriere(); }
}

if (coupe)
    difference() {
        tout();
        translate([-500, -300, -300]) cube([500 + coupe_x, 600, 600]);
    }
else tout();

if (show_dims && !coupe) cotes();

echo(str("pas=", pitch_w, "  noire=", Wb, "  talon CDE=", tal1, "  talon FGAB=", tal2));
echo(str("largeur clavier=", kb_w, "   echelle vs piano reel=", pitch_w/23.5));
