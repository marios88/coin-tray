// =====================================================================
//  Euro coin counting tray v3  -  parametric, split in two for a Creality K1
// =====================================================================
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
//                Y = depth  (0 = front / cashier side .. 105 = back)
//                Z = up     (0 = bed .. 45)
//
//  The assembled tray occupies exactly [0,310] x [0,105] x [0,45].
//  It is split at x = 155 between the 50c and 20c lanes.  The halves are
//  joined by interlocking L-hooks standing on the bed under the coin deck:
//  two hooks of the right half reach into bridged pockets of the left half
//  and two hooks of the left half reach into the right half.  Each hook has
//  a claw that turns sideways behind a catch, so once engaged the halves
//  cannot pull apart (X) and neither half can move up or down relative to
//  the other (Z).
//
//  Assembly: set both halves on the table with the right half shifted
//  hook_slide (4.3 mm) towards the back, push them together, then slide the
//  right half forwards until it stops - the front and back faces line up.
//
//  Print: both halves upright, flat bottom on the bed, no supports.  Every
//  joint feature is a vertical prism; pocket ceilings are short bridges.
// =====================================================================

/* [Render selection] */
// assembled | left | right | left_print | right_print | exploded | coins
// | assembled_coins | fit_check | overlap_check | clearance_check_in
// | clearance_check_out | path_check | coins_partial
part = "assembled";

/* [Finished overall dimensions] */
tray_length   = 310;   // lip to lip, X
tray_depth    = 105;   // lip to lip, Y
tray_height   = 45;    // Z
lip_width     = 2.5;   // top flange overhang (inside the 310 x 105 envelope)
lip_thickness = 2.0;   // flange thickness; its underside is flat (straight drop)
lip_underside_chamfer = 0;  // optional 45 deg root chamfer under the lip (0 = sharp ledge)

/* [Structure] */
wall_thickness      = 2.4;  // perimeter walls below the lip
base_thickness      = 3.0;  // minimum floor under the deepest cradle
divider_thickness   = 2.4;  // minimum deck web between neighbouring lanes
deck_angle          = 3;   // tilt of the coin bed, rising towards the back (deg)
deck_height         = -1;   // deck Z at the BACK wall (highest point); -1 = auto = deck_height_max
// Highest usable deck_height (no coin rises above the rim), computed from the
// actual back pockets of every lane (last coin pushed to the end of its pocket):
//   deck_height_max = tray_height - max over lanes of
//       (coin_exposure * d - coin_clearance / 2) * cos(deck_angle)
//     + (end of last pocket - back wall) * sin(deck_angle)
//   = 33.76 mm with the defaults (limited by the 2 euro lane at 10 deg).
//   For a flat deck (deck_angle = 0) it is 45 - (0.5 * 25.75 - 0.25) = 32.375.
//   Echoed as REPORT deck_height_max and enforced by an assert.
corner_radius       = 6;    // plan-view radius of the outer (lip) corners
inner_corner_radius = 5;    // plan-view radius of the open well corners
well_fillet         = 3;    // cove where the deck meets the side walls (and its height at the back)
back_fillet         = 1.5;  // cove depth along the back wall (front wall: none, the
                            // tilt makes that corner obtuse and pockets reach it)
pocket_chamfer      = 1.2;  // 45 deg chamfer where pockets meet the deck (lane sides)
pocket_end_chamfer  = 0.4;  // smaller chamfer at pocket ends / zig-zag steps, leaves flat deck for the counts
rim_chamfer         = 0.8;  // inner top edge of the rim
lip_edge_chamfer    = 0.5;  // outer top edge of the lip
bottom_chamfer      = 0.6;  // bottom edges (elephant foot relief)

/* [Coin storage] */
coin_clearance  = 0.5;   // total diametral clearance of a cradle
stack_clearance = 0.8;   // extra length per pocket of 5 coins (v2: 1.0; 0.8 keeps
                         // 8 groups of 20c and 10 of 5c in the shorter tilted lanes)
front_clearance = 3;   // gap between the leaning front coins and the front wall
back_clearance  = 10;   // gap between the back pockets (deepest cradle point) and the back wall
group_size      = 5;     // coins per pocket
stagger_ratio   = 0.15;  // sideways offset between pockets, x coin diameter
coin_exposure   = 0.5;   // fraction of the coin diameter standing above the deck
separator_min   = 5;    // minimum deck between the 2c and 1c sections

/* [Joint] */
joint_x          = tray_length / 2;  // split plane
joint_clearance  = 0.3;  // clearance on every mating surface of the hooks
seam_gap         = joint_clearance;  // gap between the butt faces (split evenly,
                                      // so the external length stays 310)
joint_web_left   = 5.0;  // deck web between the 50c lane and the split plane
edge_margin_right = 3.0; // deck between the last lane and the right wall
hook_height      = 7.0;  // hooks stand on the bed, 0..hook_height
hook_reach       = 8.0;  // how far a hook reaches past the split plane
hook_arm_width   = 6.0;  // Y width of the arm that crosses the seam
hook_claw_depth  = 4.0;  // X thickness of the claw at the end of the arm
hook_claw_length = 4.0;  // how far the claw turns sideways (Y)
hook_slide       = hook_claw_length + joint_clearance;  // Y travel to engage
hook_relief      = 0.4;  // elephant-foot relief at the bed on hooks and pockets
// [y, type]: type 0 = on the right half, reaching into the left half, claw to
// the front; type 1 = on the left half, reaching into the right half, claw to
// the back.  Alternate them so both vertical directions are locked.
HOOKS = [[16, 0], [42, 1], [66, 0], [92, 1]];

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
label_size  = 8;     // "1c" label on the deck separator
back_label_size = 5.5; // back-wall labels (~5.4 mm tall) - must fit the band above the back deck
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

// Open well (inside of the perimeter wall)
well_x0 = lip_width + wall_thickness;
well_x1 = tray_length - well_x0;
well_y0 = lip_width + wall_thickness;
well_y1 = tray_depth - well_y0;
lane_avail = well_y1 - well_y0;

// Tilted coin bed.  All lane geometry is built flat in a local frame (deck at
// z = deck_z) and rotated by deck_angle about the line y = well_y1, z = deck_z.
max_cdepth = max([for (c = [0 : len(COINS) - 1]) cdepth(c)]);
// Local Y that maps to the front wall at deck level
deck_front_y = well_y1 - (well_y1 - well_y0) / cos(deck_angle);
// Per coin: first usable local Y (the forward-leaning coin top clears the
// front wall by front_clearance) and last usable local Y (the cradle bottom
// stays back_clearance inside the back wall).
function bed_front(c) = well_y1 - (well_y1 - well_y0 - front_clearance
                        - (coin_exposure * c_d(c) - coin_clearance / 2) * sin(deck_angle))
                        / cos(deck_angle);
function bed_back(c)  = well_y1 - back_clearance / cos(deck_angle)
                        - cdepth(c) * tan(deck_angle) - 0.05;

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

// Sections of a lane: [coin, y start, available length]
function sections(l) = len(LANES[l]) == 1
    ? let (c = LANES[l][0]) [[c, bed_front(c), bed_back(c) - bed_front(c)]]
    : let (cf = LANES[l][1], cb = LANES[l][0], y0 = bed_front(cf), y1 = bed_back(cb),
           sec = (y1 - y0 - separator_min) / 2)
      [[cf, y0, sec],                             // front section (1c)
       [cb, y1 - sec, sec]];                      // back section  (2c)

function n_groups(c, len) = floor(len / plen(c));
function block_y0(c, ys, len) = ys + (len - n_groups(c, len) * plen(c)) / 2;

// Pockets of a lane: [coin, y0, x offset from lane centre]
function pockets(l) = [
    for (s = sections(l))
        for (k = [0 : n_groups(s[0], s[2]) - 1])
            [s[0],
             block_y0(s[0], s[1], s[2]) + k * plen(s[0]),
             (k % 2 == 0 ? -1 : 1) * stag(s[0]) / 2]
];

// Height of the highest coin point of a section above the back-wall deck
// height (worst case: last coin pushed to the end of its pocket).
function coin_rise(s) =
    let (c = s[0], yend = block_y0(c, s[1], s[2]) + n_groups(c, s[2]) * plen(c))
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
function front_floor(s) = let (c = s[0], y = block_y0(c, s[1], s[2]))
    deck_z + (y - well_y1) * sin(deck_angle) - cdepth(c) * cos(deck_angle);
min_floor = min([for (l = [0 : n_lanes - 1]) for (s = sections(l)) front_floor(s)]);

// Half width of a (tilted) cradle at world height z and world depth y: the
// vertical section of the tilted cylinder is an ellipse.
function cradle_hw_w(c, y, z) =
    let (za = deck_w(y) + (zc(c) - deck_z) / cos(deck_angle),
         q  = R(c) ^ 2 - (cos(deck_angle) * (za - z)) ^ 2)
    z >= za ? R(c) : q <= 0 ? 0 : sqrt(q);

// Joint hooks.  Rectangles [x0, x1, y0, y1] relative to (joint_x, hook y).
hook_e = seam_gap / 2 + 1;   // part of the arm buried in its own half
function hook_rects(t) = t == 0
    ? [[-hook_reach, hook_e, 0, hook_arm_width],
       [-hook_reach, -hook_reach + hook_claw_depth, -hook_claw_length, 0]]
    : [[-hook_e, hook_reach, -hook_arm_width, 0],
       [hook_reach - hook_claw_depth, hook_reach, 0, hook_claw_length]];
// Y offset of a hook (relative to the receiving half) before the engaging slide
function hook_start(t) = (t == 0 ? 1 : -1) * hook_slide;
// Hook rectangles swept over the engaging slide
function hook_swept(t) = let (d = hook_start(t))
    [for (r = hook_rects(t)) [r[0], r[1], r[2] + min(0, d), r[3] + max(0, d)]];

// wall left between a hook pocket and the neighbouring cradle, checked at the
// front end of each pocket where the tilted deck (and cradle) is lowest
hook_ztop = hook_height + joint_clearance;
c_jl = LANES[n_left - 1][0];
c_jr = LANES[n_left][0];
function hook_y_min(h) = h[0] + min([for (r = hook_swept(h[1])) r[2]]) - joint_clearance;
function hook_y_max(h) = h[0] + max([for (r = hook_swept(h[1])) r[3]]) + joint_clearance;
function hook_wall(h) = h[1] == 0
    ? (joint_x - hook_reach - joint_clearance)
      - (lane_x(n_left - 1) + W[n_left - 1] / 2 - R(c_jl) + cradle_hw_w(c_jl, hook_y_min(h), hook_ztop))
    : (lane_x(n_left) - W[n_left] / 2 + R(c_jr) - cradle_hw_w(c_jr, hook_y_min(h), hook_ztop))
      - (joint_x + hook_reach + joint_clearance);
hook_wall_left  = min([for (h = HOOKS) if (h[1] == 0) hook_wall(h)]);
hook_wall_right = min([for (h = HOOKS) if (h[1] == 1) hook_wall(h)]);

// =====================================================================
//  Sanity checks
// =====================================================================
assert(deck_z <= deck_height_max + 1e-9, "coins would rise above the rim");
assert(min_floor >= base_thickness,
       "deck too low / too steep for base_thickness under the front cradles");
assert(hook_wall_left  >= wall_thickness, "hook pocket too close to the 50c cradle");
assert(hook_wall_right >= wall_thickness, "hook pocket too close to the 20c cradle");
assert(hook_ztop + wall_thickness <= deck_w(well_y0), "hooks too tall for the deck");
assert(min([for (h = HOOKS) hook_y_min(h)]) >= lip_width + wall_thickness, "hook too close to the front");
assert(max([for (h = HOOKS) hook_y_max(h)]) <= tray_depth - lip_width - wall_thickness, "hook too close to the back");
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
assert(back_label_size * 1.0 + 1 <= tray_height - rim_chamfer - deck_z - well_fillet,
       "back_label_size too big for the wall band above the back deck");
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

module well_outline(inset) {
    rrect(well_x0 + inset, well_y0 + inset, well_x1 - inset, well_y1 - inset,
          inner_corner_radius - inset);
}

module slab(z, h = 0.01) { translate([0, 0, z]) linear_extrude(h) children(); }

// =====================================================================
//  Body
// =====================================================================
module shell() {
    z_lip = tray_height - lip_thickness;   // flat underside of the lip
    hull() {   // body: walls straight down, lip_width inside the outer edge
        slab(0)                  outer_outline(lip_width + bottom_chamfer);
        slab(bottom_chamfer)     outer_outline(lip_width);
        slab(tray_height - 0.01) outer_outline(lip_width);
    }
    hull() {   // lip flange
        slab(z_lip)                          outer_outline(0);
        slab(tray_height - lip_edge_chamfer) outer_outline(0);
        slab(tray_height - 0.01)             outer_outline(lip_edge_chamfer);
    }
    if (lip_underside_chamfer > 0) hull() {
        slab(z_lip - lip_underside_chamfer) outer_outline(lip_width);
        slab(z_lip)                         outer_outline(lip_width - lip_underside_chamfer);
    }
}

// Lane cutters reach this far above the deck (local), so their tops never sit
// on the deck surface - keeps the F5 preview free of flickering "lids"
cut_above_deck = 2;

// Vertical extrusion of a world-plan 2D shape whose bottom and top follow the
// tilted deck (sheared): z from deck + z0 to deck + z0 + h, walls vertical.
module on_deck(z0, h) {
    multmatrix([[1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, tan(deck_angle), 1, deck_z - well_y1 * tan(deck_angle) + z0],
                [0, 0, 0, 1]])
        linear_extrude(h) children();
}
// Thin slab lying on the tilted deck plane, raised h above it (plan exact)
module deck_slice(h) { on_deck(h, 0.01) children(); }

// World Y of a point on the deck given in the local (flat) bed frame
function y_world(yl) = well_y1 + (yl - well_y1) * cos(deck_angle);

// Open well above the tilted deck.  It is convex, so it is one hull of slices
// (coves at the side and back walls) - no intersections, which keeps the F5
// preview exact.
module well_cutter() {
    steps = 8;
    hull() {
        for (i = [0 : steps]) {
            a = 90 * i / steps;
            deck_slice(well_fillet * (1 - cos(a)))
                rrect(well_x0 + well_fillet * (1 - sin(a)), well_y0,
                      well_x1 - well_fillet * (1 - sin(a)), well_y1 - back_fillet * (1 - sin(a)),
                      inner_corner_radius - well_fillet * (1 - sin(a)));
        }
        slab(tray_height - rim_chamfer) well_outline(0);
    }
    hull() {   // chamfer on the inner top edge of the rim
        slab(tray_height - rim_chamfer) well_outline(0);
        slab(tray_height, 1) well_outline(-rim_chamfer);
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
    // stepped 45 deg chamfer around the pocket edges (incl. the zig-zag steps)
    // (clipped in the local frame so the tilted chamfer never reaches a wall)
    steps = 4;
    for (i = [1 : steps])
        slab(deck_z - pocket_chamfer * (1 - (i - 1) / steps),
             pocket_chamfer * (1 - (i - 1) / steps) + cut_above_deck)
            intersection() {
                lane_outline_grown(l, pocket_chamfer * i / steps, pocket_end_chamfer * i / steps);
                translate([well_x0, deck_front_y + cut_above_deck * tan(deck_angle) + 0.05])
                    square([well_x1 - well_x0,
                            well_y1 - (back_fillet + 0.05) / cos(deck_angle)        // stop at the back cove
                            - deck_front_y - cut_above_deck * tan(deck_angle) - 0.05]);
            }
}

// =====================================================================
//  Labels
// =====================================================================
function sep_center_y(l) =
    let (s = sections(l), f = s[0], b = s[1],
         f_end   = block_y0(f[0], f[1], f[2]) + n_groups(f[0], f[2]) * plen(f[0]),
         b_start = block_y0(b[0], b[1], b[2]))
    (f_end + b_start) / 2;

module label_text(s) {
    text(s, size = label_size, font = label_font, halign = "center", valign = "center", $fn = text_fn);
}

// Back-wall labels sit centred in the free band between the cove on top of the
// back deck and the rim chamfer.
back_label_z = (deck_z + well_fillet + tray_height - rim_chamfer) / 2;

// Deboss into a vertical wall with 45 deg stepped tops, so the glyph recesses
// support themselves when printed (no flat 0.6 mm ceilings)
module wall_deboss(depth, steps = 4) {
    for (k = [0 : steps - 1])
        translate([0, depth - k * depth / steps, 0]) rotate([90, 0, 0])
            linear_extrude(depth / steps + (k == 0 ? 0.01 : 0) + 0.001)
                offset(delta = -k * depth / steps) children();
}

module back_labels() {   // inside of the back wall, above each lane, facing the cashier
    for (l = [0 : n_lanes - 1])
        translate([lane_x(l), well_y1, back_label_z])
            wall_deboss(label_depth)
                text(COINS[LANES[l][0]][0], size = back_label_size, font = label_font,
                     halign = "center", valign = "center", $fn = text_fn);
}

module separator_labels() {   // front section of the shared lane, on the deck separator
    for (l = [0 : n_lanes - 1]) if (len(LANES[l]) > 1)
        on_deck(-label_depth, label_depth + 1)
            translate([lane_x(l), y_world(sep_center_y(l))]) label_text(COINS[LANES[l][1]][0]);
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
            ye = y_world(block_y0(c, s[1], s[2]) + k * plen(c) + group_size * c_t(c));
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
        shell();
        well_cutter();
        bed_tf() for (l = [0 : n_lanes - 1]) lane_cutter(l);   // tilted with the bed
        if (show_labels) { back_labels(); separator_labels(); }
    }
    if (show_counts) count_marks();
}

// =====================================================================
//  Joint: interlocking L-hooks on the bed
// =====================================================================
//  Each hook is a vertical prism (plan view: an arm that crosses the seam
//  plus a claw that turns sideways).  The receiving half has a pocket that
//  is open at the bed and at the seam face; it is the hook swept over the
//  engaging slide, grown by joint_clearance.  The pocket ceiling is a short
//  bridge, the claw ends up behind a solid catch, so the halves are locked
//  in X and in both Z directions.
module rects2d(rs) {
    for (r = rs) translate([r[0], r[2]]) square([r[1] - r[0], r[3] - r[2]]);
}

module hook(h) {   // h = [y, type]
    translate([joint_x, h[0], 0]) {
        translate([0, 0, hook_relief])
            linear_extrude(hook_height - hook_relief) rects2d(hook_rects(h[1]));
        linear_extrude(hook_relief + 0.01)
            offset(delta = -hook_relief) rects2d(hook_rects(h[1]));
    }
}

module hook_pocket(h) {
    translate([joint_x, h[0], -1]) {
        linear_extrude(1 + hook_height + joint_clearance)
            offset(delta = joint_clearance) rects2d(hook_swept(h[1]));
        linear_extrude(1 + hook_relief + 0.2)   // elephant-foot relief at the opening
            offset(delta = joint_clearance + hook_relief) rects2d(hook_swept(h[1]));
    }
}

// Volume a hook passes through while assembling: pushed in along X at the
// start offset, then slid along Y into place (each rectangle swept separately).
module hook_path(h) {
    t  = h[1];
    dy = hook_start(t);
    dx = (t == 0 ? 1 : -1) * 40;
    module box(r, ox, oy)
        translate([joint_x + r[0] + ox, h[0] + r[2] + oy, 0])
            cube([r[1] - r[0], r[3] - r[2], hook_height]);
    for (r = hook_rects(t)) {
        hull() { box(r, dx, dy); box(r, 0, dy); }
        hull() { box(r, 0, dy); box(r, 0, 0); }
    }
}

module grown_hooks(t, g) {
    for (h = HOOKS) if (h[1] == t)
        translate([joint_x, h[0], 0])
            linear_extrude(hook_height + g) offset(delta = g) rects2d(hook_rects(t));
}

module seam_bottom_chamfer() {   // V-notch: chamfers the bottom edge of both butt faces
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
        for (h = HOOKS) if (h[1] == 0) hook_pocket(h);
    }
    for (h = HOOKS) if (h[1] == 1) hook(h);
}

module right_half() {
    difference() {
        intersection() {
            tray_full();
            translate([joint_x + seam_gap / 2, -1, -1])
                cube([tray_length, tray_depth + 2, tray_height + 2]);
        }
        seam_bottom_chamfer();
        for (h = HOOKS) if (h[1] == 1) hook_pocket(h);
    }
    for (h = HOOKS) if (h[1] == 0) hook(h);
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
    echo(str("REPORT joint hooks=", HOOKS, " slide=", hook_slide,
             " wall_to_50c=", hook_wall_left, " wall_to_20c=", hook_wall_right,
             " pocket_y=", [for (h = HOOKS) [hook_y_min(h), hook_y_max(h)]]));
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
else if (part == "right_print")     translate([-(joint_x - hook_reach), 0, 0]) right_half();
else if (part == "exploded")        { left_half(); translate([explode, hook_slide, 0]) right_half(); }
else if (part == "assembly_start")  { left_half(); translate([0, hook_slide, 0]) right_half(); }
else if (part == "coins")           coins();
else if (part == "coins_partial")   coins(partial = true);
else if (part == "assembled_coins") { left_half(); right_half(); coins(); }
else if (part == "fit_check")       intersection() { tray_full(); coins(); }
else if (part == "overlap_check")   intersection() { left_half(); right_half(); }
// Hooks grown by 0.29 mm must not touch the other half; grown by 0.31 mm they must.
else if (part == "clearance_check_in") {
    intersection() { left_half();  grown_hooks(0, joint_clearance - 0.01); }
    intersection() { right_half(); grown_hooks(1, joint_clearance - 0.01); }
}
else if (part == "clearance_check_out") {
    intersection() { left_half();  grown_hooks(0, joint_clearance + 0.01); }
    intersection() { right_half(); grown_hooks(1, joint_clearance + 0.01); }
}
// The whole push-then-slide assembly path must be free.
else if (part == "path_check") {
    intersection() { left_half();  for (h = HOOKS) if (h[1] == 0) hook_path(h); }
    intersection() { right_half(); for (h = HOOKS) if (h[1] == 1) hook_path(h); }
}
