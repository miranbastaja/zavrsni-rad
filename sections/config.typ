= Konfiguracija servisa
#h(1cm)
Konfiguracija servisa je omogućena kroz konfiguracijsku datoteku u TOML formatu
i kroz varijable okruženja (engl. „environment variables”). Konfiguracijska
datoteka je namijenjena za opću konfiguraciju koja ne sadrži povjerljive
informacije kao što je URL na preko kojeg će servis biti pružen i URL servisa
za slanje e-pošte, dok je konfiguracija kroz varijable okruženja namijenjena za
povjerljive informacije kao što su lozinke od Postgres baze podataka i Redis
servisa, HMAC koda i autentifikacijskog koda za servis e-pošte. Time se slijede
načela takozvanih „Twelve Factor” aplikacija što olakšava razvoj i podizanje
servisa, kao i dijeljenje djelova konfiguracije koji nisu povjerljivi.

#h(1cm)
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
