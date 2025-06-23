// Plaque Parameters
width = 125;
height = 125;
radius = 6;
base_thickness = 1.5;
wall_thickness = 2;

// Details Parameters
details_thickness = 0.8;

quote_font = "Montserrat:style=ExtraBold";
author_font = "Montserrat:style=ExtraBold Italic";
symbol_font = "Symbola";

symbol_char = "♫";
symbol_size = 25;
symbol_margin = 15;

quote_lines = [
    "É preciso",
    "saber viver",
];
quote_text_size = 8;
text_gap_from_symbol = 8;
line_spacing_factor = 1.6;

author_text = "— Titãs";
author_text_size = 6;
author_gap_from_quote = 10;

module rounded_rectangle(w, h, r) {
    r = min(r, min(w, h) / 2);
    minkowski() {
        square([w - 2 * r, h - 2 * r], center = true);
        circle(r = r, $fn = 64);
    }
}

module base_shell() {
    linear_extrude(base_thickness)
        rounded_rectangle(width, height, radius);

    translate([0,0,0.01])
        linear_extrude(base_thickness - 0.02)
            rounded_rectangle(
                width  - 2*wall_thickness,
                height - 2*wall_thickness,
                max(0, radius - wall_thickness)
            );
}

module symbol_left() {
    text(symbol_char,
         size = symbol_size,
         font = symbol_font,
         halign = "left",
         valign = "top");
}

module quote_text_centered() {
    line_height = quote_text_size * line_spacing_factor;
    for (i = [0 : len(quote_lines) - 1])
        translate([0, -i * line_height])
            text(quote_lines[i],
                 size = quote_text_size,
                 font = quote_font,
                 halign = "center",
                 valign = "top");
}

module author_text_right() {
    text(author_text,
         size = author_text_size,
         font = author_font,
         halign = "right",
         valign = "top");
}

// Assemble
union() {
    // Base
    color("gray") base_shell();

    // Symbol
    color("yellow")
        translate([-width/2 + symbol_margin,
                   height/2 - symbol_margin,
                   base_thickness])
            linear_extrude(details_thickness)
                symbol_left();

    // Quote text
    line_height = quote_text_size * line_spacing_factor;
    total_quote_height = line_height * len(quote_lines);

    color("yellow")
        translate([0,
                   height/2 - symbol_margin - symbol_size - text_gap_from_symbol,
                   base_thickness])
            linear_extrude(details_thickness)
                quote_text_centered();

    // Author text
    color("yellow")
        translate([width/2 - symbol_margin,
                   height/2 - symbol_margin - symbol_size - text_gap_from_symbol - total_quote_height - author_gap_from_quote,
                   base_thickness])
            linear_extrude(details_thickness)
                author_text_right();
}
