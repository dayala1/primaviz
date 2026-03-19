#import "../src/lib.typ": *

#figure(
  grouped-bar-chart(
    (
      labels: ("Word", "Markdown", "LaTeX", "Typst"),
      series: (
        (name: "Have Used", values: (93, 73, 60, 27)),
        (name: "Would Use for Thesis", values: (27, 13, 67, 80)),
      ),
    ),
    height: 180pt,
    y-label: "Respondents (%)",
  ),
)

#figure(
  pie-chart(
    (
      ("Seen Examples", 40),
      ("Never Heard", 26),
      ("Basic Doc", 27),
      ("Expert/Scripting", 7),
    ),
  ),
)

#figure(
  horizontal-bar-chart(
    (
      labels: ("Ready Now", "Template + Tour", "Template Only"),
      values: (53, 27, 20),
    ),
    width: 100%,
    height: 120pt,
    x-label: "Respondents (%)",
  ),
)
