// ─────────────────────────────────────────────────────────────
//  PARAMETRIC QUOTE PLAQUE (v2.1)
//  • Base is 2 mm thick (0 → 2 mm)
//  • All details ride 1 mm higher (2 → 3 mm)
//  • Fonts consolidated into parameters for easy tweaking
// ─────────────────────────────────────────────────────────────

// ── USER PARAMETERS ──
width  = 125;        // plaque width  (mm)
height = 125;        // plaque height (mm)
radius = 6;          // corner radius  (mm)

base_thickness    = 1.5;  // base layer thickness (mm)
details_thickness = 0.8;  // height of ALL details above the base (mm)

// ── FONT PARAMETERS ──
quote_font  = "Montserrat:style=ExtraBold";          // font used for main quote
author_font = "Montserrat:style=ExtraBold Italic";  // font used for author line
symbol_font = "Symbola";                           // font used for single‑glyph symbol

// ── SYMBOL PARAMETERS ──
symbol_char   = "♪";    // choose any glyph supported by symbol_font
symbol_size   = 30;      // glyph height (mm)
symbol_margin = 15;      // distance from plaque’s left/top edges (mm)

// ── QUOTE TEXT ──
quote_lines          = [ "O acaso vai", "me proteger", "enquanto eu", "andar distraído" ];
quote_text_size      = 8;       // font size (mm)
text_gap_from_symbol = 0;       // vertical gap from symbol to first line (mm)
line_spacing_factor  = 1.6;     // line‑to‑line spacing multiplier

// ── AUTHOR APPEARANCE ──
author_text           = "— Titãs";
author_text_size      = 6;      // font size (mm)
author_gap_from_quote = 10;     // gap from last quote line (mm)

////////////////////////////////////////////////////////////////////
//  Helper: Rounded rectangle
////////////////////////////////////////////////////////////////////
module rounded_rectangle(w, h, r) {
    r = min(r, min(w, h) / 2);
    minkowski() {
        square([w - 2 * r, h - 2 * r], center = true);
        circle(r = r, $fn = 64);
    }
}

////////////////////////////////////////////////////////////////////
//  Layer 2 – Parameterised Symbol (LEFT‑aligned)
////////////////////////////////////////////////////////////////////
module symbol_left() {
    text(symbol_char,
         size   = symbol_size,
         font   = symbol_font,
         halign = "left",
         valign = "top");
}

////////////////////////////////////////////////////////////////////
//  Layer 3 – Quote text (centered)
////////////////////////////////////////////////////////////////////
module quote_text_centered() {
    line_height = quote_text_size * line_spacing_factor;
    union() {
        for (i = [0 : len(quote_lines) - 1])
            translate([0, -i * line_height])
                text(quote_lines[i],
                     size   = quote_text_size,
                     font   = quote_font,
                     halign = "center",
                     valign = "top");
    }
}

////////////////////////////////////////////////////////////////////
//  Layer 4 – Author text (RIGHT‑aligned)
////////////////////////////////////////////////////////////////////
module author_text_right() {
    text(author_text,
         size   = author_text_size,
         font   = author_font,
         halign = "right",
         valign = "top");
}

////////////////////////////////////////////////////////////////////
//  Assemble
////////////////////////////////////////////////////////////////////
union() {
    // Base (0 → 2 mm)
    color("gray")
        linear_extrude(base_thickness)
            rounded_rectangle(width, height, radius);

    // Symbol (2 → 3 mm)
    color("yellow")
        translate([ -width/2 + symbol_margin,           // left margin
                    height/2 - symbol_margin,           // top margin
                    base_thickness ])
            linear_extrude(details_thickness)
                symbol_left();

    // Quote text (2 → 3 mm)
    line_height = quote_text_size * line_spacing_factor;
    total_quote_height = line_height * len(quote_lines);

    color("yellow")
        translate([ 0,
                    height/2 - symbol_margin - symbol_size - text_gap_from_symbol,
                    base_thickness ])
            linear_extrude(details_thickness)
                quote_text_centered();

    // Author text (2 → 3 mm)
    color("yellow")
        translate([ width/2 - symbol_margin,
                    height/2 - symbol_margin - symbol_size - text_gap_from_symbol - total_quote_height - author_gap_from_quote,
                    base_thickness ])
            linear_extrude(details_thickness)
                author_text_right();
}
