= Model podataka
#h(1cm)
U bilo kojem softverskom sistemu najlakši način za razumjeti što sistem radi
je znati koje informacije sprema i kako sprema te informacije. U ovom slučaju
sve dugotrajne informacije su spremljene u PostgreSQL bazi podataka.
Shema baze podataka se sastoji od tri tablice - `users`, `tasks` i
`user_tokens`. Baza podataka je normalizirana i tablice su povezane stranim
ključevima. @shema prikazuje dijagram pune sheme baze podataka.

#figure(
	image("../img/db_schema.png"),
	caption: [Dijagram sheme baze podataka]
) <shema>

== Model korisnika
#h(1cm)
Korisnika obilježavaju jednistveno korisničko ime i jedinstvena adresa za
e-poštu. U bazi podataka se za primarni ključ koristi redak zvan `user_id` koji
sadržava identifikacijske kodove u UUIDv4 formatu. Uz ta polja postoje još i
`status` koji obilježava je li korisnik potvrdio adresu za e-poštu, `api_key`
koji sprema API ključ koji korisnik može upotrijebiti prilikom korištenja API
servisa, `password_hash` koji sprema kriptografski hash lozinke i `created_at`
koji sprema kada je korisnik registrirao račun.

=== Korisničko ime
#h(1cm)
Korisničko ime je niz alfanumeričkih znakova dug od 1 znaka do 64 znaka.
Ne smiju sadržavati razmake i moraju biti jednistvena tj. ne mogu postojati dva
korisnika sa istim korisničkim imenom. Primjeri pravilnih korisničkih imena su
`peroperic11`, `2fast4u`, `throwaway12312` itd.

=== Lozinka
#h(1cm)
Kada se korisnik registrira mora postaviti lozinku. Sustav trenutačno zahtijeva
da su lozinke između 8 i 128 znakova dugačke. Lozinke se u bazi podataka
spremaju samo nakon što su provedene kroz argon2 hash algoritam koji preporučava
OWASP.

#h(1cm)
Limitacija na maksimalnu dužinu lozinke postavljena je kako bi se spriječili
napadi odbijanjem usluge (engl. „denial of service attack”). Bez limitacije,
zlonamjerni korisnik bi mogao poslužitelju poslati dugačku lozinku (> 1000
znakova) koju bi poslužitelj onda morao hashati što bi zauzelo značajnu količinu
vremena i resursa.

=== Adresa e-pošte i status
#h(1cm)
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
#h(1cm)
Zadaci (engl. „tasks”) su, u suštini, osnovni sadržaj koji ovaj sustav
korisnicima pomaže menažirati i spremati, a obilježava ih naslov, sadržaj,
status i identifikacijski kod korisnika kojem taj zadatak pripada. U korisničkom
sučelju na stranici za zadatke (`/tasks` ruta) isprva se vidi samo naslov svakog
zadatka, a sadržaj se vidi tek nakon što korisnik mišem pritisne na zadatak.
Uz ta polja u bazi se sprema još i identifikacijski kod zadatka u `task_id`
polju i vrijeme kada je zadatak stvoren u `created_at` polju.

=== Naslov
#h(1cm)
Naslov zadatka je niz znakova koji, za razliku od korisničkih imena, smije
sadržavati razmake i posebne znakove. Naslovi su limitirani po dužini, smiju
biti najviše 64 znaka dugački. Pri stvaranju novog zadatka razmaci se skidaju
s početka i kraja naslova jer nema razloga da postoje na tim mjestima.

=== Sadržaj
#h(1cm)
Sadržaj zadatka je, isto kao i naslov, niz znakova koji može sadržavati
posebne znakove. Međutim, za razliku od naslova sadržaj ima dopušta puno veću
dužinu. Maksimalna dužina sadržaja zadatka je sto tisuća znakova.
Sadržaj zadatka je u potpunosti opcionalan i korisnik ga ne mora postaviti ako
misli da im je naslov dovoljno detaljan da opiše zadatak. U bazi podataka
sadržaj zadatka se sprema u `text` polju.

=== Status
#h(1cm)
Polje `status` u bazi podataka obilježava je li zadatak izvršen.
Moguće vrijednosti `status` polja su `incomplete`, koji je dodijeljen svim
zadacima kada su napravljeni, i `complete`, koji korisnik može dodati zadatku
kako bi označio da je izvršen.

=== Identifikacijski kod korisnika
#h(1cm)
U `user_id` polju `tasks` tablice sprema se identifikacijski kod korisnika
kojemu taj zadatak pripada. Svaki zadatak obavezno mora imati asociranog
korisnika, a to osigurava PostgreSQL mehanizmom stranih ključeva.
Navedeno `user_id` polje u `tasks` tablici je zapravo strani ključ na `user_id`
polje u `users` tablici. Ova veza je jedan prema više (engl. „one to many”) veza
što znači da korisnik može imati više zadataka, no svaki zadatak može
posjedovati samo jedan korisnik.

#pagebreak()
