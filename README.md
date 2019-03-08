# Environment setup

## Configuration files

You need the following configuration file as it is excluded from source control.
Create the file `config/rncs_sources.yml` with the content :

```yaml
development:
  path: <YOUR PATH TO SOURCE FILES>
  import_batch_size: 5_000

test:
  path: ./spec/fixtures
  import_batch_size: 3
```

## Run bundler

Run `bundle install`

## Database setup

### Create PostgreSQL role and databases for application

`psql -f postgresql_setup.txt`

### Run migrations


`rails db:migrate`
`rails db:migrate RAILS_ENV=test`


## Data

* Capital social de la forme euros.cents (cents peut etre en mono ou duo digits) ou alors vide

## Quelques commandes utiles

### Récupération des fichiers depuis le serveur FTP de l'INPI

La commande utilisée pour se synchroniser avec le flux de fichiers disponibles
sur le FTP de l'INPI :

```zsh
lftp -u 'login','password' -p 21 opendata-rncs.inpi.fr -e 'set
ftp:use-mode-z true; mirror -c -P 4 --only-missing public/IMR_Donnees_Saisies
~/rncs_data/IMR_Donnees_Saisies; quit'
```

### Import du stock

Il s'agit ici de la commande pour importer un stock, au vrai sens du terme :
un stock complet afin d'initialiser la base. Il ne s'agit pas des stocks
partiels, même s'ils sont rangés au même endroit (le dossier *tc/stocks*).

Il n'y a aujourd'hui qu'un seul stock complet, en date du 4 mai 2017, et il
n'est pas prévu qu'il en soit mis à disposition régulièrement. L'import d'un
stock est donc aujourd'hui une opération manuelle, réalisée excepionnellement :

```ruby
my_stock = { year: '2017', month: '05', day: '04' }
TribunalCommerce::Stock::Operation::Import.call(stock_args: my_stock)
```

Toute la donnée en base sera supprimée avant import pour ne laisser place qu'à
la donnée du stock.

### Import des mises à jour quotidennes

L'import du flux quotidien est réalisé en deux étapes : l'ajout des nouvelles
mises à jours disponibles dans la file d'attente et l'import des mises à jour
dans la file.

La commande suivante sert à remplir la file d'attente avec les nouvelles mises à
jour disponibles :

```ruby
TribunalCommerce::DailyUpdate::Operation::Load.call
```

Il est possible d'utiliser l'option *delay:* (en nombre de jours) pour spécifier
le nombre de jours à attendre avant d'importer les mises à jour. Par exemple, la
commande suivante n'ajoutera pas la mise à jour du jour en cours dans la file
d'attente (ceci permet d'attendre que toutes les transmissions d'une même
journée soient disponibles sur le FTP avant d'importer les mises à jour).

```ruby
TribunalCommerce::DailyUpdate::Operation::Load.call(delay: 1)
```

L'opération récupère la date de la dernière mise à jour importée en base et
place dans la file toute nouvelle mise à jour plus récente.

La commande suivante permet d'importer les mises à jour en attente dans la file,
dans l'ordre :

```ruby
TribunalCommerce::DailyUpdate::Operation::Import.call
```

## Import des données des Greffes des Tribunaux de Commerce

### Traitements des fichiers CSV avant import

#### Uniformisation des en-têtes de colonnes

Les fichiers CSV transmis ne respectent pas toujours les en-têtes de colonne
de la documentation technique : en fonction des Greffes et en fonction du temps
les en-têtes peuvent varier d'un fichier à l'autre (variation de la casse,
présence ou non des guillemets séparateurs, ...). Pour prévenir toute erreur
dûe au parsing des fichiers CSV lors de l'import les en-têtes de tous
les fichiers sont uniformisés :

* Transformation des caractères majuscule en minuscule
* Suppression des espaces vides en début et fin des en-têtes
* Suppression des caractères de ponctuation (le point ".", les guillemets)
* Translitération (suppression des accents, ...)
* [Snake casing](https://fr.wikipedia.org/wiki/Snake_case)

De plus, tous les fichiers relatifs aux représentants possèdent deux colonnes
avec le même en-tête "Siren" ; l'un de ces deux en-têtes est renommé pour tous
les fichiers relatifs aux représentants avant import.

#### Uniformisation de la donnée

Toutes les données des fichiers CSV sont importées en base au format `String`.
En effet, comme les conventions du format CSV ne sont pas respectés, de même
que la procédure d'échange de la donnée entre les Greffes et l'INPI, cela
permet d'importer toutes les données disponibles sans froisser les contraintes
de typage (ou de format de date) de la base de données.

Les API peuvent cependant convertir la donnée en base avant de répondre, pour
par exemple renvoyer la donnée dans un format qui fait sens (dates ou entiers,
...) ou ne serait-ce que pour l'uniformiser (on peut trouver différents formats
de dates dans les fichiers de mises à jour, "06/10/2017" ou "06-10-2017").

Puisque toutes les données sont importées en tant que chaine de caractères, les
espaces blancs et les guillemets en début et fin de chaine sont supprimés avant
import en base.

#### Droits d'accès aux fichiers
Les fichiers CSV étant modifiés avant import (renommage d'un des titres de
colonne "Siren" en doublon par exeple) il faut s'assurer que les fichiers CSV
sont accessibles en lecture et en écriture, ce qui peut potentiellement changer
d'un fichier à l'autre.

```zsh
find flux -type d -exec chmod 755 {} +
find flux -type f -exec chmod 644 {} +
```

#### Défaut d'encodage des fichiers CSV
Seulement 2 fichiers de mises à jour quotidiennes (sur environ 1,5 millions de
fichiers à ce jour) ne sont pas encodés en UTF-8 mais en ISO-8859-1. Afin de ne
pas ajouter de complexité supplémentaire au script d'import, ces fichiers ont
été ré-encodés au format UTF-8 manuellement :

* IMR_Donnees_Saisies/tc/flux/2017/05/24/8401/5/8401_5_20170512_212823_11_obs.csv
* IMR_Donnees_Saisies/tc/flux/2017/05/24/5601/5/5601_5_20170512_213441_11_obs.csv

### Les stocks partiels

Certaines mises à jour transmises ne respectent pas les contraintes d'intégrité
de la donné décrite dans la documentation technique et ne sont alors pas
importées en base. Lorsqu'une mise à jour est inapplicable, l'INPI demande le
dossier complet au Greffe concerné à des fins de corrections. Ces dossiers
correctifs sont transmis sous la forme de stocks partiels et doivent être
traités en annule et remplace.

#### Les cas de mises à jour rejetées

Tout **ajout ou mise** à jour d'un etablissement, d'un représentant ou d'une
observation dont la personne morale ou physique est inconnue (ie n'a jamais été
créée en base) est rejetée.

La documentation précise (pour les établissements, représentants et
observations) qu'une mise à jour sur un objet *dont l'identifiant n'est pas
trouvé en base doit être gérée comme une création*. Nous distinguons deux cas,
par exemple :

* Le dossier de la personne morale (ou physique) identifée par le code et le
  numéro de gestion du greffe concernée par la mise à jour est présente en base,
  mais l'établissement d'ID "X" n'existe pas. Dans ce cas un établissement d'ID
  "X" est inséré en base et rattaché au bon dossier.

* Le dossier de la personne morale (ou physique) identifé par le code et le
  numéro de gestion du greffe *n'existe pas en base*. Créer l'établissement
  reviendrait à créer un dossier "vide" auquel rattacher l'objet... Dans ce
  cas là, la mise à jour est rejetée et un dossier complet sera retransmit à
  terme dans un stock partiel.

#### Mises à jour de dossiers inexistant

Il arrive que des *mises à jour* sur des personnes morales ou physiques (dans
les fichiers PM_EVT et PP_EVT) soient transmisent alors qu'aucune entrée
n'existe en base pour ces dossiers. Dans ces cas là, une demande de dossier
complet est effectuée et ceux-ci seront retransmis dans des stocks partiels.

Dans ces cas là, nous avons fait le choix de créer les dossiers en base en
attendant que les dossiers complets soient disponibles.

## Import des données des Greffes des Tribunaux d'Instance et de Commerce Mixte (TITMC)

_Il faut opérer des fusions et non des remplacements._

Le stock ne contient pas toutes les informations présentes dans les flux précédents.
Des bilans sont présents dans les flux antérieurs au stock, mais aussi l'adresse du
siège par exemple. Et inversement des codes juridiques sont présents dans le stock
mais pas dans les flux antérieurs.

C'est pour cela que l'import doit se faire de cette façon :

1. Import des flux du 2017/05/18 au 2018/05/05 (inclu)
2. Import du stock du 2018/05/05
3. Import du reste des flux

Les différents scripts doivent être lancés manuellement avec les bons paramètres.
```
# As of 3/3/2019 these doesn't exists yet. Soon ;)
bundle exec rake titmc:flux:load[2018/05/05]
bundle exec rake titmc:stock:load
bundle exec rake titmc:flux:load[2018/05/05]
```

### Stock

Chaque stock pour un greffe donné est composé de une ou deux transissions, car
une tramission ne peut contenir plus de 50 000 dossiers.

L'import des fichiers contenant 50 000 dossiers prend 1h et consomme 6-8Go de mémoire.
Cela est dû au nombre d'ojets crées ainsi que toutes les associations du modèle.

#### Fusion des éléments du code greffe '0000'

Chaque fichier XML de stock TITMC et composé de deux balises `<grf cod="1234">`.
La première balise possède l'attribut "cod" qui est le même que le fichier en cours ;
c'est le code du greffe actuellement traité. Par contre la seconde balise contient le
cod='0000'.

Cette seconde balise '0000' ne contient **que** les représentants, les actes,
les bilans, les observations et *quelques* établissements. À l'inverse la première
balise ne contiendra **jamais** de représentants, actes, ou bilans.

Ainsi pour une entreprise donnée on se retrouve avec des informations dans la balise
'1234' et dans la balise '0000'. Ce **ne sont pas** des informations provenant
d'inscriptions secondaires dans d'autres greffes. En effet une entreprise peut avoir
plusieurs inscriptions chez différents greffes.

C'est pour cette raison qu'il faut rattacher ces informations associées au code greffe
'0000' à l'entreprise qui est définie dans la première balise. Cela est fait par
l'opération MergeGreffeZero. Cette entreprise est identifiée par son SIREN
seule information d'identification présente dans la balise '0000'.

P.S : Ceci est une exception des premiers stocks. Les flux suivants n'ont plus cette seconde
balise et les prochains stocks (s'il y a) n'en n'auront pas non plus.

### Flux
