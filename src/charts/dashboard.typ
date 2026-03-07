// dashboard.typ - Dashboard layout primitives (card, compact-table)
#import "../theme.typ": _resolve-ctx

/// Renders a themed card container with optional title and description.
///
/// - title (none, content, str): Optional card title
/// - desc (none, content, str): Optional description shown beside the title
/// - width (length): Card width
/// - theme (none, dictionary): Theme overrides
/// - body (content): Card body content
/// -> content
#let card(title: none, desc: none, width: 100%, theme: none, body) = context {
  let t = _resolve-ctx(theme)
  let fill = if t.background != none { t.background } else { white }
  let stroke = if t.border != none { t.border } else { 0.75pt + luma(220) }
  let muted = t.text-color-light

  box(
    width: width,
    stroke: stroke,
    inset: 0pt,
    fill: fill,
  )[
    #if title != none {
      box(inset: (x: 8pt, top: 7pt, bottom: 0pt), width: 100%)[
        #text(size: t.axis-title-size, weight: "bold", fill: t.text-color, title)
        #if desc != none {
          h(6pt)
          text(size: t.axis-label-size, fill: muted, desc)
        }
      ]
    }
    #box(inset: (x: 8pt, top: 5pt, bottom: 7pt), width: 100%, body)
  ]
}

/// Renders a compact data table with themed header row and alternating fills.
///
/// - headers (array): Column header strings
/// - rows (array): Array of row arrays (each row is an array of cell strings)
/// - highlight-col (none, int): Column index to render in bold with primary color
/// - col-widths (none, array): Custom column widths; defaults to equal `1fr` columns
/// - theme (none, dictionary): Theme overrides
/// -> content
#let compact-table(headers, rows, highlight-col: none, col-widths: none, theme: none) = context {
  let t = _resolve-ctx(theme)
  let fill = if t.background != none { t.background } else { white }
  let alt-fill = if t.background != none { t.background.lighten(5%) } else { luma(248) }
  let header-fill = t.palette.at(1, default: t.palette.at(0))
  let stroke = if t.border != none { t.border } else { 0.4pt + luma(220) }
  let highlight-color = t.palette.at(0)

  let cols = if col-widths != none { col-widths } else { range(headers.len()).map(_ => 1fr) }
  table(
    columns: cols,
    align: (left, ..range(headers.len() - 1).map(_ => right)),
    stroke: stroke,
    inset: (x: 5pt, y: 3.5pt),
    fill: (_, row) => if row == 0 { header-fill } else if calc.rem(row, 2) == 0 { alt-fill } else { fill },
    ..headers.map(h => text(size: t.axis-label-size, weight: "bold", fill: t.text-color-inverse, upper(h))),
    ..rows.flatten().enumerate().map(((i, cell)) => {
      let col = calc.rem(i, headers.len())
      text(
        size: t.value-label-size,
        weight: if highlight-col != none and col == highlight-col { "bold" } else { "regular" },
        fill: if highlight-col != none and col == highlight-col { highlight-color } else { t.text-color },
        cell,
      )
    }),
  )
}
