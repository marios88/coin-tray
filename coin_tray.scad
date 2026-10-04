// =====================================================================
//  Euro coin counting tray  -  parametric, split in two for a Creality K1
// =====================================================================
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
// | clearance_check_out | path_check
part = "assembled";

/* [Finished overall dimensions] */
tray_length   = 310;   // lip to lip, X
tray_depth    = 105;   // lip to lip, Y
tray_height   = 45;    // Z
lip_width     = 2.5;   // top flange overhang (inside the 310 x 105 envelope)
lip_thickness = 2.0;   // flat part of the flange; a 45 deg chamfer sits below it

/* [Structure] */
wall_thickness      = 2.4;  // perimeter walls below the lip
base_thickness      = 3.0;  // minimum floor under the deepest cradle
divider_thickness   = 2.4;  // minimum deck web between neighbouring lanes
deck_height         = 18;   // Z of the flat coin deck (cradles are cut into it)
corner_radius       = 6;    // plan-view radius of the outer (lip) corners
inner_corner_radius = 5;    // plan-view radius of the open well corners
well_fillet         = 3;    // cove radius where the deck meets the walls
pocket_chamfer      = 1.2;  // 45 deg chamfer where pockets meet the deck
rim_chamfer         = 0.8;  // inner top edge of the rim
lip_edge_chamfer    = 0.5;  // outer top edge of the lip
bottom_chamfer      = 0.6;  // bottom edges (elephant foot relief)

/* [Coin storage] */
coin_clearance  = 0.5;   // total diametral clearance of a cradle
stack_clearance = 1.0;   // extra length per pocket of 5 coins
group_size      = 5;     // coins per pocket
stagger_ratio   = 0.35;  // sideways offset between pockets, x coin diameter
coin_exposure   = 0.5;   // fraction of the coin diameter standing above the deck
separator_min   = 12;    // minimum deck between the 2c and 1c sections

/* [Joint] */
joint_x          = tray_length / 2;  // split plane
joint_clearance  = 0.3;  // clearance on every mating surface of the hooks
seam_gap         = joint_clearance;  // gap between the butt faces (split evenly,
                                      // so the external length stays 310)
joint_web_left   = 9.05; // deck web between the 50c lane and the split plane
joint_web_right  = 3.75; // deck web between the split plane and the 20c lane
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
HOOKS = [[12, 0], [40, 1], [62, 0], [92, 1]];

/* [Labels] */
show_labels = true;
label_font  = "Liberation Sans:style=Bold";
label_size  = 8;     // ~5.8 mm cap height, ~1.1 mm strokes
label_depth = 0.6;   // deboss depth
label_z     = 36;    // label centre height on the back wall

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
function zbot(c)    = deck_height - cdepth(c);                    // cradle bottom
function zc(c)      = zbot(c) + R(c);                             // cradle axis
function lane_w(l)  = max([for (c = LANES[l]) 2 * R(c) + stag(c)]);

function sumv(v, n) = n <= 0 ? 0 : v[n - 1] + sumv(v, n - 1);

// Open well (inside of the perimeter wall)
well_x0 = lip_width + wall_thickness;
well_x1 = tray_length - well_x0;
well_y0 = lip_width + wall_thickness;
well_y1 = tray_depth - well_y0;
lane_avail = well_y1 - well_y0;

// Lane placement: fixed webs either side of the joint, remaining width is
// shared evenly within each half.
W        = [for (l = [0 : n_lanes - 1]) lane_w(l)];
jw_left  = joint_web_left;
jw_right = joint_web_right;
gap_left  = (joint_x - well_x0 - jw_left - sumv(W, n_left)) / n_left;
gap_right = (well_x1 - joint_x - jw_right - (sumv(W, n_lanes) - sumv(W, n_left)))
            / (n_lanes - n_left);

function lane_x(l) = l < n_left
    ? well_x0 + (l + 1) * gap_left + sumv(W, l) + W[l] / 2
    : joint_x + jw_right + (l - n_left) * gap_right
      + (sumv(W, l) - sumv(W, n_left)) + W[l] / 2;

// Sections of a lane: [coin, y start, available length]
function sections(l) = len(LANES[l]) == 1
    ? [[LANES[l][0], well_y0, lane_avail]]
    : let (sec = (lane_avail - separator_min) / 2)
      [[LANES[l][1], well_y0, sec],               // front section (1c)
       [LANES[l][0], well_y1 - sec, sec]];        // back section  (2c)

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

max_cdepth = max([for (c = [0 : len(COINS) - 1]) cdepth(c)]);

// Half width of a cradle at height z
function cradle_hw(c, z) = z <= zbot(c) ? 0 : z >= zc(c) ? R(c) : sqrt(R(c) ^ 2 - (zc(c) - z) ^ 2);

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

// wall left between a hook pocket and the neighbouring cradle
hook_ztop = hook_height + joint_clearance;
c_jl = LANES[n_left - 1][0];
c_jr = LANES[n_left][0];
hook_wall_left  = (joint_x - hook_reach - joint_clearance)
                - (lane_x(n_left - 1) + W[n_left - 1] / 2 - R(c_jl) + cradle_hw(c_jl, hook_ztop));
hook_wall_right = (lane_x(n_left) - W[n_left] / 2 + R(c_jr) - cradle_hw(c_jr, hook_ztop))
                - (joint_x + hook_reach + joint_clearance);

// =====================================================================
//  Sanity checks
// =====================================================================
assert(deck_height - max_cdepth >= base_thickness,
       "deck_height too low for base_thickness under the deepest cradle");
assert(hook_wall_left  >= wall_thickness, "hook pocket too close to the 50c cradle");
assert(hook_wall_right >= wall_thickness, "hook pocket too close to the 20c cradle");
assert(hook_ztop + wall_thickness <= deck_height, "hooks too tall for the deck");
function hook_y_min(h) = h[0] + min([for (r = hook_swept(h[1])) r[2]]) - joint_clearance;
function hook_y_max(h) = h[0] + max([for (r = hook_swept(h[1])) r[3]]) + joint_clearance;
assert(min([for (h = HOOKS) hook_y_min(h)]) >= lip_width + wall_thickness, "hook too close to the front");
assert(max([for (h = HOOKS) hook_y_max(h)]) <= tray_depth - lip_width - wall_thickness, "hook too close to the back");
assert(gap_left  >= divider_thickness + 2 * pocket_chamfer, "left lanes too crowded");
assert(gap_right >= divider_thickness + 2 * pocket_chamfer, "right lanes too crowded");
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
    z_lip0 = tray_height - lip_thickness - lip_width;   // start of the 45 deg lip chamfer
    hull() {
        slab(0)                                   outer_outline(lip_width + bottom_chamfer);
        slab(bottom_chamfer)                      outer_outline(lip_width);
        slab(z_lip0)                              outer_outline(lip_width);
        slab(tray_height - lip_thickness)         outer_outline(0);
        slab(tray_height - lip_edge_chamfer)      outer_outline(0);
        slab(tray_height - 0.01)                  outer_outline(lip_edge_chamfer);
    }
}

module well_cutter() {
    steps = 8;
    hull() {   // cove fillet at the deck, then straight walls
        for (i = [0 : steps]) {
            a = 90 * i / steps;
            slab(deck_height + well_fillet * (1 - cos(a)))
                well_outline(well_fillet * (1 - sin(a)));
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
module pocket_profile(c) {   // X-Z cross-section: round cradle + open top
    translate([0, zc(c)]) circle(r = R(c));
    translate([-R(c), zc(c)]) square([2 * R(c), tray_height + 2 - zc(c)]);
}

module pocket(l, p) {
    c = p[0];
    translate([lane_x(l) + p[2], p[1] + plen(c), 0])
        rotate([90, 0, 0]) linear_extrude(plen(c)) pocket_profile(c);
}

module lane_outline(l) {     // zig-zag footprint of a lane at deck level
    for (p = pockets(l))
        translate([lane_x(l) + p[2] - R(p[0]), p[1]]) square([2 * R(p[0]), plen(p[0])]);
}

module lane_cutter(l) {
    for (p = pockets(l)) pocket(l, p);
    // stepped 45 deg chamfer around the pocket edges (incl. the zig-zag steps)
    steps = 4;
    for (i = [1 : steps])
        slab(deck_height - pocket_chamfer * (1 - (i - 1) / steps),
             pocket_chamfer * (1 - (i - 1) / steps) + well_fillet + 1)
            intersection() {
                offset(r = pocket_chamfer * i / steps) lane_outline(l);
                well_outline(0);
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
    text(s, size = label_size, font = label_font, halign = "center", valign = "center");
}

module labels() {
    // on the inside of the back wall, above each lane, facing the cashier
    for (l = [0 : n_lanes - 1])
        translate([lane_x(l), well_y1 + label_depth, label_z])
            rotate([90, 0, 0]) linear_extrude(label_depth + 0.01) label_text(COINS[LANES[l][0]][0]);
    // front section of the shared lane: on the deck separator, right behind it
    for (l = [0 : n_lanes - 1]) if (len(LANES[l]) > 1)
        translate([lane_x(l), sep_center_y(l), deck_height - label_depth])
            linear_extrude(label_depth + 1) label_text(COINS[LANES[l][1]][0]);
}

// =====================================================================
//  Whole tray (one piece, before splitting)
// =====================================================================
module tray_full() {
    difference() {
        shell();
        well_cutter();
        for (l = [0 : n_lanes - 1]) lane_cutter(l);
        if (show_labels) labels();
    }
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

module coins(lift = 0.05) {
    for (l = [0 : n_lanes - 1]) for (p = pockets(l)) {
        c   = p[0];
        gap = (plen(c) - group_size * c_t(c)) / (group_size + 1);
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
    echo(str("REPORT deck_height=", deck_height, " gap_left=", gap_left,
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
                 " depth=", cdepth(c), " floor=", zbot(c),
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
