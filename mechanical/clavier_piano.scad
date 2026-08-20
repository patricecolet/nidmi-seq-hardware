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
// UNE SEULE PIECE PAR PLAQUE : les touches restent reliees par un DOS plein a
// l'arriere (peigne), au lieu d'etre 27 pieces separees. Divise le nombre de
// pieces par plus de deux et supprime tout probleme d'alignement au montage.
//
// !! Le dos est un CHEMIN DE LUMIERE. Il doit etre a l'OPPOSE de l'injection :
//    LED en tranche AVANT, dos ARRIERE. Relier les touches du cote des LED
//    repartirait la lumiere dans le dos et eclairerait toutes les touches a la
//    fois — exactement la selectivite qu'on cherche a preserver.
//    Le dos partage quand meme un peu de lumiere entre touches voisines : le
//    garder AUSSI ETROIT que la tenue mecanique le permet, et mesurer.
plaques_entieres = true;
dos              = 5;   // profondeur du dos (doit rester <= cache_ov pour etre cache)

piece         = "tout"; // "tout" | "blanches" | "noires" — isole une plaque pour
                        // juger le travail de decoupe, ou pour exporter un DXF
coupe         = false; // true = coupe transversale : seul moyen de voir les PCB
                       // de tranche et les caches, qui sont justement faits pour
                       // etre invisibles une fois assembles.

/* [Géométrie clavier] */
white_n     = 16;      // blanches (do → ré sur 2 octaves + 1 ton)
pitch_w     = 18.5;    // PAS des blanches (entraxe). Piano réel : 23.5
gap_w       = 1.2;     // trait de découpe entre blanches
Wh          = 58;      // longueur d'une blanche
Bh          = 36;      // longueur d'une noire (piano réel : ~0,63 × blanche)
// LARGEUR DES NOIRES — attention a la cote choisie. Une noire de piano est
// TRONCONIQUE : ~9.5 mm au sommet (ou le doigt se pose) mais 13.7 mm a la base.
// Vue de dessus, et a plus forte raison sur une facade PLATE ou il n'y a aucun
// fruit, c'est la BASE qui fait la largeur apparente.
//   Cotes normalisees : blanche 23.5 mm, noire 13.7 mm -> rapport 0.583.
// (Prendre 0.404, la cote du sommet, donne des noires visiblement maigres.)
black_ratio = 0.583;
// TALONS DES BLANCHES (partie etroite entre les noires), do re mi fa sol la si.
//
// Des talons TOUS EGAUX sont mathematiquement IMPOSSIBLES : il faudrait resoudre
// en meme temps 3W = 3w + 2B (groupe do-re-mi) et 4W = 4w + 3B (groupe
// fa-sol-la-si), ce qui n'admet de solution que pour B = 0, donc sans noires.
//
// L'arrangement optimal retenu par les facteurs de piano, et le defaut de ce
// modele (tails = undef) :
//     do, re, mi        talon = W - 2B/3
//     fa, sol, la, si   talon = W - 3B/4
// L'ecart maximal entre les deux vaut B/12 — c'est le minimum atteignable.
// Refs : mathpages.com/home/kmath043.htm, quadibloc.com/other/cnv05.htm
//
//   tails = [...] -> sept cotes explicites si l'on veut coller a un clavier
//                    particulier, mesurees puis mises a l'echelle.
//
// CONTRAINTE : somme des 7 talons + 5 x Wb = 7 x pitch_w, sinon les talons
// derivent par rapport aux faces avant (qui restent a pas egal). Verifie par echo.
tails = undef;
key_clr     = 0.8;     // garde autour des noires (creusée dans les blanches)

// SOLIDITE — l'acrylique est CASSANT : il ne se deforme pas, il fissure. Tout
// angle interne vif est une amorce de rupture, et la piece ne casse pas au
// montage mais des mois plus tard.
//   conge_r   : congé dans les angles internes des encoches (36.8 mm de
//               profondeur : c'est l'entaille la plus dangereuse du dessin)
//   arret_d   : TROU D'ARRET en fond de fente entre dents. Une fente terminee en
//               angle vif propage une fissure depuis son extremite ; un trou plus
//               large que la fente l'arrete. Technique d'atelier standard.
conge_r     = 1.2;
arret_d     = 2.4;     // diametre ; doit etre > gap_w pour servir a quelque chose

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
cache_ov    = 6;       // recouvrement du cache (doit couvrir le dos)

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
tal1 = (3*pitch_w - 2*Wb) / 3;
tal2 = (4*pitch_w - 3*Wb) / 4;
Ww   = pitch_w - gap_w;

// Talons effectivement utilises : table mesuree si fournie, sinon modele groupes
T = is_undef(tails) ? [tal1, tal1, tal1, tal2, tal2, tal2, tal2] : tails;
somme_T = T[0]+T[1]+T[2]+T[3]+T[4]+T[5]+T[6];

function white_left(i) = kb_x0 + i*pitch_w;
function white_cx(i)   = white_left(i) + Ww/2;
function has_black(i)  = let(n = i % 7) (n==0 || n==1 || n==3 || n==4 || n==5);

// Abscisse ou commence le talon de la blanche i : on cumule talons et noires
// depuis le debut du clavier. Fonctionne quelle que soit la table de talons.
function xstart(i) = i <= 0 ? kb_x0
                            : xstart(i-1) + T[(i-1) % 7] + (has_black(i-1) ? Wb : 0);

function black_cx(i) = xstart(i) + T[i % 7] + Wb/2;

black_list = [ for (i = [0 : white_n-2]) if (has_black(i)) black_cx(i) ];

kb_w = white_n * pitch_w - gap_w;
by0  = kb_y0 + Wh - Bh;

// ---------------- 2D ----------------
// Fin des DENTS : les touches s'arretent la, le dos occupe le reste.
y_dents = kb_y0 + Wh - (plaques_entieres ? dos : 0);

// Emprise des noires, servant aussi a creuser les encoches des blanches.
// Ne mord pas dans le dos, sinon le peigne se separerait en 16 morceaux.
// Les angles CONVEXES de l'outil de coupe deviennent les angles CONCAVES de la
// piece : arrondir l'outil, c'est mettre un conge dans l'encoche.
module blacks_2d(clr = 0, conge = 0) {
    for (x = black_list)
        translate([x - Wb/2 - clr, by0 - clr])
            offset(r = conge) offset(r = -conge)
                square([Wb + 2*clr, (y_dents - by0) + clr + 0.1]);
}

module dos_2d() { translate([kb_x0, y_dents]) square([kb_w, dos]); }

// Trous d'arret en fond des fentes entre dents (peigne uniquement : sans dos,
// les fentes debouchent et n'ont pas d'extremite a proteger).
module arrets_2d() {
    if (plaques_entieres && arret_d > 0)
        for (i = [0 : white_n-2])
            translate([white_left(i) + Ww + gap_w/2, y_dents])
                circle(d = arret_d, $fn = 24);
}

module whites_2d() {
    difference() {
        union() {
            for (i = [0 : white_n-1])
                translate([white_left(i), kb_y0]) square([Ww, Wh - (plaques_entieres ? dos : 0)]);
            if (plaques_entieres) dos_2d();
        }
        blacks_2d(key_clr, conge_r);
        arrets_2d();
    }
}

// Plaque des noires : dents + dos, ou 11 pieces separees.
module noires_2d() {
    difference() {
        union() {
            blacks_2d(0);
            if (plaques_entieres) dos_2d();
        }
        // memes trous d'arret en fond des creux entre dents
        if (plaques_entieres && arret_d > 0)
            for (i = [0 : len(black_list)-2])
                translate([(black_list[i] + Wb/2 + black_list[i+1] - Wb/2)/2, y_dents])
                    circle(d = arret_d, $fn = 24);
    }
}

// ---------------- 3D ----------------
module plaque_blanches() {
    color(C_ACRYL) linear_extrude(t_blanches) whites_2d();
}

module plaque_noires() {
    color(C_NOIR) translate([0, 0, t_blanches + explode])
        linear_extrude(t_noires) noires_2d();
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
    txt([kb_w/2, kb_y0 - 33], str("noire ", r2(Wb), "   talons do..si : ",
                                  r2(T[0]), " ", r2(T[1]), " ", r2(T[2]), " ",
                                  r2(T[3]), " ", r2(T[4]), " ", r2(T[5]), " ",
                                  r2(T[6])), 3.2);
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
    seul = piece != "tout";
    if (show_blanches && piece != "noires")   plaque_blanches();
    if (show_noires   && piece != "blanches") plaque_noires();
    if (show_pcb    && !vue_plan && !seul) { pcb_blanches(); pcb_noires(); }
    if (show_caches && !vue_plan && !seul) { cache_avant(); cache_arriere(); }
}

if (coupe)
    difference() {
        tout();
        translate([-500, -300, -300]) cube([500 + coupe_x, 600, 600]);
    }
else tout();

if (show_dims && !coupe) cotes();

echo(str("pas=", pitch_w, "  noire=", Wb, "  talons=", T));
// La somme talons + noires doit refermer l'octave, sinon les talons derivent par
// rapport aux faces avant qui restent a pas egal.
echo(somme_T + 5*Wb == 7*pitch_w
     ? "octave coherente"
     : str("!! ATTENTION talons incoherents : ", somme_T + 5*Wb,
           " au lieu de ", 7*pitch_w, " -> derive des talons"));
echo(str("largeur clavier=", kb_w, "   echelle vs piano reel=", pitch_w/23.5));
