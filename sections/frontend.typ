= Servis za korisničko sučelje
#h(1cm)
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
#h(1cm)
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

#figure(
	image("../img/flash-message-success.png"),
	caption: [Primjer flash poruke koja oznaćava da je akcija uspjela]
)
#figure(
	image("../img/flash-message-error.png"),
	caption: [Primjer flash poruke koja oznaćava da akcija nije uspjela]
)
#figure(
	image("../img/flash-message-warning.png"),
	caption: [Primjer flash poruke koja prikazuje upozorenje]
)

== Stranice
#h(1cm)
Stranice su rute na servisu za korisničko sučelje koje vraćaju HTML sadržaj.
Postoji šest stranica u ovom radu: index i login stranice, stranica
za stvaranje novog računa, stranica za pregled svih zadataka, stranica za
korisničke postavke i na kraju stranica za uređivanje postojećeg zadatka.

=== Index stranica
#h(1cm)
Index stranica je prva stranica koju korisnik vidi kada posjeti web aplikaciju.
Nalazi se na `GET /` ruti, a u ovom radu indeks stranica opisuje čemu služi ova
web aplikacija i kako je napravljena.

#figure(
	image("../img/pages/index.png"),
	caption: [Izgled index stranice]
)

=== Login i signup stranice
#h(1cm)
Login stranica nalazi se na `GET /login` ruti, a postoji kako bi korisnik mogao
pristupiti svom računu. Cijela stranica se sastoji od jedne forme koja obrađuje
`POST` zahtjev na `/login` rutu. Ako je zahtjev uspješan, tj. ako je korisnik
unio točno korisničko ime i lozinku, onda ga pošaljemo na stranicu za pregled
svih zadataka. Naprotiv, ako je korisnik unio krive korisničke podatke vraćamo
ga na login stranicu uz flash poruku koja opisuje da je krive podatke upisao.

#figure(
	image("../img/pages/login.png"),
	caption: [Izgled login stranice]
)
#figure(
	image("../img/pages/login-error.png"),
	caption: [Izgled login stranice nakon neuspješnog pokušaja pristupa računu]
)

#h(1cm)
Signup stranica se nalazi na `GET /signup` ruti i postoji kao jedinu mjesto u
ovoj web aplikaciji gdje korisnik može stvoriti novi račun. Pri stvaranju novog
računa potrebno je unijeti adresu e-pošte koja će biti vezana uz taj račun i
smisliti novo korisničko ime i lozinku. U slučaju da korisnik upiše korisničko
ime ili adresu e-pošte koje već drugi korisnik koristi stvaranje novog računa ne
uspije, a korisnik dobije flash poruku koja opisuje zašto nije uspjelo.
Forma na signup stranici obrađuje zahtjeve na `POST /signup` rutu.

#figure(
	image("../img/pages/signup.png"),
	caption: [Izgled signup stranice]
)

=== Stranica za zadatke
#h(1cm)
Stranica za zadatke postoji kako bi korisnik mogao pregledati sve zadatke koje
je stvorio i kako bi mogao stvoriti nove zadatke. Nalazi se na `GET /tasks`
ruti, a sastoji se od tri glavna dijela. Ti dijelovi su: forma za dodavanje
novih zadataka pri vrhu stranice, popis neriješenih zadataka na sredini stranice
i popis riješenih zadataka na dnu stranice. Dijelovi su poslagani u tom
redoslijedu da bi korisniku bilo olakšano snalaženje u slučaju da ima mnogo
zadataka.

#figure(
	image("../img/pages/tasks.png"),
	caption: [Izgled stranice za zadatke]
)

#h(1cm)
Forma za dodavanje novih zadataka ima polja za naslov zadatka i za puni tekst
zadatka. Zadatak mora imati naslov, a puni tekst je opcionalno polje koje
korisnik može koristiti ako želi detaljnije opisati zadatak. Forma šalje `POST`
zahtjev na `/tasks` rutu.

#figure(
	image("../img/add-task-form.png"),
	caption: [Forma za dodavanje novog zadatka]
)

#h(1cm)
Kada korisnik prvo dođe na stranicu za pregled zadataka, svi zadaci su prikazani
u sažetom obliku. U tom obliku se vidi samo naslov zadatka, a tekst i gumbovi za
akcije su sakriveni. U punom obliku zadatka se vidi tekst kao i gumbovi za
promjenu statusa zadatka, za uređivanje zadatka i za brisanje zadatka.

#figure(
	image("../img/task-summary.png"),
	caption: [Primjer zadatka u sažetom obliku]
)

#figure(
	image("../img/task-full.png"),
	caption: [Primjer zadatka u punom obliku]
)

#h(1cm)
Prvi gumb je gumb za promjenu statusa zadatka, on šalje `POST` zahtjev na 
`/tasks/{task_id}/toggle-status` rutu. Drugi gumb je gumb za uređivanje
zadatka i on korisnika šalje na stranicu na kojoj može urediti zadatak.
Ruta te stranice je `GET /tasks/{task_id}/edit`. Treći gumb služi za brisanje
zadatka, a on šalje `POST` zahtjev na `/tasks/{task_id}/delete` rutu.

=== Stranica za uređivanje zadatka
#h(1cm)
Stranica za uređivanje zadataka nalazi se na `GET /tasks/{task_id}/edit` ruti.
Na stranici postoji jedan obrazac na kojem korisnik može promijeniti status,
naslov i tekst zadatka. Obrazac šalje `POST` zahtjev na `/tasks/{task_id}/edit`
rutu.

#figure(
	image("../img/pages/edit-task.png"),
	caption: [Stranica za uređivanja zadataka]
)

#figure(
	image("../img/edit-task-form.png"),
	caption: [Obrazac za uređivanja zadataka]
)

=== Stranica za postavke
#h(1cm)
Stranica za postavke nalazi se na `GET /settings` ruti, a postoji kako bi
korisnik mogao promijeniti važne postavke vezane uz njihov račun. Na toj
stranici postoje forme za promjenu API ključa, lozinke, adrese e-pošte.
Usto postoji i forma za brisanje korisničkog računa.

#figure(
	image("../img/pages/settings.png"),
	caption: [Izgled stranice za postavke]
)

#h(1cm)
Prva forma koja postoji na stranici za postavke je forma koja prikazuje je li
korisnik potvrdio svoju adresu e-pošte. U slučaju da nije potvrdio adresu jer
nije dobio poruku postoji gumb kojim korisnik može zatražiti da mu se ponovo
pošalje poruka za potvrdu. Ova forma šalje `POST` zahtjev na
`/settings/resend-confirmation-email` rutu.

#figure(
	image("../img/account-status-form.png"),
	caption: [Izgled forme za status adrese e-pošte]
)

#h(1cm)
Forma za promjenu adrese e-pošte ima polje za unos nove adrese i zahtjeva
potvrdu putem upisa korisnikove lozinke. Kada korisnik unese novu adresu dobije
na nju poruku kojom može potvrditi da je nova adresa njihova. Ta forma šalje
`POST` zahtjev na `/settings/email` rutu.

#figure(
	image("../img/change-email-form.png"),
	caption: [Izgled forme za promjenu adrese epošte]
)

#h(1cm)
Ispod forme za promjenu adrese e-pošte nalazi se forma za promjenu API ključa.
API ključ se koristi pri autentikaciji na API servisu, a ovdje se ga korisnik
može kopirati za korištenje ili promijeniti u slučaju da su, na primjer, prošli
API ključ slučajno javno objavili. Ova forma šalje `POST` zahtjev na
`/settings/api-key` rutu.

#figure(
	image("../img/api-key-form.png"),
	caption: [Izgled forme za promjenu API kljuća]
)

#h(1cm)
Sljedeća je forma za promjenu lozinke. Kako bi korisnik promijenio lozinku mora
prvo potvrditi da znaju trenutačnu lozinku i onda dvaput unijeti novu. Forma za
promjenu lozinke šalje `POST` zahtjev na `/settings/password` rutu.

#figure(
	image("../img/change-password-form.png"),
	caption: [Izgled forme za promjenu lozinke]
)

#h(1cm)
Zadnja je forma za brisanje korisničkog računa. Kada korisnik izbriše račun gubi
sve zadatke i podatke vezane uz račun. Kako bi izbrisao račun, korisnik treba
potvrditi trenutačno korisničko ime i lozinku. Ova forma šalje `POST` zahtjev na
`/settings/delete-account` rutu.

#figure(
	image("../img/delete-account-form.png"),
	caption: [Izgled forme za brisanje korisničkog računa]
)

== Dodatne rute
#h(1cm)
Kako bi servis za korisničko sučelje radio, uz rute koje korisniku vraćaju HTML
kod, tj. stranice potrebne su i dodatne rute koje procesiraju obrasce. Te rute
su gore navedene pored opisa obrasca koji procesiraju.

#h(1cm)
U servisu za korisničko sučelje postoje 12 ruta koje obrađuju forme, sve primaju
jedino `POST` metodu zbog ograničenja HTML `<form>` elementa. Te rute su:
- `/login` za pristup korisničkom računu
- `/signup` za stvaranje novog korisničkog računa
- `/logout` za izlazak iz računa
- `/tasks` za stvaranje novog zadatka
- `/tasks/{task_id}/delete` za brisanje postojećeg zadatka
- `/tasks/{task_id}/toggle-status` za promjenu statusa postojećeg zadatka
- `/tasks/{task_id}/edit` za uređivanje postojećeg zadatka
- `/settings/api-key` za promjenu API ključa
- `/settings/email` za promjenu korisnikove adrese e-pošte
- `/settings/password` za promjenu korisnikove lozinke
- `/settings/resend-confirmation-email` kojim korisnik može zatražiti da mu se
  ponovo pošalje poruka za potvrdu adrese e-pošte
- `/settings/delete-account` za brisanje korisnikovog računa


== Autentikacija sesijom
#h(1cm)
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

#pagebreak()
