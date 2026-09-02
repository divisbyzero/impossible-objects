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
base_diameter         = 100;  // thin disc that sits on the table
base_height_no_tether = 4;    // thickness of the base disc when has_tether_dowel is false; when true, the disc is instead made as thick as tether_base_height so the tether hole sits fully within it -- see base_height below

/* [Stand center post (mm)] */
post_diameter = 15;   // taller cylinder in the middle, holds the dowel
post_height   = dowel_hole_depth+1;   // height of the post above the base disc

/* [Tether dowel hole (mm)] */
has_tether_dowel   = true;  // bores a horizontal hole into the base disc's edge, sized for a second dowel that ties this stand to mirror-spinner-stand.scad at a fixed distance; must match that file's own has_tether_dowel toggle. Also thickens the base disc (see tether_base_height) so the hole sits fully within it, not breaking through the top or bottom face.
tether_base_height = post_diameter; // thickness the base disc is made when has_tether_dowel is true (replacing base_height_no_tether), giving the hole enough surrounding material; defaults to match the vertical post's diameter
tether_hole_depth  = 20;    // mm, how deep the horizontal hole is bored into the base disc from its edge

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;
base_height  = has_tether_dowel ? tether_base_height : base_height_no_tether; // full disc thickness; thickened when enabled so the tether hole sits fully within the slab (top and bottom) instead of breaking through

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(post_height > dowel_hole_depth,
    "post_height should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(!has_tether_dowel || tether_base_height > dowel_hole_d,
    "tether_base_height must be larger than the dowel hole diameter so the tether hole doesn't break through the disc's top or bottom face");
assert(!has_tether_dowel || tether_hole_depth > 0,
    "tether_hole_depth must be positive");
assert(!has_tether_dowel || tether_hole_depth < base_diameter / 2,
    "tether_hole_depth must be less than the disc's radius so the hole stays blind and doesn't break through the far side or reach the center post");

// ===== Stand =====

// Horizontal hole bored into the base disc's edge -- open at the outer
// edge, blind at the inner end -- sized for a second dowel. That dowel
// spans over to the matching hole on mirror-spinner-stand.scad,
// holding the two stands a fixed distance apart.
module tether_hole() {
    overcut = 1; // extra length so the cutter fully clears the disc's outer surface
    translate([base_diameter / 2 + overcut, 0, base_height / 2])
        rotate([0, -90, 0])
            cylinder(d = dowel_hole_d, h = tether_hole_depth + overcut);
}

module stand() {
    difference() {
        union() {
            // base disc on the table (thickened when the tether hole is enabled)
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

        if (has_tether_dowel)
            tether_hole();
    }
}

echo(str("Dowel hole diameter: ", dowel_hole_d, " mm (dowel ", dowel_diameter,
         " mm + ", hole_clearance, " mm clearance)"));
echo(str("Stand: base d=", base_diameter, " x h=", base_height,
         " mm, post d=", post_diameter, " x h=", post_height, " mm"));
echo(has_tether_dowel
    ? str("Tether dowel hole: d=", dowel_hole_d, " mm, ", tether_hole_depth,
          " mm deep, bored into the base disc's edge; base disc thickness raised to match (h=", base_height, " mm)")
    : "Tether dowel hole: disabled");

stand();
