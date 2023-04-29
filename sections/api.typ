= Autentikacija API servisa ključevima
Za razliku od servisa za korisničko sučelje, sve rute na API servisu zahtijevaju
autentikaciju. Autentikacija se provodi API ključem (engl. „API key”) koji
korisnik može pribaviti u svojim korisničkim postavkama. Svaki zahtjev API
servisu mora sadržavati HTTP zaglavlje (engl. „HTTP header”) nazvan
`TODO_API_KEY` koji prenosi vrijednost API ključa tog korisnika.
Za autentikaciju korisnika tj. provjeravanje API ključeva zadužen je posredni
sloj. Pošto svaka ruta servisa zahtjeva autentikaciju, svi zahtjevi koji stignu
prvo prolaze kroz posredni sloj za autentikaciju. Navedeni posredni sloj
provjerava postoji li `TODO_API_KEY` zaglavlje, ako postoji provjerava je li
pruženi API ključ povezan s nekim korisnikom u bazi podataka. Ako zaglavlje ne
postoji ili ako ključ nije povezan s korisnikom posredni sloj odmah odgovara
na zahtjev s HTTP odgovorom koji sadrži statusni kod 401 („Unauthorized”).
U drugom slučaju, kada ključ postoji i kada je povezan s nekim korisnikom,
posredni sloj zahtjev prosljeđuje obradniku zahtjeva zajedno s jednom dodatnom
informacijom - identifikacijskim kodom korisnika.

#pagebreak()