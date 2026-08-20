// GENERE par un script — ne pas editer a la main.
// Optique d'une cloison de separation entre touches.
// angle critique PMMA/air = 42.2 deg

translate([0,0]) {
  color([0.80,0.88,0.93]) difference() {
    square([130.0,10.0]);
    translate([77.85,3.0]) square([0.3,7.1]);
  }
  color([1.0,0.75,0.25]) translate([-1.6,3.8]) square([1.4,2.4]);
  color([0.85,0.25,0.15]) {
    hull() { translate([0.00,1.50]) circle(0.140,$fn=6); translate([26.16,10.00]) circle(0.140,$fn=6); }
    hull() { translate([26.16,10.00]) circle(0.140,$fn=6); translate([56.94,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.94,0.00]) circle(0.140,$fn=6); translate([78.00,6.84]) circle(0.140,$fn=6); }
    hull() { translate([78.00,6.84]) circle(0.140,$fn=6); translate([87.71,10.00]) circle(0.140,$fn=6); }
    hull() { translate([87.71,10.00]) circle(0.140,$fn=6); translate([118.49,0.00]) circle(0.140,$fn=6); }
    hull() { translate([118.49,0.00]) circle(0.140,$fn=6); translate([130.00,3.74]) circle(0.140,$fn=6); }
  }

  color([0.15,0.45,0.80]) {
    hull() { translate([0.00,4.50]) circle(0.140,$fn=6); translate([8.47,10.00]) circle(0.140,$fn=6); }
    hull() { translate([8.47,10.00]) circle(0.140,$fn=6); translate([23.87,0.00]) circle(0.140,$fn=6); }
    hull() { translate([23.87,0.00]) circle(0.140,$fn=6); translate([39.27,10.00]) circle(0.140,$fn=6); }
    hull() { translate([39.27,10.00]) circle(0.140,$fn=6); translate([54.67,0.00]) circle(0.140,$fn=6); }
    hull() { translate([54.67,0.00]) circle(0.140,$fn=6); translate([70.06,10.00]) circle(0.140,$fn=6); }
    hull() { translate([70.06,10.00]) circle(0.140,$fn=6); translate([78.00,4.85]) circle(0.140,$fn=6); }
    hull() { translate([78.00,4.85]) circle(0.140,$fn=6); translate([85.46,0.00]) circle(0.140,$fn=6); }
    hull() { translate([85.46,0.00]) circle(0.140,$fn=6); translate([100.86,10.00]) circle(0.140,$fn=6); }
    hull() { translate([100.86,10.00]) circle(0.140,$fn=6); translate([116.26,0.00]) circle(0.140,$fn=6); }
    hull() { translate([116.26,0.00]) circle(0.140,$fn=6); translate([130.00,8.92]) circle(0.140,$fn=6); }
  }

  color([0.15,0.60,0.35]) {
    hull() { translate([0.00,2.00]) circle(0.140,$fn=6); translate([7.73,10.00]) circle(0.140,$fn=6); }
    hull() { translate([7.73,10.00]) circle(0.140,$fn=6); translate([17.38,0.00]) circle(0.140,$fn=6); }
    hull() { translate([17.38,0.00]) circle(0.140,$fn=6); translate([27.04,10.00]) circle(0.140,$fn=6); }
    hull() { translate([27.04,10.00]) circle(0.140,$fn=6); translate([36.70,0.00]) circle(0.140,$fn=6); }
    hull() { translate([36.70,0.00]) circle(0.140,$fn=6); translate([46.35,10.00]) circle(0.140,$fn=6); }
    hull() { translate([46.35,10.00]) circle(0.140,$fn=6); translate([56.01,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.01,0.00]) circle(0.140,$fn=6); translate([65.67,10.00]) circle(0.140,$fn=6); }
    hull() { translate([65.67,10.00]) circle(0.140,$fn=6); translate([75.32,0.00]) circle(0.140,$fn=6); }
    hull() { translate([75.32,0.00]) circle(0.140,$fn=6); translate([84.98,10.00]) circle(0.140,$fn=6); }
    hull() { translate([84.98,10.00]) circle(0.140,$fn=6); translate([94.64,0.00]) circle(0.140,$fn=6); }
    hull() { translate([94.64,0.00]) circle(0.140,$fn=6); translate([104.29,10.00]) circle(0.140,$fn=6); }
    hull() { translate([104.29,10.00]) circle(0.140,$fn=6); translate([113.95,0.00]) circle(0.140,$fn=6); }
    hull() { translate([113.95,0.00]) circle(0.140,$fn=6); translate([123.61,10.00]) circle(0.140,$fn=6); }
    hull() { translate([123.61,10.00]) circle(0.140,$fn=6); translate([130.00,3.38]) circle(0.140,$fn=6); }
  }

  color([0.15,0.15,0.15]) translate([0,14.2]) text("A — SAIGNEE NUE, profonde  ->  la lumiere PASSE", size=2.4);
  color([0.35,0.35,0.35]) translate([0,-3.6]) text("la normale d'une paroi verticale est HORIZONTALE ; la lumiere guidee la frappe presque de face, sous l'angle critique -> elle traverse", size=1.7);
}
translate([0,-26]) {
  color([0.80,0.88,0.93]) difference() {
    square([130.0,10.0]);
    translate([77.85,3.0]) square([0.3,7.1]);
  }
  color([0.08,0.08,0.10]) translate([77.85,3.0]) square([0.3,7.0]);
  color([1.0,0.75,0.25]) translate([-1.6,3.8]) square([1.4,2.4]);
  color([0.85,0.25,0.15]) {
    hull() { translate([0.00,1.50]) circle(0.140,$fn=6); translate([26.16,10.00]) circle(0.140,$fn=6); }
    hull() { translate([26.16,10.00]) circle(0.140,$fn=6); translate([56.94,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.94,0.00]) circle(0.140,$fn=6); translate([78.00,6.84]) circle(0.140,$fn=6); }
  }

  color([0.15,0.45,0.80]) {
    hull() { translate([0.00,4.50]) circle(0.140,$fn=6); translate([8.47,10.00]) circle(0.140,$fn=6); }
    hull() { translate([8.47,10.00]) circle(0.140,$fn=6); translate([23.87,0.00]) circle(0.140,$fn=6); }
    hull() { translate([23.87,0.00]) circle(0.140,$fn=6); translate([39.27,10.00]) circle(0.140,$fn=6); }
    hull() { translate([39.27,10.00]) circle(0.140,$fn=6); translate([54.67,0.00]) circle(0.140,$fn=6); }
    hull() { translate([54.67,0.00]) circle(0.140,$fn=6); translate([70.06,10.00]) circle(0.140,$fn=6); }
    hull() { translate([70.06,10.00]) circle(0.140,$fn=6); translate([78.00,4.85]) circle(0.140,$fn=6); }
  }

  color([0.15,0.60,0.35]) {
    hull() { translate([0.00,2.00]) circle(0.140,$fn=6); translate([7.73,10.00]) circle(0.140,$fn=6); }
    hull() { translate([7.73,10.00]) circle(0.140,$fn=6); translate([17.38,0.00]) circle(0.140,$fn=6); }
    hull() { translate([17.38,0.00]) circle(0.140,$fn=6); translate([27.04,10.00]) circle(0.140,$fn=6); }
    hull() { translate([27.04,10.00]) circle(0.140,$fn=6); translate([36.70,0.00]) circle(0.140,$fn=6); }
    hull() { translate([36.70,0.00]) circle(0.140,$fn=6); translate([46.35,10.00]) circle(0.140,$fn=6); }
    hull() { translate([46.35,10.00]) circle(0.140,$fn=6); translate([56.01,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.01,0.00]) circle(0.140,$fn=6); translate([65.67,10.00]) circle(0.140,$fn=6); }
    hull() { translate([65.67,10.00]) circle(0.140,$fn=6); translate([75.32,0.00]) circle(0.140,$fn=6); }
    hull() { translate([75.32,0.00]) circle(0.140,$fn=6); translate([84.98,10.00]) circle(0.140,$fn=6); }
    hull() { translate([84.98,10.00]) circle(0.140,$fn=6); translate([94.64,0.00]) circle(0.140,$fn=6); }
    hull() { translate([94.64,0.00]) circle(0.140,$fn=6); translate([104.29,10.00]) circle(0.140,$fn=6); }
    hull() { translate([104.29,10.00]) circle(0.140,$fn=6); translate([113.95,0.00]) circle(0.140,$fn=6); }
    hull() { translate([113.95,0.00]) circle(0.140,$fn=6); translate([123.61,10.00]) circle(0.140,$fn=6); }
    hull() { translate([123.61,10.00]) circle(0.140,$fn=6); translate([130.00,3.38]) circle(0.140,$fn=6); }
  }

  color([0.15,0.15,0.15]) translate([0,14.2]) text("B — SAIGNEE NOIRCIE, profonde  ->  barriere efficace", size=2.4);
  color([0.35,0.35,0.35]) translate([0,-3.6]) text("c'est l'ABSORPTION qui travaille, et elle agit a tous les angles", size=1.7);
}
translate([0,-52]) {
  color([0.80,0.88,0.93]) difference() {
    square([130.0,10.0]);
    translate([77.85,7.5]) square([0.3,2.6]);
  }
  color([0.08,0.08,0.10]) translate([77.85,7.5]) square([0.3,2.5]);
  color([1.0,0.75,0.25]) translate([-1.6,3.8]) square([1.4,2.4]);
  color([0.85,0.25,0.15]) {
    hull() { translate([0.00,1.50]) circle(0.140,$fn=6); translate([26.16,10.00]) circle(0.140,$fn=6); }
    hull() { translate([26.16,10.00]) circle(0.140,$fn=6); translate([56.94,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.94,0.00]) circle(0.140,$fn=6); translate([87.71,10.00]) circle(0.140,$fn=6); }
    hull() { translate([87.71,10.00]) circle(0.140,$fn=6); translate([118.49,0.00]) circle(0.140,$fn=6); }
    hull() { translate([118.49,0.00]) circle(0.140,$fn=6); translate([130.00,3.74]) circle(0.140,$fn=6); }
  }

  color([0.15,0.45,0.80]) {
    hull() { translate([0.00,4.50]) circle(0.140,$fn=6); translate([8.47,10.00]) circle(0.140,$fn=6); }
    hull() { translate([8.47,10.00]) circle(0.140,$fn=6); translate([23.87,0.00]) circle(0.140,$fn=6); }
    hull() { translate([23.87,0.00]) circle(0.140,$fn=6); translate([39.27,10.00]) circle(0.140,$fn=6); }
    hull() { translate([39.27,10.00]) circle(0.140,$fn=6); translate([54.67,0.00]) circle(0.140,$fn=6); }
    hull() { translate([54.67,0.00]) circle(0.140,$fn=6); translate([70.06,10.00]) circle(0.140,$fn=6); }
    hull() { translate([70.06,10.00]) circle(0.140,$fn=6); translate([85.46,0.00]) circle(0.140,$fn=6); }
    hull() { translate([85.46,0.00]) circle(0.140,$fn=6); translate([100.86,10.00]) circle(0.140,$fn=6); }
    hull() { translate([100.86,10.00]) circle(0.140,$fn=6); translate([116.26,0.00]) circle(0.140,$fn=6); }
    hull() { translate([116.26,0.00]) circle(0.140,$fn=6); translate([130.00,8.92]) circle(0.140,$fn=6); }
  }

  color([0.15,0.60,0.35]) {
    hull() { translate([0.00,2.00]) circle(0.140,$fn=6); translate([7.73,10.00]) circle(0.140,$fn=6); }
    hull() { translate([7.73,10.00]) circle(0.140,$fn=6); translate([17.38,0.00]) circle(0.140,$fn=6); }
    hull() { translate([17.38,0.00]) circle(0.140,$fn=6); translate([27.04,10.00]) circle(0.140,$fn=6); }
    hull() { translate([27.04,10.00]) circle(0.140,$fn=6); translate([36.70,0.00]) circle(0.140,$fn=6); }
    hull() { translate([36.70,0.00]) circle(0.140,$fn=6); translate([46.35,10.00]) circle(0.140,$fn=6); }
    hull() { translate([46.35,10.00]) circle(0.140,$fn=6); translate([56.01,0.00]) circle(0.140,$fn=6); }
    hull() { translate([56.01,0.00]) circle(0.140,$fn=6); translate([65.67,10.00]) circle(0.140,$fn=6); }
    hull() { translate([65.67,10.00]) circle(0.140,$fn=6); translate([75.32,0.00]) circle(0.140,$fn=6); }
    hull() { translate([75.32,0.00]) circle(0.140,$fn=6); translate([84.98,10.00]) circle(0.140,$fn=6); }
    hull() { translate([84.98,10.00]) circle(0.140,$fn=6); translate([94.64,0.00]) circle(0.140,$fn=6); }
    hull() { translate([94.64,0.00]) circle(0.140,$fn=6); translate([104.29,10.00]) circle(0.140,$fn=6); }
    hull() { translate([104.29,10.00]) circle(0.140,$fn=6); translate([113.95,0.00]) circle(0.140,$fn=6); }
    hull() { translate([113.95,0.00]) circle(0.140,$fn=6); translate([123.61,10.00]) circle(0.140,$fn=6); }
    hull() { translate([123.61,10.00]) circle(0.140,$fn=6); translate([130.00,3.38]) circle(0.140,$fn=6); }
  }

  color([0.15,0.15,0.15]) translate([0,14.2]) text("C — SAIGNEE NOIRCIE mais TROP PEU PROFONDE  ->  la lumiere passe dessous", size=2.4);
  color([0.35,0.35,0.35]) translate([0,-3.6]) text("ce qui compte n'est pas la largeur de la saignee mais sa PROFONDEUR", size=1.7);
}
color([0.15,0.15,0.15]) translate([0,21.0]) text("CLOISON ENTRE TOUCHES — ce qui arrete la lumiere guidee, et ce qui ne l'arrete pas", size=3.0);
color([0.35,0.35,0.35]) translate([0,-80]) text("rayons guides : rouge 18 deg, bleu 33 deg, vert 46 deg (angle avec le plan de la plaque). Angle critique PMMA/air = 42 deg.", size=1.7);
