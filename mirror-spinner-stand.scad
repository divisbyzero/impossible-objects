// ===================================================================
// Mirror + Spinner Stand (stationary base)
//
// The stationary half of the lazy-susan mirror stand: merges the
// lazy-susan base disc with the leaning mirror stand into one solid
// piece. The rotating 3-arm spinner that sits on top is a separate
// part -- see spinner.scad.
//
// The mirror stand's flat plate overlaps the lazy susan's stationary
// base disc all the way to the disc's center (the spinner axis),
// rather than just touching its edge. The disc stays a full circle
// underneath (so the small center post that the spinner's bearing
// insert mounts to stays solid, not cut in half) but the rectangle
// covers its entire back half, so in silhouette the fused base reads
// as a true Norman window -- a semicircle capping a rectangle, one
// continuous outline with no notch, gap, or seam.
//
// Only the raised boss (the part tall enough to reach the spinner's
// rotation plane) is set back far enough that it sits mirror_clearance
// mm beyond the circle the spinner's arm tips sweep out (spinner_
// sweep_radius below, which must match spinner.scad's own value), so
// the arms spin freely and just barely miss it. The thin flat plate
// itself can safely run right through the spinner's footprint because
// it's well below spinner height -- only the boss needs the clearance.
//
// An optional pair of tabs rises from the base's floor and interlocks
// with a matching tab on the underside of the spinner's pointed
// (90-degree) arm (see spinner.scad's spinner_stop_tab()) to limit the
// spinner to exactly 180 degrees of travel: from the pointer aimed at
// the mirror to aimed directly away from it. Toggle it with
// has_rotation_stop below; spinner.scad has its own independent
// toggle for its half of the mechanism, so set both true for the stop
// to actually work.
//
// Axes: X/Y = footprint, Z = up, sits on Z = 0. The base disc is
// centered on the origin (the spinner axis); the mirror stand sits
// behind it along +X, centered on Y = 0, leaning back away from the
// spinner (its mirror faces toward -X, i.e. toward the spinner).
// ===================================================================

/* [Lazy susan base dimensions (mm)] */
base_height          = 3;
base_radius          = 110 / 3;  // must match object_width / 3, where object_width matches spinner.scad
base_center_diameter = 10;
base_center_extra    = 1;    // center cylinder rises this much above base_height
base_top_extra       = 9;    // top post rises this much above center cylinder; must leave the spinner enough clearance above the tether dowel boss below (see the tether_clearance check)
base_top_radius      = 4.0;

/* [Mirror] */
mirror_base_depth = 6;   // front-to-back thickness of the mirror's plastic base

/* [Mirror lean] */
lean_angle = 86;          // desired angle of the mirror from horizontal (90 = vertical)
tilt = -(90 - lean_angle); // negative so the slot leans the mirror toward its front edge

/* [Mirror slot] */
eps = 0.3;                            // clearance so the mirror base slides in freely
slot_gap   = mirror_base_depth + eps; // front-to-back width of the slot
slot_depth = 10;                      // vertical depth of the (blind) slot

/* [Mirror stand base] */
// stand_width matches the lazy-susan base disc's diameter, and
// plate_thickness matches base_height, and front_apron is derived from
// the spinner clearance below (under Derived values) -- see there for
// why these aren't free parameters here.
back_apron      = 13;   // X: plate material behind the slot
floor_thickness = 3;    // solid material below the slot floor (within the boss)
boss_margin     = 5;    // X: extra boss material in front of and behind the slot

/* [Mirror stand corners] */
plate_corner_radius = 3;  // rounding radius of the plate's back two footprint corners
boss_corner_radius  = 3;  // rounding radius of the boss's footprint corners
corner_fn = 32;            // smoothness of the rounded corners

/* [Fit between spinner and mirror stand] */
// Radius of the circle swept by the spinner arms' rounded tips (arm_length
// + arm_width / 2 in spinner.scad); must match spinner.scad's
// spinner_sweep_radius.
spinner_sweep_radius = 62.5;
// Extra gap, beyond the bare minimum, between that swept circle and the
// mirror stand's front edge.
mirror_clearance = 1.5;

/* [Rotation stop] */
has_rotation_stop = true;  // adds the two tabs that limit spinner rotation to 180 degrees; must match spinner.scad's has_rotation_stop for the stop to work
// A tab hanging below the spinner's pointed (90-degree) arm, plus two
// matching tabs rising from the base, limit the spinner to exactly 180
// degrees of rotation: from the pointed arm aimed at the mirror to
// aimed directly away from it. All three tabs share the same radial
// span and width; see the Derived values / module comments below for
// how they're positioned to interlock.
stop_width = 2;   // mm, tangential width of each stop tab; must match spinner.scad
stop_r_in  = 20;  // mm, inner radius of the stop tabs; must match spinner.scad
stop_r_out = 30;  // mm, outer radius of the stop tabs; must match spinner.scad
stop_rise  = 3;   // mm, how far the base's tabs rise above the floor

/* [Tether dowel] */
// Adds a horizontal cylinder at the edge of the lazy-susan base disc,
// on the opposite side from the mirror, bored for a dowel that ties
// this stand to dowel-stand.scad at a fixed distance. Toggle it with
// has_tether_dowel below; dowel-stand.scad has its own independent
// toggle for its matching cylinder, so set both true to use the
// tether. The boss rests on the table (tangent at Z=0, like the base
// disc) so it stays low enough to pass underneath the spinner as it
// rotates through the away-from-mirror position -- see the
// tether_clearance check below, which keeps base_top_extra tall
// enough for the spinner to clear it.
has_tether_dowel = true;
dowel_diameter    = 6.5;  // actual diameter of the connecting dowel; must match dowel-stand.scad
hole_clearance    = 0;    // added to dowel_diameter for a snug press/slide fit; must match dowel-stand.scad
dowel_hole_depth  = 20;   // how deep the dowel is expected to sit in the hole; must match dowel-stand.scad
tether_diameter   = 10;   // mm, outer diameter of the horizontal boss, resting tangent to the table (Z=0) like the base disc; kept slim so it clears the spinner without needing a very tall base_top_extra
tether_length     = dowel_hole_depth + 1; // mm, how far the boss extends beyond the base disc's edge
tether_clearance  = 2;    // mm, minimum vertical gap kept between the top of the boss and the spinner's bottom face

/* [Preview / debug helpers] */
stand_color = "DeepSkyBlue";

$fn = 64;

// ===== Checks =====
assert(base_height > 0 && base_radius > 0,
    "base_height and base_radius must be positive");
assert(base_center_diameter > 0 && base_top_radius > 0,
    "base_center_diameter and base_top_radius must be positive");
assert(mirror_clearance >= 0, "mirror_clearance must not be negative");
assert(stop_width > 0, "stop_width must be positive");
assert(stop_r_in > 0 && stop_r_in < stop_r_out,
    "stop_r_in must be positive and less than stop_r_out");
assert(stop_r_out < base_radius,
    "stop_r_out must be less than base_radius so the away-from-mirror base tab has a full disc under it");
assert(stop_rise > 0, "stop_rise must be positive");
assert(tether_diameter > dowel_diameter + hole_clearance,
    "tether_diameter must be larger than the dowel hole diameter");
assert(tether_length > dowel_hole_depth,
    "tether_length should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(base_radius > tether_diameter / 2,
    "base_radius is too small for the tether cylinder to embed into the disc");
assert(!has_tether_dowel ||
    base_height + base_center_extra + base_top_extra
        >= tether_diameter + tether_clearance,
    "base_top_extra is too small for the spinner to clear the tether dowel boss; increase base_top_extra or decrease tether_diameter");

// ===== Derived values =====

dowel_hole_d = dowel_diameter + hole_clearance;
tether_embed = tether_diameter / 2; // how far the horizontal cylinder is buried into the base disc for a solid fused joint; also its resting height above the table, since it sits tangent to Z=0 like the base disc

// The mirror stand's width matches the lazy-susan base disc's diameter,
// so the stand reads as a continuation of the disc rather than a
// mismatched width.
stand_width = 2 * base_radius;

// The mirror plate is the same thickness as the lazy-susan base, so
// the two flat footprints fuse into one seamless "Norman window" shape
// (circle + rectangle, sharing one flat top face) with no bridge piece
// and no seam.
plate_thickness = base_height;

// Front-to-back footprint of the mirror stand's slot boss.
boss_depth = slot_gap + 2 * boss_margin;
boss_height = slot_depth + floor_thickness;        // Z: total height at the boss, from Z=0

// The mirror stand's local origin (X = 0, its front-left corner in
// mirror_stand.scad's own axes) sits at the spinner axis itself -- the
// rectangle's flat front edge passes right through the disc's center,
// covering the disc's whole front half. No cutting is needed: the disc
// stays a full circle underneath (so the center post / bearing mount
// stays solid and full-strength), and the union of full-circle disc +
// rectangle-through-the-center reads, in silhouette, as exactly a
// Norman window (semicircle capping a rectangle) -- the rectangle
// simply overlaps and covers where the disc's front half would show.
stand_origin_x = 0;
stand_origin_y = -stand_width / 2;

// Local-to-the-stand X position of the boss's near (front) edge: far
// enough from the world origin (spinner axis) that the boss clears the
// spinner's swept circle by mirror_clearance.
boss_near_x = spinner_sweep_radius + mirror_clearance - stand_origin_x;
slot_x      = boss_near_x + boss_margin + slot_gap / 2; // X: center of the slot, local to the stand

front_apron = slot_x - slot_gap / 2; // X: plate material in front of the slot, local to the stand
base_depth  = front_apron + slot_gap + back_apron; // X: total mirror-stand footprint depth

assert(boss_near_x >= 0,
    "mirror stand's boss would start before the disc's edge; increase mirror_clearance or base_radius, or decrease spinner_sweep_radius");

// ===== Lazy susan base geometry =====

module lazy_susan_base() {
    union() {
        cylinder(r = base_radius, h = base_height);
        cylinder(d = base_center_diameter, h = base_height + base_center_extra);
        translate([0, 0, base_height + base_center_extra])
            cylinder(r = base_top_radius, h = base_top_extra);
    }
}

// Horizontal cylinder resting on the table (tangent at Z=0, like the
// base disc itself), embedded into the disc's edge on the side
// opposite the mirror (-X) and bored with a hole (open at the outward
// tip) for a dowel. That dowel spans over to the matching cylinder on
// dowel-stand.scad, holding the two stands a fixed distance apart. Its
// top stays below the spinner's swept bottom face as it rotates
// through the away-from-mirror position -- see the tether_clearance
// check above.
module tether_post() {
    translate([-(base_radius - tether_embed), 0, tether_embed])
        rotate([0, -90, 0])
            difference() {
                cylinder(d = tether_diameter, h = tether_embed + tether_length);

                // dowel hole, open at the outward tip
                translate([0, 0, tether_embed + tether_length - dowel_hole_depth])
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth + 1);
            }
}

// Rotation-stop tabs on the base: two ribs, stop_rise mm tall, rising
// from the floor (Z = base_height). One sits just past the "toward
// mirror" radial line (+X, X from stop_r_in to stop_r_out) and the
// other just past the "away from mirror" line (-X, mirrored). Both are
// offset stop_width / 2 to the -Y side of their line (rather than
// centered on it): since the spinner's tab is centered on its own line
// when it's aimed exactly at (or away from) the mirror, offsetting the
// base tab by half the spinner tab's width means the two tabs' facing
// edges meet exactly at that moment, not before or after it. Both
// tabs use the same -Y offset -- not mirrored left/right -- because
// that is the side that blocks the spinner from swinging past either
// end of its 180-degree arc; see the geometry note below.
//
// Geometry: picture the spinner tab starting centered on the +X line
// (pointer aimed at the mirror), resting against the first base tab.
// Rotating the spinner counterclockwise lifts its tab away (+Y) from
// that base tab and sweeps it through the +Y half-plane; by the time
// it reaches the -X line (pointer aimed away from the mirror), the
// tab has swung back down to meet the second base tab from the same
// -Y side. So both stops sit on -Y, and the spinner is confined to the
// 180-degree arc between them.
module base_stop_tab(x0, x1) {
    translate([x0, -(stop_width / 2 + stop_width), base_height])
        cube([x1 - x0, stop_width, stop_rise]);
}

module base_stop_tabs() {
    union() {
        base_stop_tab(stop_r_in, stop_r_out);    // toward the mirror (+X)
        base_stop_tab(-stop_r_out, -stop_r_in);  // away from the mirror (-X)
    }
}

// ===== Mirror stand geometry (stand_width is derived from base_radius,
// plate_thickness matches base_height, and the plate's front edge is
// square instead of rounded -- it sits buried inside the disc's front
// half rather than at a visible seam, but square keeps the overlap
// simple and fully solid) =====

// A box with its footprint (XY) corners rounded, straight from Z=0 to h.
module rounded_box(x, y, h, r) {
    assert(r <= min(x, y) / 2, "rounded_box: corner radius too large for box footprint");
    hull() {
        for (i = [r, x - r], j = [r, y - r])
            translate([i, j, 0])
                cylinder(r = r, h = h, $fn = corner_fn);
    }
}

// Like rounded_box, but only the two corners at X = x (the far/back
// end) are rounded; the two corners at X = 0 stay square. Used for the
// mirror plate, whose front edge sits at the spinner axis, buried
// inside the lazy-susan disc's front half.
module back_rounded_box(x, y, h, r) {
    assert(r <= min(x, y) / 2, "back_rounded_box: corner radius too large for box footprint");
    hull() {
        cube([0.001, y, h]);
        for (j = [r, y - r])
            translate([x - r, j, 0])
                cylinder(r = r, h = h, $fn = corner_fn);
    }
}

module mirror_plate() {
    back_rounded_box(base_depth, stand_width, plate_thickness, plate_corner_radius);
}

module mirror_boss() {
    translate([slot_x - boss_depth / 2, 0, 0])
        rounded_box(boss_depth, stand_width, boss_height, boss_corner_radius);
}

module mirror_slot_cutter() {
    overcut   = 4;  // extra length so the cutter fully clears both sides of the stand
    top_pad   = 2;  // extra length so the cutter pokes above the top face for a clean cut
    cutter_len = slot_depth / cos(tilt) + top_pad;

    translate([slot_x, stand_width / 2, boss_height])
        rotate([0, tilt, 0])
            translate([-slot_gap / 2, -stand_width / 2 - overcut / 2, top_pad - cutter_len])
                cube([slot_gap, stand_width + overcut, cutter_len]);
}

module mirror_stand() {
    difference() {
        union() {
            mirror_plate();
            mirror_boss();
        }
        mirror_slot_cutter();
    }
}

// ===== Combined base: lazy susan base disc fused with the mirror
// stand's flat plate, overlapping all the way to the disc's center
// (no gap, no bridge). The disc stays a full circle for a solid center
// post, but the rectangle covers its back half, so the outline reads
// as a Norman window: rectangle capped by a semicircle. Only the
// raised boss, which actually reaches spinner height, is set back to
// clear the spinning arms. =====

module base_and_mirror_stand() {
    union() {
        lazy_susan_base();
        if (has_rotation_stop)
            base_stop_tabs();
        if (has_tether_dowel)
            tether_post();
        translate([stand_origin_x, stand_origin_y, 0])
            mirror_stand();
    }
}

echo(str("Lazy susan base: r=", base_radius, " mm, h=", base_height,
         " mm, center d=", base_center_diameter,
         " mm, top post r=", base_top_radius, " mm"));
echo(str("Mirror stand: base_depth=", base_depth, " mm, stand_width=", stand_width,
         " mm (matches lazy-susan base diameter), flat plate flush against the disc (no gap)"));
echo(str("Mirror stand boss (holds the mirror) sits at X=", stand_origin_x + boss_near_x,
         " mm from the spinner axis, ", mirror_clearance,
         " mm beyond the spinner's swept circle (radius ", spinner_sweep_radius, " mm)"));
echo(has_rotation_stop
    ? str("Rotation stop tabs: r=", stop_r_in, " to r=", stop_r_out,
          " mm, ", stop_width, " mm wide -- limits the spinner to 180 degrees",
          " (pointer at the mirror to pointer away from it)")
    : "Rotation stop tabs: disabled");
echo(has_tether_dowel
    ? str("Tether dowel cylinder: d=", tether_diameter, " mm, extends ", tether_length,
          " mm beyond the base disc's edge, away from the mirror")
    : "Tether dowel cylinder: disabled");

color(stand_color) base_and_mirror_stand();

// ===================================================================
// Printing notes
// ===================================================================
// Print flat side down (Z = 0); the two base stop tabs (if enabled),
// the tether dowel boss (if enabled), and the mirror boss all rise
// from that same flat face, so this needs no supports.
// ===================================================================
