// ===================================================================
// Spinner (lazy susan rotating plate)
//
// The 3-arm rotating plate that sits on top of the base disc in
// mirror-spinner-stand.scad. Split out into its own file so the two
// halves -- this spinner and the stationary base + mirror stand --
// print (and are edited) independently.
//
// An optional tab hangs below the spinner's pointed (90-degree) arm
// and interlocks with two matching tabs on the base
// (mirror-spinner-stand.scad) to limit rotation to exactly 180
// degrees, from the pointer aimed at the mirror to aimed directly
// away from it. Toggle it with has_rotation_stop below; the
// corresponding half of the mechanism in mirror-spinner-stand.scad
// has its own independent toggle, so set both true for the stop to
// actually work.
//
// Several dimensions here (arm_length/arm_width via object_width,
// hub_diameter, and the rotation-stop parameters) must match the
// values baked into mirror-spinner-stand.scad's spinner_sweep_radius
// and stop tabs -- see the comments there.
//
// Axes: X/Y = footprint, Z = up, centered on the origin (the spinner
// axis), sitting on Z = 0.
// ===================================================================

/* [Dimensions of the object (mm)] */
leg_diameter          = 3;    // must match leg_diameter in impossible.scad
foot_height           = 2;    // must match foot_height in impossible.scad
foot_width_90         = 7;    // must match foot_width_90 in impossible.scad
foot_diameter_others  = 7;    // must match foot_diameter_others in impossible.scad
object_width          = 110;  // must match width in impossible.scad; sets how far the groove arms reach

/* [Overall plate dimensions (mm)] */
box_height   = 8;    // Z: overall plate thickness
arm_length   = object_width / 2 + 1;   // center to rounded outer tip of each arm; must match mirror-spinner-stand.scad's spinner_sweep_radius
arm_width    = 13;   // width of each arm (main shape tuning parameter); must match mirror-spinner-stand.scad's spinner_sweep_radius
hub_diameter = 30;   // central round hub joining the three arms

/* [Top groove for the impossible-object feet] */
groove_clearance      = .5;    // groove is this much wider than the feet
groove_depth          = foot_height;  // groove depth matches the foot so it sits fully recessed
groove_length         = object_width / 2;  // length of each arm from the center

/* [Bottom insert pocket (mm)] */
insert_diameter       = 21.6;    // your round insert diameter
insert_clearance      = 0.2;   // small added diameter for snug fit
insert_pocket_depth   = 4;     // pocket depth from bottom face

/* [Rotation stop] */
has_rotation_stop = true;  // adds the tab below the pointed arm that limits rotation to 180 degrees; must match mirror-spinner-stand.scad's base_stop_tabs for the stop to work
stop_width = 2;   // mm, tangential width of the stop tab; must match mirror-spinner-stand.scad
stop_r_in  = 20;  // mm, inner radius of the stop tab; must match mirror-spinner-stand.scad
stop_r_out = 30;  // mm, outer radius of the stop tab; must match mirror-spinner-stand.scad
stop_drop  = 3;   // mm, how far the tab hangs below the spinner's bottom face

/* [Preview / debug helpers] */
show_top_groove = true;

plate_color = "DeepSkyBlue";

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
assert(groove_length + max(leg_diameter, foot_width_90, foot_diameter_others) / 2 + groove_clearance
        <= arm_length + arm_width / 2,
    "groove arms reach past the end of the plate arm; decrease groove_length/object_width or increase arm_length");
assert(groove_length > (foot_width_90 + groove_clearance) * sqrt(3) / 2,
    "groove_length is too short for the fish-eye tip on the 90-degree arm; increase groove_length/object_width or decrease foot_width_90/groove_clearance");
assert(stop_width > 0 && stop_width < arm_width,
    "stop_width must be positive and narrower than arm_width so the spinner's tab stays inside the pointed arm");
assert(stop_r_in > hub_diameter / 2 && stop_r_in < stop_r_out,
    "stop_r_in must be past the hub and less than stop_r_out");
assert(stop_r_out < arm_length,
    "stop_r_out must be less than arm_length so it stays on the spinner's arm");
assert(stop_drop > 0, "stop_drop must be positive");

// ===== Derived values =====

// Radius of the circle swept by the spinner arms' rounded tips. Must
// match the spinner_sweep_radius baked into mirror-spinner-stand.scad.
spinner_sweep_radius = arm_length + arm_width / 2;

// ===== Spinner geometry =====

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
// mirror-spinner-stand.scad's base_stop_tabs()) to limit the spinner
// to exactly 180 degrees of rotation. Printable without supports: the
// model's bottom face (Z = 0) is the face placed UP when printing
// groove-side-down per the notes at the end of this file, so this tab
// prints as a simple upward-facing rib, not an overhang.
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
        if (has_rotation_stop)
            spinner_stop_tab();
    }
}

echo(str("Spinner: 3-arm, height ", box_height, " mm, sweep radius ", spinner_sweep_radius, " mm"));
echo(str("Top groove: ", groove_depth, " mm deep, arms ", groove_length, " mm long"));
echo(str("Bottom insert pocket: d=", insert_diameter + insert_clearance,
         " mm, depth=", insert_pocket_depth, " mm"));
echo(has_rotation_stop
    ? str("Rotation stop tab: r=", stop_r_in, " to ", stop_r_out,
          " mm, ", stop_width, " mm wide, drops ", stop_drop, " mm below the bottom face")
    : "Rotation stop tab: disabled");

color(plate_color) lazy_susan_plate();

// ===================================================================
// Printing notes
// ===================================================================
// Print top (groove) face DOWN on the build plate -- this also puts
// the rotation-stop tab (which hangs below the bottom/Z=0 face, if
// enabled) pointing straight UP once flipped onto the bed, so it
// prints as a simple upright rib with no overhang and needs no
// supports.
// ===================================================================
