#!/usr/bin/env python3
"""Enregistre et resume le flux CSV du croquis firmware/test_touch_ito.

Usage :
    scripts/touch_log.py [--port /dev/cu.usbmodemXXXX] [--out mesure.csv]
                         [--secs 10] [--label "ITO 25mm / plexi 1.5mm"]

Affiche, par canal : base, delta moyen, delta max, bruit (sigma des deltas),
SNR = delta_moyen / sigma_repos. Sans --secs, tourne jusqu'a Ctrl-C.
"""
import argparse, glob, statistics, sys, time
import serial

def find_port():
    cands = [p for p in glob.glob("/dev/cu.usb*") + glob.glob("/dev/cu.wchusb*")]
    if not cands:
        sys.exit("Aucun port /dev/cu.usb* — brancher l'ESP32 (ou passer --port).")
    if len(cands) > 1:
        print("# plusieurs ports, choix du premier :", cands, file=sys.stderr)
    return cands[0]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--out")
    ap.add_argument("--secs", type=float)
    ap.add_argument("--label", default="")
    a = ap.parse_args()

    port = a.port or find_port()
    print(f"# port {port} @ {a.baud}", file=sys.stderr)

    rows = {}      # ch -> list of (raw, delta, snr)
    header = []
    out = open(a.out, "w") if a.out else None
    if out and a.label:
        out.write(f"# {a.label}\n")

    with serial.Serial(port, a.baud, timeout=1) as ser:
        t0 = time.time()
        try:
            while a.secs is None or time.time() - t0 < a.secs:
                line = ser.readline().decode("utf-8", "replace").strip()
                if not line:
                    continue
                if out:
                    out.write(line + "\n")
                if line.startswith("#"):
                    header.append(line)
                    print(line, file=sys.stderr)
                    continue
                parts = line.split(",")
                if len(parts) != 5:
                    continue
                try:
                    _, ch, raw, delta, snr = (int(parts[0]), int(parts[1]),
                                              float(parts[2]), float(parts[3]),
                                              float(parts[4]))
                except ValueError:
                    continue
                rows.setdefault(ch, []).append((raw, delta, snr))
        except KeyboardInterrupt:
            pass
    if out:
        out.close()

    if not rows:
        sys.exit("Aucune donnee — verifier le baud et que le croquis tourne.")
    print(f"\n=== resume {a.label} ===")
    print(f"{'ch':>3} {'n':>5} {'raw moy':>9} {'d moy':>8} {'d max':>8} "
          f"{'sigma_d':>8} {'SNR max':>8}")
    for ch in sorted(rows):
        raws   = [r[0] for r in rows[ch]]
        deltas = [r[1] for r in rows[ch]]
        snrs   = [r[2] for r in rows[ch]]
        sd = statistics.pstdev(deltas) if len(deltas) > 1 else 0.0
        print(f"{ch:>3} {len(deltas):>5} {statistics.mean(raws):>9.1f} "
              f"{statistics.mean(deltas):>8.1f} {max(deltas):>8.1f} "
              f"{sd:>8.2f} {max(snrs):>8.1f}")
    if a.out:
        print(f"\nbrut -> {a.out}")

if __name__ == "__main__":
    main()
