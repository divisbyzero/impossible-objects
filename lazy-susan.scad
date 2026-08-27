// ===================================================================
// Lazy Susan Mount Plate
//
// A symmetric 3-arm plate that sits on top of a lazy susan bearing
// mechanism and gives an impossible object (from impossible.scad)
// somewhere to seat.
//
//   - The bottom face is flat.
//   - The top face has a 2 mm deep Y-shaped groove, sized for the
//     current impossible-object feet (same geometry as the groove in
//     viewing_box.scad), which centers and orients the object.
//
// Axes: X/Y = plate footprint, Z = up. Bottom face sits at Z = 0;
// the top face is at Z = box_height.
//
// Print orientation: see the notes at the end of this file. The short
// version — print with the top (groove) face DOWN on the build
// plate. That gives the smoothest possible top surface (a mirror of
// the bed) with zero supports.
// ===================================================================

/* [Dimensions of the object (mm)] */
leg_diameter          = 3;    // must match leg_diameter in impossible.scad
foot_height           = 2;    // must match foot_height in impossible.scad
foot_width_90         = 7;    // must match foot_width_90 in impossible.scad
foot_diameter_others  = 7;    // must match foot_diameter_others in impossible.scad
object_width          = 110;  // must match width in impossible.scad; sets how far the groove arms reach

/* [Preview mode] */
show_spinner          = true;  // true: show 3-arm spinner, false: show base

/* [Overall plate dimensions (mm)] */
box_height   = 8;    // Z: overall plate thickness
arm_length   = object_width / 2+1;   // center to rounded outer tip of each arm
arm_width    = 13;   // width of each arm (main shape tuning parameter)
hub_diameter = 30;   // central round hub joining the three arms

/* [Base dimensions (mm)] */
base_height          = 3;
base_radius          = object_width / 3;
base_center_diameter = 10;
base_center_extra    = 1;    // center cylinder rises this much above base_height
base_top_extra       = 6.5;  // top post rises this much above center cylinder
base_top_radius      = 3.9;

/* [Top groove for the impossible-object feet] */
// Y-shaped groove sunk into the top face, centered on the plate.
// Sized to match the leg/foot parameters of the current version of
// impossible.scad, so the object's feet drop in and self-center.
groove_clearance      = .5;    // groove is this much wider than the feet
groove_depth          = foot_height;  // groove depth matches the foot so it sits fully recessed
groove_length         = object_width / 2;  // length of each arm from the center

/* [Bottom insert pocket (mm)] */
insert_diameter       = 22;    // your round insert diameter
insert_clearance      = 0.2;   // small added diameter for snug fit
insert_pocket_depth   = 4;     // pocket depth from bottom face

/* [Preview / debug helpers] */
show_top_groove     = true;

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
assert(base_height > 0 && base_radius > 0,
    "base_height and base_radius must be positive");
assert(base_center_diameter > 0 && base_top_radius > 0,
    "base_center_diameter and base_top_radius must be positive");
assert(groove_length + max(leg_diameter, foot_width_90, foot_diameter_others) / 2 + groove_clearance
        <= arm_length + arm_width / 2,
    "groove arms reach past the end of the plate arm; decrease groove_length/object_width or increase arm_length");
assert(groove_length > (foot_width_90 + groove_clearance) * sqrt(3) / 2,
    "groove_length is too short for the fish-eye tip on the 90-degree arm; increase groove_length/object_width or decrease foot_width_90/groove_clearance");

// ===== Geometry =====

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
// 90-degree leg can slide down into: parallel sides for most of its
// run, tapering to a point only over the last stretch, at the same
// taper the almond foot itself tapers to its tip (see almond_2d in
// impossible.scad: half-length sqrt(3) * w / 2 beyond the foot's
// widest point). The rounded near end blends into the hub where the
// three arms meet.
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

// Y-shaped centering groove: three slots radiating from the plate
// center, sunk groove_depth into the top face. One arm toward the
// back (+Y) and the other two 120/240 degrees around, matching the
// three legs generated by impossible.scad. The 90-degree arm is a
// straight-sided slot that only points at its far end, echoing the
// almond-shaped foot that slides into it, so its shape alone marks
// where that leg goes; the other two arms stay plain rounded-rectangle
// slots for the round feet.
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

module lazy_susan_plate() {
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
}

module base_object() {
    union() {
        cylinder(r = base_radius, h = base_height);
        cylinder(d = base_center_diameter, h = base_height + base_center_extra);
        translate([0, 0, base_height + base_center_extra])
            cylinder(r = base_top_radius, h = base_top_extra);
    }
}

echo(str("Plate: 3-arm, height ", box_height, " mm"));
echo(str("Arm geometry: length ", arm_length, " mm, width ", arm_width,
         " mm, hub ", hub_diameter, " mm"));
echo(str("Top groove: ", groove_depth, " mm deep, arms ", groove_length, " mm long"));
echo(str("Bottom insert pocket: d=", insert_diameter + insert_clearance,
         " mm, depth=", insert_pocket_depth, " mm"));
echo(str("Base: r=", base_radius, " mm, h=", base_height,
         " mm, center d=", base_center_diameter,
         " mm, top post r=", base_top_radius, " mm"));

if (show_spinner)
    color(plate_color) lazy_susan_plate();
else
    color(plate_color) base_object();

// ===================================================================
// Printing notes
// ===================================================================
// The underside includes a centered round insert pocket. Groove-face
// down is still a good default when you want the smoothest possible
// top-facing surface.
