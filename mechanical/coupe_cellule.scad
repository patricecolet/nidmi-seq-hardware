// =====================================================================
//  NiDMI Seq — ASSEMBLAGE DU CLAVIER, deux coupes
//
//  A — COURANTE : en travers du clavier, au droit d'une noire et d'une coupe
//  B — RIVE     : le bord avant, ou le cache capture le film et ou la LED injecte
//
//  Dessins de PRINCIPE, traces explicitement en 2D : ce qu'on voit est
//  exactement ce qu'on a voulu montrer.
//
//  !! COUCHES MINCES EXAGEREES pour rester lisibles ; cotes reelles en regard.
//  Decisions : docs/CONCEPT_PLEXI_EPAIS.md, « Technique d'electrode » (2026-08-21)
// =====================================================================

etiquettes = true;
exag_mince = 20;

/* [Empilement — cotes reelles en mm] */
e_pet     = 0.125;   // PET vers le DOIGT : c'est lui la protection
e_ito     = 0.05;    // couche ITO, gravee en motif, tournee vers le plexi
e_air     = 0.10;    // film d'air : le film n'est colle qu'au pourtour
e_bloc    = 10.0;    // bloc PMMA — guide de lumiere, LED en tranche avant
e_fond    = 0.05;    // fond sombre absorbant
e_mousse  = 3.0;     // mousse : pousse tout vers l'avant
e_arriere = 2.0;     // plaque arriere, vissee en peripherie
e_noire   = 3.0;     // touche noire, collee SUR le film

larg_coupe = 1.2;
p_grav     = 0.6;
pas_w      = 18.5;
larg_noire = 10.8;
n_pas      = 3;
L          = n_pas * pas_w;

e_cache = 2.0;
e_pcb   = 1.6;
led_c   = 3.5;
jeu_led = 1.0;

C_PMMA=[0.80,0.88,0.93]; C_PET=[0.95,0.95,0.90]; C_ITO=[0.30,0.72,0.52];
C_ITO_N=[0.60,0.30,0.70]; C_LAM=[0.10,0.10,0.12]; C_FOND=[0.12,0.12,0.14];
C_MOUS=[0.75,0.65,0.55]; C_ARR=[0.45,0.47,0.50]; C_NOIRE=[0.10,0.10,0.12];
C_CACHE=[0.28,0.28,0.31]; C_PCB=[0.05,0.35,0.18]; C_LED=[1.00,0.75,0.25];
C_TXT=[0.15,0.15,0.15];

function ep(e) = e < 0.5 ? e * exag_mince : e;

y_pet_h  = ep(e_air) + ep(e_ito) + ep(e_pet);
y_pet_b  = ep(e_air) + ep(e_ito);
y_ito_b  = ep(e_air);
y_bloc_b = -e_bloc;
y_fond_b = y_bloc_b - ep(e_fond);
y_mou_b  = y_fond_b - e_mousse;
y_arr_b  = y_mou_b - e_arriere;

module txt(p,s,t=1.6,al="left") color(C_TXT) translate(p) text(s,size=t,halign=al,valign="center");
module trait(a,b) color([0.55,0.55,0.58]) hull(){translate(a) circle(0.07,$fn=8); translate(b) circle(0.07,$fn=8);}

module coupe_courante() {
    x_c = pas_w;
    x_n = pas_w - larg_noire/2;

    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([L,e_bloc]);
        translate([x_c-larg_coupe/2, y_bloc_b-0.1]) square([larg_coupe, e_bloc+0.2]);
        for (x=[2:2.4:L-2]) translate([x,y_bloc_b]) circle(d=p_grav*1.6,$fn=16);
    }
    color(C_LAM) translate([x_c-0.35, y_bloc_b]) square([0.7, e_bloc]);
    color(C_FOND) translate([0,y_fond_b]) square([L,ep(e_fond)]);
    color(C_MOUS) translate([0,y_mou_b])  square([L,e_mousse]);
    color(C_ARR)  translate([0,y_arr_b])  square([L,e_arriere]);

    j = 2.0;
    color(C_ITO)   translate([j/2, y_ito_b]) square([x_n-j, ep(e_ito)]);
    color(C_ITO_N) translate([x_n+j/2, y_ito_b]) square([larg_noire-j, ep(e_ito)]);
    color(C_ITO)   translate([x_n+larg_noire+j/2, y_ito_b]) square([2*pas_w-(x_n+larg_noire)-j, ep(e_ito)]);
    color(C_ITO)   translate([2*pas_w+j/2, y_ito_b]) square([pas_w-j, ep(e_ito)]);

    color(C_PET) translate([0,y_pet_b]) square([L, ep(e_pet)]);

    color(C_NOIRE) difference() {
        translate([x_n, y_pet_h]) square([larg_noire, e_noire]);
        for (x=[x_n+1.2 : 1.8 : x_n+larg_noire-1]) translate([x,y_pet_h]) circle(d=0.5,$fn=12);
    }

    if (etiquettes) {
        xr = L + 3;
        for (l = [
          [y_pet_b+ep(e_pet)/2, str("PET  ",e_pet," mm  — la surface touchee, et la protection")],
          [y_ito_b+ep(e_ito)/2, "ITO grave — ilots d'electrodes ; la GARDE est la mer autour"],
          [y_ito_b/2,           "film d'air — le film n'est colle qu'au POURTOUR"],
          [y_bloc_b+e_bloc/2,   str("bloc PMMA  ",e_bloc," mm  — guide, LED en tranche avant, gravure au dos")],
          [y_fond_b+ep(e_fond)/2, "fond sombre — absorbe le halo non extrait"],
          [y_mou_b+e_mousse/2,  str("mousse  ",e_mousse," mm  — pousse tout vers l'avant")],
          [y_arr_b+e_arriere/2, str("plaque arriere  ",e_arriere," mm")]
        ]) { trait([L,l[0]],[xr-0.8,l[0]]); txt([xr,l[0]],l[1]); }

        trait([x_c,y_bloc_b],[x_c,y_bloc_b-5]);
        txt([x_c,y_bloc_b-6.3],"coupe de scie traversante + LAMELLE NOIRE",1.6,"center");
        trait([x_n+larg_noire/2, y_pet_h+e_noire],[x_n+larg_noire/2, y_pet_h+e_noire+3]);
        txt([x_n+larg_noire/2, y_pet_h+e_noire+4.3], str("NOIRE ",e_noire," mm — collee SUR le film"),1.6,"center");
        txt([0, y_pet_h+e_noire+8.5], "A — COUPE COURANTE", 2.6);
    }
}

// ---------------------------------------------------------------- B
// Coupe EN LONG d'une blanche : c'est le seul plan ou se voient l'injection des
// LED et la CLOISON TRANSVERSALE qui coupe la touche en deux zones lumineuses
// independantes — une par symbole.
Lk      = 52;      // longueur utile d'une blanche
x_cl    = 24;      // abscisse de la cloison transversale
Lb      = 32;      // longueur d'une noire (posee a l'arriere)
fente   = 2.2;     // fente qui recoit une dent du PCB (1.6 de FR4 + jeu)
dos     = 8;       // dos du peigne : ce qui tient les touches ensemble
pont    = 2.0;     // pont de matiere de chaque cote, qui retient la touche

module coupe_longue() {
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([Lk+fente+dos, e_bloc]);
        translate([x_cl-larg_coupe/2, y_bloc_b-0.1]) square([larg_coupe, e_bloc+0.2]);
        translate([Lk, y_bloc_b-0.1]) square([fente, e_bloc+0.2]);
        // zone 1 : trame qui se densifie en s'eloignant de la LED avant
        for (x=[3:3.4:x_cl-2])  translate([x,y_bloc_b]) circle(d=p_grav*(0.9+x/x_cl),$fn=16);
        // zone 2 : trame qui se densifie en s'eloignant de la LED arriere
        for (x=[x_cl+2:3.4:Lk-3]) translate([x,y_bloc_b]) circle(d=p_grav*(0.9+(Lk-x)/(Lk-x_cl)),$fn=16);
    }
    color(C_LAM) translate([x_cl-0.35, y_bloc_b]) square([0.7, e_bloc]);

    color(C_FOND) translate([0,y_fond_b]) square([Lk+fente+dos,ep(e_fond)]);
    color(C_MOUS) translate([0,y_mou_b])  square([Lk+fente+dos,e_mousse]);
    color(C_ARR)  translate([-e_cache,y_arr_b]) square([Lk+fente+dos+2*e_cache,e_arriere]);
    color(C_ITO)  translate([1.5,y_ito_b]) square([Lk+fente+dos-3, ep(e_ito)]);
    color(C_PET)  translate([-1.5,y_pet_b]) square([Lk+fente+dos+3, ep(e_pet)]);

    // noire posee a l'arriere, sur le film
    color(C_NOIRE) translate([Lk-Lb, y_pet_h]) square([Lb, e_noire]);

    // PCB avant, hors du bloc
    color(C_PCB) translate([-(jeu_led+e_pcb), y_bloc_b+1]) square([e_pcb, e_bloc-2]);
    color(C_LED) translate([-jeu_led, -e_bloc/2-led_c/2]) square([jeu_led, led_c]);

    // PCB ARRIERE EN PEIGNE : une dent entre dans la fente du dos, sa LED
    // regarde vers l'avant et injecte dans la tranche que la fente vient de
    // creer. Le FR4 fait en meme temps barriere optique.
    color(C_PCB) translate([Lk + (fente-e_pcb)/2, y_bloc_b+0.5]) square([e_pcb, e_bloc-1]);
    color(C_LED) translate([Lk + (fente-e_pcb)/2 - jeu_led, -e_bloc/2-led_c/2])
        square([jeu_led, led_c]);

    xm0 = -(jeu_led+e_pcb) - e_cache;
    xm1 = Lk + fente + dos;
    color(C_CACHE) union() {
        translate([xm0,y_arr_b]) square([e_cache, y_pet_h-y_arr_b+e_cache]);
        translate([xm0,y_pet_h]) square([e_cache+6, e_cache]);
        translate([xm1,y_arr_b]) square([e_cache, y_pet_h+e_noire-y_arr_b+e_cache]);
        translate([xm1-6,y_pet_h+e_noire]) square([e_cache+6, e_cache]);
    }

    if (etiquettes) {
        trait([x_cl, y_bloc_b],[x_cl, y_bloc_b-5]);
        txt([x_cl, y_bloc_b-6.3], "CLOISON TRANSVERSALE — coupe + lamelle : deux zones optiques independantes", 1.6, "center");
        txt([x_cl/2, y_pet_h+6], "zone 1 — symbole A", 1.7, "center");
        txt([(x_cl+Lk)/2, y_pet_h+e_noire+6], "zone 2 — symbole B", 1.7, "center");
        trait([x_cl/2, y_pet_h+5.2],[x_cl/2, y_pet_h+1]);
        trait([(x_cl+Lk)/2, y_pet_h+e_noire+5.2],[(x_cl+Lk)/2, y_pet_h+e_noire+0.5]);
        txt([xm0-2, -e_bloc/2], "LED avant", 1.6, "right");
        trait([Lk+fente/2, y_bloc_b],[Lk+fente/2, y_bloc_b-9]);
        txt([Lk+fente/2, y_bloc_b-10.3], "DENT DU PCB EN PEIGNE dans sa fente — la LED injecte,", 1.6, "center");
        txt([Lk+fente/2, y_bloc_b-12.6], "le FR4 fait barriere, et le PCB s'indexe tout seul", 1.6, "center");
        txt([xm1+e_cache+2, -e_bloc/2], "dos du peigne", 1.6);
        txt([0, y_pet_h+e_noire+11], "B — COUPE EN LONG D'UNE BLANCHE", 2.6);
        txt([0, y_arr_b-11], "trame de points DENSIFIEE en s'eloignant de chaque LED : c'est ce qui egalise la luminosite", 1.6);
    }
}

// ---------------------------------------------------------------- C
// VUE DE DESSUS de la zone arriere : c'est le seul plan ou se voient les PONTS
// qui retiennent chaque touche au dos, et les dents du PCB dans leurs fentes.
module vue_dessus() {
    n  = 3;
    yk = Lk*0.45;              // profondeur de touche montree
    lk = pas_w - 1.2;          // largeur utile d'une touche
    lf = lk/2;                 // LA FENTE OCCUPE LA MOITIE DE LA TOUCHE
    ld = lf - 1.6;             // dent du PCB : la fente moins le jeu

    for (i = [0:n-1]) {
        x0 = i*pas_w + 0.6;
        color(C_PMMA) translate([x0, 0]) square([lk, yk]);          // touche
        // moitie pleine = UN SEUL PONT LARGE, qui retient la touche au dos
        color(C_PMMA) translate([x0+lf, yk]) square([lk-lf, fente]);
    }
    color(C_PMMA) translate([0, yk+fente]) square([n*pas_w, dos]);  // dos

    // PCB en peigne : dos + une dent par touche, dans la moitie ouverte
    color(C_PCB) translate([-2, yk+fente+1.2]) square([n*pas_w+4, dos-2]);
    for (i = [0:n-1]) {
        xd = i*pas_w + 0.6 + (lf-ld)/2;
        color(C_PCB) translate([xd, yk]) square([ld, fente+1.2]);
        color(C_LED) translate([xd + ld/2 - led_c/2, yk+0.3]) square([led_c, 1.0]);
    }

    if (etiquettes) {
        x1 = 0.6 + lf + (pas_w-1.2-lf)/2;
        trait([x1, yk+fente],[x1, yk+fente+dos+5]);
        txt([x1, yk+fente+dos+6.4], "PONT — la MOITIE PLEINE de la touche la retient au dos", 1.6);
        xd0 = 0.6 + lf/2;
        trait([xd0, yk+0.8],[xd0, -5]);
        txt([xd0, -6.4], "dent du PCB + LED, dans la moitie ouverte", 1.6, "center");
        txt([0, -10.5], "un pont LARGE plutot que deux etroits : moins d'amorce de rupture en matiere cassante", 1.6);
        txt([0, -13.5], "et le dos ne recoit presque rien — la LED regarde l'avant, le FR4 arrete ce qui part en arriere", 1.6);
        trait([n*pas_w*0.8, yk+fente+dos/2],[n*pas_w+6, yk+fente+dos+4]);
        txt([n*pas_w+6.5, yk+fente+dos+4], "dos du peigne + PCB en peigne", 1.6);
        txt([0, yk+fente+dos+13], "C — VUE DE DESSUS, ZONE ARRIERE", 2.6);
    }
}

coupe_courante();
translate([0,-52]) coupe_longue();
translate([0,-142]) vue_dessus();

if (etiquettes) {
    txt([0, y_arr_b-168], "film + noires = UN SEUL sous-ensemble remplacable : la « peau » du clavier", 1.8);
    txt([0, y_arr_b-171.5], str("couches minces exagerees x", exag_mince, " ; cotes reelles en regard"), 1.4);
}
