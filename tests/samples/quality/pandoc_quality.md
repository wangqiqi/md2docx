# Pandoc-style quality tier (SPRINT-QUAL-03)

## Reference links

Block reference:

[See the spec][spec]

[spec]: https://example.com/specification "Specification"

Inline in a sentence: read [the guide][guide] before shipping.

[guide]: https://docs.example.com/guide

Numeric-style ids still work:

[First ref][1] and [second ref][2].

[1]: https://example.com/one
[2]: https://example.com/two "Second"

## Inline link spacing (regression)

Words before and after: prefix [middle][m] suffix.

[m]: https://example.com/middle

## Coexist with footnotes

Reference [link][L] plus footnote marker[^fn].

[L]: https://example.com/coexist

[^fn]: Footnote beside reference links.
