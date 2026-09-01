// ===================================================================
// Lazy Susan + Mirror Stand (combined)
//
// Merges lazy-susan.scad (the rotating 3-arm plate + its stationary
// base) with mirror_stand.scad (the leaning mirror stand) into one
// solid piece: the mirror stand's flat plate overlaps the lazy susan's
// stationary base disc all the way to the disc's center (the spinner
// axis), rather than just touching its edge. The disc stays a full
// circle underneath (so the small center post that the spinner's
// bearing insert mounts to stays solid, not cut in half) but the
// rectangle covers its entire back half, so in silhouette the fused
// base reads as a true Norman window -- a semicircle capping a
// rectangle, one continuous outline with no notch, gap, or seam.
//
// The spinner itself is otherwise untouched — same geometry as
// lazy-susan.scad, centered on the Z axis. Only the mirror stand's
// raised boss (the part tall enough to reach the spinner's rotation
// plane) is set back far enough that it sits mirror_clearance mm
// beyond the circle the spinner's arm tips sweep out, so the arms spin
// freely and just barely miss it. The thin flat plate itself can
// safely run right through the spinner's footprint because it's well
// below spinner height -- only the boss needs the clearance.
//
// A rotation-stop mechanism limits the spinner to exactly 180 degrees
// of travel: a tab hangs below the spinner's pointed (90-degree) arm,
// and two matching tabs rise from the base's floor, positioned so the
// spinner can swing only from the pointer aimed at the mirror to
// aimed directly away from it. See the "Rotation stop" parameter group
// and the spinner_stop_tab() / base_stop_tabs() modules for details.
//
// Preview mode picks which of the two parts to show (they print
// separately): the spinner plate, or the fused base + mirror stand.
//
// Axes: X/Y = footprint, Z = up, both parts sit on Z = 0. The spinner
// is centered on the origin; the mirror stand sits behind it along
// +X, centered on Y = 0, leaning back away from the spinner (its
// mirror faces toward -X, i.e. toward the spinner/viewer).
// ===================================================================

/* [Preview mode] */
show_spinner = true;  // true: show 3-arm spinner, false: show fused base + mirror stand

/* [Dimensions of the object (mm)] */
leg_diameter          = 3;    // must match leg_diameter in impossible.scad
foot_height           = 2;    // must match foot_height in impossible.scad
foot_width_90         = 7;    // must match foot_width_90 in impossible.scad
foot_diameter_others  = 7;    // must match foot_diameter_others in impossible.scad
object_width          = 110;  // must match width in impossible.scad; sets how far the groove arms reach

/* [Overall plate dimensions (mm)] */
box_height   = 8;    // Z: overall plate thickness
arm_length   = object_width / 2 + 1;   // center to rounded outer tip of each arm
arm_width    = 13;   // width of each arm (main shape tuning parameter)
hub_diameter = 30;   // central round hub joining the three arms

/* [Lazy susan base dimensions (mm)] */
base_height          = 3;
base_radius          = object_width / 3;
base_center_diameter = 10;
base_center_extra    = 1;    // center cylinder rises this much above base_height
base_top_extra       = 6.5;  // top post rises this much above center cylinder
base_top_radius      = 4.0;

/* [Top groove for the impossible-object feet] */
groove_clearance      = .5;    // groove is this much wider than the feet
groove_depth          = foot_height;  // groove depth matches the foot so it sits fully recessed
groove_length         = object_width / 2;  // length of each arm from the center

/* [Bottom insert pocket (mm)] */
insert_diameter       = 21.6;    // your round insert diameter
insert_clearance      = 0.2;   // small added diameter for snug fit
insert_pocket_depth   = 4;     // pocket depth from bottom face

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
// Extra gap, beyond the bare minimum, between the spinner arm tips'
// swept circle and the mirror stand's front edge.
mirror_clearance = 1.5;

/* [Rotation stop] */
// A tab hanging below the spinner's pointed (90-degree) arm, plus two
// matching tabs rising from the base, limit the spinner to exactly 180
// degrees of rotation: from the pointed arm aimed at the mirror to
// aimed directly away from it. All three tabs share the same radial
// span and width; see the Derived values / module comments below for
// how they're positioned to interlock.
stop_width = 2;   // mm, tangential width of each stop tab
stop_r_in  = 20;  // mm, inner radius of the stop tabs
stop_r_out = 30;  // mm, outer radius of the stop tabs
stop_drop  = 3;   // mm, how far the spinner's tab hangs below its bottom face
stop_rise  = 3;   // mm, how far the base's tabs rise above the floor

/* [Preview / debug helpers] */
show_top_groove = true;

plate_color = "DeepSkyBlue";
stand_color = "DeepSkyBlue";

$fn = 64;

// ===== Checks =====
assert(arm_width > max(leg_diameter, foot_width_90, foot_diameter_others) + groove_clearance,
    "arm_width must be wider than the widest groove arm");
assert(hub_diameter >= arm_width,
    "hub_diameter should be at least arm_width so the center blend stays smooth");
assert(groove_depth > 0 && groove_depth < box_height,
    "groove_depth must be greater than 0 and less than box_height");
assert(insert_pocket_depth > 0 && insert_pocket_depth < box_height,
    "insert_pocket_depth must be greater than 0 and less than box_height");
assert(base_height > 0 && base_radius > 0,
    "base_height and base_radius must be positive");
assert(base_center_diameter > 0 && base_top_radius > 0,
    "base_center_diameter and base_top_radius must be positive");
assert(groove_length + max(leg_diameter, foot_width_90, foot_diameter_others) / 2 + groove_clearance
        <= arm_length + arm_width / 2,
    "groove arms reach past the end of the plate arm; decrease groove_length/object_width or increase arm_length");
assert(groove_length > (foot_width_90 + groove_clearance) * sqrt(3) / 2,
    "groove_length is too short for the fish-eye tip on the 90-degree arm; increase groove_length/object_width or decrease foot_width_90/groove_clearance");
assert(mirror_clearance >= 0, "mirror_clearance must not be negative");
assert(stop_width > 0 && stop_width < arm_width,
    "stop_width must be positive and narrower than arm_width so the spinner's tab stays inside the pointed arm");
assert(stop_r_in > hub_diameter / 2 && stop_r_in < stop_r_out,
    "stop_r_in must be past the hub and less than stop_r_out");
assert(stop_r_out < arm_length && stop_r_out < base_radius,
    "stop_r_out must be less than both arm_length (so it stays on the spinner's arm) and base_radius (so the away-from-mirror base tab has a full disc under it)");
assert(stop_drop > 0 && stop_rise > 0, "stop_drop and stop_rise must be positive");

// ===== Derived values =====

// Radius of the circle swept by the spinner arms' rounded tips.
spinner_sweep_radius = arm_length + arm_width / 2;

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

// ===== Spinner geometry (unchanged from lazy-susan.scad) =====

// Rounded 2D arm using two equal circles so both ends are curved.
module arm_capsule_2d(l, w) {
    hull() {
        circle(d = w);
        translate([l, 0])
            circle(d = w);
    }
}

// Symmetric three-arm footprint with curved outer ends.
module three_arm_plate_2d(l, w, hub_d) {
    union() {
        circle(d = hub_d);
        for (a = [90, 210, 330])
            rotate([0, 0, a])
                arm_capsule_2d(l, w);
    }
}

// Straight-sided slot, width w, that the almond-shaped foot on the
// 90-degree leg can slide down into.
module fisheye_slot_2d(w, l) {
    tip_reach = w * sqrt(3) / 2;
    straight_end = l - tip_reach;
    union() {
        circle(d = w);
        polygon(points = [
            [0, -w / 2],
            [straight_end, -w / 2],
            [l, 0],
            [straight_end, w / 2],
            [0, w / 2],
        ]);
    }
}

// Y-shaped centering groove sunk into the top face.
module top_groove() {
    for (a = [90, 210, 330]) {
        gw = max(leg_diameter,
                 a == 90 ? foot_width_90 : foot_diameter_others)
             + groove_clearance;
        rotate([0, 0, a])
            linear_extrude(height = groove_depth + 1)
                if (a == 90)
                    fisheye_slot_2d(gw, groove_length);
                else
                    hull() {
                        circle(d = gw);
                        translate([groove_length, 0])
                            circle(d = gw);
                    }
    }
}

// Rotation-stop tab on the spinner: a rib centered on the pointed
// (90-degree) arm's centerline (the local +Y axis), running from
// stop_r_in to stop_r_out and hanging stop_drop mm below the spinner's
// flat bottom face (Z = 0). Meets the two stop tabs on the base (see
// base_stop_tabs() below) to limit the spinner to exactly 180 degrees
// of rotation. Printable without supports: the model's bottom face
// (Z = 0) is the face placed UP when printing groove-side-down per the
// notes at the end of this file, so this tab prints as a simple
// upward-facing rib, not an overhang.
module spinner_stop_tab() {
    translate([-stop_width / 2, stop_r_in, -stop_drop])
        cube([stop_width, stop_r_out - stop_r_in, stop_drop]);
}

module lazy_susan_plate() {
    union() {
        difference() {
            linear_extrude(height = box_height)
                three_arm_plate_2d(arm_length, arm_width, hub_diameter);

            // Round recess in the underside for a press-fit insert.
            translate([0, 0, -1])
                cylinder(d = insert_diameter + insert_clearance,
                         h = insert_pocket_depth + 1);

            if (show_top_groove)
                translate([0, 0, box_height - groove_depth])
                    top_groove();
        }
        spinner_stop_tab();
    }
}

module lazy_susan_base() {
    union() {
        cylinder(r = base_radius, h = base_height);
        cylinder(d = base_center_diameter, h = base_height + base_center_extra);
        translate([0, 0, base_height + base_center_extra])
            cylinder(r = base_top_radius, h = base_top_extra);
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

// ===== Mirror stand geometry (same as mirror_stand.scad; stand_width
// is now derived from base_radius, plate_thickness matches base_height,
// and the plate's front edge is square instead of rounded -- it sits
// buried inside the disc's front half rather than at a visible seam,
// but square keeps the overlap simple and fully solid) =====

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
        base_stop_tabs();
        translate([stand_origin_x, stand_origin_y, 0])
            mirror_stand();
    }
}

echo(str("Spinner: 3-arm, height ", box_height, " mm, sweep radius ", spinner_sweep_radius, " mm"));
echo(str("Top groove: ", groove_depth, " mm deep, arms ", groove_length, " mm long"));
echo(str("Bottom insert pocket: d=", insert_diameter + insert_clearance,
         " mm, depth=", insert_pocket_depth, " mm"));
echo(str("Lazy susan base: r=", base_radius, " mm, h=", base_height,
         " mm, center d=", base_center_diameter,
         " mm, top post r=", base_top_radius, " mm"));
echo(str("Mirror stand: base_depth=", base_depth, " mm, stand_width=", stand_width,
         " mm (matches lazy-susan base diameter), flat plate flush against the disc (no gap)"));
echo(str("Mirror stand boss (holds the mirror) sits at X=", stand_origin_x + boss_near_x,
         " mm from the spinner axis, ", mirror_clearance,
         " mm beyond the spinner's swept circle (radius ", spinner_sweep_radius, " mm)"));
echo(str("Rotation stop: tabs from r=", stop_r_in, " to r=", stop_r_out,
         " mm, ", stop_width, " mm wide -- limits the spinner to 180 degrees",
         " (pointer at the mirror to pointer away from it)"));

if (show_spinner)
    color(plate_color) lazy_susan_plate();
else
    color(stand_color) base_and_mirror_stand();

// ===================================================================
// Printing notes
// ===================================================================
// Two separate prints:
//   - show_spinner = true:  the 3-arm spinner plate. Print top (groove)
//     face DOWN on the build plate, same as before -- this also puts
//     the rotation-stop tab (which hangs below the bottom/Z=0 face)
//     pointing straight UP once flipped onto the bed, so it prints as
//     a simple upright rib with no overhang and needs no supports.
//   - show_spinner = false: the fused lazy-susan base + mirror stand.
//     Print flat side down (Z = 0); the two base stop tabs and the
//     mirror boss all rise from that same flat face, so this also
//     needs no supports.
// ===================================================================
