// legend.typ - Legend rendering primitives

#import "../theme.typ": *

// Optional legend title rendered above entries.
#let _legend-title(title, theme) = {
  if title != none {
    text(size: theme.legend-size, weight: "bold", fill: theme.text-color)[#title]
    v(3pt)
  }
}

// Horizontal legend (for bar, line, area charts).
#let draw-legend(entries, theme, swatch-type: "box", title: none) = {
  let swatch-size = theme.legend-swatch-size
  v(5pt)
  align(center)[
    #_legend-title(title, theme)
    #for (i, entry) in entries.enumerate() {
      let name = if type(entry) == str { entry } else { entry.name }
      let color = if type(entry) == dictionary and "color" in entry {
        entry.color
      } else {
        get-color(theme, i)
      }

      // Wrap each swatch+label as an atomic unit to prevent mid-entry line breaks
      box(baseline: 2pt)[
        #if swatch-type == "line" {
          box(width: 15pt, height: 2pt, fill: color, baseline: -2pt)
        } else if swatch-type == "circle" {
          box(width: swatch-size, height: swatch-size, baseline: 2pt,
            circle(radius: swatch-size / 2, fill: color, stroke: white + 0.5pt))
        } else {
          box(width: swatch-size, height: swatch-size, fill: color, baseline: 2pt, radius: 2pt)
        }
        #h(3pt)
        #text(size: theme.legend-size, fill: theme.text-color)[#name]
      ]
      h(theme.legend-gap)
    }
  ]
}

// Vertical legend (for pie, radar, side panels).
#let draw-legend-vertical(entries, theme, width: 130pt, title: none) = {
  let swatch-size = theme.legend-swatch-size
  box(width: width)[
    #_legend-title(title, theme)
    #for (i, entry) in entries.enumerate() {
      let name = if type(entry) == str { entry } else { entry.name }
      let color = if type(entry) == dictionary and "color" in entry {
        entry.color
      } else {
        get-color(theme, i)
      }

      box(width: swatch-size, height: swatch-size, fill: color, baseline: 2pt, radius: 2pt)
      h(3pt)
      text(size: theme.legend-size, fill: theme.text-color)[#name]
      if i < entries.len() - 1 {
        linebreak()
        v(2pt)
      }
    }
  ]
}

/// Automatically picks horizontal or vertical legend based on
/// `theme.legend-position`.  Returns `none` when the legend is
/// suppressed (`show-legend` is false or position is `"none"`).
///
/// - entries (array): Legend entries — strings or dicts with `name` (and optional `color`)
/// - theme (dictionary): Resolved theme
/// - show-legend (bool): Master toggle; when false nothing is rendered
/// - swatch-type (str): `"box"`, `"line"`, or `"circle"`
/// - title (none, str): Optional legend title displayed above entries
/// -> content, none
#let draw-legend-auto(entries, theme, show-legend: true, swatch-type: "box", title: none) = {
  if not show-legend { return }
  if theme.legend-position == "none" { return }
  if entries.len() == 0 { return }

  if theme.legend-position == "right" or theme.legend-position == "left" {
    draw-legend-vertical(entries, theme, title: title)
  } else {
    draw-legend(entries, theme, swatch-type: swatch-type, title: title)
  }
}

/// Size legend for bubble charts — shows 2-3 reference circles with labels.
///
/// - sizes (array): Array of (value, label) pairs for reference bubbles
/// - max-radius (length): Maximum bubble radius (for scaling)
/// - max-value (number): Maximum data value (for scaling)
/// - theme (dictionary): Resolved theme
/// - title (none, str): Optional title (e.g., "Market Value (£M)")
/// -> content
#let draw-size-legend(sizes, max-radius, max-value, theme, title: none) = {
  v(3pt)
  align(center)[
    #if title != none {
      text(size: theme.legend-size, fill: theme.text-color)[#title]
      h(8pt)
    }
    #for (val, lbl) in sizes {
      let r = calc.max(3pt, max-radius * calc.sqrt(val / calc.max(1, max-value)))
      let d = r * 2
      box(baseline: r - 1pt)[
        #box(width: d, height: d,
          circle(radius: r, fill: none, stroke: theme.text-color-light + 0.75pt))
      ]
      h(2pt)
      text(size: theme.legend-size, fill: theme.text-color)[#lbl]
      h(10pt)
    }
  ]
}
