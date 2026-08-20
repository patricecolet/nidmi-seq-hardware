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
fente   = 2.2;     // fente arriere qui recoit la dent du PCB (1.6 de FR4 + jeu).
                   // Elle n'occupe que la MOITIE de la largeur : l'autre moitie
                   // retient la touche au dos.
p_cloison = 5;     // LA CLOISON DU MILIEU N'ENTAME QUE LA MOITIE DE L'EPAISSEUR.
                   // Suffisant pour bloquer la lumiere entre les deux zones, et
                   // rien n'a besoin d'etre soutenu au milieu de la touche —
                   // ni cache, ni PCB.
// DOS DU PEIGNE — c'est lui qui tient les 16 touches ensemble, et c'est la piece
// la plus exposee : l'acrylique ne plie pas, il casse. Un dos mince avec 16
// fentes taillees dedans est fragile AVANT le montage — a l'usinage, au
// debridage, a la manipulation. C'est la que ca casserait, pas en service.
// 18 mm est une valeur ESTIMEE ; elle ne coute que de la profondeur en zone
// cachee, sous le cache arriere.
dos     = 18;
Lt      = Lk + fente + dos;   // longueur totale du bloc

module coupe_longue() {
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([Lt, e_bloc]);
        translate([x_cl-larg_coupe/2, y_bloc_b-0.1]) square([larg_coupe, p_cloison+0.1]);
        // zone 1 : trame qui se densifie en s'eloignant de la LED avant
        for (x=[3:3.4:x_cl-2])  translate([x,y_bloc_b]) circle(d=p_grav*(0.9+x/x_cl),$fn=16);
        // zone 2 : trame qui se densifie en s'eloignant de la LED arriere
        for (x=[x_cl+2:3.4:Lk-3]) translate([x,y_bloc_b]) circle(d=p_grav*(0.9+(Lk-x)/(Lk-x_cl)),$fn=16);
    }
    color(C_LAM) translate([x_cl-0.35, y_bloc_b]) square([0.7, p_cloison]);

    color(C_FOND) translate([0,y_fond_b]) square([Lt,ep(e_fond)]);
    color(C_MOUS) difference() {
        translate([0,y_mou_b]) square([Lt, e_mousse]);
    }
    color(C_ARR)  translate([-e_cache,y_arr_b]) square([Lt+2*e_cache,e_arriere]);
    color(C_ITO)  translate([1.5,y_ito_b]) square([Lt-3, ep(e_ito)]);
    color(C_PET)  translate([-1.5,y_pet_b]) square([Lt+3, ep(e_pet)]);

    // noire posee a l'arriere, sur le film
    color(C_NOIRE) translate([Lk-Lb, y_pet_h]) square([Lb, e_noire]);

    // PCB avant, hors du bloc
    color(C_PCB) translate([-(jeu_led+e_pcb), y_bloc_b+1]) square([e_pcb, e_bloc-2]);
    color(C_LED) translate([-jeu_led, -e_bloc/2-led_c/2]) square([jeu_led, led_c]);

    // CETTE COUPE PASSE PAR LA MOITIE PLEINE : le bloc n'y est pas interrompu.
    // La fente arriere, la dent du PCB et sa LED sont dans l'AUTRE moitie, donc
    // DERRIERE le plan de coupe — figurees ici en teinte pale, comme un detail
    // cache en dessin technique.
    color([0.55,0.68,0.60]) translate([Lk + (fente-e_pcb)/2, y_bloc_b+0.5])
        square([e_pcb, e_bloc-1]);
    color([0.92,0.82,0.55]) translate([Lk + (fente-e_pcb)/2 - jeu_led - 1,
                                       -e_bloc/2 - led_c/2])
        square([jeu_led+1, led_c]);

    xm0 = -(jeu_led+e_pcb) - e_cache;
    xm1 = Lt;
    color(C_CACHE) union() {
        translate([xm0,y_arr_b]) square([e_cache, y_pet_h-y_arr_b+e_cache]);
        translate([xm0,y_pet_h]) square([e_cache+6, e_cache]);
        translate([xm1,y_arr_b]) square([e_cache, y_pet_h+e_noire-y_arr_b+e_cache]);
        translate([xm1-6,y_pet_h+e_noire]) square([e_cache+6, e_cache]);
    }

    if (etiquettes) {
        trait([x_cl, y_bloc_b],[x_cl, y_bloc_b-12.2]);
        txt([x_cl, y_bloc_b-13.5], str("CLOISON TRANSVERSALE : elle n'entame que ", p_cloison, " mm sur ", e_bloc,
            " — deux zones optiques, et rien a soutenir au milieu"), 1.6, "center");
        txt([x_cl/2, y_pet_h+6], "zone 1 — symbole A", 1.7, "center");
        txt([(x_cl+Lk)/2, y_pet_h+e_noire+6], "zone 2 — symbole B", 1.7, "center");
        trait([x_cl/2, y_pet_h+5.2],[x_cl/2, y_pet_h+1]);
        trait([(x_cl+Lk)/2, y_pet_h+e_noire+5.2],[(x_cl+Lk)/2, y_pet_h+e_noire+0.5]);
        txt([xm0-2, -e_bloc/2], "LED avant", 1.6, "right");
        trait([Lk+fente/2, -e_bloc/2],[Lk+fente+9, -e_bloc/2+7]);
        txt([Lk+fente+9.5, -e_bloc/2+7], "LED ARRIERE + son PCB, en teinte pale :", 1.6);
        txt([Lk+fente+9.5, -e_bloc/2+4.6], "ils sont DERRIERE le plan de coupe", 1.6);
        trait([Lk+fente/2, y_bloc_b],[Lk+fente/2, y_bloc_b-6]);
        txt([Lk+fente/2, y_bloc_b-7.3],
            "coupe par la MOITIE PLEINE : le peigne n'est pas sectionne", 1.6, "center");
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
    yk = Lk*0.45;
    lk = pas_w - 1.2;
    lf = lk/2;                 // LA FENTE ARRIERE OCCUPE LA MOITIE DE LA TOUCHE
    ld = lf - 0.6;

    color(C_PMMA) translate([0.6, 0]) square([n*pas_w-1.2, yk+fente+dos]);
    for (i = [1:n-1])          // traits de scie entre touches, arretes au dos
        color([1,1,1]) translate([i*pas_w-0.6, -0.1]) square([1.2, yk+fente+0.1]);
    for (i = [0:n-1])          // fente arriere : moitie ouverte seulement
        color([1,1,1]) translate([i*pas_w+0.6, yk]) square([lf, fente]);

    color(C_PCB) translate([-2, yk+fente+1.2]) square([n*pas_w+4, dos-2.4]);
    for (i = [0:n-1]) {
        xd = i*pas_w + 0.6 + (lf-ld)/2;
        color(C_PCB) translate([xd, yk]) square([ld, fente+1.4]);
        color(C_LED) translate([xd+ld/2-led_c*0.8, yk+0.25]) square([led_c*1.6, 1.7]);
    }

    if (etiquettes) {
        x1 = 0.6 + lf + (lk-lf)/2;
        trait([x1, yk+fente/2],[x1, yk+fente+dos+5]);
        txt([x1, yk+fente+dos+6.4], "la MOITIE PLEINE retient la touche au dos — c'est par la que passe la coupe B", 1.6);
        xd0 = 0.6 + lf/2;
        trait([xd0, yk+fente/2],[xd0, -5]);
        txt([xd0, -6.4], "fente sur la MOITIE de la largeur + dent du PCB avec sa LED", 1.6, "center");
        txt([0, -10.5], "rien ne traverse au milieu de la touche : la cloison des deux zones n'entame que la mi-epaisseur", 1.6);
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
