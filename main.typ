#include "title-page.typ"

#set heading(numbering: "1.1")
#set page(numbering: "1")
#set text(lang: "hr")
#counter(page).update(1)

#outline(
	title: "Sadržaj",
	depth: 3,
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
protokolom i HTML dokumentima, a u ovom radu je izabran Rust @rust programski
jezik sa actix-web @actix-web frameworkom. Te tehnologije su izabrane zbog
odličnih karakteristika performanse i visoke kvalitete Rust jezika i alata za
Rust jezik.

Korištena baza podataka je PostgreSQL @postgres zbog vrhunske dokumentacije i
odlične stabilnosti. Uz te alate korišteni korišteni su i Redis @redis za
spremanje podataka sesije, Astro @astro za olakšanu izradu korisnićkog sučelja
i za kompilaciju TSX i SCSS koda u HTML, Javascript i CSS.

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
Kako razumjeli bi strukturu web aplikacije u actix-webu prvo moramo znati
nekoliko ključnih pojmova. Ti pojmovi su:

/ URL: engleski akronim za `Universal Resource Locator`, to je putanja do nekog
  sadržaja na internetu. Opći oblik URL-a je
 `schema://domena:port/putanja?parametri#anchor`.

/ ruta (engl. route): opći oblik putanje URL-a. Rute su glavni način kojim web
  aplikacija razlikuje zahtjeve. Postoje dvije vrste ruta: statične i dinamične.
  Dinamične rute nam dopuštaju da odgovorimo na više sličnih zahtjeva koristeći
  istu logiku. Primjer dinamične rute iz ovog rada je `/tasks/{task_id}`.

/ obradnik (engl. handler): funkcija koja primi HTTP zahtjev, obavi nekakav posao
  i onda vrati HTTP odgovor. Tipično se jedan obradnih veže na jednu rutu.

/ posredni sloj (engl. middleware): funkcija koja primi HTTP zahtjev, obavi
  nekakav posao i onda oviseći o logici sloja ili vrati HTTP odgovor ili
  proslijedi zahtjev obradniku.

Svaka web aplikacija napravljena u actix-web frameworku mora sadržavati dvije
glavne komponente. Te komponente su `HttpServer` struktura i `App` struktura.
Obije te strukture obavljaju posao koji je nužan za rad aplikacije.
`HttpServer` je zadužen za komunikaciju naše aplikacije s vanjskim svijetom
što u praksi znači da se pomoću te strukture konfiguriraju postavke kao port,
maksimalni broj konekcija, broj threadova koji procesiraju zahtjeve itd.
`App` struktura je zadužena za svu unutarnju logiku naše aplikacije. U njoj
definiramo rute, obradnike koji odgovaraju na te rute, posredne slojeve itd.
U ovom radu postoje dvije instance `HttpServer` i `App` struktura. Jedan par za
API servis i jedan za servis za korisničko sučelje. Usto postoje dva posredna
sloja koja se bave autentikacijom korisnika, brojne rute i brojni obradnici.

= Model podataka
U bilo kojem softverskom sistemu najlakši način za razumjeti što sistem radi
je znati koje informacije sprema i kako sprema te informacije. U ovom slučaju
sve dugotrajne informacije su spremljene u PostgreSQL bazi podataka.
Shema baze podataka se sastoji od tri tablice - `users`, `tasks` i
`user_tokens`. Baza podataka je normalizirana i tablice su povezane stranim
ključevima. @shema prikazuje dijagram pune sheme baze podataka.

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/db_schema.png"),
	caption: [Dijagram sheme baze podataka]
) <shema>

== Model korisnika
Korisnika obilježavaju jednistveno korisničko ime i jedinstvena adresa za
e-poštu. U bazi podataka se za primarni ključ koristi redak zvan `user_id` koji
sadržava identifikacijske kodove u UUIDv4 formatu. Uz ta polja postoje još i
`status` koji obilježava je li korisnik potvrdio adresu za e-poštu, `api_key`
koji sprema API ključ koji korisnik može upotrijebiti prilikom korištenja API
servisa, `password_hash` koji sprema kriptografski hash lozinke i `created_at`
koji sprema kada je korisnik registrirao račun.

=== Korisničko ime
Korisničko ime je niz alfanumeričkih znakova dug od 1 znaka do 64 znaka.
Ne smiju sadržavati razmake i moraju biti jednistvena tj. ne mogu postojati dva
korisnika sa istim korisničkim imenom. Primjeri pravilnih korisničkih imena su
`peroperic11`, `2fast4u`, `throwaway12312` itd.

=== Lozinka
Kada se korisnik registrira mora postaviti lozinku. Sustav trenutačno zahtijeva
da su lozinke između 8 i 128 znakova dugačke. Lozinke se u bazi podataka
spremaju samo nakon što su provedene kroz argon2 hash algoritam koji preporučava
OWASP.

Limitacija na maksimalnu dužinu lozinke postavljena je kako bi se spriječili
napadi odbijanjem usluge (engl. „denial of service attack”). Bez limitacije,
zlonamjerni korisnik bi mogao poslužitelju poslati dugačku lozinku (> 1000
znakova) koju bi poslužitelj onda morao hashati što bi zauzelo značajnu količinu
vremena i resursa.

=== Adresa e-pošte i status
Pri registraciji svaki korisnik mora unjeti adresu e-pošte, međutim sustav u
trenutku registracije ne može potvrditi da je korisnik zapravo posjeduje adresu
koju je unio, i zato dodjeljuje korisniku status `unconfirmed`. Tada servis za
korisničko sučelje pošalje e-pismo koje sadrži poveznicu za potvrđivanje
računa. Kako bi korisnički račun dobio status `confirmed` korisnik mora
jednostavno posjetiti poveznicu koja se nalazi u navedenom e-pismu, time
potvrđujući da je uistinu vlasnik te adrese. U slučaju da poveznica ne radi
korisnik uvijek može u postavkama zatražiti da im se ponovo pošalje e-pismo s
novom poveznicom.

== Model zadatka
Zadaci (engl. „tasks”) su, u suštini, osnovni sadržaj koji ovaj sustav
korisnicima pomaže menažirati i spremati, a obilježava ih naslov, sadržaj,
status i identifikacijski kod korisnika kojem taj zadatak pripada. U korisničkom
sučelju na stranici za zadatke (`/tasks` ruta) isprva se vidi samo naslov svakog
zadatka, a sadržaj se vidi tek nakon što korisnik mišem pritisne na zadatak.
Uz ta polja u bazi se sprema još i identifikacijski kod zadatka u `task_id`
polju i vrijeme kada je zadatak stvoren u `created_at` polju.

=== Naslov
Naslov zadatka je niz znakova koji, za razliku od korisničkih imena, smije
sadržavati razmake i posebne znakove. Naslovi su limitirani po dužini, smiju
biti najviše 64 znaka dugački. Pri stvaranju novog zadatka razmaci se skidaju
s početka i kraja naslova jer nema razloga da postoje na tim mjestima.

=== Sadržaj
Sadržaj zadatka je, isto kao i naslov, niz znakova koji može sadržavati
posebne znakove. Međutim, za razliku od naslova sadržaj ima dopušta puno veću
dužinu. Maksimalna dužina sadržaja zadatka je sto tisuća znakova.
Sadržaj zadatka je u potpunosti opcionalan i korisnik ga ne mora postaviti ako
misli da im je naslov dovoljno detaljan da opiše zadatak. U bazi podataka
sadržaj zadatka se sprema u `text` polju.

=== Status
Polje `status` u bazi podataka obilježava je li zadatak izvršen.
Moguće vrijednosti `status` polja su `incomplete`, koji je dodijeljen svim
zadacima kada su napravljeni, i `complete`, koji korisnik može dodati zadatku
kako bi označio da je izvršen.

=== Identifikacijski kod korisnika
U `user_id` polju `tasks` tablice sprema se identifikacijski kod korisnika
kojemu taj zadatak pripada. Svaki zadatak obavezno mora imati asociranog
korisnika, a to osigurava PostgreSQL mehanizmom stranih ključeva.
Navedeno `user_id` polje u `tasks` tablici je zapravo strani ključ na `user_id`
polje u `users` tablici. Ova veza je jedan prema više (engl. „one to many”) veza
što znači da korisnik može imati više zadataka, no svaki zadatak može
posjedovati samo jedan korisnik.

= Servis za korisničko sučelje
TODO

== Autentikacija sesijom
Servis za korisničko sučelje provodi autentikaciju putem sesija. Autentikacija
sesijom radi tako da korisnik pošalje HTTP zahtjev koji sadržava njihovo
korisničko ime i lozinku na određenu rutu, u ovom slučaju rade `POST /login`
zahtjev. Onda backend provjerava postoji li korisnik s tim korisničkim imenom
u bazi podataka i odgovara li poslana lozinka spremljenoj. Ako su informacije
koje je korisnik poslao točne server stvara novu sesiju za tog korisnika.
To znači da server generira identifikacijski kod sesije, spremi taj
identifikacijski kod u Redis uz nekoliko dodatnih informacija kao korisničko
ime i onda korisniku pošalje HTTP kolačić koji sadržava identifikacijski kod
sesije. Taj kolačić korisnik pošalje uz svaki zahtjev poslije autentikacije.
Samu autentikaciju obavlja posredni sloj koji je postavljen ispred svih ruta
koje zahtijevaju samo autentificirane korisnike kao što su `/tasks` i
`/settings` rute. Posredni sloj provjerava je li korisnik uz zahtjev poslao
gore navedeni kolačić i postoji li identifikacijski kod sesije sadržan u tom
kolačiću. Ako identifikacijski kod postoji propušta zahtjev obradniku, a ako ne
postoji korisnika pošalje na login stranicu s upozorenjem da mora biti
autentificiran kako bi pristupio ruti na koju je poslao zahtjev.
Za logiku autentikacije je zadužena actix-session biblioteka, a za spremanje
sesija je zadužena Redis baza podataka.

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

#pagebreak()
#bibliography("works.yml")
