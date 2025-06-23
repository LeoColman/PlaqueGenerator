// custom_sign.scad
// 3‑D‑printable customizable plaque for multi‑material printers (e.g. Bambu A1 Combo)
// ───────────────────────────────────────────────────────────────────────────────
// Features
//   • Base: slightly‑rounded 125 mm × 125 mm square, 3 mm thick, colored gray
//   • Rim: 5 mm‑wide embossed frame (black) kept only near the corners; the middle
//     40 % of each edge is removed, leaving a plus‑sign void. Corner ends are
//     beveled inward for a “bent” look.
//   • Center Text: Portuguese quote embossed in black inside the rim, broken
//     across three centred lines so it fits neatly.
//
//        O infinito é
//        realmente um dos
//        deuses mais lindos
//
//   The rim and text share the same color so multi‑material slicers will treat
//   them as one body separate from the gray base.
// ───────────────────────────────────────────────────────────────────────────────

$fn = 64;                      // Facet count for smooth curves

// ── Tunable Parameters ────────────────────────────────────────────────────────
size              = 125;       // Overall width & height (mm)
radius            = 8;         // Outer corner radius (mm)

thickness         = 2;         // Base thickness (mm)

rim_margin        = 9;         // Gap between outer edge and start of rim (mm)
rim_width         = 2;         // Width of rim band (mm)
rim_height        = 1.2;       // Extra height of rim above the base (mm)

segment_ratio     = 0.30;      // Rim occupancy per side of a corner (0–0.49)

// Text parameters
text_lines        = [
                     "Let it be",
                     "realmente um dos",
                     "deuses mais lindos"
                   ];          // Each element is one line
text_size         = 8;         // Character height (mm)
text_line_spacing = 1.2;       // Line spacing multiplier (× text_size)
text_height       = rim_height;// Extrude height (same as rim)
text_font         = "Liberation Sans:style=Bold"; // Choose any installed font

// Colors (for multi‑body export)
base_color        = "gray";
rim_color         = "black";   // Used by both rim and text

// ── Helper: Rounded Square in 2‑D ─────────────────────────────────────────────
module rounded_square(sz, r) {
    offset(r) square(sz - 2*r, center = true);
}

// ── 3‑D Components ────────────────────────────────────────────────────────────
module base_plate() {
    color(base_color)
        linear_extrude(thickness)
            rounded_square(size, radius);
}

module rim_band_detailed() {
    /* Embossed rim occupying only the four corner regions, producing a “plus”
       void in the middle of each edge, with beveled ends for a bent look. */

    inner_len  = size - 2*rim_margin;                 // Length of band path
    cross_gap  = inner_len * (1 - 2*segment_ratio);   // Width of removed cross
    assert(cross_gap > 0, "(segment_ratio * 2) must be < 1");

    color(rim_color)
        translate([0, 0, thickness])
            linear_extrude(rim_height)
                difference() {
                    // 1) Outer minus inner rounded square = basic band
                    difference() {
                        rounded_square(size - 2*rim_margin,
                                       radius - rim_margin);
                        rounded_square(size - 2*(rim_margin + rim_width),
                                       max(radius - rim_margin - rim_width, 0));
                    }
                    // 2) Subtract a centred “plus” (two orthogonal rectangles)
                    union() {
                        square([cross_gap, size], center = true);
                        square([size, cross_gap], center = true);
                    }
                    // 3) Bevel (45°) the ends near the plus gap by subtracting
                    //    triangles at the ends of each segment
                    for (a = [0, 90, 180, 270])
                        rotate(a)
                            translate([ inner_len/2 - cross_gap/2, 0 ])
                                polygon(points=[[0,0],[rim_width,0],[0,rim_width]]);
                }
}

module center_text() {
    /* Emboss the multi‑line quote in the centre of the plaque. */
    n = len(text_lines);
    total_height = (n - 1) * text_size * text_line_spacing;
    color(rim_color)
        translate([0, 0, thickness])
            for (i = [0 : n - 1]) {
                y = total_height/2 - i * text_size * text_line_spacing;
                translate([0, y, 0])
                    linear_extrude(text_height)
                        text(text_lines[i], size=text_size, font=text_font,
                             halign="center", valign="center");
            }
}

// ── Assemble the plaque ───────────────────────────────────────────────────────
union() {
    base_plate();
    rim_band_detailed();
    center_text();
}

/*
  ▸ Exporting for Multi‑Color Printing
  ──────────────────────────────────
  ▸ In OrcaSlicer/Bambu Studio: “Split into Objects” to get separate bodies, then
    assign Gray filament to the base and Black filament to the rim+text.
  ▸ Alternatively, comment/uncomment the module calls above and export two STL
    files, one for each color, then combine them in the slicer.
*/
