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

/* [Mode de sortie] */
// false = modele 3D de la facade (defaut)
// true  = PLANCHE DE PLAN : 3 vues 2D cotees (dessus + 2 coupes), pour le boitier
plan       = false;
// true = on retire mousse et socle pour VOIR la carte LED du dessous et ses LED.
// Sans ca elle est enfermee dans l'empilement et aucune vue ne la montre.
ecorche    = false;

/* [Boitier] */
e_facade   = 2;       // epaisseur de la facade — elle fait CACHE
e_paroi    = 2.5;
e_fond     = 2.5;
h_int      = 33;      // 🔴 LA VARIABLE A EPROUVER (voir l'echo "h_int mini")

// Empilement du clavier sous la face touchee des blanches (coupe_cellule.scad),
// couche par couche : c'est ce qui permet de voir que LE PLEXI NE FAIT QUE 10 mm,
// donc MOINS que les 16 de l'ecran. Le reste est de la suspension.
e_plq      = 1.0;                 // plaque acrylique — la surface touchee
e_film     = 0.125 + 0.05 + 0.10; // PET + ITO + film d'air
e_plexi    = 10.0;                // LE BLOC : guide de lumiere
e_fondkb   = 0.05;                // fond sombre
e_mousse   = 3.0;                 // le ressort — DECOUPE au droit de la carte LED
e_socle    = 2.0;                 // reference rigide des LED ; LA CARTE LED EST
                                  // POSEE DESSUS, dans la decoupe de la mousse.
                                  // Elle ne s'ajoute donc PAS a kb_haut.
kb_haut    = e_plq + e_film + e_plexi + e_fondkb + e_mousse + e_socle;
relief_n   = 1.0;     // relief des noires, USINE dans la plaque -> au-dessus de z=0

// !! REPERE. z = 0 est le DESSOUS de la facade, c'est-a-dire la face touchee du
//    plexi. La surface VISIBLE est donc a +e_facade. Toute cote donnee "depuis la
//    surface visible" doit etre diminuee de e_facade pour entrer dans ce repere.
enc_prof   = 10;      // [ESTIME] EC11 : corps ~6,5 sous panneau + pattes

// [FOURNI] 2026-08-21 : 10 mm entre la SURFACE DU PCB et la SURFACE VISIBLE DU
// CACHE. Ce n'est plus une estimation, et le PB86 n'est PLUS le poste
// dimensionnant : il passe derriere l'ecran (16) et le clavier (16,3).
// (l'estimation precedente, 20 mm, etait fausse du double)
btn_h_tot  = 10;                    // surface du PCB -> surface visible du cache
btn_prof   = btn_h_tot - e_facade;  // ce qui descend sous la facade
e_pcb      = 1.6;                   // carte standard

/* [Cartes — decide en seance du 2026-08-21] */
// DEUX CARTES LATERALES, une de chaque cote de l'ecran, en DOUBLE FACE :
//   face avant  = boutons PB86 + encodeurs EC11 (traversants)
//   face arriere = l'ESP32-S3 (B a gauche, C a droite) + R serie des canaux touch
// La rangee haute fait util_w et l'ecran scr_w : il reste exactement
// (util_w - scr_w)/2 = 66 mm de chaque cote, soit precisement une colonne de
// boutons (20) + jeu (8) + une colonne de molettes (30) + jeu (8).
// Consequence sur le FILM : "queue unique" devient DEUX QUEUES, une par cote.
// Le film etant grave d'un coup au masque, cela ne coute rien, et la
// distribution reste courte. Le ruban, lui, doit choisir son cote.
esp_h      = 3.0;     // [ESTIME] module ESP32-S3-WROOM-1 au dos de la carte

// CARTE LED AVANT — verticale, en tranche du bloc, 16 LED des blanches
pcb_led_av_h = 8;     // hauteur, dans les 10 mm du bloc (clavier_piano pcb_h_blanc)
pcb_led_gap  = 1.0;   // entrefer LED <-> tranche

// CARTE LED DU DESSOUS — POSEE SUR LE SOCLE, dans la decoupe de la mousse.
// LED des noires (poches borgnes) et du ruban. Ne s'ajoute pas a kb_haut.
e_pcb_led  = 0.8;     // ENIG 0,6-0,8 : plat et non oxydable (contact par pression)
led_h      = 1.9;     // SK6812 3535

// ALIMENTATION + MIDI + CV + connectique : VOLUME RESERVE, PAS PLACE.
// Contrainte connue : le buck 3,3 V commute a quelques centaines de kHz et la
// ligne de base capacitive est a 47 000 counts -> le tenir LOIN du film et des
// nappes, donc pas sur les cartes laterales. Position a decider.
alim_w     = 120;     // [ESTIME] emprise a loger
alim_l     = 60;      // [ESTIME]
alim_h     = 12;      // [ESTIME] avec les connecteurs

cabl_h     = 8.0;     // [ESTIME] passage de cables et nappes
conn_prof  = 5;       // PJ-320A board-edge

/* [Marges et jeux] */
marge    = 12;
jeu_rang = 8;            // entre deux rangees
jeu_kb   = 10;           // au-dessus du clavier

/* [Clavier — doit suivre clavier_piano.scad] */
kb_w     = 294.8;
// 2026-08-21 : LA PIECE DE PLEXI EST D'UN SEUL TENANT — blanches + dos. Le dos
// PORTE LE RUBAN : il n'y a pas de rangee de ruban derriere le clavier, et il
// n'y a pas de piece separee. C'est ce que le modele affirmait a tort la veille.
kb_blanche = 52;         // longueur utile d'une blanche  (clavier_piano.scad Wh)
kb_dos_ini = 18;         // dos du peigne, cote de depart (coupe_cellule.scad)

kb_cache = 2;            // debord lateral
// LA FACADE FAIT CACHE : la face touchee du plexi est au niveau du DESSOUS de la
// facade, donc EN RETRAIT. Le doigt l'atteint par les ouvertures.
kb_face  = 0;            // z de la face touchee — le ruban est POSE dessus
jeu_ouv  = 1;            // jeu entre une ouverture et ce qu'elle decouvre
kb_pas   = 18.5;         // pas des blanches       (clavier_piano.scad pitch_w)
noire_w  = 10.79;        // 0,583 x pas — cote de BASE, pas de sommet
noire_l  = 32;           // longueur d'une noire   (clavier_piano.scad Bh)
// Decalages des noires par rapport a la ligne de pas (geometrie de facteur de
// piano). [index de la blanche a gauche, decalage]. N'est utilise QU'EN MODE PLAN :
// le modele 3D importe le vrai dessin de clavier_piano.scad.
noires_plan = [[0,-1.8],[1,1.8],[3,-2.7],[4,0],[5,2.7],
               [7,-1.8],[8,1.8],[10,-2.7],[11,0],[12,2.7],
               [14,-1.8]];

/* [Ecran — CrowPanel Advance 7.0-HMI ESP32-S3 800x480, 34,90 $ chez Elecrow] */
// Cotes FOURNIES PAR L'UTILISATEUR (2026-08-21), qui a passe la commande et releve les
// dimensions. Elles ne figurent ni sur la fiche produit ni sur espboards : c'est LA
// reference du projet, ne pas les "re-sourcer" sur le web.
//   carte    181.26 x 108.36 x 16 mm
//   actif    153.84 x 85.63 mm
// -> bordure 13.71 mm en largeur, 11.37 mm en hauteur (non symetrique).
// !! L'EPAISSEUR DE 16 mm commande la profondeur du boitier : c'est le composant
//    le plus epais de la facade, devant le clavier (10 mm de guide + 5 de noires).
scr_win_w = 153.84;
scr_win_h = 85.63;
scr_w     = 181.26;
scr_h     = 108.36;
scr_t     = 16;

/* [Encodeurs] */
n_enc     = 6;           // Row Pas Valeur Velo Duree Master (CONCEPTION.md §2)
enc_knob  = 20;
enc_pitch = 30;
enc_rangs = 2;           // disposition "rangees" seulement
n_gauche  = 3;           // 3 molettes a gauche de l'ecran, comme dans le VST
n_droite  = 3;           // 3 molettes a droite

/* [Boutons PB86] — 3 vues + SHIFT a gauche, 4 transport a droite */
// EN COLONNES VERTICALES aux extremites, pas en rangee : une rangee dediee
// coutait ~30 mm de profondeur, une colonne ne coute que de la largeur, dont on
// dispose. Et le regroupement gauche/droite suit la fonction.
n_vues    = 3;
n_transp  = 4;
n_btn_g   = 4;           // 3 vues + SHIFT
n_btn_d   = 4;           // Play Stop Rec Export
jeu_grp   = 22;
n_btn     = 8;
btn_w     = 12;
btn_l     = 17;
btn_pitch = 20;

/* [Ruban capacitif] */
// Rendu a sa cote du BOM (180) : la reduction a 136 n'etait imposee que par la
// rangee de boutons, qui est passee en colonnes. La bande entre clavier et ecran
// est desormais libre sur toute la largeur -> voir l'echo "ruban : ... dispo".
// Position confirmee par le MicroFreak, dont le ruban tactile est juste
// au-dessus des touches.
ruban_l   = 180;
ruban_w   = 10;
ruban_h   = 3;           // epaisseur au rendu (visibilite ; 1.5 disparaissait)

// LE DOS DOIT LOGER TROIS CHOSES, pas seulement le ruban :
//   - le CACHE : la bande de facade qui masque le dos du peigne des noires et la
//     zone de contact du film. C'est ce que la facade doit couvrir.
//   - le RUBAN et ses jeux d'ouverture.
//   - le BORD ARRIERE de facade, derriere le ruban.
cache_dos = 6;           // 🔴 bande de facade entre les deux ouvertures
bord_ar   = 5;           // 🔴 bord de facade derriere l'ouverture du ruban
// Dos strictement necessaire pour que les trois tiennent :
kb_dos_mini = 3*jeu_ouv + cache_dos + ruban_w + bord_ar;
// true  = le dos suit le besoin (le modele dit de combien il faut l'allonger)
// false = on garde 18 et on voit ce qui deborde
dos_auto = true;
kb_dos   = dos_auto ? kb_dos_mini : kb_dos_ini;
kb_h     = kb_blanche + kb_dos;
// 🔴 clavier_piano.scad porte Wh et dos EN DUR (use <> n'importe pas les
//    variables). Les deux doivent valoir ce qui est calcule ici, sinon la piece
//    dessinee n'a pas la taille de la piece calculee — et le ruban se retrouve
//    hors du plexi. L'echo ci-dessous verifie.
kp_Wh    = 76;           // valeur actuellement ecrite dans clavier_piano.scad
kp_dos   = 24;

/* [Connectique — tranche arriere] */
jack_d    = 6;           // PJ-320A (3,5 mm) : MIDI + CV
// 2026-08-21 : etait a 5 alors que la liste en compte SIX — MIDI IN, MIDI OUT,
// CV, GATE, CLK, RST. Le commentaire et la valeur se contredisaient depuis le
// debut, et il manquait donc un jack sur la tranche.
n_jack    = 6;           // MIDI IN/OUT (2) + CV GATE CLK RST (4)
n_jack_g  = 4;           // sur la carte GAUCHE : CV GATE CLK RST
n_jack_d  = 2;           // sur la carte DROITE : MIDI IN, MIDI OUT
usb_w     = 9;

/* [Sortie audio SYMETRIQUE — 2 canaux, TRS] */
// !! LE CONNECTEUR EST LE POSTE DIMENSIONNANT, pas le FPGA.
//    PJ-320A (3,5 mm) : ~6 mm de diametre, ~5 mm de profondeur.
//    TRS 6,35 mm      : ~12-15 mm de diametre, 25-30 mm DE PROFONDEUR
//                       -> deviendrait le composant le plus profond de
//                       l'instrument, devant le CrowPanel (16 mm).
audio_sym   = true;
// DECIDE 2026-08-21 : 3,5 mm. Le 6,35 aurait impose 25-30 mm de profondeur et
// serait devenu le composant le plus profond de l'instrument, devant le
// CrowPanel (16 mm). L'electronique reste symetrique, seul le format change.
audio_635   = false;
audio_d     = audio_635 ? 14 : 6;
audio_prof  = audio_635 ? 28 : 5;
n_audio     = 2;

/* [Reservation moteur audio FPGA — volume en cavite arriere, pas en facade] */
// Option gardee ouverte (cf. docs/BOM.md) : Cmod A7-35T (Artix-7, la puce du
// XVA1) + DAC I2S UDA1334A. En PLAN la facade est saturee -> la reservation est
// un VOLUME dans la cavite, sous les composants. Seule consequence visible :
// deux jacks de sortie audio de plus sur la tranche arriere (ci-dessus).
res_audio    = true;
cmod_w       = 17.78;    // Cmod A7-35T : 0.7" x 2.75"
cmod_l       = 69.85;
cmod_h       = 12;       // ESTIME : carte + support DIP
dac_w        = 40.0;     // UDA1334A : cotes constructeur
dac_l        = 25.0;
dac_h        = 7.1;

// ---------------- COULEURS ----------------
C_PLAQUE = [0.90, 0.90, 0.88];
C_ECRAN  = [0.10, 0.11, 0.14];
C_WIN    = [0.20, 0.45, 0.70];
C_ENC    = [0.35, 0.36, 0.40];
C_BTN    = [0.80, 0.55, 0.20];
C_RUBAN  = [0.45, 0.65, 0.55];
C_PCB    = [0.05, 0.35, 0.18];
C_ESP    = [0.20, 0.22, 0.26];
C_LED    = [1.00, 0.75, 0.25];
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
btn_col_h = max(n_btn_g, n_btn_d) * btn_pitch;
rang1_h = fonc ? max(scr_h, max(max(col_g_h, col_d_h), btn_col_h))
               : max(scr_h, enc_h);
// Boutons groupes par fonction : vues | SHIFT | transport
btn_grp_w = n_vues*btn_pitch + jeu_grp + btn_pitch + jeu_grp + n_transp*btn_pitch;
// Le ruban prend sa PROPRE rangee des qu'il ne tient pas a cote des boutons :
// l'y forcer elargissait la facade au-dela du clavier.
rang2_w = fonc ? 0 : n_btn * btn_pitch + jeu_rang + ruban_l;
rang2_h = fonc ? 0 : max(btn_l, ruban_w) + 6;   // plus de rangee de boutons

avec_kb = variante == "complete";

// En "modeste" boutons et ruban ne partagent plus la largeur du clavier :
// on les empile pour garder un objet compact.
rang2_w_eff = fonc ? rang2_w : (avec_kb ? rang2_w : n_btn * btn_pitch);
// 2026-08-21 : en variante COMPLETE le ruban n'a plus de rangee — il est SUR le
// dos du peigne. Il ne coute donc plus 24 mm de profondeur de facade. En MODESTE
// il n'y a pas de peigne : il garde sa rangee.
rang3_w     = avec_kb ? 0 : ruban_l;
rang3_h     = avec_kb ? 0 : ruban_w + 6 + jeu_rang;

// L'ecran est desormais un COMPOSANT REEL (CrowPanel) : il impose sa largeur au
// lieu de remplir ce qui reste. La rangee haute vaut donc :
//   boutons | molettes | ECRAN | molettes | boutons
rang1_w_fonc = 2*btn_pitch + 2*enc_pitch + 4*jeu_rang + scr_w;
util_w = max(avec_kb ? kb_w + 2*kb_cache : 0,
             max(fonc ? rang1_w_fonc : 0, max(rang2_w_eff, rang3_w)));
util_h = rang1_h + jeu_rang + rang2_h + rang3_h + (avec_kb ? jeu_kb + kb_h : 0);

// Colonnes exterieures de boutons, puis colonnes de molettes, puis l'ecran au
// centre : l'ecran prend ce qui reste.
btn_col_w  = btn_pitch;
scr_w_auto = scr_w;
scr_h_auto = scr_h;

F_W = util_w + 2*marge;
F_H = util_h + 2*marge;

// ---------------- ELEMENTS ----------------
// LA FACADE EST UN CACHE. La piece de plexi passe DESSOUS : sa face touchee est
// au niveau du DESSOUS de la facade (z = 0), et le doigt l'atteint par les
// ouvertures. Deux ouvertures, decidees le 2026-08-21 :
//   1 — les TOUCHES (blanches + relief des noires)
//   2 — le RUBAN
// La bande de facade entre les deux masque LE DOS DU PEIGNE DES NOIRES (la bande
// qui relie les noires entre elles) et la zone de contact du film. Le bord
// arriere masque la fin du dos.
module plaque() {
    difference() {
        color(C_PLAQUE) cube([F_W, F_H, e_facade]);
        if (avec_kb) {
            translate([x_ouv, y_kb - 1, -1])
                cube([w_ouv, kb_blanche + 1 + jeu_ouv, e_facade + 2]);
            translate([x_ouv_r, y_ruban - jeu_ouv, -1])
                cube([ruban_l + 2*jeu_ouv, ruban_w + 2*jeu_ouv, e_facade + 2]);
        }
        // fenetre de l'ecran : la ZONE ACTIVE, pas la carte. La bordure de
        // 13,71 x 11,37 mm du CrowPanel reste cachee sous la facade.
        translate([x_sc_a + (scr_w - scr_win_w)/2 - jeu_ouv,
                   y_rang1 + (rang1_h - scr_h)/2 + (scr_h - scr_win_h)/2 - jeu_ouv, -1])
            cube([scr_win_w + 2*jeu_ouv, scr_win_h + 2*jeu_ouv, e_facade + 2]);
    }
}

// L'ecran a SA PROFONDEUR REELLE : il descend de scr_t sous la facade, comme le
// clavier descend de kb_haut. Il etait dessine avec 3 mm d'epaisseur, ce qui le
// faisait passer pour une vignette posee sur la facade au lieu du composant le
// plus epais de la rangee haute.
module ecran(p, w, h) {
    translate([p[0], p[1], -scr_t]) {
        color(C_ECRAN) cube([w, h, scr_t]);
        color(C_WIN) translate([(w - scr_win_w)/2, (h - scr_win_h)/2, scr_t])
            cube([scr_win_w, scr_win_h, 0.4]);
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

// Colonne verticale de boutons. shift_i = index du bouton SHIFT (-1 si aucun).
module colonne_boutons(x, y0, n, shift_i = -1) {
    h = n * btn_pitch;
    for (i = [0 : n-1])
        translate([x + (btn_col_w - btn_w)/2,
                   y0 + (rang1_h - h)/2 + i*btn_pitch + (btn_pitch-btn_l)/2, 2])
            color(i == shift_i ? [0.85,0.30,0.20] : C_BTN)
                cube([btn_w, btn_l, 5]);
}

module boutons(p) {
    for (i = [0 : n_btn-1])
        translate([p[0] + i*btn_pitch + (btn_pitch-btn_w)/2, p[1], 2])
            color(C_BTN) cube([btn_w, btn_l, 5]);
}

// !! Le ruban est POSE SUR LA FACE TOUCHEE, pas noye dedans. Il etait place a
//    z = 0 alors que le clavier occupe z = 2..6 : il passait SOUS le plexi.
//    C'est une zone tactile a la surface, donc une bande affleurante — son
//    epaisseur ici n'est que de la visibilite.
module ruban(p, z = kb_face) {
    translate([p[0], p[1], z]) color(C_RUBAN) cube([ruban_l, ruban_w, 0.4]);
}

// La face touchee AFFLEURE la facade : la plaque acrylique continue EST la
// surface. Le plexi est dessous, dans l'epaisseur du boitier (cf. la coupe B du
// mode plan). Seul le RELIEF DES NOIRES depasse, de relief_n.
module clavier(p) {
    translate([p[0], p[1], kb_face - 0.4]) {
        color(C_KB)   linear_extrude(0.4) whites_2d();
        // blacks_2d() et NON noires_2d() : cette derniere inclut le DOS, herite
        // de l'epoque ou les noires etaient une plaque teintee rapportee. Le dos
        // serait sorti tout noir, et le ruban aurait disparu dessous.
        color(C_NOIR) translate([0, 0, 0.4]) linear_extrude(relief_n) blacks_2d();
    }
    // ---- LA PROFONDEUR ----------------------------------------------
    // Le clavier avait une surface mais aucun volume, alors que les boutons, les
    // encodeurs et l'ecran en ont un. Ce qui descend sous la face touchee, sur
    // TOUTE la piece (touches ET dos qui porte le ruban) :
    //   BLOC PMMA 10 · fond sombre · MOUSSE 3 (le ressort) · SOCLE 2.
    // !! Le bloc suit whites_2d(), PAS un rectangle plein : les decoupes entre
    //    blanches et les encoches des noires descendent dans l'epaisseur. Un
    //    rectangle plein les bouchait.
    translate([p[0], p[1], kb_face - 0.4]) {
        color(C_KB)   translate([0, 0, -e_plexi]) linear_extrude(e_plexi)
                      whites_2d();
        if (!ecorche) {
            color(C_MOUS) translate([0, 0, -(e_plexi + e_fondkb + e_mousse)])
                          linear_extrude(e_mousse + e_fondkb) square([kb_w, kb_h]);
            color(C_SOC)  translate([0, 0, -(e_plexi + e_fondkb + e_mousse + e_socle)])
                          linear_extrude(e_socle) square([kb_w, kb_h]);
        }
    }
}

// Connectique sur la tranche arriere
// ---------------- LES CARTES, EN VOLUME ----------------
// Quatre cartes identifiees, plus un volume d'alimentation NON PLACE.
module cartes() {
    // --- 1 et 2 : les deux cartes laterales, en DOUBLE FACE ---------
    for (c = [0, 1]) {
        x = c == 0 ? x_lat_g : x_lat_d;
        color(C_PCB) translate([x, y_lat_av, z_lat])
            cube([pcb_lat_w, pcb_lat_l, e_pcb]);
        // l'ESP32-S3 au DOS de la carte : c'est tout l'interet du double face,
        // les commandes devant, la puce derriere.
        // TOURNE A 90 deg ET REPOUSSE AU BORD EXTERIEUR (cote boutons) : couche,
        // il ne coupe plus la carte en deux et laisse une zone continue.
        // Et surtout son ANTENNE PCB se retrouve au bord du boitier, ce que la
        // note d'application d'Espressif demande — un module au milieu d'un plan
        // de masse rayonne mal.
        esp_x = c == 0 ? x : x + pcb_lat_w - 25.5;   // toujours vers l'exterieur
        color(C_ESP) translate([esp_x, y_lat_ar - 18 - 2, z_lat - esp_h])
            cube([25.5, 18, esp_h]);
    }

    if (avec_kb) {
        // --- 3 : carte LED AVANT, VERTICALE, en tranche du bloc -----
        color(C_PCB) translate([x_kb_g, y_kb - pcb_led_gap - e_pcb,
                                -e_plq - e_film - e_plexi])
            cube([kb_w, e_pcb, pcb_led_av_h]);

        // --- 4 : carte LED DU DESSOUS, POSEE SUR LE SOCLE -----------
        // Elle vit DANS la decoupe de la mousse : elle ne s'ajoute pas a la
        // hauteur. Elle couvre les poches des noires et celle du ruban.
        y0 = y_kb + kb_blanche - noire_l;
        z0 = -(kb_haut - e_socle);
        color(C_PCB) translate([x_kb_g, y0, z0])
            cube([kb_w, (y_kb + kb_h) - y0, e_pcb_led]);

        // LES 11 LED DES NOIRES — une par noire, sous sa poche borgne, aux memes
        // decalages de facteur de piano que le relief. Elles eclairent PAR EN
        // DESSOUS : couplage par l'AIR, cone a +/-42 deg, donc rien ne doit etre
        // colle dessus.
        for (n = noires_plan)
            color(C_LED) translate([x_kb_g + (n[0]+1)*kb_pas + n[1] - 1.75,
                                    y_kb + kb_blanche - noire_l/2 - 1.75,
                                    z0 + e_pcb_led])
                cube([3.5, 3.5, led_h]);

        // LES LED DU RUBAN — meme carte, sous la bande tactile.
        n_led_rub = floor(ruban_l / 16.7);   // bande 60 LED/m : pas de 16,7 mm
        for (i = [0 : n_led_rub-1])
            color(C_LED) translate([marge + (util_w - ruban_l)/2 + 4 + i*16.7,
                                    y_ruban + ruban_w/2 - 1.75, z0 + e_pcb_led])
                cube([3.5, 3.5, led_h]);
    }
}

// VOLUME D'ALIMENTATION — reserve, PAS PLACE. Dessine contre la paroi arriere
// uniquement pour montrer l'emprise ; sa position n'est pas decidee.
module volume_alim() {
    color(C_LIBRE) translate([(F_W - alim_w)/2, F_H - marge - alim_l, -h_int])
        cube([alim_w, alim_l, alim_h]);
}

// ---------------- CONNECTIQUE, EN BORD DE CARTE ----------------
// Les deux cartes laterales arrivent a 2 mm de la paroi arriere : les connecteurs
// sont donc soudes DESSUS, en bord de carte, et traversent la paroi. Plus besoin
// d'une carte de connectique separee, ni de fils vers la tranche.
//
// REPARTITION — elle suit la piste "une carte l'alimentation, l'autre l'audio" :
//   GAUCHE  = le cote ALIMENTATION et CV. USB-C (entree 5 V) + les quatre
//             CV/GATE/CLK/RST, qui viennent du DAC et du 74HCT125, donc du 5 V.
//   DROITE  = le cote AUDIO et MIDI. Les deux sorties audio symetriques y sont
//             loin du convertisseur a decoupage, et pres du moteur audio si la
//             reservation FPGA se concretise de ce cote.
// L'entraxe des jacks 3,5 est fixe par le DIAMETRE DES FICHES, pas par celui des
// embases : une fiche fait ~9 mm de corps, d'ou 12 mm mini pour pouvoir la saisir.
jack_pas = 12;

module jack(x, z, d, c) {
    translate([x, F_H - e_paroi - 1, z]) rotate([-90,0,0])
        color(c) cylinder(d = d, h = e_paroi + 3, $fn = 24);
}

module connectique() {
    // axe des embases : ~3 mm au-dessus de la carte qui les porte
    z_j = z_lat + 3;

    // --- CARTE GAUCHE : USB-C + CV GATE CLK RST ---
    translate([x_lat_g + 4, F_H - e_paroi - 1, z_lat + 1])
        color(C_CONN) cube([usb_w, e_paroi + 3, 3.26]);
    for (i = [0 : n_jack_g - 1])        // CV GATE CLK RST
        jack(x_lat_g + 4 + usb_w + 10 + i*jack_pas, z_j, jack_d, C_CONN);

    // --- CARTE DROITE : MIDI IN/OUT + audio L/R ---
    for (i = [0 : n_jack_d - 1])        // MIDI IN, MIDI OUT
        jack(x_lat_d + 8 + i*jack_pas, z_j, jack_d, C_CONN);
    for (i = [0 : n_audio - 1])         // audio L, R — ecartes du MIDI
        jack(x_lat_d + 8 + (n_jack_d + i)*jack_pas + 6, z_j, audio_d, [0.55,0.45,0.20]);
}

// ---------------- ASSEMBLAGE ----------------
y_kb    = marge;
y_rang3 = marge + (avec_kb ? kb_h + jeu_kb : 0);
y_rang2 = y_rang3 + rang3_h;
y_rang1 = y_rang2 + rang2_h + jeu_rang;

// ---- LES CARTES, en volume ----------------------------------------
// Reperes des deux cartes laterales : elles occupent tout ce qui reste de la
// rangee haute de part et d'autre de l'ecran.
x_r1_a   = marge + (util_w - rang1_w_fonc)/2;
x_sc_a   = x_r1_a + btn_col_w + jeu_rang + col_w + jeu_rang;
// TAILLE OPTIMISEE : on ne se limite pas a la rangee de commandes, on prend tout
// ce qui est libre a cette hauteur.
//   en X : de la paroi (avec jeu) jusqu'au bord de l'ecran. Au-dela, l'ecran
//          descend a -16 alors que la carte est a -9,6 : elle ne peut pas passer
//          dessous.
//   en Y : de l'arriere du clavier (avec jeu) a la paroi arriere. Vers l'avant,
//          la piece de plexi descend a -16,3 et barre le passage.
jeu_paroi = 2;
y_lat_av  = (avec_kb ? y_kb + kb_h : marge) + jeu_paroi;   // derriere le clavier
y_lat_ar  = F_H - e_paroi - jeu_paroi;                     // contre la paroi arriere
pcb_lat_l = y_lat_ar - y_lat_av;                           // profondeur de carte
x_lat_g   = e_paroi + jeu_paroi;                           // carte GAUCHE (ESP32-B)
pcb_lat_w = x_sc_a - jeu_paroi - x_lat_g;                  // largeur de carte
x_lat_d   = x_sc_a + scr_w + jeu_paroi;                    // carte DROITE (ESP32-C)
// La carte est sous les boutons : le PB86 fixe sa hauteur.
z_lat    = -btn_prof - e_pcb;
// Ce qui reste au-dessus de la carte pour les composants traversants, et en
// dessous pour tout le reste :
h_sous_lat = h_int - btn_prof - e_pcb;

// Ouvertures de la facade (le plexi passe dessous)
x_kb_g  = marge + (util_w - kb_w)/2;
x_ouv   = x_kb_g - jeu_ouv;
w_ouv   = kb_w + 2*jeu_ouv;
x_ouv_r = marge + (util_w - ruban_l)/2 - jeu_ouv;
// Le ruban recule dans le dos, derriere le cache
y_ruban = y_kb + kb_blanche + 2*jeu_ouv + cache_dos;

// Poste dimensionnant en hauteur, et hauteur interieure minimale
h_organe_max = max(scr_t, max(btn_prof, max(enc_prof, kb_haut)));
h_dessous    = e_pcb + esp_h + cabl_h;
h_int_mini   = h_organe_max + h_dessous;

if (!plan) {
plaque();
if (avec_kb) clavier([marge + (util_w - kb_w)/2, y_kb]);

if (fonc) {
    // gauche -> droite : vues+SHIFT | 3 molettes | ECRAN | 3 molettes | transport
    x = marge + (util_w - rang1_w_fonc)/2;                   // centree
    // SHIFT en index 0 = le plus BAS de la colonne, donc le plus PRES du clavier :
    // c'est un modificateur tenu au pouce pendant qu'on joue, pas une commande
    // qu'on va chercher.
    colonne_boutons(x, y_rang1, n_btn_g, 0);
    x1 = x + btn_col_w + jeu_rang;
    colonne(x1, y_rang1, n_gauche);
    x2 = x1 + col_w + jeu_rang;
    ecran([x2, y_rang1 + (rang1_h - scr_h_auto)/2], scr_w_auto, scr_h_auto);
    x3 = x2 + scr_w_auto + jeu_rang;
    colonne(x3, y_rang1, n_droite);
    colonne_boutons(x3 + col_w + jeu_rang, y_rang1, n_btn_d);
} else {
    ecran([marge, y_rang1 + (rang1_h - scr_h)/2], scr_w, scr_h);
    encodeurs([marge + scr_w + jeu_rang, y_rang1 + (rang1_h - enc_h)/2]);
}
if (!fonc) boutons([marge, y_rang2]);
// LE RUBAN EST POSE SUR LE DOS DU PEIGNE : meme piece de plexi que les touches,
// centre dans les 18 mm du dos. Il n'est PAS derriere le clavier.
if (avec_kb)
    ruban([marge + (util_w - ruban_l)/2, y_ruban]);
else
    ruban([marge + (util_w - ruban_l)/2, y_rang3], 2);
cartes();
connectique();
}   // fin du modele 3D

// =====================================================================
//  MODE PLAN — trois vues 2D cotees, pour dessiner le BOITIER
//
//    A — DESSUS               la facade ci-dessus, a plat, cotee
//    B — COUPE LONGITUDINALE  vertical, axe avant-arriere, AU MILIEU :
//                             traverse le clavier ET l'ecran
//    C — COUPE TRANSVERSALE   vertical, gauche-droite, AU DROIT DE LA
//                             RANGEE HAUTE : bouton|molette|ecran|molette|bouton
//
//  !! CHAQUE VUE NOMME SON PLAN DE COUPE. C'est le point d'ambiguite
//     recurrent du projet.
//  Le clavier EN TRAVERS n'est pas repris : coupe_cellule.scad le traite.
// =====================================================================
C_BOITE = [0.42,0.44,0.47];  C_FACE  = [0.93,0.93,0.91];
C_LIBRE = [0.97,0.87,0.45,0.60];
C_MOUS  = [0.75,0.65,0.55];  C_SOC   = [0.45,0.47,0.50];
C_TXT   = [0.13,0.13,0.13];  C_ROUGE = [0.75,0.15,0.15];
C_COTE  = [0.45,0.45,0.50];

module txt(p,s,t=4,al="left",c=C_TXT)
    color(c) translate(p) text(s,size=t,halign=al,valign="center");
module trait(a,b,ep=0.35,c=C_COTE)
    color(c) hull(){ translate(a) circle(ep,$fn=10); translate(b) circle(ep,$fn=10); }
module cote_h(x0,x1,y,s,t=4,dec=2.6) {
    trait([x0,y],[x1,y]);
    trait([x0,y-1.6],[x0,y+1.6]);  trait([x1,y-1.6],[x1,y+1.6]);
    txt([(x0+x1)/2, y+dec], s, t, "center");
}
module cote_v(y0,y1,x,s,t=4,dec=2.6) {
    trait([x,y0],[x,y1]);
    trait([x-1.6,y0],[x+1.6,y0]);  trait([x-1.6,y1],[x+1.6,y1]);
    txt([x+dec,(y0+y1)/2], s, t, dec < 0 ? "right" : "left");
}

// ---- A : dessus -----------------------------------------------------
module plan_A() {
    x_kb = marge + (util_w - kb_w)/2 - kb_cache;
    kb_tot = kb_w + 2*kb_cache;
    x_r1 = marge + (util_w - rang1_w_fonc)/2;
    x_sc = x_r1 + btn_col_w + jeu_rang + col_w + jeu_rang;

    color(C_FACE) square([F_W,F_H]);
    color(C_BOITE) difference(){ square([F_W,F_H]);
        translate([e_paroi,e_paroi]) square([F_W-2*e_paroi, F_H-2*e_paroi]); }

    // LA FACADE FAIT CACHE : on ne dessine que ce que les OUVERTURES laissent
    // voir. Le plexi continue dessous — son contour reel est trace en fin.
    color(C_KB) translate([x_ouv, y_kb]) square([w_ouv, kb_blanche + jeu_ouv]);
    // les noires sont un RELIEF USINE dans la plaque, pas une piece a part :
    // il faut voir les TALONS DES BLANCHES passer entre elles, sinon le dessin
    // laisse croire que la piece s'arrete avant le ruban.
    // (`use <>` n'importe que les modules, pas les variables : les decalages de
    //  facteur de piano sont donc recopies ici, et doivent suivre clavier_piano.scad)
    for (n = noires_plan)
        color(C_NOIR) translate([marge + (util_w - kb_w)/2
                                 + (n[0]+1)*kb_pas + n[1] - noire_w/2,
                                 y_kb + kb_blanche - noire_l])
            square([noire_w, noire_l]);
    // le ruban, SUR le dos, dans sa propre ouverture
    color(C_RUBAN) translate([marge + (util_w - ruban_l)/2, y_ruban])
        square([ruban_l, ruban_w]);
    // contour REEL de la piece de plexi : elle passe SOUS la facade
    for (seg = [[[x_kb,y_kb],[x_kb,y_kb+kb_h]], [[x_kb+kb_tot,y_kb],[x_kb+kb_tot,y_kb+kb_h]],
                [[x_kb,y_kb+kb_h],[x_kb+kb_tot,y_kb+kb_h]]])
        trait(seg[0], seg[1], 0.3, [0.35,0.38,0.42]);

    // rangee haute
    color(C_ECRAN) translate([x_sc, y_rang1 + (rang1_h - scr_h)/2]) square([scr_w, scr_h]);
    color(C_WIN)   translate([x_sc + (scr_w-scr_win_w)/2,
                              y_rang1 + (rang1_h - scr_h)/2 + (scr_h-scr_win_h)/2])
        square([scr_win_w, scr_win_h]);
    for (c=[0,1]) {
        xc = c==0 ? x_r1 + btn_col_w + jeu_rang + col_w/2
                  : x_sc + scr_w + jeu_rang + col_w/2;
        n  = c==0 ? n_gauche : n_droite;
        hh = n*(enc_knob+8);
        for (i=[0:n-1])
            color(C_ENC) translate([xc, y_rang1 + (rang1_h-hh)/2 + i*(enc_knob+8) + (enc_knob+8)/2])
                circle(d=enc_knob,$fn=36);
    }
    for (c=[0,1]) {
        xc = c==0 ? x_r1 + btn_col_w/2
                  : x_sc + scr_w + jeu_rang + col_w + jeu_rang + btn_col_w/2;
        n  = c==0 ? n_btn_g : n_btn_d;
        hh = n*btn_pitch;
        for (i=[0:n-1])
            color(C_BTN) translate([xc-btn_w/2,
                                    y_rang1 + (rang1_h-hh)/2 + i*btn_pitch + (btn_pitch-btn_l)/2])
                square([btn_w,btn_l]);
    }

    // tranche arriere rabattue
    yc = F_H + 9;  n_tot = n_jack + n_audio;  pas = (F_W - 2*marge)/(n_tot+2);
    color(C_CONN) translate([marge + pas*(n_tot+1) - usb_w/2, yc]) square([usb_w, 3.3]);
    for (i=[0:n_tot-1])
        color(C_CONN) translate([marge + pas*(i+1), yc+1.6]) circle(d=jack_d,$fn=24);
    trait([marge-3,yc-4],[F_W-marge,yc-4]);
    txt([marge, yc+7], "MIDI IN/OUT  CV GATE CLK RST  audio L/R          USB-C", 3.4);
    txt([F_W-marge, yc-8], "tranche arriere (rabattue)", 3.4, "right");

    txt([0, F_H+32], "A — VUE DE DESSUS", 8);
    txt([0, F_H+24], "plan de coupe : aucun. Facade de face, tranche arriere rabattue.", 4);
    cote_h(0, F_W, -10, str("FACADE  ", F_W, " mm"), 5);
    cote_h(x_kb, x_kb+kb_tot, y_kb-5, str("clavier ", kb_tot), 4);
    cote_v(0, F_H, F_W+9, str(F_H, " mm"), 5);
    txt([F_W+3, F_H+17], "PROFONDEUR", 5, "left");
    cote_v(y_kb, y_kb+kb_blanche, x_kb-7, str("touches ", kb_blanche), 3.6, -2);
    cote_v(y_kb+kb_blanche, y_kb+kb_h, x_kb-7, str("dos ", kb_dos), 3.6, -2);
    // le decoupage du dos : cache | ruban | bord arriere
    cote_v(y_kb+kb_blanche+jeu_ouv, y_ruban-jeu_ouv, x_kb+kb_tot+6,
           str("CACHE ", cache_dos), 3.6);
    cote_v(y_ruban+ruban_w+jeu_ouv, y_kb+kb_h, x_kb+kb_tot+6, str("bord ", bord_ar), 3.6);
    txt([F_W/2, y_kb+7],
        str("UNE SEULE PIECE DE PLEXI, ", kb_h, " mm : ", kb_blanche,
            " de touches + ", kb_dos, " de dos — elle passe SOUS la facade"), 3.8, "center");
    txt([F_W/2, y_kb+kb_blanche+jeu_ouv+cache_dos/2],
        "la facade CACHE le dos du peigne des noires et la zone de contact du film",
        3.4, "center");
    txt([0, -18],
        str("DOS = cache ", cache_dos, " + jeux ", 3*jeu_ouv, " + ruban ", ruban_w,
            " + bord ", bord_ar, " = ", kb_dos, " mm   (la cote de depart etait ",
            kb_dos_ini, " : il en manquait ", kb_dos_mini - kb_dos_ini, ")"),
        4.2, "left", kb_dos_mini > kb_dos_ini ? C_ROUGE : C_TXT);
    txt([F_W/2, y_kb+kb_blanche-noire_l-5],
        "11 noires — RELIEF USINE dans la plaque ; les talons des blanches passent entre elles",
        3.6, "center");
}

// ---- B : coupe longitudinale ----------------------------------------
module plan_B() {
    z = -h_int;
    color(C_BOITE) {
        translate([-e_paroi, z-e_fond]) square([F_H+2*e_paroi, e_fond]);
        translate([-e_paroi, z-e_fond]) square([e_paroi, h_int+e_fond+relief_n+3]);
        translate([F_H, z-e_fond])      square([e_paroi, h_int+e_fond+relief_n+3]);
    }
    color(C_LIBRE) translate([y_kb, z]) square([kb_h, h_int-kb_haut]);
    color(C_LIBRE) translate([y_rang1, z]) square([rang1_h, h_int-scr_t]);
    color(C_LIBRE) translate([y_kb+kb_h, z]) square([y_rang1-y_kb-kb_h, h_int]);

    // !! LE CLAVIER N'EST PAS UN BLOC PLEIN DE 16,3 mm. Le PLEXI ne fait que
    //    10 mm — MOINS que les 16 de l'ecran. Le reste, c'est la suspension :
    //    mousse (le ressort) et socle. Les dessiner separement, sinon le plan
    //    laisse croire que le plexi est plus epais que l'ecran, ce qui est faux.
    color(C_KB)   translate([y_kb, -(e_plq+e_film)])   square([kb_h, e_plq+e_film]);
    color(C_KB)   translate([y_kb, -(e_plq+e_film+e_plexi)]) square([kb_h, e_plexi]);
    color(C_MOUS) translate([y_kb, -(kb_haut-e_socle)]) square([kb_h, e_mousse+e_fondkb]);
    color(C_SOC)  translate([y_kb, -kb_haut])          square([kb_h, e_socle]);

    color(C_RUBAN) translate([y_kb+kb_blanche+(kb_dos-ruban_w)/2, 0]) square([ruban_w, 1.2]);
    color(C_ECRAN) translate([y_rang1 + (rang1_h-scr_h)/2, -scr_t]) square([scr_h, scr_t]);
    color(C_CONN)  translate([F_H-conn_prof, z+cabl_h/2]) square([conn_prof, jack_d]);
    // les cartes traversees par cette coupe
    color(C_PCB) translate([y_kb - pcb_led_gap - e_pcb, -e_plq-e_film-e_plexi])
                 square([e_pcb, pcb_led_av_h]);          // LED avant, verticale
    y0b = y_kb + kb_blanche - noire_l;
    color(C_PCB) translate([y0b, -(kb_haut - e_socle)])
                 square([(y_kb + kb_h) - y0b, e_pcb_led]); // LED dessous, sur le socle
    color(C_LIBRE) translate([F_H - marge - alim_l, z]) square([alim_l, alim_h]);
    txt([F_H - marge - alim_l, z + alim_h + 3], "alim / MIDI / CV — NON PLACE", 3.4);

    txt([0, relief_n+22], "B — COUPE LONGITUDINALE", 8);
    txt([0, relief_n+14],
        "plan de coupe : VERTICAL, axe avant-arriere, AU MILIEU — il traverse le clavier ET l'ecran.", 4);
    txt([0, relief_n+8],
        str("z = 0 a la face touchee des BLANCHES. AUCUNE NOIRE ICI : au milieu la coupe tombe entre SI et DO. (relief : +",
            relief_n, ")"), 4);
    // Cotes couche par couche : le PLEXI (10) est plus MINCE que l'ecran (16).
    // Une seule cote graphique — celle qui compte : le PLEXI. Elle tient dans la
    // bande libre entre le clavier et la rangee haute, son label au-dessus.
    x_c = y_kb + kb_h + 6;
    cote_v(-(e_plq+e_film+e_plexi), -(e_plq+e_film), x_c, "", 3.4);
    txt([x_c, 4], str("PLEXI ", e_plexi), 4, "center");
    cote_v(-kb_haut, 0, y_kb-5, str(kb_haut), 3.6, -2);
    cote_v(z, 0, F_H+e_paroi+8, str("h_int = ", h_int), 5);
    txt([F_H+e_paroi+8, z-6], str("hors-tout ", e_facade+h_int+e_fond, " mm"), 4.5);
    cote_h(0, F_H, z-e_fond-9, str("profondeur interieure ", F_H), 4.5);
    txt([y_kb+2, z+3], "en jaune : ce qui reste LIBRE", 4);
    txt([0, z-e_fond-20],
        str("a loger dessous : PCB ", e_pcb, " + ESP32 ", esp_h, " + cablage ", cabl_h,
            " = ", h_dessous, " mm  ->  h_int MINIMALE ", h_int_mini), 4.5, "left",
        h_int < h_int_mini ? C_ROUGE : C_TXT);
    txt([0, z-e_fond-28],
        str("empilement clavier : plaque ", e_plq, " + film ", e_film, " + PLEXI ",
            e_plexi, " + mousse ", e_mousse, " + socle ", e_socle, " = ", kb_haut), 4.5);
    txt([0, z-e_fond-35],
        str("=> LE PLEXI SEUL FAIT ", e_plexi, " mm, MOINS que les ", scr_t,
            " de l'ecran. Le reste est la suspension, pas du plexi."), 4.5, "left", C_ROUGE);
}

// ---- C : coupe transversale -----------------------------------------
module plan_C() {
    z = -h_int;
    x_r1 = marge + (util_w - rang1_w_fonc)/2;
    x_sc = x_r1 + btn_col_w + jeu_rang + col_w + jeu_rang;
    color(C_BOITE) {
        translate([-e_paroi, z-e_fond]) square([F_W+2*e_paroi, e_fond]);
        translate([-e_paroi, z-e_fond]) square([e_paroi, h_int+e_fond+3]);
        translate([F_W, z-e_fond])      square([e_paroi, h_int+e_fond+3]);
    }
    color(C_LIBRE) translate([0, z]) square([F_W, h_int-max(scr_t,btn_prof)]);
    color(C_ECRAN) translate([x_sc, -scr_t]) square([scr_w, scr_t]);
    color(C_WIN)   translate([x_sc+(scr_w-scr_win_w)/2, -0.5]) square([scr_win_w, 0.5]);
    for (c=[0,1]) {
        xc = c==0 ? x_r1 + btn_col_w + jeu_rang + col_w/2
                  : x_sc + scr_w + jeu_rang + col_w/2;
        color(C_ENC) translate([xc-3.5, -enc_prof]) square([7, enc_prof]);
        color(C_ENC) translate([xc-enc_knob/2, 0]) square([enc_knob, 6]);
    }
    for (c=[0,1]) {
        xc = c==0 ? x_r1 + btn_col_w/2
                  : x_sc + scr_w + jeu_rang + col_w + jeu_rang + btn_col_w/2;
        color(btn_prof > scr_t ? C_ROUGE : C_BTN)
            translate([xc-btn_w/2, -btn_prof]) square([btn_w, btn_prof]);
    }
    // LES DEUX CARTES LATERALES, coupees par ce plan
    for (c=[0,1]) {
        x = c==0 ? x_lat_g : x_lat_d;
        color(C_PCB) translate([x, z_lat]) square([pcb_lat_w, e_pcb]);
        color(C_ESP) translate([x + pcb_lat_w/2 - 9, z_lat - esp_h]) square([18, esp_h]);
    }
    txt([x_lat_g, z_lat - esp_h - 5],
        str("carte GAUCHE ", pcb_lat_w, " x ", rang1_h, " — ESP32-B au DOS"), 3.6);
    txt([x_lat_d + pcb_lat_w, z_lat - esp_h - 5],
        str("carte DROITE — ESP32-C au DOS"), 3.6, "right");

    txt([0, 26], "C — COUPE TRANSVERSALE", 8);
    txt([0, 18],
        "plan de coupe : VERTICAL, gauche-droite, AU DROIT DE LA RANGEE HAUTE — bouton | molette | ecran | molette | bouton.", 4);
    txt([0, 12], "Le clavier en travers n'est pas repris ici : voir coupe_cellule.scad, vues A et B.", 4);
    cote_v(-scr_t, 0, x_sc+scr_w+4, str("ecran ", scr_t), 4);
    cote_v(z, 0, F_W+e_paroi+8, str("h_int = ", h_int), 5);
    cote_h(0, F_W, z-e_fond-9, str("largeur interieure ", F_W), 4.5);
    txt([x_r1+btn_col_w/2+9, -btn_prof/2], str("PB86 : ", btn_h_tot, " de la surface visible au PCB, soit ", btn_prof, " sous la facade"), 4,
        "left", btn_prof > scr_t ? C_ROUGE : C_TXT);
    if (btn_prof > scr_t)
        txt([x_r1, -btn_prof-7],
            "!! plus profond que l'ecran : c'est LUI qui commande h_int. Cote a recuperer avant de figer.",
            4.2, "left", C_ROUGE);
}

if (plan) {
    txt([0, F_H+68], "NiDMI Seq — PLAN GLOBAL D'ENCOMBREMENT", 11);
    txt([0, F_H+56], str("2026-08-21  ·  cotes en mm  ·  variante ", variante,
                         "  ·  A dessus · B coupe longitudinale · C coupe transversale"), 4.5);
    txt([0, F_H+48], "En jaune : le volume LIBRE. En rouge : ce qui repose sur une cote ESTIMEE.", 4.5);
    trait([0, F_H+42], [F_W, F_H+42], 0.5);
    plan_A();
    translate([0, -h_int-100])          plan_B();
    translate([0, -2*h_int-190])        plan_C();

    echo(str("POSTE DIMENSIONNANT en hauteur : ", h_organe_max, " mm -> ",
             btn_prof >= h_organe_max ? "PB86" :
             (scr_t >= h_organe_max ? "ecran CrowPanel" : "clavier")));
    echo(str("h_int = ", h_int, " ; mini = ", h_int_mini,
             h_int < h_int_mini ? "  !! INSUFFISANT" : "  ok"));
    echo(str("HORS-TOUT ", F_W+2*e_paroi, " x ", F_H+2*e_paroi, " x ",
             e_facade+h_int+e_fond, " mm   (facade ", e_facade, " + interieur ",
             h_int, " + fond ", e_fond, ")"));
}

echo(str("VARIANTE ", variante, "  ->  facade ", F_W, " x ", F_H, " mm"));
if (avec_kb) {
  echo(str("  DOS DU PEIGNE : ", kb_dos, " mm  =  cache ", cache_dos,
           " + jeux ", 3*jeu_ouv, " + ruban ", ruban_w, " + bord arriere ", bord_ar));
  echo(str("  -> la cote de depart etait ", kb_dos_ini, " mm : il en ",
           kb_dos_mini > kb_dos_ini ? str("MANQUE ", kb_dos_mini - kb_dos_ini)
                                    : str("reste ", kb_dos_ini - kb_dos_mini), " mm"));
  echo(str("  -> piece de plexi ", kb_h, " mm  (", kb_blanche, " + ", kb_dos, ")"));
  echo(str("  CARTES LATERALES (optimisees) : 2 x ", pcb_lat_w, " x ", pcb_lat_l,
           " mm = ", pcb_lat_w*pcb_lat_l/100, " cm2 chacune"));
  echo(str("     hauteur dispo : ", btn_prof, " au-dessus (composants traversants) + ",
           h_sous_lat, " en dessous"));
  echo(str("     a comparer a l'emprise de la rangee de commandes : 66 x ", rang1_h,
           " = ", 66*rang1_h/100, " cm2"));
  echo(str("  CARTE LED avant ", kb_w, " x ", pcb_led_av_h,
           " (verticale)  ·  CARTE LED dessous ", kb_w, " x ",
           kb_h - (kb_blanche - noire_l), " (sur le socle, dans la mousse)"));
  echo(str("  CONNECTIQUE en bord de carte, a l'entraxe ", jack_pas, " mm :"));
  echo(str("     GAUCHE  USB-C + ", n_jack_g, " jacks (CV GATE CLK RST)  ->  ",
           4 + usb_w + 10 + n_jack_g*jack_pas, " mm sur ", pcb_lat_w, " disponibles"));
  echo(str("     DROITE  ", n_jack_d, " jacks MIDI + ", n_audio,
           " audio  ->  ", 8 + (n_jack_d+n_audio)*jack_pas + 6, " mm sur ",
           pcb_lat_w, " disponibles"));
  echo(str("  ALIMENTATION : ", alim_w, " x ", alim_l, " x ", alim_h,
           " mm A LOGER — position NON DECIDEE (a tenir loin du film)"));
  if (kp_Wh != kb_h || kp_dos != kb_dos)
      echo(str("  !!!! DESYNCHRONISE : clavier_piano.scad a Wh=", kp_Wh, " dos=", kp_dos,
               "  alors qu'il faut Wh=", kb_h, " dos=", kb_dos,
               "  -> le ruban sortira du plexi"));
}
echo(str("  zone utile ", util_w, " x ", util_h,
         "   rangee haute ", rang1_h, " mm de profondeur"));
echo(str("  ruban ", ruban_l, " mm   (dispo dans la bande : ", util_w, " mm)"));
if (res_audio)
    echo(str("  reserve audio FPGA (cavite) : ", cmod_w + 4 + dac_w, " x ",
             max(cmod_l, dac_l), " mm, hauteur ", max(cmod_h, dac_h),
             "   [Cmod A7 ", cmod_w, "x", cmod_l, " + DAC ", dac_w, "x", dac_l, "]"));
echo(str("  sortie audio ", audio_sym ? "SYMETRIQUE" : "asymetrique", " x", n_audio,
         "   jack ", audio_635 ? "6,35 mm" : "3,5 mm",
         " -> profondeur ", audio_prof, " mm",
         audio_prof > 16 ? "  !! COMPOSANT LE PLUS PROFOND DE L'INSTRUMENT" : ""));
if (fonc) echo(str("  rangee haute ", rang1_w_fonc, " mm de large   CrowPanel Advance carte ",
                   scr_w, " x ", scr_h, " (actif ", scr_win_w, " x ", scr_win_h, ")"));
