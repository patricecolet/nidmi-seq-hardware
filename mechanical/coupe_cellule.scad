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

module coupe_rive() {
    Lr = L*0.55;
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([Lr,e_bloc]);
        for (x=[6:2.4:Lr-2]) translate([x,y_bloc_b]) circle(d=p_grav*1.6,$fn=16);
    }
    color(C_FOND) translate([0,y_fond_b]) square([Lr,ep(e_fond)]);
    color(C_MOUS) translate([0,y_mou_b])  square([Lr,e_mousse]);
    color(C_ARR)  translate([-e_cache,y_arr_b]) square([Lr+e_cache,e_arriere]);
    color(C_ITO)  translate([2,y_ito_b]) square([Lr-2, ep(e_ito)]);
    color(C_PET)  translate([-1.5,y_pet_b]) square([Lr+1.5, ep(e_pet)]);

    x_pcb = -(jeu_led + e_pcb);
    color(C_PCB) translate([x_pcb, y_bloc_b+1]) square([e_pcb, e_bloc-2]);
    color(C_LED) translate([x_pcb+e_pcb, -e_bloc/2-led_c/2]) square([jeu_led, led_c]);

    x_mur = x_pcb - e_cache;
    color(C_CACHE) union() {
        translate([x_mur,y_arr_b]) square([e_cache, y_pet_h - y_arr_b + e_cache]);
        translate([x_mur,y_pet_h]) square([e_cache+7, e_cache]);
    }

    if (etiquettes) {
        trait([x_mur+4, y_pet_h+e_cache],[x_mur+12, y_pet_h+e_cache+5]);
        txt([x_mur+12.5, y_pet_h+e_cache+5], "le cache PINCE le film — aucun bord colle, aucune arete ou un ongle s'insere");
        trait([x_pcb+e_pcb/2, y_bloc_b+1],[x_pcb+e_pcb/2, y_bloc_b-4]);
        txt([x_pcb+e_pcb/2, y_bloc_b-5.3], "PCB de tranche + LED : injection dans le bloc", 1.6);
        txt([0, y_pet_h+e_noire+8.5], "B — RIVE AVANT", 2.6);
    }
}

coupe_courante();
translate([0,-48]) coupe_rive();

if (etiquettes) {
    txt([0, y_arr_b-54], "film + noires = UN SEUL sous-ensemble remplacable : la « peau » du clavier", 1.8);
    txt([0, y_arr_b-57.5], str("couches minces exagerees x", exag_mince, " ; cotes reelles en regard"), 1.4);
}
