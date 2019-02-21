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

## Récupération des fichiers depuis le serveur FTP de l'INPI

La commande utilisée pour se synchroniser avec le flux de fichiers disponibles
sur le FTP de l'INPI :

```zsh
lftp -u 'login','password' -p 21 opendata-rncs.inpi.fr -e 'set
ftp:use-mode-z true; mirror -c -P 4 --only-missing public/IMR_Donnees_Saisies
~/rncs_data/IMR_Donnees_Saisies; quit'
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
avec le même en-tête "Siren" ; l'un de ces deux en-têtes est renommé.

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
