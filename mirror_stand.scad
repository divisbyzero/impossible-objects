// ===================================================================
// Leaning mirror stand
//
// Holds a rectangular mirror (with a 5mm-thick plastic base edge) in
// a blind slot cut into a solid base block. The slot is tilted so the
// mirror leans forward at lean_angle from horizontal instead of
// standing perfectly vertical (90 deg).
//
// Axes: X = front/back (depth, X=0 is the front edge, +X is toward
//       the back), Y = left/right (stand_width), Z = up (Z=0 at the
//       bottom of the base).
//
// Stability: leaning the mirror forward shifts its weight toward the
// front edge of the stand, so the base apron in front of the slot is
// made larger than the apron behind it. front_apron/back_apron below
// are a starting guess — widen front_apron (or add mass/weight to the
// base) if the actual mirror is tall/heavy enough to still tip.
// ===================================================================

/* [Mirror] */
mirror_base_depth = 6;   // front-to-back thickness of the mirror's plastic base

/* [Lean] */
lean_angle = 86;          // desired angle of the mirror from horizontal (90 = vertical)
// Negative so the slot leans the mirror toward the front (X=0) edge,
// per the rotate([0, tilt, 0]) convention used in slot_cutter().
tilt = -(90 - lean_angle);

/* [Slot] */
eps = 0.3;                          // clearance so the mirror base slides in freely
slot_gap   = mirror_base_depth + eps; // front-to-back width of the slot
slot_depth = 10;                    // vertical depth of the (blind) slot

/* [Base] */
// Base is a thin flat plate across the whole footprint (for a low,
// low-profile look and a wide stable footprint), with a raised boss
// only around the slot, tall enough to hold the full slot depth.
stand_width     = 60;   // Y: overall width of the stand (and the slot)
front_apron     = 13;   // X: plate material in front of the slot
back_apron      = 13;   // X: plate material behind the slot
plate_thickness = 3;    // Z: thickness of the flat plate away from the boss
floor_thickness = 3;    // solid material below the slot floor (within the boss)
boss_margin     = 5;    // X: extra boss material in front of and behind the slot
base_depth = front_apron + slot_gap + back_apron; // X: total footprint depth
boss_height = slot_depth + floor_thickness; // Z: total height at the boss, from Z=0
boss_depth  = slot_gap + 2 * boss_margin;   // X: footprint of the raised boss
slot_x = front_apron + slot_gap / 2; // X: center of the slot

/* [Corners] */
plate_corner_radius = 3;  // rounding radius of the plate's footprint corners
boss_corner_radius  = 3;  // rounding radius of the boss's footprint corners
corner_fn = 32;           // smoothness of the rounded corners

// A box with its footprint (XY) corners rounded, straight from Z=0 to h.
// r must be <= half of both x and y, or the corner cylinders overlap and
// the box silently renders wider/deeper than [x, y].
module rounded_box(x, y, h, r) {
    assert(r <= min(x, y) / 2, "rounded_box: corner radius too large for box footprint");
    hull() {
        for (i = [r, x - r], j = [r, y - r])
            translate([i, j, 0])
                cylinder(r = r, h = h, $fn = corner_fn);
    }
}

module plate() {
    rounded_box(base_depth, stand_width, plate_thickness, plate_corner_radius);
}

module boss() {
    translate([slot_x - boss_depth / 2, 0, 0])
        rounded_box(boss_depth, stand_width, boss_height, boss_corner_radius);
}

module slot_cutter() {
    overcut   = 4;  // extra length so the cutter fully clears both sides of the stand
    top_pad   = 2;  // extra length so the cutter pokes above the top face for a clean cut
    cutter_len = slot_depth / cos(tilt) + top_pad;

    // pivot: center of the slot at the top of the boss
    translate([slot_x, stand_width / 2, boss_height])
        rotate([0, tilt, 0])
            translate([-slot_gap / 2, -stand_width / 2 - overcut / 2, top_pad - cutter_len])
                cube([slot_gap, stand_width + overcut, cutter_len]);
}

difference() {
    union() {
        plate();
        boss();
    }
    slot_cutter();
}
