= Uvod
#h(1cm)
Cilj ovog rada je prikazati web aplikaciju za izradu i korištenje popisa zadataka. 

#h(1cm)
Popis zadataka (engl. „to-do list”) je sustav za organizaciju obavljenih i
planiranih zadataka kako bi mogli lakše pratiti naše obaveze. Poslovni ljudi i
studenti često koriste popise zadataka jer im olakšavaju snalaženje među
brojnim obavezama.

#h(1cm)
Tradicionalno su se popisi zadataka pisali na papiru, u planerima ili digitalno
u tekstualnoj datoteci. Međutim, takvi načini imaju nekoliko nedostataka.
Korisnik planer mora nositi sa sobom kad god misli da mu je popis zadataka
potreban, a ako ga izgubi ili slučajno uništi gubi sve informacije koje je imao
u njemu zapisane i nema mogućnost dodavanja poveznica koje prenose dodatne
informacije. Tekstualne datoteke korisnik može lagano kopirati, ali
sinkronizacija tih kopija nije jednostavna i ne pružaju korisničko sučelje za
olakšanje rada. Izradom web aplikacije u ovom radu su riješeni svi prethodno
navedeni problemi.

#h(1cm)
Za izradu web aplikacije potrebno je napraviti ili integrirati: korisničko
sučelje (engl. „front end”) putem kojeg korisnici mogu pristupiti stranici,
serverski kod (engl. „back end”) koji procesira korisničke zahtjeve i bazu
podataka koja sprema podatke. Uz to, u ovom radu je napravljen i JSON REST
API za automatiziran tj. programski pristup korisničkim informacijama.

#h(1cm)
Pošto ovaj rad opisuje izradu web aplikacije, korisničko sučelje mora biti
izrađeno tehnologijama i alatima koji nam pružaju moderni web preglednici. Za
korisničko sučelje korišteni su HTML5, CSS3 i Typescript koji se transpilira u
Javascript.

#h(1cm)
Serverski kod je moguće napraviti sa bilo kojim alatom koji može raditi sa HTTP
protokolom i HTML dokumentima, a u ovom radu je izabran Rust @rust programski
jezik sa actix-web @actix-web frameworkom. Te tehnologije su izabrane zbog
odličnih karakteristika performanse i visoke kvalitete Rust jezika i alata za
Rust jezik.

#h(1cm)
Korištena baza podataka je PostgreSQL @postgres zbog vrhunske dokumentacije i
odlične stabilnosti. Uz te alate korišteni korišteni su i Redis @redis za
spremanje podataka sesije, Astro @astro za olakšanu izradu korisnićkog sučelja
i za kompilaciju TSX i SCSS koda u HTML, Javascript i CSS.

#pagebreak()
