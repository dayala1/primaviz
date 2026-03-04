// test-helpers.typ — Data helper utils: sort-data, top-n, aggregate

#import "../src/lib.typ": *

#set page(margin: 0.5cm)

= Data Helpers

#let raw = (labels: ("C", "A", "D", "B"), values: (30, 10, 40, 20))

#bar-chart(sort-data(raw), title: "sort-data (ascending)")

#bar-chart(top-n(raw, 2), title: "top-n(2)")

#bar-chart(percent-of-total(raw), title: "percent-of-total")

#let multi = (
  labels: ("A", "B", "C"),
  series: (
    (name: "X", values: (10, 20, 30)),
    (name: "Y", values: (5, 15, 25)),
  ),
)
#bar-chart(aggregate(multi, fn: "sum"), title: "aggregate(sum)")
