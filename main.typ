#include "title-page.typ"

#set heading(numbering: "1.1")
#set text(lang: "hr")
#set figure(supplement: [Slika])

#set par(leading: 0.8em, justify: true)
#show par: set block(spacing: 0.75em)

#set page(
	margin: (left: 3cm, right: 2.5cm, y: 2.5cm)
)

#set terms(tight: true)

#outline(
	title: "Sadržaj",
	depth: 3,
	indent: true,
)

#pagebreak()

#set page(numbering: "1")
#counter(page).update(1)

#include "sections/uvod.typ"
#include "sections/architecture.typ"
#include "sections/data-model.typ"
#include "sections/frontend.typ"
#include "sections/config.typ"

#outline(
	title: [Slike],
	target: figure.where(kind: image)
)

// Hacky way to get bibliography to render stuff that wasn't directly cited
// in the doc.
#[
#set text(size: 0pt)
@zero2prod
]

#pagebreak()

#bibliography(title: "Literatura", "works.yml", style: "chicago-author-date")
