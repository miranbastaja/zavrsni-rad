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

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/one-instance.drawio.png"),
	caption: [Graf implementacije sa jedom instancom svakog servisa]
)

A kada nam je potrebno više instanca da bi odgovorili na sve dolazeće zahtjeve
graf implementacije izgleda ovako:

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/multi-instance.drawio.png"),
	caption: [Graf implementacije sa više instanca svakog servisa]
)

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
  proslijedi zahtjev obradniku koji je zadužen za tu rutu.

/ HTTP kolačić (engl. cookie): mala datoteka koja internet preglednik sprema po
  zahtjevu poslužitelja. Kolačići se šalju uz svaki sljedeći zahtjev nakon što
  su spremljeni sve dok ne isteknu. U ovom radu se koriste tijekom autentikacije
  na servisu za korisničko sučelje.

/ HTTP zaglavlje (engl. header): dodatna informacija koja se veže uz HTTP
  zahtjev ili odgovor. Primjer zaglavlja koje se koristi u ovom radu je
  `Location` zaglavlje. Ono se koristi na servisu za korisničko sučelje kod svih
  formi kako bi korisnika preusmjerili na stranicu koju želimo da vidi.

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
Servis za korisničko sučelje je zadužen za pružanje grafičkog korisničkog
sučelja korisniku u obliku HTML web stranice. Kako bi uspješno pružali sve
funkcije web aplikacije za upravljanje popisom zadataka potrebno je dizajnirati
sučelje kojim će korisnik pristupiti tim funkcijama i potrebno je kroz dodatne
rute pružiti funkcionalnosti koje nisu vezane uz grafičko sučelje. Zato je u
ovom radu servis za korisničko sučelje podijeljen u dva dijela: rute koje
pružaju stranice tj. rute koje na svaki zahtjev odgovaraju s HTML stranicom i
na rute koje na svaki zahtjev obave neki posao i onda korisnika pošalju natrag
na rutu koja pruža HTML stranicu. Razdjelom poslova pojednostavljeno
implementaciju obradnika - za svaku stranicu znamo da uvijek mora vratiti odgovor
s HTTP kodom 200 (`OK`) i HTML sadržajem, a za svaku dodatnu rutu znamo da
uvijek mora vratiti odgovor s HTTP kodom 303 (`See Other`) i `Location`
zaglavljem koje korisnika šalje natrag na stranicu. Na koju stranicu će ruta
korisnika poslati ovisi o sadržaju korisnikova zahtjeva. Usto dodatna ruta u
odgovor može dodati takozvanu flash poruku (engl. „flash message”) koja se
koristi kako bi informirali korisnika o rezultatu njihovog zahtjeva. Ovakvim
načinom razdjele poslova znatno olakšavamo testiranje stranica i ruta.

== Flash poruke
Flash poruke su glavni mehanizam kojim servis za korisničko sučelje vraća
povratnu informaciju o uspjehu neke akcije korisniku. Bazirane su na HTTP
kolačićima. Kada se stvara novi HTTP kolačić moguće mu je dodati
tzv. „expires” polje koje web pregledniku pruža informaciju o koliko dugo bi
trebao taj kolačić slati uz nasljedne zahtjeve. Ako `expires` polje postavimo
na nulu to znači da će web preglednik samo jednom taj kolačić poslati uz
zahtjev. U ovom radu se s dodatnih ruta vrate dvije informacije: kolačić koji
sadržava poruku o uspjehu akcije i koji ima `expires` polje postavljeno na nulu
i HTTP odgovor sa statusnim kodom 303 (`See Other`). To znači će kolačić koji je
bio postavljen odmah isteći čim web preglednik otiđe na stranicu na koju ga
odgovor upućuje. Sve stranice imaju implementiran mehanizam koji pristigle flash
poruke formatira u HTML.

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/flash-message-success.png"),
	caption: [Primjer flash poruke koja oznaćava da je akcija uspjela]
)
#figure(
	image("img/flash-message-error.png"),
	caption: [Primjer flash poruke koja oznaćava da akcija nije uspjela]
)
#figure(
	image("img/flash-message-warning.png"),
	caption: [Primjer flash poruke koja prikazuje upozorenje]
)

== Stranice
Stranice su rute na servisu za korisničko sučelje koje vraćaju HTML sadržaj.
Postoji šest stranica u ovom radu: index i login stranice, stranica
za stvaranje novog računa, stranica za pregled svih zadataka, stranica za
korisničke postavke i na kraju stranica za uređivanje postojećeg zadatka.

=== Index stranica
Index stranica je prva stranica koju korisnik vidi kada posjeti web aplikaciju.
Nalazi se na `GET /` ruti, a u ovom radu indeks stranica opisuje čemu služi ova
web aplikacija i kako je napravljena.

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/pages/index.png"),
	caption: [Izgled index stranice]
)

=== Login i signup stranice
Login stranica nalazi se na `GET /login` ruti, a postoji kako bi korisnik mogao
pristupiti svom računu. Cijela stranica se sastoji od jedne forme koja obrađuje
`POST` zahtjev na `/login` rutu. Ako je zahtjev uspješan, tj. ako je korisnik
unio točno korisničko ime i lozinku, onda ga pošaljemo na stranicu za pregled
svih zadataka. Naprotiv, ako je korisnik unio krive korisničke podatke vraćamo
ga na login stranicu uz flash poruku koja opisuje da je krive podatke upisao.

// TODO: make typst use other word than Figure in the caption, currently not
// possible but will be https://github.com/typst/typst/pull/283 gets merged
#figure(
	image("img/pages/login.png"),
	caption: [Izgled login stranice]
)
#figure(
	image("img/pages/login-error.png"),
	caption: [Izgled login stranice nakon neuspješnog pokušaja pristupa računu]
)

Signup stranica se nalazi na `GET /signup` ruti i postoji kao jedinu mjesto u
ovoj web aplikaciji gdje korisnik može stvoriti novi račun. Pri stvaranju novog
računa potrebno je unijeti adresu e-pošte koja će biti vezana uz taj račun i
smisliti novo korisničko ime i lozinku. U slučaju da korisnik upiše korisničko
ime ili adresu e-pošte koje već drugi korisnik koristi stvaranje novog računa ne
uspije, a korisnik dobije flash poruku koja opisuje zašto nije uspjelo.
Forma na signup stranici obrađuje zahtjeve na `POST /signup` rutu.

#figure(
	image("img/pages/signup.png"),
	caption: [Izgled signup stranice]
)

=== Stranica za zadatke
Stranica za zadatke postoji kako bi korisnik mogao pregledati sve zadatke koje
je stvorio i kako bi mogao stvoriti nove zadatke. Nalazi se na `GET /tasks`
ruti, a sastoji se od tri glavna dijela. Ti dijelovi su: forma za dodavanje
novih zadataka pri vrhu stranice, popis neriješenih zadataka na sredini stranice
i popis riješenih zadataka na dnu stranice. Dijelovi su poslagani u tom
redoslijedu da bi korisniku bilo olakšano snalaženje u slučaju da ima mnogo
zadataka.

#figure(
	image("img/pages/tasks.png"),
	caption: [Izgled stranice za zadatke]
)

Forma za dodavanje novih zadataka ima polja za naslov zadatka i za puni tekst
zadatka. Zadatak mora imati naslov, a puni tekst je opcionalno polje koje
korisnik može koristiti ako želi detaljnije opisati zadatak. Forma šalje `POST`
zahtjev na `/tasks` rutu.

#figure(
	image("img/add-task-form.png"),
	caption: [Forma za dodavanje novog zadatka]
)

Kada korisnik prvo dođe na stranicu za pregled zadataka, svi zadaci su prikazani
u sažetom obliku. U tom obliku se vidi samo naslov zadatka, a tekst i gumbovi za
akcije su sakriveni. U punom obliku zadatka se vidi tekst kao i gumbovi za
promjenu statusa zadatka, za uređivanje zadatka i za brisanje zadatka.

#figure(
	image("img/task-summary.png"),
	caption: [Primjer zadatka u sažetom obliku]
)

#figure(
	image("img/task-full.png"),
	caption: [Primjer zadatka u punom obliku]
)

Prvi gumb je gumb za promjenu statusa zadatka, on šalje `POST` zahtjev na 
`/tasks/{task_id}/toggle-status` rutu. Drugi gumb je gumb za uređivanje
zadatka i on korisnika šalje na stranicu na kojoj može urediti zadatak.
Ruta te stranice je `GET /tasks/{task_id}/edit`. Treći gumb služi za brisanje
zadatka, a on šalje `POST` zahtjev na `/tasks/{task_id}/delete` rutu.

=== Stranica za uređivanje zadatka
Stranica za uređivanje zadataka nalazi se na `GET /tasks/{task_id}/edit` ruti.
Na stranici postoji jedan obrazac na kojem korisnik može promijeniti status,
naslov i tekst zadatka. Obrazac šalje `POST` zahtjev na `/tasks/{task_id}/edit`
rutu.

#figure(
	image("img/pages/edit-task.png"),
	caption: [Stranica za uređivanja zadataka]
)

#figure(
	image("img/edit-task-form.png"),
	caption: [Obrazac za uređivanja zadataka]
)

=== Stranica za postavke
Stranica za postavke nalazi se na `GET /settings` ruti, a postoji kako bi
korisnik mogao promijeniti važne postavke vezane uz njihov račun. Na toj
stranici postoje forme za promjenu API ključa, lozinke, adrese e-pošte.
Usto postoji i forma za brisanje korisničkog računa.

#figure(
	image("img/pages/settings.png"),
	caption: [Izgled stranice za postavke]
)

Prva forma koja postoji na stranici za postavke je forma koja prikazuje je li
korisnik potvrdio svoju adresu e-pošte. U slučaju da nije potvrdio adresu jer
nije dobio poruku postoji gumb kojim korisnik može zatražiti da mu se ponovo
pošalje poruka za potvrdu. Ova forma šalje `POST` zahtjev na
`/settings/resend-confirmation-email` rutu.

#figure(
	image("img/account-status-form.png"),
	caption: [Izgled forme za status adrese e-pošte]
)

Forma za promjenu adrese e-pošte ima polje za unos nove adrese i zahtjeva
potvrdu putem upisa korisnikove lozinke. Kada korisnik unese novu adresu dobije
na nju poruku kojom može potvrditi da je nova adresa njihova. Ta forma šalje
`POST` zahtjev na `/settings/email` rutu.

#figure(
	image("img/change-email-form.png"),
	caption: [Izgled forme za promjenu adrese epošte]
)

Ispod forme za promjenu adrese e-pošte nalazi se forma za promjenu API ključa.
API ključ se koristi pri autentikaciji na API servisu, a ovdje se ga korisnik
može kopirati za korištenje ili promijeniti u slučaju da su, na primjer, prošli
API ključ slučajno javno objavili. Ova forma šalje `POST` zahtjev na
`/settings/api-key` rutu.

#figure(
	image("img/api-key-form.png"),
	caption: [Izgled forme za promjenu API kljuća]
)

Sljedeća je forma za promjenu lozinke. Kako bi korisnik promijenio lozinku mora
prvo potvrditi da znaju trenutačnu lozinku i onda dvaput unijeti novu. Forma za
promjenu lozinke šalje `POST` zahtjev na `/settings/password` rutu.

#figure(
	image("img/change-password-form.png"),
	caption: [Izgled forme za promjenu lozinke]
)

Zadnja je forma za brisanje korisničkog računa. Kada korisnik izbriše račun gubi
sve zadatke i podatke vezane uz račun. Kako bi izbrisao račun, korisnik treba
potvrditi trenutačno korisničko ime i lozinku. Ova forma šalje `POST` zahtjev na
`/settings/delete-account` rutu.

#figure(
	image("img/delete-account-form.png"),
	caption: [Izgled forme za brisanje korisničkog računa]
)

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
