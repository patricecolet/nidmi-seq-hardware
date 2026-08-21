// =====================================================================
//  NiDMI Seq — ASSEMBLAGE DU CLAVIER
//
//  Etat au 2026-08-21, apres la seance de conception. Cinq vues :
//    A — coupe en travers AVANT   : les blanches, traits de scie, gravure
//    B — coupe en travers ARRIERE : au droit d'une noire, LED par en dessous
//    C — coupe en long d'une blanche, jusqu'au ruban
//    D — vue de dessus du BLOC    : ce qui est usine et ou
//    E — le FILM a plat           : un seul ITO pour tout
//
//  Dessins de PRINCIPE, traces explicitement en 2D.
//  !! COUCHES MINCES EXAGEREES ; cotes reelles en regard.
//
//  ---- LES TROIS DECISIONS QUI STRUCTURENT TOUT ----------------------
//  1. PLAQUE CONTINUE d'acrylique par-dessus l'ITO, relief des noires USINE
//     dedans. Elle pince le film sur toute sa surface, protege l'electrode
//     partout, supprime la colle. Son epaisseur EST le parametre d'aftertouch.
//  2. UN SEUL FILM ITO pour les touches ET le ruban, grave d'un seul coup :
//     un seul calage, fige par le masque.
//  3. TROIS ECLAIRAGES INDEPENDANTS. Blanches par la tranche avant, en lumiere
//     guidee. Noires et ruban PAR EN DESSOUS, sur une meme carte horizontale.
//     Une LED couplee par l'AIR n'emet dans le PMMA qu'a +/-42 deg, exactement
//     l'angle critique : tout sort au premier contact, rien ne passe en mode
//     guide. D'ou l'isolement, et deux corollaires :
//        - NE RIEN COLLER sous ces LED (un indice ~1,5 ouvre le cone a 90 deg)
//        - SATINER LE DESSOUS DE LA PLAQUE, jamais la face inferieure du bloc.
// =====================================================================

etiquettes = true;
exag_mince = 20;

/* [Empilement — cotes reelles en mm] */
e_plaque = 1.0;    // PLAQUE ACRYLIQUE continue — la surface touchee
relief_n = 1.0;    // relief de la noire, USINE dans la plaque
e_pet    = 0.125;  // PET porteur du film
e_ito    = 0.05;   // ITO grave en motif
e_air    = 0.10;   // le film n'est plaque que par la plaque au-dessus
e_bloc   = 10.0;   // bloc PMMA — guide de lumiere des blanches
e_fond   = 0.05;   // fond sombre absorbant, FENETRE sous chaque noire
e_mousse = 3.0;    // LE RESSORT : pousse tout contre la levre du cadre
e_socle  = 2.0;    // socle rigide — c'est LUI la reference des LED

/* [Decoupes du bloc] */
larg_coupe = 1.2;  // trait de scie entre blanches
p_scie     = 20;   // PROFONDEUR du trait : il s'arrete a 20 mm, donc il n'y a
                   // AUCUN trait sous les noires ni sous le ruban. Le bloc
                   // reste continu a l'arriere -> beaucoup plus solide.
poche_p    = 4.0;  // poche borgne sous la noire, PAR LE DESSOUS
poche_l    = 6.0;
p_grav     = 0.6;  // gravure d'extraction, face inferieure, blanches seulement

/* [Geometrie] */
pas_w      = 18.5;
larg_noire = 10.8;
n_pas      = 3;
L          = n_pas * pas_w;
Lk         = 52;   // longueur utile d'une blanche
Lb         = 32;   // longueur d'une noire, posee a l'arriere
dos        = 18;   // dos du peigne — porte le RUBAN
Lt         = Lk + dos;
ruban_l    = 10;

e_pcb = 1.6;  led_c = 3.5;  jeu_led = 1.0;

C_PMMA=[0.80,0.88,0.93]; C_PLQ=[0.86,0.91,0.95]; C_PET=[0.95,0.95,0.90];
C_ITO=[0.30,0.72,0.52];  C_ITO_N=[0.60,0.30,0.70]; C_NOIRE=[0.10,0.10,0.12];
C_FOND=[0.12,0.12,0.14]; C_MOUS=[0.75,0.65,0.55]; C_SOC=[0.45,0.47,0.50];
C_PCB=[0.05,0.35,0.18];  C_LED=[1.00,0.75,0.25];  C_TXT=[0.15,0.15,0.15];
C_RAY=[0.95,0.60,0.10];  C_SAT=[0.70,0.78,0.84];

function ep(e) = e < 0.5 ? e * exag_mince : e;

y_bloc_b = -e_bloc;
y_fond_b = y_bloc_b - ep(e_fond);
y_mou_b  = y_fond_b - e_mousse;
y_soc_b  = y_mou_b - e_socle;
y_ito_b  = ep(e_air);
y_pet_b  = y_ito_b + ep(e_ito);
y_plq_b  = y_pet_b + ep(e_pet);
y_plq_h  = y_plq_b + e_plaque;

module txt(p,s,t=1.6,al="left") color(C_TXT) translate(p) text(s,size=t,halign=al,valign="center");
module trait(a,b) color([0.55,0.55,0.58]) hull(){translate(a) circle(0.07,$fn=8); translate(b) circle(0.07,$fn=8);}
module rayon(a,b) color(C_RAY) hull(){translate(a) circle(0.07,$fn=8); translate(b) circle(0.07,$fn=8);}

// Empilement du dessous, commun aux coupes en travers
module dessous(x0, w, fenetre=[]) {
    difference() {
        color(C_FOND) translate([x0,y_fond_b]) square([w,ep(e_fond)]);
        for (f=fenetre) translate([f[0],y_fond_b-0.1]) square([f[1],ep(e_fond)+0.2]);
    }
    color(C_MOUS) translate([x0,y_mou_b]) square([w,e_mousse]);
    color(C_SOC)  translate([x0,y_soc_b]) square([w,e_socle]);
}

// ---------------------------------------------------------------- A
// COUPE EN TRAVERS, ZONE AVANT (moins de 20 mm du bord) : c'est la seule
// zone ou le bloc est fendu. Les blanches y sont des guides independants.
module coupe_avant() {
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([L,e_bloc]);
        for (i=[1:n_pas-1])
            translate([i*pas_w-larg_coupe/2, y_bloc_b-0.1]) square([larg_coupe, e_bloc+0.2]);
        for (x=[2:2.4:L-2]) translate([x,y_bloc_b]) circle(d=p_grav*1.6,$fn=16);
    }
    dessous(0, L);

    j = 2.0;
    for (i=[0:n_pas-1])
        color(C_ITO) translate([i*pas_w+j/2, y_ito_b]) square([pas_w-j, ep(e_ito)]);
    color(C_PET) translate([0,y_pet_b]) square([L, ep(e_pet)]);
    color(C_PLQ) translate([0,y_plq_b]) square([L, e_plaque]);

    if (etiquettes) {
        xr = L + 3;
        for (l = [
          [y_plq_b+e_plaque/2,   str("PLAQUE ACRYLIQUE  ", e_plaque, " mm — la surface touchee")],
          [y_pet_b+ep(e_pet)/2,  str("PET  ", e_pet, " mm")],
          [y_ito_b+ep(e_ito)/2,  "ITO grave — ilots d'electrodes ; la GARDE est la mer autour"],
          [y_ito_b/2,            "film d'air — la plaque plaque le film, il n'est pas colle"],
          [y_bloc_b+e_bloc/2,    str("bloc PMMA  ", e_bloc, " mm — guide, LED en tranche avant")],
          [y_fond_b+ep(e_fond)/2,"fond sombre — absorbe le halo non extrait"],
          [y_mou_b+e_mousse/2,   str("mousse  ", e_mousse, " mm — LE RESSORT (faible deformation remanente)")],
          [y_soc_b+e_socle/2,    str("socle  ", e_socle, " mm — reference rigide des LED")]
        ]) { trait([L,l[0]],[xr-0.8,l[0]]); txt([xr,l[0]],l[1]); }

        trait([pas_w,y_bloc_b],[pas_w,y_bloc_b-5]);
        txt([pas_w,y_bloc_b-9.5], str("trait de scie traversant — PLUS DE LAMELLE"),1.6,"center");
        txt([pas_w,y_bloc_b-11.7], "un trait sur quatre marque, pour le repere rythmique au doigt",1.6,"center");
        txt([0, y_plq_h+7], "A — COUPE EN TRAVERS, ZONE AVANT (moins de 20 mm du bord)", 2.6);
        txt([0, y_plq_h+3.6], "la seule zone ou le bloc est fendu ; ici la plaque est plate", 1.6);
    }
}

// ---------------------------------------------------------------- B
// COUPE EN TRAVERS, ZONE ARRIERE, AU DROIT D'UNE NOIRE.
// Le trait de scie s'est arrete a 20 mm : le bloc est CONTINU ici. Rien ne
// coupe la tache de la LED, et le relief de la noire est usine dans la plaque.
module coupe_arriere() {
    x_n  = pas_w - larg_noire/2;
    x_po = pas_w - poche_l/2;
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([L,e_bloc]);
        translate([x_po, y_bloc_b-0.1]) square([poche_l, poche_p+0.1]);
        for (x=[2:2.4:L-2])
            if (x < x_po-2 || x > x_po+poche_l+2)
                translate([x,y_bloc_b]) circle(d=p_grav*1.6,$fn=16);
    }
    dessous(0, L, [[x_po, poche_l]]);
    // la mousse est evidee pour laisser passer la carte : appui sur le SOCLE
    color(C_SOC) translate([0,y_soc_b]) square([L,e_socle]);
    color(C_PCB) translate([x_po-3, y_mou_b]) square([poche_l+6, e_pcb]);
    y_led = y_bloc_b + poche_p - led_c/2 - 0.3;
    color(C_LED) translate([pas_w-led_c/2, y_led]) square([led_c, led_c*0.55]);

    // le cone est limite a +/-42 deg : tout sort au premier contact
    for (s=[-1,1]) rayon([pas_w, y_led+led_c*0.55], [pas_w + s*0.906*(poche_p==0?e_bloc:(e_bloc-poche_p)), 0]);
    rayon([pas_w, y_led+led_c*0.55],[pas_w, 0]);

    j = 2.0;
    color(C_ITO)   translate([j/2, y_ito_b]) square([x_n-j, ep(e_ito)]);
    color(C_ITO_N) translate([x_n+j/2, y_ito_b]) square([larg_noire-j, ep(e_ito)]);
    color(C_ITO)   translate([x_n+larg_noire+j/2, y_ito_b]) square([L-(x_n+larg_noire)-j, ep(e_ito)]);
    color(C_PET) translate([0,y_pet_b]) square([L, ep(e_pet)]);
    color(C_PLQ) translate([0,y_plq_b]) square([L, e_plaque]);
    color(C_NOIRE) translate([x_n, y_plq_h]) square([larg_noire, relief_n]);

    if (etiquettes) {
        trait([x_n+larg_noire/2, y_plq_h+relief_n],[x_n+larg_noire/2, y_plq_h+relief_n+5]);
        txt([x_n+larg_noire/2, y_plq_h+relief_n+6.3],
            str("NOIRE : relief de ", relief_n, " mm USINE dans la plaque"),1.6,"center");
        txt([x_n+larg_noire/2, y_plq_h+relief_n+4.1],
            str("le doigt voit ", e_plaque+relief_n, " mm ici contre ", e_plaque, " sur une blanche"),1.6,"center");
        trait([x_po+poche_l, y_bloc_b+poche_p],[L+3, y_bloc_b+poche_p+2]);
        txt([L+3.5, y_bloc_b+poche_p+2], str("POCHE BORGNE  ", poche_l, " x ", poche_p, " mm, par le dessous"),1.8);
        txt([L+3.5, y_bloc_b+poche_p-0.4], "elle remonte la LED a 6 mm de la surface : c'est ce qui",1.6);
        txt([L+3.5, y_bloc_b+poche_p-2.8], "fixe le DIAMETRE de la tache (+/-0,9 x la profondeur restante)",1.6);
        trait([pas_w, y_mou_b],[pas_w, y_soc_b-4]);
        txt([pas_w, y_soc_b-5.3], "carte incrustee dans la mousse mais POSEE SUR LE SOCLE",1.6,"center");
        txt([pas_w, y_soc_b-7.5], "sur la mousse, la cote deriverait et les taches seraient inegales",1.6,"center");
        txt([L+3.5, 1], "cone limite a +/-42 deg par le couplage AIR : rien ne part en mode guide",1.6);
        txt([0, y_plq_h+relief_n+17], "B — COUPE EN TRAVERS, ZONE ARRIERE, AU DROIT D'UNE NOIRE", 2.6);
        txt([0, y_plq_h+relief_n+13.6], "le trait de scie s'est arrete a 20 mm : ici le bloc est CONTINU", 1.6);
    }
}

// ---------------------------------------------------------------- C
// COUPE EN LONG D'UNE BLANCHE, de la LED de tranche avant jusqu'au ruban.
module coupe_longue() {
    x_r = Lk + 4;                       // debut de la bande touchee du ruban
    x_po = x_r + ruban_l/2 - poche_l/2;
    color(C_PMMA) difference() {
        translate([0,y_bloc_b]) square([Lt,e_bloc]);
        translate([x_po, y_bloc_b-0.1]) square([poche_l, poche_p+0.1]);
        for (x=[2:2.6:Lk-2]) translate([x,y_bloc_b]) circle(d=p_grav*(0.9+1.4*x/Lk),$fn=16);
    }
    dessous(0, Lt, [[x_po, poche_l]]);
    color(C_SOC) translate([0,y_soc_b]) square([Lt,e_socle]);
    color(C_PCB) translate([x_po-3, y_mou_b]) square([poche_l+6, e_pcb]);
    y_led = y_bloc_b + poche_p - led_c/2 - 0.3;
    color(C_LED) translate([x_po+poche_l/2-led_c/2, y_led]) square([led_c, led_c*0.55]);

    // LED de tranche AVANT, hors du bloc
    color(C_PCB) translate([-(jeu_led+e_pcb), y_bloc_b+1]) square([e_pcb, e_bloc-2]);
    color(C_LED) translate([-jeu_led, -e_bloc/2-led_c/2]) square([jeu_led, led_c]);
    for (i=[0:4]) rayon([0, -e_bloc/2],[6+i*9, y_bloc_b+0.4]);

    color(C_PET) translate([-1.5,y_pet_b]) square([Lt+3, ep(e_pet)]);
    color(C_ITO) translate([-1.5,y_ito_b]) square([Lt+3, ep(e_ito)]);
    color(C_PLQ) translate([-1.5,y_plq_b]) square([Lt+3, e_plaque]);
    color(C_SAT) translate([x_r-2, y_plq_b]) square([ruban_l+4, 0.25]);   // satinage

    if (etiquettes) {
        txt([-34, -e_bloc/2+2.4], "LED de tranche AVANT",1.6);
        txt([-34, -e_bloc/2], "lumiere GUIDEE,",1.6);
        txt([-34, -e_bloc/2-2.4], "extraite par la gravure",1.6);
        trait([Lk/2, y_bloc_b],[Lk/2, y_bloc_b-8]);
        txt([Lk/2, y_bloc_b-9.5], "gravure DENSIFIEE en s'eloignant de la LED : c'est ce qui egalise",1.6,"center");
        trait([x_r+ruban_l/2, y_plq_h],[x_r+ruban_l/2, y_plq_h+5]);
        txt([x_r+ruban_l/2, y_plq_h+6.3], str("RUBAN — bande touchee ", ruban_l, " mm"),1.6,"center");
        txt([x_r+ruban_l/2, y_plq_h+4.1], "SATINAGE au dessous de la plaque (jamais sous le bloc)",1.6,"center");
        trait([x_po+poche_l/2, y_bloc_b+poche_p],[Lt+3, y_bloc_b+poche_p+3]);
        txt([Lt+3.5, y_bloc_b+poche_p+3], "meme principe que les noires : LED PAR EN DESSOUS,",1.6);
        txt([Lt+3.5, y_bloc_b+poche_p+0.6], "donc MEME CARTE HORIZONTALE. Plus de lame verticale,",1.6);
        txt([Lt+3.5, y_bloc_b+poche_p-1.8], "plus de fente arriere, plus de gravure sous le ruban.",1.6);
        trait([Lk+dos/2, y_plq_h],[Lk+dos/2, y_plq_h+10]);
        txt([Lk+dos/2, y_plq_h+11.3], str("dos du peigne ", dos, " mm — il porte le ruban"),1.6,"center");
        txt([0, y_plq_h+20], "C — COUPE EN LONG D'UNE BLANCHE, JUSQU'AU RUBAN", 2.6);
    }
}

// ---------------------------------------------------------------- D
// VUE DE DESSUS DU BLOC : ce qui est usine, et ou.
module vue_bloc() {
    n = 3;
    color(C_PMMA) square([n*pas_w, Lt]);
    for (i=[1:n-1])                                   // traits de scie, ARRETES a 20
        color([1,1,1]) translate([i*pas_w-larg_coupe/2, -0.1]) square([larg_coupe, p_scie+0.1]);
    for (i=[0:n-2]) {                                 // poches sous les noires
        x = (i+1)*pas_w - poche_l/2;
        color(C_LED) translate([x, Lk-Lb/2-poche_l/2]) square([poche_l, poche_l]);
    }
    color([0.55,0.75,0.62]) translate([0, Lk+4]) square([n*pas_w, ruban_l]);
    for (i=[0:2])
        color(C_LED) translate([3+i*pas_w, Lk+4+ruban_l/2-poche_l/2]) square([poche_l, poche_l]);

    if (etiquettes) {
        trait([pas_w, p_scie],[n*pas_w+4, p_scie+4]);
        txt([n*pas_w+4.5, p_scie+4], str("LES TRAITS DE SCIE S'ARRETENT A ", p_scie, " mm"),1.8);
        txt([n*pas_w+4.5, p_scie+1.6], "au-dela le bloc est CONTINU : rien ne coupe la tache des noires,",1.6);
        txt([n*pas_w+4.5, p_scie-0.8], "et les dents ne sont plus des porte-a-faux de 52 mm mais de 20",1.6);
        trait([pas_w, Lk-Lb/2],[n*pas_w+4, Lk-Lb/2]);
        txt([n*pas_w+4.5, Lk-Lb/2], "poche + LED sous chaque noire",1.6);
        trait([pas_w, Lk+4+ruban_l/2],[n*pas_w+4, Lk+4+ruban_l/2]);
        txt([n*pas_w+4.5, Lk+4+ruban_l/2], "RUBAN sur le dos — meme carte de LED que les noires",1.6);
        txt([0, Lt+8], "D — VUE DE DESSUS DU BLOC", 2.6);
        txt([0, Lt+4.6], "portion de 3 pas ; le bloc reel fait ~296 x 70 mm", 1.6);
        txt([0, -5], "PLUS DE FENTE ARRIERE, PLUS DE CLOISON TRANSVERSALE, PLUS DE LAMELLE.", 1.8);
        txt([0, -7.6], "Seules decoupes restantes : les traits de scie avant, et les poches par le dessous.", 1.6);
    }
}

// ---------------------------------------------------------------- E
// LE FILM A PLAT — UN SEUL ITO POUR TOUT.
el_w = 17;  el_n = 12;  n_dents = 8;  n_film = 3;
module vue_film() {
    W = n_film*pas_w;  y_r0 = Lk + 4;
    C_GARDE=[0.62,0.66,0.70]; C_ITO2=[0.16,0.45,0.34]; C_AG=[0.78,0.80,0.84];

    color(C_GARDE) square([W, y_r0+ruban_l+5]);
    for (i=[0:n_film-1]) {
        x = i*pas_w + (pas_w-el_w)/2;
        color(C_ITO) translate([x, 4]) square([el_w, Lk-26]);
        color(C_AG)  translate([x+el_w/2-0.8, 0]) square([1.6, 4]);
    }
    for (i=[0:n_film-2]) {
        x = (i+1)*pas_w - el_n/2;
        color(C_ITO2) translate([x, Lk-20]) square([el_n, 16]);
        color(C_AG)   translate([x+el_n/2-0.8, Lk-4]) square([1.6, 7]);
    }
    w = W/n_dents;
    for (i=[0:n_dents-1]) {
        f = 1 - i/(n_dents-1);
        wa = max(0.25, w*f);
        color(C_ITO)  translate([i*w, y_r0]) square([wa, ruban_l]);
        if (w-wa > 0.25) color(C_ITO2) translate([i*w+wa+0.3, y_r0]) square([w-wa-0.3, ruban_l]);
    }
    color(C_AG) translate([1, y_r0+ruban_l]) square([1.6, 5]);
    color(C_AG) translate([W-2.6, y_r0+ruban_l]) square([1.6, 5]);

    if (etiquettes) {
        yh = y_r0+ruban_l+5;
        txt([0, yh+16], "E — LE FILM A PLAT : UN SEUL ITO POUR TOUT", 2.6);
        txt([0, yh+12], "touches et ruban graves d'un seul coup ; la GARDE est la mer autour", 1.6);
        txt([0, yh+9.4], "portion de 3 pas — le film reel fait ~296 x 70 mm", 1.6);
        trait([W/2, y_r0+ruban_l/2],[W+4, y_r0+ruban_l/2]);
        txt([W+4.5, y_r0+ruban_l/2], "RUBAN — dents interdigitees (AT11805)", 1.8);
        txt([W+4.5, y_r0+ruban_l/2-2.6], "5 canaux ; segments de bout 33,75 / milieu 56,25 sur 180 mm", 1.6);
        txt([W+4.5, y_r0+ruban_l/2-5.2], "4 mm max entre deux dents, 0,25 mm mini en pointe", 1.6);
        txt([W+4.5, y_r0+ruban_l/2-7.8], "-> C'EST LE RUBAN QUI FIXE LA PRECISION DE GRAVURE du film", 1.8);
        trait([pas_w, Lk-8],[W+4, Lk-8]);
        txt([W+4.5, Lk-8], "LES NOIRES SORTENT PAR L'ARRIERE", 1.8);
        txt([W+4.5, Lk-10.6], "rien ne passe entre deux blanches -> ilot maintenu a 17 mm (BOM)", 1.6);
        trait([pas_w/2, 12],[W+4, 12]);
        txt([W+4.5, 12], "ilots de touche", 1.6);
        txt([0, -5.5], "EN GRIS CLAIR : LES PISTES D'ARGENT SERIGRAPHIEES SUR L'ITO.", 1.8);
        txt([0, -8], "On ne contacte JAMAIS l'ITO directement. L'argent fait ~0,01 ohm/carre contre 100", 1.6);
        txt([0, -10.4], "pour l'ITO, soit des milliers de fois moins : la distribution peut donc rester", 1.6);
        txt([0, -12.8], "SUR LE FILM et sortir par une queue unique dans un connecteur a charniere.", 1.6);
        txt([0, -16.3], "UN SEUL FILM = UN SEUL CALAGE, fige par le MASQUE et non par le montage.", 1.8);
        txt([0, -18.8], "Ancrer le film AU NIVEAU DU CONTACT et le laisser flotter a l'autre bout :", 1.6);
        txt([0, -21.2], "l'acrylique se dilate 4x plus que le PET, 0,3 mm sur la longueur du clavier.", 1.6);
    }
}

coupe_avant();
translate([0,-58])  coupe_arriere();
translate([0,-125]) coupe_longue();
translate([0,-240]) vue_bloc();
translate([0,-350]) vue_film();

if (etiquettes)
    txt([0, -400], str("couches minces exagerees x", exag_mince, " ; cotes reelles en regard"), 1.4);
