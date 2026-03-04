// radar.typ - Radar/spider charts
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-vertical
#import "../primitives/polar.typ": place-polar-label

/// Renders a radar (spider) chart for comparing series across multiple axes.
///
/// - data (dictionary): Dict with `labels` (axis names) and `series` (each with `name` and `values`)
/// - size (length): Diameter of the radar chart
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - show-value-labels (bool): Display scale values and data point labels
/// - fill-opacity (ratio): Opacity of the filled data area
/// - theme (none, dictionary): Theme overrides
/// -> content
#let radar-chart(
  data,
  size: 200pt,
  title: none,
  show-legend: true,
  show-value-labels: true,
  fill-opacity: 30%,
  theme: none,
) = {
  validate-series-data(data, "radar-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series
  let n = labels.len()
  let radius = size / 2 - calc.max(25pt, size * 0.15)  // Scale padding with size
  let cx = size / 2
  let cy = size / 2

  // Find max value across all series
  let all-values = series.map(s => s.values).flatten()
  let max-val = calc.max(..all-values)

  // Respect both show-legend param and theme legend-position
  let show-legend = show-legend and t.legend-position != "none"

  // Calculate legend width
  let legend-width = if show-legend and series.len() > 1 { 100pt } else { 0pt }

  chart-container(size + legend-width, size, title, t, extra-height: 40pt)[
    #grid(
      columns: if legend-width > 0pt { (size, legend-width) } else { (size,) },

      // Radar chart
      box(width: size, height: size)[
        // Draw grid polygons with value labels
        #for level in array.range(1, 5) {
          let r = radius * level / 4
          let pts = ()
          for i in array.range(n) {
            let angle = -90deg + (i / n) * 360deg
            pts.push((
              cx + r * calc.cos(angle),
              cy + r * calc.sin(angle)
            ))
          }
          pts.push(pts.at(0))

          place(
            left + top,
            polygon(
              fill: none,
              stroke: t.grid-stroke,
              ..pts.map(p => (p.at(0), p.at(1)))
            )
          )

          // Value label on first axis (top)
          if show-value-labels {
            let val = calc.round(max-val * level / 4, digits: 0)
            place(
              left + top,
              dx: cx + 3pt,
              dy: cy - r - 4pt,
              text(size: 6pt, fill: t.text-color-light)[#val]
            )
          }
        }

        // Draw axis lines and labels
        #for (i, lbl) in labels.enumerate() {
          let angle = -90deg + (i / n) * 360deg
          let x-end = cx + radius * calc.cos(angle)
          let y-end = cy + radius * calc.sin(angle)

          // Axis line
          place(
            left + top,
            line(
              start: (cx, cy),
              end: (x-end, y-end),
              stroke: t.grid-stroke
            )
          )

          // Label positioning - push labels outward based on angle
          place-polar-label(cx, cy, angle.deg(), radius + 12pt,
            text(size: t.value-label-size, fill: t.text-color, weight: "medium")[#lbl],
            box-width: calc.max(40pt, size * 0.18))
        }

        // Draw data series
        #for (si, s) in series.enumerate() {
          let pts = ()
          for (i, val) in s.values.enumerate() {
            let angle = -90deg + (i / n) * 360deg
            let r = (val / max-val) * radius
            pts.push((
              cx + r * calc.cos(angle),
              cy + r * calc.sin(angle)
            ))
          }

          let color = get-color(t, si)

          // Filled area — scale stroke with chart size
          let stroke-w = calc.max(0.5pt, size / 150)
          let dot-r = calc.max(2pt, size / 60)
          place(
            left + top,
            polygon(
              fill: color.transparentize(100% - fill-opacity),
              stroke: color + stroke-w,
              ..pts.map(p => (p.at(0), p.at(1)))
            )
          )

          // Points with value labels
          for (i, pt) in pts.enumerate() {
            place(
              left + top,
              dx: pt.at(0) - dot-r,
              dy: pt.at(1) - dot-r,
              circle(radius: dot-r, fill: color, stroke: white + 0.5pt)
            )

            // Show value near point (offset based on angle to avoid overlap)
            if show-value-labels and series.len() == 1 {
              let angle = -90deg + (i / n) * 360deg
              let offset-x = 8pt * calc.cos(angle)
              let offset-y = 8pt * calc.sin(angle)
              place(
                left + top,
                dx: pt.at(0) + offset-x,
                dy: pt.at(1) + offset-y,
                move(dx: -1em, dy: -0.5em,
                  text(size: t.axis-label-size, fill: color, weight: "bold")[#s.values.at(i)])
              )
            }
          }
        }
      ],

      // Legend
      if legend-width > 0pt {
        draw-legend-vertical(series.map(s => s.name), t, width: legend-width)
      }
    )
  ]
}
