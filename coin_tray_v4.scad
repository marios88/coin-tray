// =====================================================================
//  Euro coin counting tray v4  -  parametric, split in two for a Creality K1
// =====================================================================
//
//  v4 changes (on top of v3):
//   * No front and back walls: only the two side walls (with their lip)
//     remain.  The deck runs out to the front and back faces, which are flush
//     with the tray_depth envelope (100 mm = the depth of the slot), and its
//     front and back top edges are bevelled (deck_edge_chamfer).  The tray
//     hangs on the side lips only.
//   * front_clearance / back_clearance are the deck left between the pockets
//     and the front / back face, measured at deck level.
//   * Denomination labels are debossed into the deck behind each lane (as in
//     example.png) instead of into the back wall.
//   * A 45 deg bevel with a rounded top runs along the front bottom edge
//     (front_bevel, front_bevel_round) of the side walls, the seam walls and
//     the front beam.
//   * Hollow underside (hollow): below the coin bed there is one open cavity
//     per half, under skin_thickness of deck and cradle skin, between the side
//     walls and in front of a wall_thickness back skin.  It is open at the
//     bottom and (front_open) at the front, so other things fit under the deck.
//     The cavity ceiling needs supports.
//   * Lengthwise beams (front_beam, beam_pitch): the tray hangs on its side
//     lips, so it bends along its length.  A beam under the front edge of the
//     deck and more beams about every beam_pitch behind it run from side wall
//     to seam wall.  Their underside is level with the lowest cradle skin, so
//     they cost no clear height; the deck between them is a short bridge.
//   * Glued joint: a full-depth wall on each half at the split (the glue
//     faces) and vertical dovetail keys (KEYS) instead of the L-hooks.
//
//  v3 changes (on top of v2):
//   * The whole coin bed (deck, cradles, pockets, counts) is tilted by
//     deck_angle about the X axis, rising towards the back: the coins in the
//     35 stack sit higher than those in the first stack and every coin leans
//     at the same angle, resting against the front of its pocket.  Walls and
//     rim stay vertical.
//   * deck_height is now the deck height at the BACK wall (the highest
//     point) and defaults to deck_height_max - the highest value for which
//     no coin rises above the rim.
//   * Denomination labels stay on the back wall as in v2 but smaller, so they
//     fit between the raised back deck (and its cove) and the rim.
//   * Hooks moved back so their pockets stay clear of the (now lower) cradles
//     near the front.
//
//  v2 changes:
//   * The top lip is a true flange: the walls drop straight down lip_width
//     inside the outer edge and the lip underside is flat, so the tray slots
//     into a cut-out and hangs on the lip.  (Optional lip_underside_chamfer.)
//   * Raised running counts (5, 10, 15 ...) at the top left of every 5-coin
//     pocket, each under a raised tick that lines up with the pocket end.
//   * Lanes re-spaced so every lane has a count gutter on its left.
//
//  Layout (after example.png): one front-to-back lane per denomination.
//  Coins stand on edge ("vertically stacked"), face to face, in a round
//  cradle.  Each lane is a chain of pockets that hold exactly 5 coins;
//  consecutive pockets are offset sideways (zig-zag), so every group of 5
//  is visible at a glance and its protruding side can be pinched out.
//  2c and 1c share the last lane (2c at the back, 1c at the front), each
//  with half the capacity of a full lane.
//
//  Coordinates:  X = length (left -> right, 0..310)
//                Y = depth  (0 = front / cashier side .. 100 = back)
//                Z = up     (0 = bed .. 45)
//
//  The assembled tray occupies exactly [0,310] x [0,100] x [0,45].
//  It is split at x = 155 between the 50c and 20c lanes.  Each half has a
//  full-depth wall at the split (from the bed up into the deck); the two
//  walls are glued face to face.  Vertical dovetail keys on the left half's
//  seam face sit in grooves of the right half: they line the halves up and
//  hold them together (X) while the glue cures.
//
//  Assembly: glue on the seam faces and keys, set the left half on the table,
//  lower the right half onto it from above (keys into the grooves, which are
//  open at the bottom) until it sits on the table; front and back faces line up.
//
//  Print: both halves upright, flat bottom on the bed.  The cavity under the
//  coin bed needs supports (tree supports, on build plate only - the cavity
//  is open at the bottom).  Everything else prints without: the keys are
//  vertical prisms and the groove tops are short bridges.
// =====================================================================

/* [Render selection] */
// assembled | left | right | left_print | right_print | exploded | coins
// | assembled_coins | fit_check | overlap_check | clearance_check_in
// | clearance_check_out | path_check | coins_partial
part = "assembled";

/* [Finished overall dimensions] */
tray_length   = 310;   // lip to lip, X
tray_depth    = 100;   // front face to back face, Y (= the depth of the slot: no lip at the front and back)
tray_height   = 45;    // Z
lip_width     = 2.5;   // top flange overhang on the side walls (inside the 310 x 100 envelope)
lip_thickness = 2.0;   // flange thickness; its underside is flat (straight drop)
lip_underside_chamfer = 0;  // optional 45 deg root chamfer under the lip (0 = sharp ledge)

/* [Structure] */
wall_thickness      = 2.4;  // side walls below the lip, front / back skins of the hollow body;
                            // also the least material around a pocket
base_thickness      = 3.0;  // minimum floor under the deepest cradle
divider_thickness   = 2.4;  // minimum deck web between neighbouring lanes
deck_angle          = 1;   // tilt of the coin bed, rising towards the back (deg)
deck_height         = -1;   // deck Z at the BACK face (highest point); -1 = auto = deck_height_max
// Highest usable deck_height (no coin rises above the top of the side walls),
// computed from the actual back pockets of every lane (last coin pushed to the
// end of its pocket):
//   deck_height_max = tray_height - max over lanes of
//       (coin_exposure * d - coin_clearance / 2) * cos(deck_angle)
//     + (end of last pocket - back face) * sin(deck_angle)
//   For a flat deck (deck_angle = 0) it is 45 - (0.5 * 25.75 - 0.25) = 32.375.
//   Echoed as REPORT deck_height_max and enforced by an assert.
corner_radius       = 6;    // plan-view radius of the outer (lip) corners
well_fillet         = 3;    // cove where the deck meets the side walls
deck_edge_chamfer   = 1.0;  // 45 deg bevel on the front and back top edges of the deck
pocket_chamfer      = 1.2;  // 45 deg chamfer where pockets meet the deck (lane sides)
pocket_end_chamfer  = 0.4;  // smaller chamfer at pocket ends / zig-zag steps, leaves flat deck for the counts
rim_chamfer         = 0.8;  // inner top edge of the rim
lip_edge_chamfer    = 0.5;  // outer top edge of the lip
bottom_chamfer      = 0.6;  // bottom edges (elephant foot relief)
front_bevel         = 20;   // 45 deg bevel along the front bottom edge: this tall and this deep (0 = none)
front_bevel_round   = 5;    // radius where the bevel meets the vertical front face

/* [Hollow underside] */
hollow          = true;  // open cavity under the coin bed (print it with supports, on build plate only)
front_open      = true;  // no front skin: the cavity is open at the front as well
front_beam      = true;  // lengthwise beam under the front edge of the deck
beam_pitch      = 10;    // more lengthwise beams behind it, about this far apart, evenly
                         // spaced up to the back skin (0 = front beam only)
beam_width      = 2.4;   // thickness of the beams (and width of the front beam's flat
                         // underside behind the front bevel)
beam_bottom     = -1;    // Z of the beams' underside; -1 = auto: level with the lowest
                         // cradle skin, so the beams cost no clear height
lane_support    = false; // true: each lane sits on a solid, flat-bottomed block that reaches
                         // skin_thickness below its deepest coin (false: the skin follows
                         // the round cradles)
skin_thickness  = 2.4;   // deck and cradle skin over the cavity
// Cavity pieces narrower than this are left solid: slots that thin print badly
// and their supports cannot be pulled out
cavity_min_width = 2 * skin_thickness;

/* [Coin storage] */
coin_clearance  = 0.5;   // total diametral clearance of a cradle
stack_clearance = 0.8;   // extra length per pocket of 5 coins (v2: 1.0; 0.8 keeps
                         // 8 groups of 20c and 10 of 5c in the shorter tilted lanes)
front_clearance = 6;   // deck between the front face and the first pockets (at deck level)
back_clearance  = 10;   // deck between the last pockets and the back face (at deck level);
                        // the lane labels sit on this strip
group_size      = 5;     // coins per pocket
stagger_ratio   = 0.15;  // sideways offset between pockets, x coin diameter
coin_exposure   = 0.55;   // fraction of the coin diameter standing above the deck
separator_min   = 5;    // minimum deck between the 2c and 1c sections

/* [Joint] */
joint_x          = tray_length / 2;  // split plane
joint_clearance  = 0.3;  // clearance (glue gap) on every mating surface of the keys
seam_gap         = joint_clearance;  // gap between the glued seam faces (split evenly,
                                      // so the external length stays 310)
joint_web_left   = 5.0;  // deck web between the 50c lane and the split plane
edge_margin_right = 3.0; // deck between the last lane and the right wall
// The seam walls fill from the split to the skin of the neighbouring lanes.
// Vertical dovetail keys stand on the left half's seam face (narrow at the
// seam, wide at the tip) and sit in grooves of the right half that are open at
// the bottom: the right half is lowered onto the left one from above.
KEYS             = [30, 70];  // y of the key centres
key_root_width   = 8.0;  // Y width at the seam face
key_tip_width    = 12.0; // Y width at the tip (wider than the root: locks X)
key_depth        = 4.0;  // how far a key reaches into the right half (X)
key_height       = 20.0; // keys stand on the bed, 0..key_height
key_relief       = 0.4;  // elephant-foot relief at the bed on keys and grooves

/* [Group counts] */
show_counts       = true;
count_size        = 4;   // text size of the counts: digits ~1.0 x size tall, two digits ~1.5 x size wide
count_emboss      = 1;   // height of counts and ticks above the deck
count_tick_length = 5.0;   // length of the tick line above each count (a bit wider than "50")
count_line_width  = 0.8;   // tick width (2 extrusion lines)
count_text_gap    = 0.6;   // gap between tick and count
count_offset      = 2.0;   // gap from a stack's left edge to the right end of its tick;
                           // counts follow the zig-zag of their own stacks

/* [Labels] */
show_labels = true;
label_font  = "Liberation Sans:style=Bold";
label_size  = 6.5;   // deck labels behind each lane and on the 2c/1c separator
                     // (measured: ~0.99 x size tall, "50c" 2.24 x size wide)
label_depth = 0.6;   // deboss depth

/* [Euro coins (official dimensions)] */
d_2e  = 25.75;  t_2e  = 2.20;
d_1e  = 23.25;  t_1e  = 2.33;
d_50c = 24.25;  t_50c = 2.38;
d_20c = 22.25;  t_20c = 2.14;
d_10c = 19.75;  t_10c = 1.93;
d_5c  = 21.25;  t_5c  = 1.67;
d_2c  = 18.75;  t_2c  = 1.67;
d_1c  = 16.25;  t_1c  = 1.67;

/* [Quality] */
$fn = 96;
text_fn = 32;   // curve segments for text (the global $fn would make ~120 numbers very slow to render)

// =====================================================================
//  Derived values
// =====================================================================

// [label, diameter, thickness]
COINS = [
    ["2€",  d_2e,  t_2e ],   // 0
    ["1€",  d_1e,  t_1e ],   // 1
    ["50c", d_50c, t_50c],   // 2
    ["20c", d_20c, t_20c],   // 3
    ["10c", d_10c, t_10c],   // 4
    ["5c",  d_5c,  t_5c ],   // 5
    ["2c",  d_2c,  t_2c ],   // 6
    ["1c",  d_1c,  t_1c ],   // 7
];

// Lanes left -> right.  A two-coin lane is [back section, front section].
LANES   = [[0], [1], [2], [3], [4], [5], [6, 7]];
n_lanes = len(LANES);
n_left  = 3;   // lanes on the left half (split between 50c and 20c)

function c_d(c) = COINS[c][1];
function c_t(c) = COINS[c][2];
function R(c)       = c_d(c) / 2 + coin_clearance / 2;           // cradle radius
function plen(c)    = group_size * c_t(c) + stack_clearance;      // pocket length
function stag(c)    = stagger_ratio * c_d(c);                     // zig-zag offset
function cdepth(c)  = (1 - coin_exposure) * c_d(c) + coin_clearance / 2;
function zbot(c)    = deck_z - cdepth(c);                    // cradle bottom
function zc(c)      = zbot(c) + R(c);                             // cradle axis
function lane_w(l)  = max([for (c = LANES[l]) 2 * R(c) + stag(c)]);

function sumv(v, n) = n <= 0 ? 0 : v[n - 1] + sumv(v, n - 1);

// Open well: between the side walls in X; no front and back walls, so in Y it
// spans the whole depth (the deck runs out to the front and back faces)
well_x0 = lip_width + wall_thickness;
well_x1 = tray_length - well_x0;
well_y0 = 0;
well_y1 = tray_depth;
lane_avail = well_y1 - well_y0;

// Tilted coin bed.  All lane geometry is built flat in a local frame (deck at
// z = deck_z) and rotated by deck_angle about the line y = well_y1, z = deck_z.
max_cdepth = max([for (c = [0 : len(COINS) - 1]) cdepth(c)]);
// First and last usable local Y: front_clearance / back_clearance of deck
// (measured at deck level, in world Y) to the front / back face.
function bed_front(c) = well_y1 - (well_y1 - well_y0 - front_clearance) / cos(deck_angle);
function bed_back(c)  = well_y1 - back_clearance / cos(deck_angle);

// Lane placement: every lane gets a gutter on its left (for the counts),
// equal within each half.  Left of the split there is a fixed web; the first
// gutter of the right half starts at the split plane.
W        = [for (l = [0 : n_lanes - 1]) lane_w(l)];
jw_left  = joint_web_left;
gap_left  = (joint_x - well_x0 - jw_left - sumv(W, n_left)) / n_left;
gap_right = (well_x1 - joint_x - edge_margin_right - (sumv(W, n_lanes) - sumv(W, n_left)))
            / (n_lanes - n_left);
jw_right = gap_right;

function lane_x(l) = l < n_left
    ? well_x0 + (l + 1) * gap_left + sumv(W, l) + W[l] / 2
    : joint_x + (l - n_left + 1) * gap_right
      + (sumv(W, l) - sumv(W, n_left)) + W[l] / 2;

// Right end of the count ticks of lane l (they run leftwards from here)
function count_x1(l, c, k) =   // right end of the tick of pocket k (coin c) in lane l
    lane_x(l) + (k % 2 == 0 ? -1 : 1) * stag(c) / 2 - R(c) - count_offset;

// Sections of a lane: [coin, y start, available length, align]
// align 0 = pockets at the front of the section, 1 = at its back
function sections(l) = len(LANES[l]) == 1
    ? let (c = LANES[l][0]) [[c, bed_front(c), bed_back(c) - bed_front(c), 0]]
    : let (cf = LANES[l][1], cb = LANES[l][0], y0 = bed_front(cf), y1 = bed_back(cb),
           sec = (y1 - y0 - separator_min) / 2)
      [[cf, y0, sec, 0],                          // front section (1c)
       [cb, y1 - sec, sec, 1]];                   // back section  (2c)

function n_groups(c, len) = floor(len / plen(c));
// Start of a section's first pocket.  Front-aligned sections (all single
// lanes and the 1c section) start at the front of their section, so every
// lane's first pocket sits exactly front_clearance from the front face and
// the spare length goes behind the last pocket.  The back (2c) section of the
// shared lane is back-aligned, so the spare length of both its sections goes
// into the separator between them (room for the "1c" label).
function block_y0(s) = s[1] + s[3] * (s[2] - n_groups(s[0], s[2]) * plen(s[0]));
function block_y1(s) = block_y0(s) + n_groups(s[0], s[2]) * plen(s[0]);   // end of the last pocket

// Pockets of a lane: [coin, y0, x offset from lane centre]
function pockets(l) = [
    for (s = sections(l))
        for (k = [0 : n_groups(s[0], s[2]) - 1])
            [s[0],
             block_y0(s) + k * plen(s[0]),
             (k % 2 == 0 ? -1 : 1) * stag(s[0]) / 2]
];

// Height of the highest coin point of a section above the deck height at the
// back face (worst case: last coin pushed to the end of its pocket).
function coin_rise(s) =
    let (c = s[0], yend = block_y1(s))
    (coin_exposure * c_d(c) - coin_clearance / 2) * cos(deck_angle)
    + (yend - well_y1) * sin(deck_angle);
deck_height_max = tray_height - max([for (l = [0 : n_lanes - 1]) for (s = sections(l)) coin_rise(s)]);
deck_z = deck_height < 0 ? deck_height_max : deck_height;

// local -> world transform of the coin bed, and the world deck height at y
module bed_tf() {
    translate([0, well_y1, deck_z]) rotate([deck_angle, 0, 0])
        translate([0, -well_y1, -deck_z]) children();
}
function deck_w(y) = deck_z - (well_y1 - y) * tan(deck_angle);

// World Z of the cradle bottom at the front end of a section's first pocket
function front_floor(s) = let (c = s[0], y = block_y0(s))
    deck_z + (y - well_y1) * sin(deck_angle) - cdepth(c) * cos(deck_angle);
min_floor = min([for (l = [0 : n_lanes - 1]) for (s = sections(l)) front_floor(s)]);

// World [y, z] of a point given in the local (flat) bed frame
function bed_pt(yl, zl) = [well_y1 + (yl - well_y1) * cos(deck_angle) - (zl - deck_z) * sin(deck_angle),
                           deck_z + (yl - well_y1) * sin(deck_angle) + (zl - deck_z) * cos(deck_angle)];

// Front bevel: the body's side profile (Y-Z) has a 45 deg bevel from
// (fbv, 0) up to (0, fbv), whose top corner is rounded by front_bevel_round.
// The same points build the body hull and the front / back skins.
fbv  = max(front_bevel, bottom_chamfer);
fbr  = front_bevel > 0 ? front_bevel_round : 0;
fb_top = fbv + tan(22.5) * fbr;   // where the round leaves the vertical front face
function front_pts() = concat(
    [[0, tray_height]],
    fbr > 0 ? [for (i = [0 : 6]) let (a = 180 + 45 * i / 6) [fbr + fbr * cos(a), fb_top + fbr * sin(a)]]
            : [[0, fbv]],
    [[fbv, 0]]);
function side_pts() = concat(front_pts(),
    [[tray_depth - bottom_chamfer, 0], [tray_depth, bottom_chamfer], [tray_depth, tray_height]]);
// Distance from the lowest front corner of a section's first pocket to the bevel
function bevel_gap(s) = let (p = bed_pt(block_y0(s), zbot(s[0]))) (p[0] + p[1] - fbv) / sqrt(2);
// Y of the front face at height z (front_pts() runs downwards)
function front_y(z) = let (P = front_pts(),
                           i = [for (k = [0 : len(P) - 2]) if (P[k][1] >= z && P[k + 1][1] <= z) k][0],
                           a = P[i], b = P[i + 1])
    a[0] + (b[0] - a[0]) * (a[1] - z) / max(a[1] - b[1], 1e-9);

// Clear height under the coin bed: below the lowest cradle skin
clear_under_cradles = min_floor - skin_thickness / cos(deck_angle);
// Beams: underside at beam_z.  The front beam is flat for beam_width behind
// the bevel (back face at beam_y1); the others are spread evenly between it
// and the back skin, beam_p apart (front face of each at BEAM_YS)
beam_z  = beam_bottom < 0 ? clear_under_cradles : beam_bottom;
beam_y1 = front_y(beam_z) + beam_width;
beam_ya = front_beam ? beam_y1 : well_y0 + front_skin;   // clear span for the other beams
beam_yb = well_y1 - wall_thickness;
n_beams = beam_pitch > 0 ? max(0, round((beam_yb - beam_ya + beam_width) / beam_pitch) - 1) : 0;
beam_p  = (beam_yb - beam_ya + beam_width) / (n_beams + 1);
BEAM_YS = n_beams > 0 ? [for (k = [1 : n_beams]) beam_ya + k * beam_p - beam_width] : [];

// Hollow underside.  Lane l (cradles plus their skin) spans X from lane_ext_l
// to lane_ext_r; the cavity is cut in pieces under each lane section (A),
// between lanes (B) and under the deck strips around the sections (C).
function lane_ext_l(l) = lane_x(l) - W[l] / 2 - skin_thickness;
function lane_ext_r(l) = lane_x(l) + W[l] / 2 + skin_thickness;
cav_top = deck_z - skin_thickness;                      // local Z of the cavity ceiling
cav_bot = deck_z - tray_height - tray_depth;            // local Z well below the bed
cav_y0  = -tray_depth;  cav_y1 = 2 * tray_depth;        // local Y well past both faces
// B: [x0, x1] between the lanes and next to the side walls (the seam walls
// fill the span across the split)
B_SPANS = concat([[well_x0, lane_ext_l(0)]],
                 [for (l = [0 : n_lanes - 2]) if (l != n_left - 1) [lane_ext_r(l), lane_ext_l(l + 1)]],
                 [[lane_ext_r(n_lanes - 1), well_x1]]);
// C: [lane, y0, y1, width, name, open]; y0 / y1 are local and reach past the
// faces, width is the clear strip between the skins (world).  An open strip
// (the front one when front_open) is cut whatever its width: it is not a slot.
front_skin = front_open ? 0 : wall_thickness;
function c_strips(l) = let (S = sections(l), n = len(S), sk = skin_thickness) concat(
    [[l, cav_y0, block_y0(S[0]) - sk,
      y_world(block_y0(S[0]) - sk) - (well_y0 + front_skin), str("front ", COINS[S[0][0]][0]), front_open]],
    [for (i = [0 : n - 2]) [l, block_y1(S[i]) + sk, block_y0(S[i + 1]) - sk,
      (block_y0(S[i + 1]) - block_y1(S[i])) * cos(deck_angle) - 2 * sk, str("separator ", COINS[S[i][0]][0]),
      false]],
    [[l, block_y1(S[n - 1]) + sk, cav_y1,
      (well_y1 - wall_thickness) - y_world(block_y1(S[n - 1]) + sk), str("back ", COINS[S[n - 1][0]][0]),
      false]]);
C_STRIPS = [for (l = [0 : n_lanes - 1]) each c_strips(l)];
function c_cut(c) = c[5] || c[3] >= cavity_min_width;
cavity_dropped = concat(
    [for (b = B_SPANS) if (b[1] - b[0] < cavity_min_width) str("gap x=", b[0], " ", b[1] - b[0])],
    [for (c = C_STRIPS) if (!c_cut(c)) str(c[4], " ", c[3])]);

// Seam walls: from the skin of the neighbouring lanes to the split
seam_wall_left  = joint_x - seam_gap / 2 - lane_ext_r(n_left - 1);
seam_wall_right = lane_ext_l(n_left) - (joint_x + seam_gap / 2);
// Top of the seam walls and skins: just into the deck slab (world, at y)
function skin_top(y) = deck_w(y) - skin_thickness / cos(deck_angle) + 0.5;

// Joint keys.  Plan view relative to (joint_x, key y): a dovetail whose neck is
// at the right half's seam face; key_e of it is buried in the left half.
key_e = seam_gap / 2 + 1;
function key_pts() = [[-key_e, -key_root_width / 2], [seam_gap / 2, -key_root_width / 2],
                      [key_depth, -key_tip_width / 2], [key_depth, key_tip_width / 2],
                      [seam_gap / 2, key_root_width / 2], [-key_e, key_root_width / 2]];
key_ymin = min(KEYS) - key_tip_width / 2 - joint_clearance;   // groove extent in Y
key_ymax = max(KEYS) + key_tip_width / 2 + joint_clearance;

// Lane labels: centred on the deck strip behind the last pockets, between
// their end chamfer and the bevel on the back edge
label_strip = back_clearance - pocket_end_chamfer - deck_edge_chamfer;
label_y     = well_y1 - deck_edge_chamfer - label_strip / 2;
label_h     = 0.99 * label_size;   // measured glyph heights (all labels)
label_w     = 2.24 * label_size;   // measured width of the widest label ("50c")
lane_pitch_min = min([for (l = [0 : n_lanes - 2]) lane_x(l + 1) - lane_x(l)]);

// =====================================================================
//  Sanity checks
// =====================================================================
assert(deck_z <= deck_height_max + 1e-9, "coins would rise above the rim");
assert(min_floor >= base_thickness,
       "deck too low / too steep for base_thickness under the front cradles");
// joint: seam walls and keys
assert(seam_wall_left >= wall_thickness, "left seam wall too thin (50c lane too close to the split)");
assert(seam_wall_right - seam_gap / 2 >= key_depth + joint_clearance + wall_thickness,
       "right seam wall too thin for the key grooves (20c lane too close to the split)");
assert(key_tip_width > key_root_width && key_depth > seam_gap / 2, "keys must widen towards the tip");
assert(key_height + joint_clearance + wall_thickness <= deck_w(key_ymin) - skin_thickness,
       "keys too tall for the seam walls");
assert(key_ymin - wall_thickness >= fbv, "first key too close to the front (bevel)");
assert(key_ymax + wall_thickness <= well_y1 - bottom_chamfer, "last key too close to the back");
// front bevel: below the deck, and clear of the first pockets
assert(fbv - (1 - cos(45)) * fbr >= 0, "front_bevel_round too big for front_bevel");
assert(fb_top <= deck_w(well_y0) - deck_edge_chamfer - 1,
       "front bevel reaches the deck (lower front_bevel or front_bevel_round)");
assert(front_bevel == 0 || min([for (l = [0 : n_lanes - 1]) bevel_gap(sections(l)[0])]) >= wall_thickness,
       "front bevel comes too close to the first pockets (lower front_bevel, front_clearance up or deck_angle down)");
assert((!front_beam && n_beams == 0) || (beam_z >= 0 && beam_z <= skin_top(well_y0) - skin_thickness),
       "beam_bottom must lie between the bed and the deck slab");
// deck in front of / behind the pockets (the pocket ends lean back with the
// tilt, so the front web is thinnest at the deck, the back web at the cradle bottom)
assert(front_clearance >= max(wall_thickness, deck_edge_chamfer + pocket_end_chamfer + 1),
       "front_clearance too small for the front web and its bevel");
assert(back_clearance - max_cdepth * sin(deck_angle) >= wall_thickness,
       "back_clearance too small: the deepest cradle comes too close to the back face");
assert(gap_left  >= divider_thickness + 2 * pocket_chamfer, "left lanes too crowded");
// counts of left-shifted stacks sit in the gutter: clear of the neighbour lane
count_w = max(count_tick_length, 1.5 * count_size);   // widest count ("45") incl. tick
assert(count_offset + count_w + pocket_chamfer + 0.3 <= gap_right + 1e-9,
       "count gutter too narrow on the right half");
// counts of right-shifted stacks sit in the zig-zag notch: clear of their own
// stack's side chamfer and of the next pocket's (small) end chamfer
assert(count_offset >= pocket_chamfer + 0.3, "count_offset too small");
assert(pocket_end_chamfer + 0.3 <= stack_clearance, "end chamfer would reach the ticks");
assert(min([for (c = COINS) group_size * c[2]])
       >= count_line_width + count_text_gap + 1.0 * count_size + pocket_end_chamfer + 0.3,
       "counts do not fit beside the thinnest stack");
assert(lane_x(n_left) - W[n_left] / 2 - count_offset - count_w >= joint_x + seam_gap / 2 + 0.5,
       "counts of the first right-hand lane would cross the split");
assert(gap_right >= divider_thickness + 2 * pocket_chamfer, "right lanes too crowded");
assert(label_h + 1 <= label_strip,
       "label_size too big for the deck strip behind the lanes (or back_clearance too small)");
assert(label_w + 2 <= lane_pitch_min, "label_size too big: neighbouring lane labels would touch");
assert(lane_x(0) - label_w / 2 >= well_x0 + well_fillet
       && lane_x(n_lanes - 1) + label_w / 2 <= well_x1 - well_fillet,
       "outer lane labels would run into the side coves");
assert(min([for (l = [0 : n_lanes - 1]) if (len(LANES[l]) > 1) sep_len(l)])
       >= label_h + 1 + 2 * pocket_end_chamfer,
       "separator too short for its label (raise separator_min or lower label_size)");
assert(stack_clearance < min([for (c = COINS) c[2]]),
       "stack_clearance must be smaller than one coin, or a 6th coin fits");
assert(lane_x(n_left - 1) + W[n_left - 1] / 2 + jw_left <= joint_x + 1e-6);

// =====================================================================
//  2D helpers
// =====================================================================
module rrect(x0, y0, x1, y1, r) {
    rr = max(r, 0.01);
    translate([x0 + rr, y0 + rr]) offset(r = rr) square([x1 - x0 - 2 * rr, y1 - y0 - 2 * rr]);
}

module outer_outline(inset) {
    rrect(inset, inset, tray_length - inset, tray_depth - inset, corner_radius - inset);
}

// Body below the lip: lip_width in from the ends (side walls), flush with the
// envelope at the front and back (no lip there)
module body_outline(inset) {
    rrect(lip_width + inset, inset, tray_length - lip_width - inset, tray_depth - inset,
          corner_radius - lip_width - inset);
}

// The open well in plan: between the side walls (grown by g), and 1 mm past
// the front and back faces so no cutter face sits on them
module well_plan(g = 0) {
    translate([well_x0 - g, well_y0 - 1]) square([well_x1 - well_x0 + 2 * g, well_y1 - well_y0 + 2]);
}

module slab(z, h = 0.01) { translate([0, 0, z]) linear_extrude(h) children(); }

// =====================================================================
//  Body
// =====================================================================
module shell() {
    z_lip = tray_height - lip_thickness;   // flat underside of the lip
    hull() {   // body: side walls straight down lip_width inside the outer edge,
               // front bottom edge bevelled (one slab per point of front_pts())
        rc = corner_radius - lip_width;
        slab(0)              rrect(lip_width + bottom_chamfer, fbv, tray_length - lip_width - bottom_chamfer,
                                   tray_depth - bottom_chamfer, rc - bottom_chamfer);
        slab(bottom_chamfer) rrect(lip_width, fbv - bottom_chamfer, tray_length - lip_width, tray_depth, rc);
        for (p = front_pts()) if (p[1] > bottom_chamfer)
            slab(min(p[1], tray_height - 0.01)) rrect(lip_width, p[0], tray_length - lip_width, tray_depth, rc);
    }
    hull() {   // lip flange (the well cutter leaves it on the side walls only)
        slab(z_lip)                          outer_outline(0);
        slab(tray_height - lip_edge_chamfer) outer_outline(0);
        slab(tray_height - 0.01)             outer_outline(lip_edge_chamfer);
    }
    if (lip_underside_chamfer > 0) hull() {
        slab(z_lip - lip_underside_chamfer) body_outline(0);
        slab(z_lip) rrect(lip_width - lip_underside_chamfer, 0,
                          tray_length - lip_width + lip_underside_chamfer, tray_depth,
                          corner_radius - lip_width + lip_underside_chamfer);
    }
}

// Lane cutters reach this far above the deck (local), so their tops never sit
// on the deck surface - keeps the F5 preview free of flickering "lids"
cut_above_deck = 2;

// Vertical extrusion of a world-plan 2D shape whose bottom lies on the plane
// z = z0 + s * y (sheared): z from that plane to h above it, walls vertical.
module sheared(s, z0, h) {
    multmatrix([[1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, s, 1, z0],
                [0, 0, 0, 1]])
        linear_extrude(h) children();
}
// The same on the tilted deck: z from deck + z0 to deck + z0 + h.
module on_deck(z0, h) { sheared(tan(deck_angle), deck_w(0) + z0, h) children(); }

// World Y of a point on the deck given in the local (flat) bed frame
function y_world(yl) = well_y1 + (yl - well_y1) * cos(deck_angle);

// Thin slices across the well (Y from ya to yb) whose ends follow the side
// coves, lying on the plane z = z0 + s * y.  Hulled, they make a cutter whose
// floor is that plane with the coves along the side walls.
module cove_slices(s, z0, ya, yb) {
    steps = 8;
    for (i = [0 : steps]) {
        a = 90 * i / steps;
        e = well_fillet * (1 - sin(a));
        sheared(s, z0 + well_fillet * (1 - cos(a)), 0.01)
            translate([well_x0 + e, ya]) square([well_x1 - well_x0 - 2 * e, yb - ya]);
    }
}

// Open well above the tilted deck, between the side walls and out through the
// front and back faces.  It is convex, so it is one hull of slices - no
// intersections, which keeps the F5 preview exact.
module well_cutter() {
    hull() {
        cove_slices(tan(deck_angle), deck_w(0), well_y0 - 1, well_y1 + 1);
        slab(tray_height - rim_chamfer) well_plan();
    }
    hull() {   // chamfer on the inner top edge of the side walls
        slab(tray_height - rim_chamfer) well_plan();
        slab(tray_height, 1) well_plan(rim_chamfer);
    }
}

// 45 deg bevels on the front and back top edges of the deck, through the side
// coves as well: each is a hull of cove slices on the bevel plane, which meets
// the deck about deck_edge_chamfer in from the face.
module deck_edge_bevels() {
    c = deck_edge_chamfer;
    t = tan(deck_angle);
    top = well_fillet + c + 1;   // high enough to clear the cove tops at the faces
    if (c > 0) {
        // front: z = deck_w(well_y0) - c + (y - well_y0)
        z0f = deck_w(well_y0) - c - well_y0;
        yef = well_y0 + c / (1 - t);
        hull() {
            cove_slices(1, z0f, well_y0 - 1, yef);
            sheared(1, z0f + top, 0.01) translate([well_x0, well_y0 - 1]) square([well_x1 - well_x0, yef - well_y0 + 1]);
        }
        // back: z = deck_w(well_y1) - c + (well_y1 - y)
        z0b = deck_w(well_y1) - c + well_y1;
        yeb = well_y1 - c / (1 + t);
        hull() {
            cove_slices(-1, z0b, yeb, well_y1 + 1);
            sheared(-1, z0b + top, 0.01) translate([well_x0, yeb]) square([well_x1 - well_x0, well_y1 + 1 - yeb]);
        }
    }
}

// =====================================================================
//  Coin lanes
// =====================================================================
module pocket_profile(c) {   // X-Z cross-section: round cradle up to the deck
    // (the well cutter clears everything above the deck)
    intersection() {
        union() {
            translate([0, zc(c)]) circle(r = R(c));
            translate([-R(c), zc(c)]) square([2 * R(c), tray_height]);
        }
        translate([-R(c) - 1, zbot(c) - 1]) square([2 * R(c) + 2, deck_z + cut_above_deck - zbot(c) + 1]);
    }
}

module pocket(l, p) {
    c = p[0];
    e = 0.01;   // overlap neighbouring pockets so no two faces coincide (clean F5 preview)
    translate([lane_x(l) + p[2], p[1] + plen(c) + e, 0])
        rotate([90, 0, 0]) linear_extrude(plen(c) + 2 * e) pocket_profile(c);
}

// Lane footprint grown by gx along the sides and gy at pocket ends (chamfer steps)
module lane_outline_grown(l, gx, gy) {
    offset(r = 0.2) offset(delta = -0.2)
        for (p = pockets(l))
            translate([lane_x(l) + p[2] - R(p[0]) - gx, p[1] - gy])
                square([2 * R(p[0]) + 2 * gx, plen(p[0]) + 2 * gy]);
}

module lane_outline(l) {     // zig-zag footprint of a lane at deck level
    for (p = pockets(l))
        translate([lane_x(l) + p[2] - R(p[0]), p[1]]) square([2 * R(p[0]), plen(p[0])]);
}

module lane_cutter(l) {
    for (p = pockets(l)) pocket(l, p);
    // stepped 45 deg chamfer around the pocket edges (incl. the zig-zag steps);
    // no front/back walls to clip against, the clearances keep it off the faces
    steps = 4;
    for (i = [1 : steps])
        slab(deck_z - pocket_chamfer * (1 - (i - 1) / steps),
             pocket_chamfer * (1 - (i - 1) / steps) + cut_above_deck)
            lane_outline_grown(l, pocket_chamfer * i / steps, pocket_end_chamfer * i / steps);
}

// =====================================================================
//  Labels
// =====================================================================
// Deck separator of a shared lane in local Y: [end of the front section's last
// pocket, start of the back section's first pocket]
function sep_span(l) =
    let (s = sections(l)) [block_y1(s[0]), block_y0(s[1])];
function sep_center_y(l) = (sep_span(l)[0] + sep_span(l)[1]) / 2;
function sep_len(l) = (sep_span(l)[1] - sep_span(l)[0]) * cos(deck_angle);   // world

module label_text(s) {
    text(s, size = label_size, font = label_font, halign = "center", valign = "center", $fn = text_fn);
}

module lane_labels() {   // on the deck strip behind each lane (as in example.png), read from the front
    for (l = [0 : n_lanes - 1])
        on_deck(-label_depth, label_depth + 1)
            translate([lane_x(l), label_y]) label_text(COINS[LANES[l][0]][0]);
}

module separator_labels() {   // front section of the shared lane, on the deck separator
    for (l = [0 : n_lanes - 1]) if (len(LANES[l]) > 1)
        on_deck(-label_depth, label_depth + 1)
            translate([lane_x(l), y_world(sep_center_y(l))]) label_text(COINS[LANES[l][1]][0]);
}

// =====================================================================
//  Hollow underside
// =====================================================================
// One open cavity per half under the coin bed.  It is cut from the shell in
// pieces that are plain boxes or Y-extrusions of 2D shapes in the bed frame
// (no 3D intersections or nested differences, so F5 stays clean):
//   A  under each lane section, over the section's pockets +- skin_thickness
//      (end caps): with lane_support a box up to a flat floor skin_thickness
//      below the deepest coin, so the lane sits on a solid block; without it
//      the lane's width minus the cradles grown by skin_thickness (both
//      zig-zag offsets), so the skin follows the cradles;
//   B  between the lanes and next to the side walls, full depth;
//   C  the deck strips in front of / behind each lane and the 2c/1c separator.
// B and C run from below the bed to skin_thickness under the deck.  All pieces
// run out through the front and back faces; outer_skins() puts wall_thickness
// back at the back (and at the front unless front_open), following the side
// profile.  Closed pieces narrower than cavity_min_width stay solid.  The span
// across the split is not hollowed: it is the seam wall.
module cav_under_section(l, s) {   // A
    c  = s[0];
    ya = block_y0(s) - skin_thickness;
    yb = block_y1(s) + skin_thickness;
    if (lane_support)
        translate([lane_ext_l(l) - 0.01, ya, cav_bot])
            cube([lane_ext_r(l) - lane_ext_l(l) + 0.02, yb - ya, zbot(c) - skin_thickness - cav_bot]);
    else
        translate([0, yb, 0]) rotate([90, 0, 0]) linear_extrude(yb - ya)
            difference() {
                translate([lane_ext_l(l) - 0.01, cav_bot])
                    square([lane_ext_r(l) - lane_ext_l(l) + 0.02, cav_top - cav_bot]);
                for (o = [-1, 1]) translate([lane_x(l) + o * stag(c) / 2, 0])
                    offset(r = skin_thickness) pocket_profile(c);
            }
}

module cavity() {   // in the bed frame (bed_tf)
    for (l = [0 : n_lanes - 1]) for (s = sections(l)) cav_under_section(l, s);
    for (c = C_STRIPS) if (c_cut(c))   // C
        translate([lane_ext_l(c[0]) - 0.01, c[1] - 0.01, cav_bot])
            cube([lane_ext_r(c[0]) - lane_ext_l(c[0]) + 0.02, c[2] - c[1] + 0.02, cav_top - cav_bot]);
    for (b = B_SPANS) if (b[1] - b[0] >= cavity_min_width)   // B
        translate([b[0], cav_y0, cav_bot]) cube([b[1] - b[0], cav_y1 - cav_y0, cav_top - cav_bot]);
}

// The body's side profile (Y-Z) extended past the top and the bed, so that its
// inward offset only moves the front and back faces
function side_ext_pts() = concat([[0, tray_height + 50]],
    [for (i = [1 : len(front_pts()) - 2]) front_pts()[i]],
    [[fbv + 50, -50], [tray_depth, -50], [tray_depth, tray_height + 50]]);

module below_skin_top() {   // Y-Z: everything below skin_top(y)
    polygon([[-1, -60], [tray_depth + 1, -60],
             [tray_depth + 1, skin_top(tray_depth + 1)], [-1, skin_top(-1)]]);
}

module yz_extrude(x0, x1) {   // 2D (y, z) shape extruded along X from x0 to x1
    translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
}

// Back (and, unless front_open, front) skin: the side profile minus its inward
// offset, from the bed up into the deck slab, across the whole well
module outer_skins() {
    yz_extrude(well_x0 - 0.01, well_x1 + 0.01)
        intersection() {
            difference() {
                polygon(side_pts());
                offset(delta = -wall_thickness) polygon(side_ext_pts());
            }
            below_skin_top();
            translate([front_open ? tray_depth / 2 : -1, -60]) square([tray_depth + 2, 200]);
        }
}

// Lengthwise beams from beam_z up into the deck slab, across the whole well:
// the front one is the side profile (with the front bevel) from the front face
// back to beam_y1, the others are beam_width thick at BEAM_YS
module beams() {
    module band(y0, y1) polygon([[y0, beam_z], [y1, beam_z], [y1, skin_top(y1)], [y0, skin_top(y0)]]);
    yz_extrude(well_x0 - 0.01, well_x1 + 0.01) {
        if (front_beam) intersection() { polygon(side_pts()); band(-1, beam_y1); }
        for (y = BEAM_YS) band(y, y + beam_width);
    }
}

module body() {
    if (hollow) {
        difference() { shell(); bed_tf() cavity(); }
        outer_skins();
        beams();
    } else shell();
}

// =====================================================================
//  Whole tray (one piece, before splitting)
// =====================================================================
// Raised running count + tick at the back (top) left of every pocket
module count_marks() {   // vertical sides, top parallel to the tilted deck
    for (l = [0 : n_lanes - 1]) for (s = sections(l)) {
        c  = s[0];
        for (k = [0 : n_groups(c, s[2]) - 1]) {
            x1 = count_x1(l, c, k);   // zig-zags with the stacks
            // back face of the 5th coin (coins packed to the front of the pocket);
            // the tick ends exactly there and sits entirely beside its own stack
            ye = y_world(block_y0(s) + k * plen(c) + group_size * c_t(c));
            on_deck(-0.01, count_emboss + 0.01) {
                translate([x1 - count_tick_length, ye - count_line_width])
                    square([count_tick_length, count_line_width]);
                translate([x1 - count_tick_length / 2, ye - count_line_width - count_text_gap])
                    text(str(group_size * (k + 1)), size = count_size, font = label_font,
                         halign = "center", valign = "top", $fn = text_fn);
            }
        }
    }
}

module tray_full() {
    difference() {
        body();
        well_cutter();
        deck_edge_bevels();
        bed_tf() for (l = [0 : n_lanes - 1]) lane_cutter(l);   // tilted with the bed
        if (show_labels) { lane_labels(); separator_labels(); }
    }
    if (show_counts) count_marks();
}

// =====================================================================
//  Joint: glued seam walls with vertical dovetail keys
// =====================================================================
//  The span between the 50c and 20c lane skins is not hollowed out: it is the
//  seam wall of each half, and the two walls are glued face to face.  Each key
//  is a vertical prism on the left half's seam face, a dovetail in plan (neck
//  at the right half's face, wide tip inside it), so it locks X and Y.  The
//  right half's groove is the key grown by joint_clearance, open at the bottom
//  and closed by a short bridge at the top: the right half is lowered onto the
//  left half from above.
module key_2d(g = 0) { offset(delta = g) polygon(key_pts()); }

module key(y) {
    translate([joint_x, y, 0]) {
        translate([0, 0, key_relief]) linear_extrude(key_height - key_relief) key_2d();
        linear_extrude(key_relief + 0.01) key_2d(-key_relief);
    }
}

module key_groove(y) {
    translate([joint_x, y, -1]) {
        linear_extrude(1 + key_height + joint_clearance) key_2d(joint_clearance);
        linear_extrude(1 + key_relief + 0.2)   // elephant-foot relief at the opening
            key_2d(joint_clearance + key_relief);
    }
}

// Volume a key sweeps through the right half while that half is lowered onto
// it: in the right half's frame the key comes up from below the bed.
module key_path(y) {
    translate([joint_x, y, -50]) linear_extrude(50 + key_height) key_2d();
}

module grown_keys(g) {
    for (y = KEYS) translate([joint_x, y, 0]) linear_extrude(key_height + g) key_2d(g);
}

module seam_bottom_chamfer() {   // V-notch: chamfers the bottom edge of both seam faces
    h = seam_gap / 2 + bottom_chamfer;
    translate([0, tray_depth + 1, 0]) rotate([90, 0, 0]) linear_extrude(tray_depth + 2)
        polygon([[joint_x - h, -1], [joint_x + h, -1], [joint_x + h, 0],
                 [joint_x, h], [joint_x - h, 0]]);
}

module left_half() {
    difference() {
        intersection() {
            tray_full();
            translate([-1, -1, -1]) cube([joint_x - seam_gap / 2 + 1, tray_depth + 2, tray_height + 2]);
        }
        seam_bottom_chamfer();
    }
    for (y = KEYS) key(y);
}

module right_half() {
    difference() {
        intersection() {
            tray_full();
            translate([joint_x + seam_gap / 2, -1, -1])
                cube([tray_length, tray_depth + 2, tray_height + 2]);
        }
        seam_bottom_chamfer();
        for (y = KEYS) key_groove(y);
    }
}

// =====================================================================
//  Coins (for visualisation and fit checks)
// =====================================================================
COIN_COLORS = ["silver", "gold", "goldenrod", "goldenrod", "goldenrod",
               "chocolate", "chocolate", "chocolate"];

// partial = true fills only the first few pockets of each lane (for renders)
module coins(partial = false) { bed_tf() coins_local(partial = partial); }

module coins_local(lift = 0.05, partial = false) {
    for (l = [0 : n_lanes - 1]) let (P = pockets(l))
        for (i = [0 : len(P) - 1]) if (!partial || i < 3 + l % 3) {
            p   = P[i];
            c   = p[0];
            gap = 0.02;   // coins packed to the front of the pocket, as they rest
            for (j = [0 : group_size - 1])
                color(COIN_COLORS[c])
                translate([lane_x(l) + p[2], p[1] + gap + j * (c_t(c) + gap),
                           zbot(c) + c_d(c) / 2 + lift])
                    rotate([-90, 0, 0]) cylinder(d = c_d(c), h = c_t(c), $fn = 64);
        }
}

// =====================================================================
//  Report
// =====================================================================
module report() {
    echo(str("REPORT bed deck_angle=", deck_angle, " deck_back=", deck_z,
             " deck_front=", deck_w(well_y0), " deck_height_max=", deck_height_max,
             " min_floor=", min_floor));
    echo(str("REPORT deck_z=", deck_z, " deck_height_max=", deck_height_max,
             " gap_left=", gap_left,
             " gap_right=", gap_right, " jw_left=", jw_left, " jw_right=", jw_right,
             " lane_avail=", lane_avail));
    echo(str("REPORT labels label_y=", label_y, " strip=", label_strip,
             " label_h=", label_h, " label_w=", label_w, " lane_pitch_min=", lane_pitch_min,
             " separator=", [for (l = [0 : n_lanes - 1]) if (len(LANES[l]) > 1) sep_len(l)]));
    echo(str("REPORT joint keys=", KEYS, " slide=0 (lowered from above)",
             " seam_wall_left=", seam_wall_left, " seam_wall_right=", seam_wall_right,
             " groove_y=", [key_ymin, key_ymax],
             " bevel_gap_min=", min([for (l = [0 : n_lanes - 1]) bevel_gap(sections(l)[0])])));
    echo(str("REPORT cavity hollow=", hollow, " front_open=", front_open, " lane_support=", lane_support,
             " front_beam=", front_beam, " beam_bottom_z=", beam_z, " beam_depth=", deck_w(well_y0) - beam_z,
             " front_beam_back_y=", beam_y1, " beams=", n_beams, " pitch=", beam_p,
             " gap=", beam_p - beam_width, " beam_y=", BEAM_YS,
             " clear_under_cradles=", clear_under_cradles,
             " clear_between_lanes=", deck_w(well_y0) - skin_thickness / cos(deck_angle),
             " left_solid=", cavity_dropped));
    for (l = [0 : n_lanes - 1]) for (s = sections(l)) {
        c = s[0];
        n = n_groups(c, s[2]);
        echo(str("REPORT lane=", l, " coin=", COINS[c][0],
                 " d=", c_d(c), " t=", c_t(c),
                 " cradle_R=", R(c), " cradle_w=", 2 * R(c),
                 " pocket_len=", plen(c), " five_coins=", group_size * c_t(c),
                 " six_coins=", (group_size + 1) * c_t(c),
                 " stagger=", stag(c), " lane_w=", W[l],
                 " groups=", n, " capacity=", n * group_size,
                 " used_len=", n * plen(c), " section_len=", s[2],
                 " depth=", cdepth(c), " front_floor=", front_floor(s),
                 " top_coin=", deck_z + coin_rise(s),
                 " lane_x=", lane_x(l)));
    }
}

// =====================================================================
//  Output
// =====================================================================
report();

explode = 30;

if (part == "assembled")            { left_half(); right_half(); }
else if (part == "left")            left_half();
else if (part == "right")           right_half();
else if (part == "left_print")      left_half();
else if (part == "right_print")     translate([-(joint_x + seam_gap / 2), 0, 0]) right_half();
else if (part == "exploded")        { left_half(); translate([explode, 0, 0]) right_half(); }
else if (part == "assembly_start")  { left_half(); translate([0, 0, key_height + 5]) right_half(); }
else if (part == "coins")           coins();
else if (part == "coins_partial")   coins(partial = true);
else if (part == "assembled_coins") { left_half(); right_half(); coins(); }
else if (part == "fit_check")       intersection() { tray_full(); coins(); }
else if (part == "overlap_check")   intersection() { left_half(); right_half(); }
// Keys grown by 0.29 mm must not touch the right half; grown by 0.31 mm they must.
else if (part == "clearance_check_in")  intersection() { right_half(); grown_keys(joint_clearance - 0.01); }
else if (part == "clearance_check_out") intersection() { right_half(); grown_keys(joint_clearance + 0.01); }
// Lowering the right half onto the keys from above must be free.
else if (part == "path_check")          intersection() { right_half(); for (y = KEYS) key_path(y); }
