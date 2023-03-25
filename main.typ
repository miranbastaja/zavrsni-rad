#include "title-page.typ"

#set heading(numbering: "1.1")
#set page(numbering: "1")
#set text(lang: "hr")
#counter(page).update(1)

#outline(
	title: "Sadržaj",
	depth: 2,
	indent: true,
)

#pagebreak()

= Uvod
Cilj ovog rada je prikazati web aplikaciju za izradu i korištenje popisa zadataka. 

Popis zadataka (engl. „to-do list”) je sustav za organizaciju obavljenih i
planiranih zadataka kako bi mogli lakše pratiti naše obaveze. Poslovni ljudi i
studenti često koriste popise zadataka jer im olakšavaju snalaženje među
brojnim obavezama.

Tradicionalno su se popisi zadataka pisali na papiru, u planerima ili digitalno
u tekstualnoj datoteci. Međutim, takvi načini imaju nekoliko nedostataka.
Korisnik planer mora nositi sa sobom kad god misli da mu je popis zadataka
potreban, a ako ga izgubi ili slučajno uništi gubi sve informacije koje je imao
u njemu zapisane i nema mogućnost dodavanja poveznica koje prenose dodatne
informacije. Tekstualne datoteke korisnik može lagano kopirati, ali
sinkronizacija tih kopija nije jednostavna i ne pružaju korisničko sučelje za
olakšanje rada. Izradom web aplikacije u ovom radu su riješeni svi prethodno
navedeni problemi.

Za izradu web aplikacije potrebno je napraviti ili integrirati: korisničko
sučelje (engl. „front end”) putem kojeg korisnici mogu pristupiti stranici,
serverski kod (engl. „back end”) koji procesira korisničke zahtjeve i bazu
podataka koja sprema podatke. Uz to, u ovom radu je napravljen i JSON REST
API za automatiziran tj. programski pristup korisničkim informacijama.

Pošto ovaj rad opisuje izradu web aplikacije, korisničko sučelje mora biti
izrađeno tehnologijama i alatima koji nam pružaju moderni web preglednici. Za
korisničko sučelje korišteni su HTML5, CSS3 i Typescript koji se transpilira u
Javascript.

Serverski kod je moguće napraviti sa bilo kojim alatom koji može raditi sa HTTP
protokolom i HTML dokumentima, a u ovom radu je izabran Rust programski jezik
sa actix-web frameworkom. Te tehnologije su izabrane zbog odličnih
karakteristika performanse i visoke kvalitete Rust jezika i alata za Rust jezik.

Korištena baza podataka je PostgreSQL zbog vrhunske dokumentacije i odlične
stabilnosti. Uz te alate korišteni korišteni su i Redis za spremanje podataka
sesije, Astro za olakšanu izradu korisnićkog sučelja i za kompilaciju TSX i SCSS
koda u HTML, Javascript i CSS.

= Arhitektura rada
Ovaj rad podijeljen je na dva glavna dijela koja mogu operirati neovisno jedan
o drugome. Ti dijelovi su servis za korisničko sučelje i servis za API. Svaki
servis se pokreće putem statički povezane izvršne datoteke i oba servisa su
napisana na takav način da se mogu lagano prilagoditi povećanju ili smanjenju
opterećenja tako što se pokrene više instanca istog servisa. Na primjer, u
slučaju u kojem imamo malo korisnika i time malo opterećenje možemo imati jednu
instancu svakog servisa pokrenutu jer nam je to dovoljno da odgovorimo na sve
dolazeće zahtjeve. No, kada bi došlo do povećanja opterećenja mogli bi pokrenuti
više instanci tih servisa na drugim serverima i onda rasporediti zahtjeve tako
što servise stavimo iza raspoređivača opterećenja (engl. „load balancer ”).

Izvršne datoteke oba servisa ne spremaju stanje sesije. Samo servis za
korisničko sučelje zahtijeva spremanje stanja sesije i taj posao prepušta Redis
spremištu ključ vrijednosti koje je dijeljeno između svih instanca tog servisa.
Prepuštanje stanja sesija Redisu omogućava bezbolno horizontalno skaliranje
servisa. U praksi, graf implementacije ovih servisa u slučaju kada nam je samo
jedna instanca dovoljna izgleda ovako:
{TODO: flowchart grafa implementacije sa jedon instancom}.

A kada nam je potrebno više instanca da bi odgovorili na sve dolazeće zahtjeve
graf implementacije izgleda ovako:
{TODO: flowchart grafa implementacije sa više instanca}

Oba servisa su napisana u actix-web frameworku i dijele dio koda koji se bavi
logikom. Pisanje oba servisa sa istim alatima nam omogućava lakši razvoj
aplikacije pošto ne moramo dva puta kod za poslovnu logiku

== Arhitektura web aplikacije u actix-web frameworku
TODO

= API servis
TODO

== Autentikacija API ključevima
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

= Servis za korisničko sučelje
TODO

= Konfiguracija servisa
Konfiguracija servisa je omogućena kroz konfiguracijsku datoteku u TOML formatu
i kroz varijable okruženja (engl. „environment variables”). Konfiguracijska
datoteka je namijenjena za opću konfiguraciju koja ne sadrži povjerljive
informacije kao što je URL na preko kojeg će servis biti pružen i URL servisa
za slanje e-pošte, dok je konfiguracija kroz varijable okruženja namijenjena za
povjerljive informacije kao što su lozinke od Postgres baze podataka i Redis
servisa, HMAC koda i autentifikacijskog koda za servis e-pošte. Time se slijede
načela takozvanih „Twelve Factor” aplikacija što olakšava razvoj i podizanje
servisa, kao i dijeljenje djelova konfiguracije koji nisu povjerljivi.

Na primjer, konfiguracijska datoteka za API servis koje je bila korištena
tijekom razvoja je:
```toml
host = "127.0.0.1"
port = 8000
base_url = "http://127.0.0.1"
redis_uri = "redis://127.0.0.1:6379"
hmac_secret = "superlongandsecuresecret-01929310234u20942930023480329823akdlads"

[postgres]
user = "postgres"
password = "mysupersecretpassword"
port = 5432
host = "localhost"
db = "todo-dev"
require_ssl = false

[email_client]
base_url = "http://127.0.0.1"
sender = "test@domain.com"
auth_token = "my-secret-token"
timeout_millis = 10000
```