// ===================================================================
// Dowel Stand + Angled Viewing Window
//
// Two separate printable parts for a 7 mm wooden dowel, selected with
// the "part" toggle below:
//
//   - "stand"  : a thin round base sitting on the table with a taller
//                round post in the middle, bored with a hole that the
//                dowel presses into.
//   - "window" : a picture-frame border (outer rounded rectangle with
//                a rectangular hole through the middle, like a real
//                picture frame) mounted above a socket cylinder that
//                is bored to take the dowel. The socket stays upright
//                — parallel to the Z axis, same as the dowel — while
//                only the frame tilts, hinged up and back off the
//                socket's front rim by tilt_angle, so it leans over
//                the socket without any part of it reaching down into
//                the middle of the viewing opening. A tapered gusset
//                (a smooth hull blend, like the root flare on a wine
//                glass stem) fills the concave gap between the round
//                socket and the flat underside of the frame, so the
//                two parts are backed by a continuous wedge of solid
//                material instead of meeting at a thin edge.
//
// Axes for both parts: X/Y = footprint on the table, Z = up.
// ===================================================================

/* [Which part to render] */
part = "stand"; // [stand:Stand, window:Window]

/* [Dowel (mm)] */
dowel_diameter   = 6.5;     // actual diameter of the wooden dowel
hole_clearance   = 0;   // added to dowel_diameter for a snug press/slide fit
dowel_hole_depth = 20;    // how deep the dowel is expected to sit in either hole

/* [Stand base disc (mm)] */
base_diameter = 100;  // thin disc that sits on the table
base_height   = 4;    // thickness of the base disc

/* [Stand center post (mm)] */
post_diameter = 15;   // taller cylinder in the middle, holds the dowel
post_height   = dowel_hole_depth+1;   // height of the post above the base disc

/* [Window picture-frame opening (mm)] */
opening_width  = 80;  // inner opening you look through, X (the "picture frame hole")
opening_depth  = 100;   // inner opening you look through, Y

/* [Window picture-frame border (mm)] */
frame_border    = 8;   // border width added on all sides (outer = opening + 2 * frame_border)
frame_thickness = 4;   // how thick the frame material is (depth into the page)
frame_corner_r  = 5;  // corner rounding radius of the OUTER edge of the frame

/* [Window socket cylinder] */
socket_diameter = post_diameter;  // cylinder attached to the bottom border, holds the dowel
socket_length   = dowel_hole_depth+3;  // length of the socket cylinder, continuing the frame's plane

/* [Window support gusset] */
gusset_width = 40;  // width of the reinforcing brace between socket and frame, along X (mm)
gusset_reach = 8;   // how far the brace extends into the frame border, from the pivot (mm)

/* [Window tilt] */
tilt_angle = 45;  // angle the whole frame+socket assembly leans forward, degrees

/* [Rendering] */
$fn = 96;

// ===== Derived values =====
dowel_hole_d = dowel_diameter + hole_clearance;
frame_width  = opening_width + 2 * frame_border;   // outer frame footprint, X
frame_depth  = opening_depth + 2 * frame_border;   // outer frame footprint, Y

// ===== Checks =====
assert(base_diameter > post_diameter,
    "base_diameter should be larger than post_diameter");
assert(post_diameter > dowel_hole_d,
    "post_diameter must be larger than the dowel hole diameter");
assert(post_height > dowel_hole_depth,
    "post_height should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(2 * frame_corner_r <= min(frame_width, frame_depth),
    "frame_corner_r is too large for the frame footprint");
assert(socket_diameter > dowel_hole_d,
    "socket_diameter must be larger than the dowel hole diameter");
assert(socket_length > dowel_hole_depth,
    "socket_length should be greater than dowel_hole_depth so the hole doesn't pass all the way through");
assert(gusset_width > 0 && gusset_width <= frame_width,
    "gusset_width must be positive and no wider than the frame");
assert(gusset_reach > 0 && gusset_reach <= opening_depth,
    "gusset_reach must be positive and small enough to stay within the window");
assert(tilt_angle > 0 && tilt_angle < 90,
    "tilt_angle must be between 0 and 90 degrees");

// ===== 2D helpers =====

// Rounded rectangle centered on the origin, width w (X) x depth d (Y).
module rounded_rect_2d(w, d, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w / 2 - r), sy * (d / 2 - r)])
                circle(r = r);
    }
}

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

// ===== Window =====
//
// The socket is a plain upright cylinder, axis parallel to Z, base at
// the origin — same orientation as the dowel it receives.
//
// The frame is built flat in the X/Y plane (as if lying face-up on
// the table, centered on the origin) and then hinged upward: rotated
// about a pivot line that runs through the socket's center, at the
// socket's top. Because the pivot line sits at the same height as the
// socket's top face, the frame's bottom border rests flush on top of
// the socket (solid contact, welded by the union) and then leans back
// as it tilts, opening up above the socket without any part of the
// frame or its border reaching back down over the dowel hole.
//
// A gusset — the hull() between the socket's top disc and a patch in
// that same tilted plane, matching the border's own footprint at the
// pivot — fills in the concave wedge between the round socket and the
// flat frame underside with a smooth, continuously tapered brace, so
// the joint carries load over a wide blended area rather than the
// thin edge where the two would otherwise just touch.
//
// Because the socket stays vertical while only the frame tilts, the
// socket's own rim (and the gusset built from it) pokes slightly past
// the plane of the frame's outward face — the face most people would
// want flat on the print bed. front_face_trim() shaves off exactly
// that sliver so the outward face is the true extremal plane of the
// part and can sit flush, with no visible impact anywhere else.

// Picture-frame border: outer rounded rectangle with a plain
// rectangular hole through the middle, extruded to frame_thickness.
module frame_border_shape() {
    linear_extrude(height = frame_thickness)
        difference() {
            rounded_rect_2d(frame_width, frame_depth, frame_corner_r);
            square([opening_width, opening_depth], center = true);
        }
}

// Upright socket cylinder, bored for the dowel, base at the origin.
module socket_shape() {
    difference() {
        cylinder(d = socket_diameter, h = socket_length);
        translate([0, 0, -1])
            cylinder(d = dowel_hole_d, h = dowel_hole_depth + 1);
    }
}

// Structural gusset: the hull between a flat disc at the socket's top
// and a block that matches the frame border's own footprint at the
// pivot (same width-limited-to-gusset_width, same reach as the border
// is deep there). Both cross-sections live in the frame's tilted
// plane, so the hull sweeps smoothly from round socket to flat
// border — a strong, continuously tapered fillet instead of a knife
// edge.
module gusset_shape() {
    hull() {
        translate([0, 0, socket_length - 0.01])
            cylinder(d = socket_diameter, h = 0.01);

        translate([0, 0, socket_length])
            rotate([tilt_angle, 0, 0])
                translate([-gusset_width / 2, 0, 0])
                    cube([gusset_width, gusset_reach, frame_thickness]);
    }
}

// Half-space cutter coincident with the frame's outward face (local
// z = frame_thickness in frame_border_shape's own coordinates),
// carried through the exact same translate/rotate/translate chain
// used to place the frame. Subtracting this trims away any material
// (socket rim, gusset) that would otherwise poke past that plane,
// without touching the frame itself, which never extends beyond it.
module front_face_trim() {
    big = 1000;
    translate([0, 0, socket_length])
        rotate([tilt_angle, 0, 0])
            translate([0, frame_depth / 2, 0])
                translate([-big / 2, -big / 2, frame_thickness])
                    cube([big, big, big]);
}

module window() {
    difference() {
        union() {
            socket_shape();
            gusset_shape();

            // hinge the frame up from the socket's top, pivoting through
            // its center so the bottom border sits flush on the socket
            // face before leaning back
            translate([0, 0, socket_length])
                rotate([tilt_angle, 0, 0])
                    translate([0, frame_depth / 2, 0])
                        frame_border_shape();
        }

        front_face_trim();
    }
}

echo(str("Dowel hole diameter: ", dowel_hole_d, " mm (dowel ", dowel_diameter,
         " mm + ", hole_clearance, " mm clearance)"));
echo(str("Stand: base d=", base_diameter, " x h=", base_height,
         " mm, post d=", post_diameter, " x h=", post_height, " mm"));
echo(str("Window: outer frame ", frame_width, " x ", frame_depth, " x ", frame_thickness,
         " mm, opening ", opening_width, " x ", opening_depth,
         " mm, border ", frame_border,
         " mm, socket d=", socket_diameter, " x l=", socket_length,
         " mm, gusset w=", gusset_width, " x reach=", gusset_reach,
         " mm, tilt ", tilt_angle, " deg"));

if (part == "stand")
    stand();
else
    window();
