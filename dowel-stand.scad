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

/* [Tether dowel (mm)] */
has_tether_dowel = true;   // adds a horizontal cylinder at the base, bored for a second dowel that ties this stand to mirror-spinner-stand.scad at a fixed distance; must match that file's own has_tether_dowel toggle
tether_diameter  = post_diameter;      // outer diameter of the horizontal cylinder; matches the vertical post
tether_length    = dowel_hole_depth+1; // how far the cylinder extends beyond the base disc's edge

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;
tether_embed = tether_diameter / 2; // how far the horizontal cylinder is buried into the base disc for a solid fused joint; also its resting height above the table, since it sits tangent to Z=0 like the base disc

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(post_height > dowel_hole_depth,
    "post_height should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(tether_diameter > dowel_hole_d,
    "tether_diameter must be larger than the dowel hole diameter");
assert(tether_length > dowel_hole_depth,
    "tether_length should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(base_diameter / 2 > tether_embed,
    "base_diameter is too small for the tether cylinder to embed into the disc");

// ===== Stand =====

// Horizontal cylinder resting on the table (tangent at Z=0, like the
// base disc itself) and embedded into the disc's edge, bored with a
// hole (open at the outward tip) for a second dowel. That dowel spans
// over to the matching cylinder on mirror-spinner-stand.scad, holding
// the two stands a fixed distance apart.
module tether_post() {
    translate([base_diameter / 2 - tether_embed, 0, tether_embed])
        rotate([0, 90, 0])
            difference() {
                cylinder(d = tether_diameter, h = tether_embed + tether_length);

                // dowel hole, open at the outward tip
                translate([0, 0, tether_embed + tether_length - dowel_hole_depth])
                    cylinder(d = dowel_hole_d, h = dowel_hole_depth + 1);
            }
}

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

        if (has_tether_dowel)
            tether_post();
    }
}

echo(str("Dowel hole diameter: ", dowel_hole_d, " mm (dowel ", dowel_diameter,
         " mm + ", hole_clearance, " mm clearance)"));
echo(str("Stand: base d=", base_diameter, " x h=", base_height,
         " mm, post d=", post_diameter, " x h=", post_height, " mm"));
echo(has_tether_dowel
    ? str("Tether dowel cylinder: d=", tether_diameter, " mm, extends ", tether_length,
          " mm beyond the base disc's edge")
    : "Tether dowel cylinder: disabled");

stand();
