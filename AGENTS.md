# Euro coin tray — notes for agents

Parametric OpenSCAD model of a cashier coin-counting tray for Euro coins. It is
split into two halves for FDM printing. Read this before changing anything.

## The brief (owner's requirements)

- **Printer:** Creality K1, 220 × 220 × 250 mm bed, PETG, 0.4 mm nozzle.
  - FDM, so **no supports and no unsupported overhangs**.
  - Walls ≥ 2.4 mm; fillets/chamfers where useful.
- **Finished size, assembled:** exactly **310 × 105 × 45 mm**, including a
  2.5 mm top lip that sits inside that envelope.
- **Split:** two halves of about 155 mm, joined at a lane divider (never through
  a pocket).
  - The joint must not add to the outside size.
  - The halves must sit flat and must not move vertically relative to each other.
  - Clearance on mating faces about 0.3 mm.
- **Coins:** one channel per denomination (2€ 1€ 50c 20c 10c 5c 2c 1c), using the
  official sizes.
  - 1c and 2c need only half capacity.
  - Coins are grouped in **5s**: easy to see, easy to lift out.
  - Diameter clearance about 0.4–0.6 mm, as a parameter.
- **Comfort:** fingers can reach the coins, no sharp inside corners.
  - Denomination labels; text must print with a 0.4 mm nozzle.
- **Parametric:** all values as named parameters at the top of the file; no
  scattered magic numbers.
- **Reference:** `example.png` is the target layout, with coins **standing on
  edge** in front-to-back lanes ("vertical stacked like the example"). The
  `0-02-05-*.jpg` photos show the owner's current tray (310 × 105 × 45, lip).

## Files

| file | what |
|---|---|
| `coin_tray_v3.scad` | **current** — tilted coin bed (10°), counts, back-wall labels |
| `coin_tray_v2.scad` | flat deck, straight-drop lip, counts, back-wall labels |
| `coin_tray.scad` | v1 — first design (45° chamfer under the lip, no counts) |
| `coin_tray_<v>_left.stl` / `_right.stl` | printable halves (binary STL, assembled coordinates) |
| `renders/<v>/*.png` | preview images (`renders/*.png` = v1) |
| `build.py` | rebuilds STLs + checks + renders for one version |
| `coin_tray_v2 (copy).scad` | **the owner's own scratch copy — do not touch or delete** |

Keep each version in its own file. When the owner asks for "v4", copy v3
forward and leave the older versions working.

## Tooling

- **OpenSCAD:** use `~/.local/bin/openscad-nightly` (2026.10.03 AppImage,
  Manifold backend). Each part renders in about 0.6 s.
  - The system `/usr/bin/openscad` is 2021.01 (CGAL): 4–17 min per part. Avoid it.
- **`./build.py [v1|v2|v3|path.scad] [-D name=value ...] [--no-renders] [--no-checks]`:**
  - Runs the model asserts first and prints lane capacities and deck numbers.
  - Writes both halves, then checks:
    - mesh is closed;
    - each half fits the bed;
    - bottom sits at z = 0;
    - assembled bounding box;
    - the 5 geometry checks below.
  - Renders 12 PNGs plus a lane cross-section (Pillow).
  - About 5 s in total; exit code 1 on any failure.
- **The model's `part` values:** these are the parts `build.py` uses.
  - `left`, `right`, `assembled`, `assembled_coins`, `coins`, `coins_partial`;
  - checks: `overlap_check`, `fit_check`, `clearance_check_in` (must be empty),
    `clearance_check_out` (must NOT be empty), `path_check` (must be empty);
  - `none` prints only the `REPORT` echo lines.
- The owner previews in the OpenSCAD **GUI with F5**. The preview must look
  right, not just the F6 render (see the pitfalls below).

## Design (v3)

- **Lanes:** 7 front-to-back lanes. Order: 2€ 1€ 50c | 20c 10c 5c (2c back / 1c front).
  - The split is at x = 155, between 50c and 20c.
  - Coins stand on edge in a round cradle, `coin_exposure` 0.5 above the deck.
- **Pockets:** each holds exactly 5 coins: length = 5 × thickness + `stack_clearance`.
  - Consecutive pockets are offset sideways by `stagger_ratio` × diameter (the
    zig-zag), which makes the 5-groups visible and graspable.
  - A 6th coin can never fit (asserted).
- **Capacities:**

  | coin | 2€ | 1€ | 50c | 20c | 10c | 5c | 2c | 1c |
  |---|---|---|---|---|---|---|---|---|
  | coins per lane | 35 | 35 | 35 | 40 | 40 | 50 | 20 | 20 |

  Equal-length lanes give thin coins more; the brief wanted bigger
  denominations to get more, and the owner has been told this is not met.
- **Tilted bed (v3):** the whole coin bed (deck, cradles, pockets, counts) is
  rotated `deck_angle` = 10° about X, rising to the back.
  - Lanes are built flat in a local frame and placed by `bed_tf()`.
  - The deck plane in world coordinates is `deck_w(y)`.
  - Coins lean forward and settle at the front of each pocket.
- **Deck height:**
  - `deck_height = -1` means auto = `deck_height_max`, the highest value at
    which no coin rises above the rim (33.76 mm at the back wall in v3;
    32.375 mm for a flat deck).
  - The front-leaning coins need `bed_front(c)` / `bed_back(c)`, set per lane.
    v3 therefore uses `stack_clearance` 0.8 (v2: 1.0) to keep the capacities.
- **Joint:** four bed-level L-hooks (`HOOKS`): two from each half.
  - Each hook goes into a bridged pocket in the other half and its claw sits
    behind a catch.
  - Assembly: push the halves together with the right half 4.3 mm
    (`hook_slide`) to the back, then slide it forward.
  - Locks X and both Z directions. Sliding back releases it; a snug drawer or
    glue holds it.
- **Lip:** a 2.5 mm flat ledge with a straight drop below (owner's request, so
  the tray hangs in a cut-out).
  - It is the one unsupported overhang. `lip_underside_chamfer` can soften it.
- **Counts:** raised "5, 10, 15 …" next to each stack.
  - Each sits below a tick whose back edge lines up with the back face of the
    5th coin.
  - Counts follow the zig-zag (`count_offset` from each stack's own left edge).
  - Odd groups sit in the gutter, even groups in the notch beside their stack.
  - The pocket-end chamfer is small (`pocket_end_chamfer` 0.4, sides 1.2) so the
    ticks sit on flat deck.
  - In v3, counts are sheared (`on_deck`): vertical walls, top parallel to the deck.
- **Labels:**
  - Small denomination labels on the inside of the back wall, above the raised
    back deck, recessed with 45° stepped tops (`wall_deboss`).
  - "1c" on the deck separator in the shared lane.

## Pitfalls already hit (don't repeat)

- **Text size is not cap height × 0.7.** In OpenSCAD, `size` ≈ digit height,
  and two digits are ≈ 1.5 × size wide. Measure glyphs (export and take the
  bounding box) before sizing anything around text.
- **Keep the CSG F5-friendly:**
  - No `intersection()` or nested `difference()` among the subtractors of the
    main `difference()`: OpenCSG draws stray "lids".
  - No coincident faces: pockets overlap by 0.01 mm, and cutter tops stay
    `cut_above_deck` (2 mm) above the deck.
  - The v3 well is a single `hull()` of sheared slices.
- **Text `$fn`:** the global `$fn = 96` on ~120 glyphs made CGAL renders take
  minutes. Text uses `text_fn = 16`.
- **Printability means more than face angle.**
  - A horizontal sliding dovetail always leaves a downward-pointing, unsupported
    tip in one half (this is why the joint is hooks).
  - Raised items must not sit over a chamfer.
  - Scan the mesh: there must be no faces pointing down more than 48° above the
    hook bridges (z > 8) except the lip and the 0.16 mm label steps.
- **Tilted coins lean:** check that coin tops clear the front wall (the
  `fit_check` catches this).
- Owner messages arrive mid-task and are terse ("numbers" can mean counts or
  denomination labels). Look at the geometry they mean before changing it.

## Open items / ideas

- €2/€1 capacity is below 5c. Options: tighter `stack_clearance`, or a
  different lane allocation.
- The 10° deck terraces at 0.2 mm layers. Recommend adaptive or 0.12 mm layers
  over z 15–36 mm.
- At the auto maximum deck height, the highest coin is flush with the rim
  (45.0 mm). Lower `deck_height` if a drawer cover sits on top.
- The joint has no y-detent; consider a small snap if the halves creep.
