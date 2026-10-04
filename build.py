#!/usr/bin/env python3
"""Rebuild a coin tray version: the two printable STL halves, all geometry
checks, and the preview renders.

Usage
  ./build.py                          # builds coin_tray_v3.scad
  ./build.py v2                       # or coin_tray_v2.scad / any .scad path
  ./build.py v3 -D deck_angle=8 -D stack_clearance=0.9
                                      # try values without editing the file
  ./build.py v3 --no-renders          # STLs + checks only
  ./build.py v3 --no-checks           # STLs + renders only

Outputs (next to the .scad file)
  <name>_left.stl, <name>_right.stl   binary STL in assembled coordinates
                                      (slicers re-centre them on import)
  renders/<tag>/*.png                 tag = v2, v3, ... (v1 for coin_tray.scad)

-D overrides are passed straight to OpenSCAD; files are only written if the
model's own asserts pass.  Exit code 1 if an assert or any check fails.

Needs OpenSCAD.  Uses ~/.local/bin/openscad-nightly (Manifold backend, ~1 s
per part) when present, otherwise `openscad` (2021.01 CGAL: minutes per
part).  Override with --openscad PATH or the OPENSCAD environment variable.
Python 3 standard library only; Pillow (optional) adds a lane cross-section.
"""
import argparse
import concurrent.futures as cf
import math
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent

# part name -> True if OpenSCAD must produce geometry, False if it must be empty
CHECKS = {
    "overlap_check":       (False, "halves do not overlap when assembled"),
    "fit_check":           (False, "every coin fits its pocket without touching the tray"),
    "clearance_check_in":  (False, "hooks grown by clearance - 0.01 mm touch nothing"),
    "clearance_check_out": (True,  "hooks grown by clearance + 0.01 mm do touch (clearance is exact)"),
    "path_check":          (False, "push-then-slide assembly path is free"),
}


# --------------------------------------------------------------------------
#  OpenSCAD helpers
# --------------------------------------------------------------------------
def find_openscad(cli):
    for cand in (cli, os.environ.get("OPENSCAD"), shutil.which("openscad-nightly"),
                 str(Path.home() / ".local/bin/openscad-nightly"), shutil.which("openscad")):
        if cand and Path(cand).exists():
            return cand
    sys.exit("OpenSCAD not found (install it or pass --openscad PATH)")


class Scad:
    def __init__(self, exe, scad, defines):
        self.exe, self.scad, self.defines = exe, scad, defines
        h = subprocess.run([exe, "--help"], capture_output=True, text=True)
        help_text = h.stdout + h.stderr
        self.backend = ["--backend=manifold"] if "--backend" in help_text else []
        if not self.backend:
            print("note: this OpenSCAD has no Manifold backend - renders will be slow")

    def run(self, out, part=None, extra=(), scad=None):
        cmd = [self.exe, *self.backend, "-o", str(out)]
        if str(out).endswith(".stl"):
            cmd += ["--export-format", "binstl"]
        if part:
            cmd += ["-D", f'part="{part}"']
        for d in self.defines:
            cmd += ["-D", d]
        cmd += list(extra) + [str(scad or self.scad)]
        p = subprocess.run(cmd, capture_output=True, text=True)
        return p.returncode, p.stdout + p.stderr


def model_errors(log):
    return [l for l in log.splitlines()
            if re.search(r"ERROR|Assertion|assert", l) and "REPORT" not in l]


# --------------------------------------------------------------------------
#  STL helpers
# --------------------------------------------------------------------------
def load_stl(path):
    data = Path(path).read_bytes()
    tris = []
    if data[:5] == b"solid" and b"facet" in data[:1000]:
        v = []
        for line in data.decode("ascii", "replace").splitlines():
            line = line.strip()
            if line.startswith("vertex"):
                v.append(tuple(float(x) for x in line.split()[1:4]))
                if len(v) == 3:
                    tris.append(tuple(v)); v = []
    else:
        n = struct.unpack("<I", data[80:84])[0]
        for i in range(n):
            f = struct.unpack("<12f", data[84 + 50 * i: 84 + 50 * i + 48])
            tris.append(((f[3], f[4], f[5]), (f[6], f[7], f[8]), (f[9], f[10], f[11])))
    return tris


def bbox(tris):
    xs = [p[0] for t in tris for p in t]; ys = [p[1] for t in tris for p in t]
    zs = [p[2] for t in tris for p in t]
    return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


def open_edges(tris):
    key = lambda p: (round(p[0], 4), round(p[1], 4), round(p[2], 4))
    edges = {}
    for t in tris:
        a, b, c = (key(p) for p in t)
        if a == b or b == c or a == c:
            continue
        for e in ((a, b), (b, c), (c, a)):
            edges[e] = edges.get(e, 0) + 1
    return sum(1 for (u, v), n in edges.items() if n != 1 or edges.get((v, u), 0) != 1)


# --------------------------------------------------------------------------
#  Renders
# --------------------------------------------------------------------------
SCENE = """
L = ""; R = ""; C = ""; view = "tray"; slide = 4.3; sep = 35;
module Lh() color([0.22, 0.42, 0.62]) import(L);
module Rh() color([0.30, 0.55, 0.45]) import(R);
module Co() color([0.86, 0.68, 0.22]) import(C);
if (view == "tray")       { Lh(); Rh(); }
if (view == "tray_coins") { Lh(); Rh(); Co(); }
if (view == "separated")  { Lh(); translate([sep, 0, 0]) Rh(); }
if (view == "assembly")   { Lh(); translate([12, slide, 0]) Rh(); }
"""


def render_views(scad, tmp, left, right, coins_some, coins_all, outdir, bb, slide):
    (x0, y0, z0), (x1, y1, z1) = bb
    L, D, H = x1 - x0, y1 - y0, z1 - z0
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    scene = tmp / "scene.scad"
    scene.write_text(SCENE)
    f = lambda v: f"{v:.2f}"
    # name: (view, coins file, camera, size, ortho)
    views = {
        "top":             ("tray", None, [cx, cy, 0, 0, 0, 0, 1.39 * L], "1800,700", True),
        "top_coins":       ("tray_coins", coins_some, [cx, cy, 0, 0, 0, 0, 1.39 * L], "1800,700", True),
        "angled":          ("tray", None, [cx, cy, 0.22 * H, 50, 0, 345, 1.8 * L], "1800,1100", False),
        "angled_coins":    ("tray_coins", coins_some, [cx, cy, 0.22 * H, 50, 0, 345, 1.8 * L], "1800,1100", False),
        "separated":       ("separated", None, [cx + 17, cy, 0.22 * H, 48, 0, 345, 2.06 * L], "1800,1100", False),
        "separated_below": ("separated", None, [cx + 17, cy, 0, 235, 0, 25, 1.35 * L], "1800,1100", False),
        "assembly_below":  ("assembly", None, [cx + 5, cy, 0, 215, 0, 40, 0.61 * L], "1600,1100", False),
        "closeup":         ("tray_coins", coins_some, [x0 + 0.23 * L, y0 + 0.29 * D, 0.5 * H, 48, 0, 345, 0.56 * L], "1600,1100", False),
        "ticks":           ("tray_coins", coins_all, [x0 + 0.77 * L, y0 + 0.46 * D, 0.6 * H, 38, 0, 15, 0.35 * L], "1600,1100", False),
        "counts":          ("tray_coins", coins_all, [x0 + 0.645 * L, y0 + 0.476 * D, 0.67 * H, 0, 0, 0, 0.45 * L], "1600,1100", True),
        "side":            ("tray_coins", coins_all, [cx, cy, 0.5 * H, 90, 0, 0, 1.06 * L], "1800,700", True),
        "lip":             ("tray", None, [x1 - 10, y0 + 8, z1 - 5, 75, 0, 300, 70], "1600,1000", False),
    }
    outdir.mkdir(parents=True, exist_ok=True)

    def one(item):
        name, (view, coins, cam, size, ortho) = item
        cmd = ["-D", f'L="{left}"', "-D", f'R="{right}"', "-D", f'C="{coins or ""}"',
               "-D", f'view="{view}"', "-D", f"slide={slide}",
               f"--camera={','.join(f(c) for c in cam)}", f"--imgsize={size}",
               "--colorscheme=Tomorrow", f"--projection={'o' if ortho else 'p'}"]
        rc, log = scad.run(outdir / f"{name}.png", extra=cmd, scad=scene)
        return name, rc == 0

    with cf.ThreadPoolExecutor(max_workers=4) as ex:
        results = list(ex.map(one, views.items()))
    return [n for n, ok in results if not ok]


def lane_section(left, coins, x, title, out):
    """Lengthwise cross-section through the first lane (needs Pillow)."""
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        return False
    Y0, Y1, Z0, Z1, S = -1, 106, -1, 47, 11
    W, H = int((Y1 - Y0) * S), int((Z1 - Z0) * S)
    img = Image.new("RGB", (W, H + 50), (250, 250, 250)); px = img.load()
    for name, col in ((left, (60, 100, 160)), (coins, (215, 175, 60))):
        segs = []
        for t in load_stl(name):
            pts = []
            for a, b in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
                if (a[0] - x) * (b[0] - x) < 0:
                    k = (x - a[0]) / (b[0] - a[0])
                    pts.append((a[1] + k * (b[1] - a[1]), a[2] + k * (b[2] - a[2])))
            if len(pts) == 2:
                segs.append(pts)
        for row in range(H):
            z = Z1 - (row + 0.5) / S + 1.234e-4
            xs = sorted(ya + (z - za) / (zb - za) * (yb - ya)
                        for (ya, za), (yb, zb) in segs if (za - z) * (zb - z) < 0)
            for i in range(0, len(xs) - 1, 2):
                for c in range(max(0, int((xs[i] - Y0) * S)), min(W, int((xs[i + 1] - Y0) * S))):
                    px[c, row + 50] = col
    d = ImageDraw.Draw(img)
    d.line([(0, (Z1 - 45) * S + 50), (W, (Z1 - 45) * S + 50)], fill=(200, 0, 0))
    d.text((10, 10), title + "   (front on the left, red line = rim)", fill=(0, 0, 0))
    img.save(out)
    return True


# --------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("model", nargs="?", default="v3", help="v1/v2/v3 or a .scad path (default v3)")
    ap.add_argument("-D", dest="defines", action="append", default=[], metavar="NAME=VALUE",
                    help="override a parameter (repeatable), e.g. -D deck_angle=8")
    ap.add_argument("--no-renders", action="store_true")
    ap.add_argument("--no-checks", action="store_true")
    ap.add_argument("--bed", type=float, default=220, help="printer bed size in mm (default 220)")
    ap.add_argument("--openscad", help="OpenSCAD executable")
    a = ap.parse_args()

    m = a.model
    scad_path = Path(m) if m.endswith(".scad") else HERE / ("coin_tray.scad" if m == "v1" else f"coin_tray_{m}.scad")
    scad_path = scad_path.resolve()
    if not scad_path.exists():
        sys.exit(f"no such model: {scad_path}")
    stem = scad_path.stem
    tag = "v1" if stem == "coin_tray" else stem.replace("coin_tray_", "")
    defines = [d if "=" in d else sys.exit(f"bad -D {d!r}") for d in a.defines]
    scad = Scad(find_openscad(a.openscad), scad_path, defines)
    tmp = Path(tempfile.mkdtemp(prefix="coin_tray_build_"))
    failed = []
    print(f"model {scad_path.name}  ({tag})  openscad: {scad.exe}"
          + (f"  overrides: {' '.join(defines)}" if defines else ""))

    try:
        # 1. parameters, asserts and the model's own report
        rc, log = scad.run(tmp / "report.echo", part="none")
        echo = (tmp / "report.echo").read_text() if (tmp / "report.echo").exists() else ""
        errs = model_errors(log + "\n" + echo)   # asserts land in the echo file
        if errs:
            print("\nMODEL ASSERT / ERROR:\n  " + "\n  ".join(errs))
            sys.exit(1)
        report = [l.split("REPORT ", 1)[1].rstrip('"') for l in echo.splitlines() if "REPORT" in l]
        lanes = [dict(kv.split("=", 1) for kv in r.split() if "=" in kv) for r in report if r.startswith("lane=")]
        print("\nlanes:")
        for ln in lanes:
            print(f"  {ln.get('coin', '?'):>4}  {ln.get('groups', '?'):>2} groups of 5 = "
                  f"{ln.get('capacity', '?'):>2} coins   pocket {ln.get('pocket_len', '?')} mm"
                  + (f"   top coin z {float(ln['top_coin']):.2f}" if "top_coin" in ln else ""))
        for r in report:
            if r.startswith("bed ") or r.startswith("deck"):
                print("  " + r)
        slide = next((float(x) for r in report for x in re.findall(r"slide=([0-9.]+)", r)), 4.3)

        # 2. the two printable halves (+ coins for checks and renders)
        outs = {"left": HERE / f"{stem}_left.stl", "right": HERE / f"{stem}_right.stl",
                "coins": tmp / "coins.stl", "coins_partial": tmp / "coins_partial.stl"}
        with cf.ThreadPoolExecutor(max_workers=4) as ex:
            res = dict(zip(outs, ex.map(lambda kv: scad.run(kv[1], part=kv[0]), outs.items())))
        for part in ("left", "right"):
            rc, log = res[part]
            if rc != 0 or not outs[part].exists():
                print(f"\nFAILED to build {part}:\n{log[-2000:]}")
                sys.exit(1)
        if res["coins_partial"][0] != 0:      # older versions have no coins_partial part
            outs["coins_partial"] = outs["coins"]

        # 3. mesh sanity: size on the bed, closed surface, assembled envelope
        print("\nhalves:")
        boxes = {}
        for part in ("left", "right"):
            tris = load_stl(outs[part])
            (x0, y0, z0), (x1, y1, z1) = boxes[part] = bbox(tris)
            bad = open_edges(tris)
            fits = x1 - x0 <= a.bed and y1 - y0 <= a.bed
            print(f"  {outs[part].name}: {x1 - x0:.2f} x {y1 - y0:.2f} x {z1 - z0:.2f} mm, "
                  f"{len(tris)} triangles, {'closed' if bad == 0 else f'{bad} OPEN EDGES'}, "
                  f"{'fits' if fits else 'DOES NOT FIT'} the {a.bed:.0f} mm bed, bottom z = {z0:.3f}")
            if bad or not fits or abs(z0) > 1e-6:
                failed.append(f"{part} mesh")
        lo = [min(boxes[p][0][i] for p in boxes) for i in range(3)]
        hi = [max(boxes[p][1][i] for p in boxes) for i in range(3)]
        bb = (tuple(lo), tuple(hi))
        print(f"  assembled: {hi[0] - lo[0]:.3f} x {hi[1] - lo[1]:.3f} x {hi[2] - lo[2]:.3f} mm")

        # 4. geometry checks
        if not a.no_checks:
            print("\nchecks:")
            with cf.ThreadPoolExecutor(max_workers=5) as ex:
                res = dict(zip(CHECKS, ex.map(lambda p: scad.run(tmp / f"{p}.stl", part=p), CHECKS)))
            for part, (want_geometry, what) in CHECKS.items():
                rc, log = res[part]
                empty = "top level object is empty" in log.lower() or not (tmp / f"{part}.stl").exists()
                ok = (not empty) if want_geometry else (empty and not model_errors(log))
                print(f"  {'PASS' if ok else 'FAIL'}  {what}")
                if not ok:
                    failed.append(part)

        # 5. renders
        if not a.no_renders:
            outdir = HERE / "renders" / tag
            bad = render_views(scad, tmp, outs["left"], outs["right"], outs["coins_partial"],
                               outs["coins"], outdir, bb, slide)
            lane0 = lanes[0] if lanes else {}
            if "lane_x" in lane0 and "stagger" in lane0:
                x = float(lane0["lane_x"]) - float(lane0["stagger"]) / 2
                lane_section(outs["left"], outs["coins"], x,
                             f"{tag}: section through the {lane0.get('coin', 'first')} lane",
                             outdir / "lane_section.png")
            print(f"\nrenders: {outdir.relative_to(HERE)}/" + (f"  (failed: {', '.join(bad)})" if bad else ""))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print(f"\nSTLs: {outs['left'].name}, {outs['right'].name}")
    if failed:
        print("FAILED: " + ", ".join(failed))
        sys.exit(1)
    print("all good")


if __name__ == "__main__":
    main()
