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
// sum to the same amount on both legs:
//   Leg 1 material = (mirror-spinner-stand: spinner center to back of
//                      its hole) + (this stand: center to back of its
//                      horizontal hole)
//   Leg 2 material = (this stand: vertical hole's blind end down to
//                      the horizontal hole's center -- negative if the
//                      blind end sits below that level) + (window:
//                      top of its hole up to its projected center)
// The base's straight-sided "stadium" shape (see stadium_offset
// below) exists purely to lengthen Leg 1's material enough to match
// Leg 2's, which is fixed by window.scad's own dimensions. Everything
// below is solved automatically from dowel_hole_depth -- the one
// parameter meant to be hand-tuned -- so changing it keeps the two
// legs equal.
//
// Axes: X/Y = footprint on the table, Z = up.
// ===================================================================

/* [Dowel (mm)] */
dowel_diameter   = 6.6;   // actual diameter of the wooden dowel; must match window.scad and mirror-spinner-stand.scad
hole_clearance   = 0;     // added to dowel_diameter for a snug press/slide fit; must match window.scad and mirror-spinner-stand.scad
dowel_hole_depth = 20;    // how deep the dowel sits in every hole in this design (vertical post, horizontal tether, and window's socket) -- must match window.scad and mirror-spinner-stand.scad. This is the one parameter meant to vary; post_height and stadium_offset below are solved from it automatically to keep the two triangle legs equal.

/* [Stand base disc (mm)] */
base_diameter         = 100;  // diameter across the base's two rounded (semicircular) ends, and its width along the straight sides
base_height_no_tether = 4;    // thickness of the base when has_tether_dowel is false; when true, the base is instead made as thick as tether_base_height so the tether hole sits fully within it -- see base_height below

/* [Stand center post (mm)] */
post_diameter = 15;   // cylinder in the middle, holds the vertical dowel; post_height is derived below

/* [Tether dowel hole (mm)] */
has_tether_dowel   = true;  // bores a horizontal hole into the base's edge, sized for a second dowel that ties this stand to mirror-spinner-stand.scad at a fixed distance; must match that file's own has_tether_dowel toggle. Also thickens the base (see tether_base_height) so the hole sits fully within it, not breaking through the top or bottom face.
tether_base_height = post_diameter; // thickness the base is made when has_tether_dowel is true (replacing base_height_no_tether), giving the hole enough surrounding material; defaults to match the vertical post's diameter
post_cap           = 1;     // mm, minimal solid cap left below the vertical hole's blind end once it's sunk as far as it can into the (now thicker) base -- see post_height below

/* [Leg-equalizing cross-file constants (mm)] */
// These duplicate values that live in the other two files, purely so
// stadium_offset below can solve itself here without needing to
// read those files. Keep them in sync by hand.
mirror_base_radius   = 110 / 3;  // must match base_radius in mirror-spinner-stand.scad
window_opening_depth = 100;      // must match opening_depth in window.scad
window_frame_border  = 8;        // must match frame_border in window.scad
window_socket_extra  = 3;        // must match the "+ 3" in window.scad's socket_length = dowel_hole_depth + 3

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;
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

// This stand's Leg-2 contribution: the vertical hole's blind end
// (Z = base_height + post_height - dowel_hole_depth) measured down to
// the horizontal hole's center (Z = base_height / 2). Whenever a post
// is actually needed (the normal case: dowel_hole_depth + post_cap >
// base_height), the dowel_hole_depth terms cancel and this reduces to
// the constant (post_cap - base_height / 2) -- independent of
// dowel_hole_depth, and negative as soon as post_cap < base_height / 2,
// meaning the vertical hole's blind end actually sits below the
// horizontal hole's center.
leg2_dowel_stand_term = (base_height / 2 + post_height) - dowel_hole_depth;

// window.scad's contribution to Leg 2: top of its dowel hole up to its
// opening's center, projected perpendicular to the 45-degree-tilted
// frame until it meets the vertical (see window.scad and the
// conversation that derived this). At exactly 45 degrees,
// frame_thickness cancels out of the projection entirely, so it
// doesn't appear here; likewise window_socket_extra is independent of
// dowel_hole_depth (window.scad defines socket_length as
// dowel_hole_depth + window_socket_extra, so the two cancel).
leg2_window_term = (window_opening_depth / 2 + window_frame_border) * sqrt(2) + window_socket_extra;

leg2_target = leg2_dowel_stand_term + leg2_window_term;

// Solve the distance between the stadium's two circle centers so
// Leg 1's material (mirror-spinner-stand's dist-to-hole-back + this
// stand's dist-to-hole-back) equals leg2_target. One circle sits right
// under the post (center at the origin, unmoved from the original
// plain-circle design); the other sits stadium_offset away, out along
// +X where the tether hole opens. This stand's own dist-to-hole-back
// is therefore (stadium_offset + base_diameter/2) - dowel_hole_depth,
// since the tether hole opens at the tip of the far circle.
stadium_offset = leg2_target - mirror_base_radius - base_diameter / 2 + 2 * dowel_hole_depth;

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(base_height + post_height >= dowel_hole_depth + post_cap,
    "base_height + post_height must be at least dowel_hole_depth + post_cap so the vertical hole doesn't break through the bottom");
assert(!has_tether_dowel || tether_base_height > dowel_hole_d,
    "tether_base_height must be larger than the dowel hole diameter so the tether hole doesn't break through the disc's top or bottom face");
assert(!has_tether_dowel || dowel_hole_depth > 0,
    "dowel_hole_depth must be positive");
assert(!has_tether_dowel || stadium_offset > 0,
    "the solved stadium_offset came out negative -- Leg 1 already exceeds leg2_target with a plain circular base at this dowel_hole_depth, so no elongation is needed (or something upstream changed); revisit the leg-equalizing constants");
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
echo(has_tether_dowel
    ? str("Leg 2 target: ", leg2_target, " mm (this stand: ", leg2_dowel_stand_term,
          " mm + window: ", leg2_window_term, " mm)")
    : "Leg 2 target: n/a (tether disabled)");

stand();
