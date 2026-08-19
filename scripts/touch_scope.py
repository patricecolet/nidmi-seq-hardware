#!/usr/bin/env python3
"""Observation en direct du banc capacitif : histogramme + chronogramme.

Lit le flux CSV de firmware/test_touch_ito sur le port serie et sert une page
web locale qui se rafraichit toute seule.

    scripts/touch_scope.py                       # port auto, http://localhost:8765
    scripts/touch_scope.py --port /dev/cu.usbmodemXXX --http-port 9000

L'histogramme est la vue utile ici : un contact intermittent se voit comme
plusieurs modes separes (broche nue / electrode au repos / doigt pose), la ou
une moyenne ne montrerait qu'une valeur intermediaire qui n'existe pas.

Un seul programme a la fois peut ouvrir le port : arreter touch_log.py avant.
"""
import argparse, glob, json, re, statistics, sys, threading, time
from collections import deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import serial

META_RE = re.compile(r"^#\s*(\d+),(\d+),([\d.]+),([\d.]+)\s*$")

lock = threading.Lock()
chans = {}          # ch -> {"gpio","base","sigma","pts": deque[(t, raw, delta, snr)]}
notes = deque(maxlen=40)
started = time.time()
ser_handle = {"s": None}


def find_port():
    c = sorted(glob.glob("/dev/cu.usb*")) + sorted(glob.glob("/dev/cu.wchusb*"))
    if not c:
        sys.exit("Aucun port /dev/cu.usb* — brancher l'ESP32 (ou passer --port).")
    return c[0]


def pulse_reset(port, baud):
    """Redemarre la carte, puis attend sa re-enumeration USB.

    Sur l'USB natif du S3, une carte deja en marche dont l'hote precedent s'est
    deconnecte n'emet plus rien pour le suivant : sans ce reset, le scope reste
    devant un port muet. Le reset fait disparaitre puis revenir le peripherique
    USB — d'ou la fermeture et l'attente avant de rouvrir, sinon on lit sur une
    poignee morte.
    """
    try:
        with serial.Serial(port, baud, timeout=1) as s:
            s.dtr = False
            s.rts = True
            time.sleep(0.15)
            s.rts = False
            s.dtr = True
        notes.append("reset de la carte — calibration en cours, ne pas toucher")
    except serial.SerialException as e:
        notes.append(f"reset impossible ({e})")
    time.sleep(2.0)


def reader(port, baud, window, reset=True):
    todo = reset
    while True:
        try:
            if todo:
                todo = False
                pulse_reset(port, baud)
            # DTR doit rester asserte (valeur par defaut) : sur l'USB natif du S3,
            # la sortie USB CDC est conditionnee a DTR — port ouvert sans DTR =
            # carte muette.
            with serial.Serial(port, baud, timeout=1) as s:
                ser_handle["s"] = s
                notes.append(f"connecte a {port}")
                # La correspondance canal->GPIO n'est imprimee qu'a la calibration.
                # Un client qui se connecte apres ne l'a jamais vue : on la reclame.
                ask_meta = [0.0]
                try:
                    s.write(b"i")
                    ask_meta[0] = time.time()
                except serial.SerialException:
                    pass
                while True:
                    chunk = s.readline()
                    if not chunk:
                        continue      # simple timeout de lecture, pas une deconnexion :
                                      # iter(s.readline, b"") s'arreterait ici a tort
                    line = chunk.decode("utf-8", "replace").strip()
                    if not line:
                        continue
                    if line.startswith("#"):
                        m = META_RE.match(line)
                        with lock:
                            if m:
                                ch = int(m.group(1))
                                c = chans.setdefault(ch, {"pts": deque(maxlen=window)})
                                c["gpio"], c["base"] = int(m.group(2)), float(m.group(3))
                                c["sigma"] = float(m.group(4))
                            else:
                                notes.append(line.lstrip("# ").strip())
                        continue
                    p = line.split(",")
                    if len(p) != 5:
                        continue
                    try:
                        ch, raw, d, sn = int(p[1]), float(p[2]), float(p[3]), float(p[4])
                    except ValueError:
                        continue
                    with lock:
                        c = chans.setdefault(ch, {"pts": deque(maxlen=window)})
                        c["pts"].append((time.time() - started, raw, d, sn))
                        manque = any("gpio" not in v for v in chans.values())
                    # Redemander tant qu'un canal n'a pas son GPIO (la carte a pu
                    # demarrer avant nous, ou l'entete s'etre perdue).
                    now = time.time()
                    if manque and now - ask_meta[0] > 3.0:
                        ask_meta[0] = now
                        try:
                            s.write(b"i")
                        except serial.SerialException:
                            pass
        except serial.SerialException as e:
            ser_handle["s"] = None
            notes.append(f"port perdu ({e}) — nouvelle tentative dans 2 s")
            time.sleep(2)


def histogram(values, nbins):
    lo, hi = min(values), max(values)
    if hi <= lo:
        hi = lo + 1.0
    # Marge pour que les modes extremes ne collent pas au bord.
    span = hi - lo
    lo, hi = lo - span * 0.02, hi + span * 0.02
    step = (hi - lo) / nbins
    counts = [0] * nbins
    for v in values:
        i = int((v - lo) / step)
        counts[min(max(i, 0), nbins - 1)] += 1
    return {"lo": lo, "hi": hi, "counts": counts}


def snapshot(nbins, series_max):
    out = {"uptime": time.time() - started, "notes": list(notes)[-8:], "chans": []}
    with lock:
        for ch in sorted(chans):
            c = chans[ch]
            pts = list(c["pts"])
            if not pts:
                continue
            raws = [p[1] for p in pts]
            step = max(1, len(pts) // series_max)
            out["chans"].append({
                "ch": ch,
                "gpio": c.get("gpio"),
                "base": c.get("base"),
                "sigma": c.get("sigma"),
                "n": len(pts),
                "cur": pts[-1][1],
                "delta": pts[-1][2],
                "snr": pts[-1][3],
                "min": min(raws), "max": max(raws),
                "median": statistics.median(raws),
                "sd": statistics.pstdev(raws) if len(raws) > 1 else 0.0,
                "hist": histogram(raws, nbins),
                "series": [[round(p[0], 2), p[1]] for p in pts[::step]],
            })
    return out


PAGE = r"""<!-- servi en local par scripts/touch_scope.py -->
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Banc capacitif</title>
<style>
:root{
  --bg:#f7f7f5; --panel:#fff; --ink:#1b1b19; --muted:#6b6b66; --line:#e2e2dd;
  --accent:#c2410c; --ok:#15803d; --warn:#b45309; --grid:#ececE6;
}
@media (prefers-color-scheme:dark){:root:not([data-theme=light]){
  --bg:#14140f; --panel:#1c1c17; --ink:#eeeee6; --muted:#96968c; --line:#2e2e26;
  --accent:#fb923c; --ok:#4ade80; --warn:#fbbf24; --grid:#26261f;
}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
  font:14px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace}
header{display:flex;flex-wrap:wrap;gap:1rem;align-items:baseline;
  padding:.9rem 1.2rem;border-bottom:1px solid var(--line);background:var(--panel)}
h1{font-size:1rem;margin:0;letter-spacing:.02em}
.sp{flex:1}
button{font:inherit;background:var(--panel);color:var(--ink);border:1px solid var(--line);
  border-radius:5px;padding:.3rem .7rem;cursor:pointer}
button:hover{border-color:var(--accent);color:var(--accent)}
nav.leds{display:flex;flex-wrap:wrap;gap:.5rem;align-items:center;
  padding:.7rem 1.2rem;border-bottom:1px solid var(--line);background:var(--panel)}
nav.leds .lbl{color:var(--muted);font-size:.72rem;text-transform:uppercase;
  letter-spacing:.06em;margin-right:.2rem}
nav.leds .mode.on{border-color:var(--accent);color:var(--accent)}
nav.leds input[type=range]{flex:1;min-width:120px;max-width:260px;accent-color:var(--accent)}
nav.leds output{font-variant-numeric:tabular-nums;min-width:2.5em}
main{padding:1.2rem;display:grid;gap:1.2rem}
.card{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:1rem}
.tabs{display:flex;gap:.4rem;flex-wrap:wrap;margin-bottom:.9rem}
.tab{padding:.3rem .8rem;border:1px solid var(--line);border-radius:5px;cursor:pointer;
  color:var(--muted)}
.tab.on{border-color:var(--accent);color:var(--accent)}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(105px,1fr));gap:.7rem;
  margin-bottom:1rem}
.stat b{display:block;font-size:1.15rem;font-weight:600;font-variant-numeric:tabular-nums}
.stat span{color:var(--muted);font-size:.72rem;text-transform:uppercase;letter-spacing:.06em}
canvas{width:100%;display:block}
.cap{color:var(--muted);font-size:.78rem;margin:.5rem 0 0}
.notes{color:var(--muted);font-size:.78rem;white-space:pre-wrap;margin:0}
</style>
<header>
  <h1>Banc capacitif — ITO / plexi</h1>
  <span class="sp"></span>
  <button id="cal">recalibrer</button>
  <button id="frz">geler</button>
</header>
<nav class="leds">
  <span class="lbl">LED</span>
  <button data-cmd="t" class="mode on">tactile</button>
  <button data-cmd="r" class="mode">rampe 5 s</button>
  <button data-cmd="c" class="mode">clignote</button>
  <button data-cmd="f" class="mode">fixe</button>
  <button data-cmd="x" class="mode">eteint</button>
  <span class="lbl">luminosite</span>
  <input id="lum" type="range" min="0" max="255" value="200">
  <output id="lumv">200</output>
  <span class="lbl">seuil</span>
  <input id="seu" type="range" min="0" max="1000" value="515">
  <output id="seuv">5.0 %</output>
</nav>
<main>
  <div class="card">
    <div class="tabs" id="tabs"></div>
    <div class="stats" id="stats"></div>
    <canvas id="hist" height="260"></canvas>
    <p class="cap">Histogramme des valeurs brutes sur la fenetre courante.
       Plusieurs pics separes = plusieurs etats physiques distincts
       (contact perdu / electrode au repos / doigt pose), pas du bruit.</p>
  </div>
  <div class="card">
    <canvas id="ts" height="200"></canvas>
    <p class="cap">Chronogramme de la meme fenetre.</p>
  </div>
  <div class="card"><p class="notes" id="notes"></p></div>
</main>
<script>
let sel=0, frozen=false, last=null;
const $=s=>document.querySelector(s);
const css=v=>getComputedStyle(document.documentElement).getPropertyValue(v).trim();
const fmt=v=>v==null?"—":(Math.abs(v)>=1e4?Math.round(v).toLocaleString("fr"):v.toFixed(1));

function fit(c){const r=c.getBoundingClientRect(),d=devicePixelRatio||1;
  c.width=r.width*d;c.height=c.height*d/(c._s||1);c._s=d;
  const x=c.getContext("2d");x.setTransform(d,0,0,d,0,0);return [x,r.width,c.height/d];}

function drawHist(h){
  const [x,W,H]=fit($("#hist")); x.clearRect(0,0,W,H);
  const c=h.counts, n=c.length, mx=Math.max(...c)||1, pad=34;
  const bw=(W-pad)/n;
  x.fillStyle=css("--grid");
  for(let i=1;i<5;i++){const y=(H-pad)*i/5;x.fillRect(pad,y,W-pad,1);}
  x.fillStyle=css("--accent");
  for(let i=0;i<n;i++){
    const bh=(c[i]/mx)*(H-pad-8);
    if(bh>0) x.fillRect(pad+i*bw, H-pad-bh, Math.max(bw-1,1), bh);
  }
  x.fillStyle=css("--muted"); x.font="11px ui-monospace,monospace";
  x.fillText(fmt(h.lo), pad, H-12);
  x.textAlign="right"; x.fillText(fmt(h.hi), W, H-12); x.textAlign="left";
  x.fillText(mx+" ech", 2, 12);
}

function drawTs(s){
  const [x,W,H]=fit($("#ts")); x.clearRect(0,0,W,H);
  if(s.length<2) return;
  const ys=s.map(p=>p[1]), lo=Math.min(...ys), hi=Math.max(...ys)||lo+1, pad=34;
  const sx=i=>pad+(W-pad)*i/(s.length-1), sy=v=>H-14-(H-28)*(v-lo)/((hi-lo)||1);
  x.fillStyle=css("--grid");
  for(let i=0;i<=4;i++) x.fillRect(pad,14+(H-28)*i/4,W-pad,1);
  x.strokeStyle=css("--accent"); x.lineWidth=1.4; x.beginPath();
  s.forEach((p,i)=>i?x.lineTo(sx(i),sy(p[1])):x.moveTo(sx(i),sy(p[1])));
  x.stroke();
  x.fillStyle=css("--muted"); x.font="11px ui-monospace,monospace";
  x.fillText(fmt(hi),2,16); x.fillText(fmt(lo),2,H-4);
}

function render(d){
  if(!d.chans.length){$("#notes").textContent=d.notes.join("\n")||"en attente de donnees…";return;}
  $("#tabs").innerHTML=d.chans.map((c,i)=>
    `<div class="tab ${i===sel?"on":""}" data-i="${i}">ch${c.ch}${c.gpio==null?"":" · GPIO"+c.gpio}</div>`).join("");
  $("#tabs").querySelectorAll(".tab").forEach(t=>t.onclick=()=>{sel=+t.dataset.i;render(last);});
  const c=d.chans[Math.min(sel,d.chans.length-1)];
  const etendue=c.max-c.min;
  $("#stats").innerHTML=[
    ["brut",fmt(c.cur)],["base",fmt(c.base)],["delta",fmt(c.delta)],
    ["snr",c.snr==null?"—":c.snr.toFixed(1)],["sigma fenetre",fmt(c.sd)],
    ["mediane",fmt(c.median)],["etendue",fmt(etendue)],["n",c.n]
  ].map(([k,v])=>`<div class="stat"><b>${v}</b><span>${k}</span></div>`).join("");
  drawHist(c.hist); drawTs(c.series);
  $("#notes").textContent=d.notes.join("\n");
}

async function tick(){
  if(!frozen){
    try{ last=await (await fetch("/data")).json(); render(last); }catch(e){}
  }
  setTimeout(tick,250);
}
const envoyer=c=>fetch("/cmd",{method:"POST",body:c});
document.querySelectorAll("nav.leds .mode").forEach(b=>b.onclick=()=>{
  document.querySelectorAll("nav.leds .mode").forEach(o=>o.classList.remove("on"));
  b.classList.add("on");
  envoyer(b.dataset.cmd);
});
// Le curseur n'emet qu'a la fin du geste : inutile d'inonder le port serie.
$("#lum").oninput=e=>$("#lumv").value=e.target.value;
$("#lum").onchange=e=>envoyer("L"+e.target.value);
// Seuil de detection en % de la ligne de base. Un seuil en counts absolus ne
// tient pas : le contact vaut des centaines de % de la base, le bruit et la
// derive quelques dixiemes.
// Course LOGARITHMIQUE de 0,1 % a 200 % : toute la discrimination entre contact
// et approche se joue sous 10 %, une echelle lineaire y laisserait une poignee de
// positions utiles. La carte recoit des dixiemes de % (S1..S2000).
const pctSeuil = p => 0.1 * Math.pow(2000, p/1000);
const fmtPct = v => v<1 ? v.toFixed(2) : v<10 ? v.toFixed(1) : v.toFixed(0);
$("#seu").oninput=e=>$("#seuv").value=fmtPct(pctSeuil(+e.target.value))+" %";
$("#seu").onchange=e=>envoyer("S"+Math.max(1,Math.round(pctSeuil(+e.target.value)*10)));
$("#cal").onclick=()=>envoyer("b");
$("#frz").onclick=e=>{frozen=!frozen;e.target.textContent=frozen?"reprendre":"geler";};
addEventListener("resize",()=>last&&render(last));
tick();
</script>
"""


def make_handler(nbins, series_max):
    class H(BaseHTTPRequestHandler):
        def log_message(self, *a):
            pass

        def _send(self, code, ctype, body):
            self.send_response(code)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            if self.path.startswith("/data"):
                self._send(200, "application/json",
                           json.dumps(snapshot(nbins, series_max)).encode())
            else:
                self._send(200, "text/html; charset=utf-8", PAGE.encode())

        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            cmd = self.rfile.read(n).decode("utf-8", "replace").strip()
            s = ser_handle["s"]
            if s and cmd:
                try:
                    # Commande entiere + retour ligne : la luminosite s'envoie
                    # sous la forme "L128", que la carte lit jusqu'au \n.
                    s.write((cmd + "\n").encode())
                except serial.SerialException:
                    pass
            self._send(200, "text/plain", b"ok")
    return H


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--http-port", type=int, default=8765)
    ap.add_argument("--window", type=int, default=3000, help="echantillons gardes par canal")
    ap.add_argument("--bins", type=int, default=90)
    ap.add_argument("--series", type=int, default=700)
    ap.add_argument("--no-reset", action="store_true",
                    help="ne pas redemarrer la carte a la connexion (garde la ligne "
                         "de base en cours, mais la carte peut rester muette)")
    a = ap.parse_args()

    port = a.port or find_port()
    threading.Thread(target=reader, args=(port, a.baud, a.window, not a.no_reset),
                     daemon=True).start()
    srv = ThreadingHTTPServer(("127.0.0.1", a.http_port), make_handler(a.bins, a.series))
    print(f"serie {port} @ {a.baud}\nouvrir  http://localhost:{a.http_port}\nCtrl-C pour arreter")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print()


if __name__ == "__main__":
    main()
