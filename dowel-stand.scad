// ===================================================================
// Dowel Stand
//
// A thin round base sitting on the table with a taller round post in
// the middle, bored with a hole that a 7 mm wooden dowel presses into.
// The matching angled viewing window that mounts on the other end of
// the dowel is a separate part -- see window.scad.
//
// Axes: X/Y = footprint on the table, Z = up.
// ===================================================================

/* [Dowel (mm)] */
dowel_diameter   = 6.5;     // actual diameter of the wooden dowel; must match window.scad
hole_clearance   = 0;   // added to dowel_diameter for a snug press/slide fit; must match window.scad
dowel_hole_depth = 20;    // how deep the dowel is expected to sit in the hole; must match window.scad

/* [Stand base disc (mm)] */
base_diameter = 100;  // thin disc that sits on the table
base_height   = 4;    // thickness of the base disc

/* [Stand center post (mm)] */
post_diameter = 15;   // taller cylinder in the middle, holds the dowel
post_height   = dowel_hole_depth+1;   // height of the post above the base disc

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(post_height > dowel_hole_depth,
    "post_height should be greater than dowel_hole_depth so the hole doesn't pass all the way through");

// ===== Stand =====

module stand() {
    union() {
        // thin base disc on the table
        cylinder(d = base_diameter, h = base_height);

        // taller center post
        translate([0, 0, base_height])
            difference() {
                cylinder(d = post_diameter, h = post_height);

                // dowel hole, open at the top
                translate([0, 0, post_height - dowel_hole_depth])
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth + 1);
            }
    }
}

echo(str("Dowel hole diameter: ", dowel_hole_d, " mm (dowel ", dowel_diameter,
         " mm + ", hole_clearance, " mm clearance)"));
echo(str("Stand: base d=", base_diameter, " x h=", base_height,
         " mm, post d=", post_diameter, " x h=", post_height, " mm"));

stand();
