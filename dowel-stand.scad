// ===================================================================
// Dowel Stand
//
// A round-ended ("stadium") base sitting on the table with a shorter
// round post in the middle, bored with a hole that a 7 mm wooden
// dowel presses into. The matching angled viewing window that mounts
// on the other end of that vertical dowel is a separate part -- see
// window.scad.
//
// This stand also optionally bores a second, horizontal hole into the
// edge of its base (see has_tether_dowel below) for a dowel that ties
// over to a matching hole in mirror-spinner-stand.scad. Together with
// the vertical dowel up to the window, that's meant to form two legs
// of an isosceles right triangle:
//   Leg 1 (horizontal): spinner center -> vertical dowel's center
//   Leg 2 (up to the window): horizontal dowel's center -> window's
//     center, projected perpendicular to the (45-degree-tilted)
//     window face until it meets the vertical
// For the two legs to come out equal when you use dowels of the same
// length in both, the "material" that isn't spanned by a dowel has to
// sum to the same amount on both legs. The base's straight-sided
// "stadium" shape (see stadium_offset below) exists purely to
// lengthen Leg 1's material enough to match Leg 2's. stadium_offset is
// a plain hand-tuned parameter, currently set to the value that
// balances the two legs at this design's dowel/window/mirror-stand
// dimensions; if those dimensions change materially, re-derive and
// update it by hand.
//
// Axes: X/Y = footprint on the table, Z = up.
// ===================================================================

/* [Dowel (mm)] */
dowel_diameter   = 6.7;   // actual diameter of the wooden dowel; must match window.scad and mirror-spinner-stand.scad
hole_clearance   = 0;     // added to dowel_diameter for a snug press/slide fit; must match window.scad and mirror-spinner-stand.scad
dowel_hole_depth = 20;    // how deep the dowel sits in every hole in this design (vertical post, horizontal tether, and window's socket) -- must match window.scad and mirror-spinner-stand.scad. post_height below is derived from it automatically.

/* [Stand base disc (mm)] */
base_diameter         = 100;  // diameter across the base's two rounded (semicircular) ends, and its width along the straight sides
base_height_no_tether = 4;    // thickness of the base when has_tether_dowel is false; when true, the base is instead made as thick as tether_base_height so the tether hole sits fully within it -- see base_height below
stadium_offset        = 0.1; // mm, distance between the stadium base's two circle centers (i.e. the length of its straight sides); lengthens the base along +X, where the tether hole opens, so Leg 1 of the leg-equalizing triangle (see header comment) matches Leg 2. Hand-tuned -- currently set to the value that balances the two legs for this design's dowel/window/mirror-stand dimensions; depends on tether_base_height below, so re-derive if tether_hole_margin (or any other leg-equalizing dimension) changes.

/* [Stand center post (mm)] */
post_diameter = 15;   // cylinder in the middle, holds the vertical dowel; post_height is derived below

/* [Tether dowel hole (mm)] */
has_tether_dowel   = true;  // bores a horizontal hole into the base's edge, sized for a second dowel that ties this stand to mirror-spinner-stand.scad at a fixed distance; must match that file's own has_tether_dowel toggle. Also thickens the base (see tether_base_height below) so the hole sits fully within it, not breaking through the top or bottom face.
tether_hole_margin = 3;   // mm, solid material desired above and below the tether dowel hole; tether_base_height below is derived from this plus the hole diameter, so the hole sits centered with this much material on each side. Must match tether_hole_margin in mirror-spinner-stand.scad so the two tether dowel holes (each centered at base_height/2) sit the same height off the table
post_cap           = 1;     // mm, minimal solid cap left below the vertical hole's blind end once it's sunk as far as it can into the (now thicker) base -- see post_height below

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;
tether_base_height = 2 * tether_hole_margin + dowel_hole_d; // mm, base thickness needed to leave tether_hole_margin of material above and below the (centered) tether hole
base_height  = has_tether_dowel ? tether_base_height : base_height_no_tether; // full base thickness; thickened when enabled so the tether hole sits fully within the slab (top and bottom) instead of breaking through

// The vertical post only needs to rise as far above the base as the
// hole depth still requires once the base's own (now much thicker)
// thickness -- minus the post_cap safety margin -- is used up. When
// the base is thick enough on its own (base_height >= dowel_hole_depth
// + post_cap), no post is needed at all (post_height clamps to 0) and
// the hole sits entirely within the base. This sinking only applies
// when has_tether_dowel thickens the base; with the original thin base
// it keeps the original fixed post_height (dowel_hole_depth + 1).
post_height = has_tether_dowel
    ? max(0, dowel_hole_depth + post_cap - base_height)
    : dowel_hole_depth + 1;

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(base_height + post_height >= dowel_hole_depth + post_cap,
    "base_height + post_height must be at least dowel_hole_depth + post_cap so the vertical hole doesn't break through the bottom");
assert(!has_tether_dowel || tether_hole_margin > 0,
    "tether_hole_margin must be positive so the tether hole doesn't break through the disc's top or bottom face");
assert(!has_tether_dowel || dowel_hole_depth > 0,
    "dowel_hole_depth must be positive");
assert(!has_tether_dowel || stadium_offset > 0,
    "stadium_offset must be positive");
assert(!has_tether_dowel || dowel_hole_depth < stadium_offset + base_diameter / 2,
    "dowel_hole_depth must be less than the stand's reach (stadium_offset + base_diameter/2) so the tether hole stays blind and doesn't reach the center post");

// ===== Stand =====

// Round-ended ("stadium") base: two circular ends of diameter
// base_diameter, joined by a hull (i.e. two semicircular ends plus
// straight sides). The near circle is centered right at the origin --
// exactly where the plain circular disc used to be, directly under
// the post -- and the far circle sits stadium_offset away along +X,
// the same axis the tether hole bores along. Only extending the one
// (tether-hole) side is what lengthens Leg 1 to match Leg 2, without
// adding unnecessary bulk on the post's far side; see the header
// comment.
module stand_base() {
    hull() {
        cylinder(d = base_diameter, h = base_height);
        translate([stadium_offset, 0, 0])
            cylinder(d = base_diameter, h = base_height);
    }
}

// Horizontal hole bored into the tip of the base's far (+X) rounded
// end -- open at the outer edge, blind at the inner end -- sized for a
// second dowel. That dowel spans over to the matching hole on
// mirror-spinner-stand.scad, holding the two stands a fixed distance
// apart.
module tether_hole() {
    overcut = 1; // extra length so the cutter fully clears the base's outer surface
    mouth_x = stadium_offset + base_diameter / 2; // tip of the far rounded end
    translate([mouth_x + overcut, 0, base_height / 2])
        rotate([0, -90, 0])
            cylinder(d = dowel_hole_d, h = dowel_hole_depth + overcut);
}

module stand() {
    difference() {
        union() {
            // base on the table (thickened when the tether hole is enabled)
            if (has_tether_dowel)
                stand_base();
            else
                cylinder(d = base_diameter, h = base_height);

            // center post (zero-height when the base alone is already
            // thick enough to hold the full hole depth)
            if (post_height > 0)
                translate([0, 0, base_height])
                    cylinder(d = post_diameter, h = post_height);
        }

        // Vertical dowel hole, open at the top of the whole assembly
        // (post top, or base top if there's no post) and bored down by
        // dowel_hole_depth. Subtracted from the full union (not just
        // the post alone) so it correctly spans across the post/base
        // boundary and reaches its true blind end even when
        // post_height < dowel_hole_depth.
        translate([0, 0, base_height + post_height - dowel_hole_depth])
            cylinder(d = dowel_hole_d, h = dowel_hole_depth + 1);

        if (has_tether_dowel)
            tether_hole();
    }
}

echo(str("Dowel hole diameter: ", dowel_hole_d, " mm (dowel ", dowel_diameter,
         " mm + ", hole_clearance, " mm clearance)"));
echo(str("Stand: base d=", base_diameter, " mm, stadium offset=", stadium_offset,
         " mm, h=", base_height, " mm, post d=", post_diameter, " x h=", post_height, " mm"));
echo(has_tether_dowel
    ? str("Tether dowel hole: d=", dowel_hole_d, " mm, ", dowel_hole_depth,
          " mm deep, bored into the base's rounded end; base thickness raised to match (h=", base_height, " mm)")
    : "Tether dowel hole: disabled");

stand();
