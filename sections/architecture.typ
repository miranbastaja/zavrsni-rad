= Arhitektura rada
#h(1cm)
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

#h(1cm)
Izvršne datoteke oba servisa ne spremaju stanje sesije. Samo servis za
korisničko sučelje zahtijeva spremanje stanja sesije i taj posao prepušta Redis
spremištu ključ vrijednosti koje je dijeljeno između svih instanca tog servisa.
Prepuštanje stanja sesija Redisu omogućava bezbolno horizontalno skaliranje
servisa. U praksi, graf implementacije ovih servisa u slučaju kada nam je samo
jedna instanca dovoljna izgleda ovako:

#figure(
	image("../img/one-instance.drawio.png"),
	caption: [Graf implementacije sa jedom instancom svakog servisa]
)

#h(1cm)
A kada nam je potrebno više instanca da bi odgovorili na sve dolazeće zahtjeve
graf implementacije izgleda ovako:

#figure(
	image("../img/multi-instance.drawio.png"),
	caption: [Graf implementacije sa više instanca svakog servisa]
)

#h(1cm)
Oba servisa su napisana u actix-web frameworku i dijele dio koda koji se bavi
logikom. Pisanje oba servisa sa istim alatima nam omogućava lakši razvoj
aplikacije pošto ne moramo dva puta kod za poslovnu logiku

== Arhitektura web aplikacije u actix-web frameworku
#h(1cm)
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

#h(1cm)
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

#pagebreak()

