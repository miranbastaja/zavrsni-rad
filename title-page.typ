#let title = "TODO web aplikacija s Rust backend-om"
#let author = "Miran Bastaja, 4.E2"
#let institution = (
	name: "Tehnička škola Zagreb",
	address: "Zagreb, Palmotićeva 84"
)
#let mentor = "Željko Vrabec, prof."
#let placeAndTime = "Zagreb, travanj 2023."
#set document(
	author: author,
	title: title
)

#set align(center)
#set text(
	font: "DS Sans",
	weight: "bold",
	size: 14pt
)

#upper(institution.name)
#v(0.5pt)
#text(institution.address)

#v(1fr)

#text(size: 18pt, upper("Završni rad"))
#v(0.5pt)
#text(size: 20pt, upper(title))

#v(1fr)

#columns(2, [
	#set align(left)
	Mentor:\
	#mentor

	#colbreak()

	#set align(right)
	Učenik:\
	#author
])

#v(3cm)

#placeAndTime

#pagebreak()
