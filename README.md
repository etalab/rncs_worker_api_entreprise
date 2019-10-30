# Environment setup

## Configuration files

You need the following configuration file as it is excluded from source control.
Create the file `config/rncs_sources.yml` with the content :

```yaml
development:
  local_path_prefix: <FOLDER TO SYNC SOURCE FILES TO>
  ftp_path_prefix: opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies
  import_batch_size: 5_000

test:
  local_path_prefix: ./spec/fixtures
  ftp_path_prefix: ''
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


## Quelques commandes utiles

### Pré-requis

Avant de lancer les commandes d'import des données en base, assurez-vous d'avoir
corrigé les erreurs présentes dans les fichiers CSV comme décrit dans la partie
[Pré-traitement](#pré-traitement-de-mise-en-conformité-à-la-rfc-4180).

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

#### Pré-traitement de mise en conformité à la RFC 4180

De nombreux fichiers CSV transmis les premières années ne sont pas conformes à la
[RFC 4180](https://tools.ietf.org/html/rfc4180), ce qui complique l'analyse des
fichiers CSV sources lors de l'import des données. Ces défauts dans les fichiers
CSV transmis semblent disparaître avec le temps. En effet, en 2019, tous les
fichiers disponibles sur le FTP de l'INPI sont conformes à la RFC 4180. Pour
cause : l'INPI annonce ne plus diffuser de données sujettes à erreurs sur le
FTP. Lorsque l'INPI rencontre une erreur ou une ambiguïté, elle ne la transmet
plus aux utilisateurs et elle fait la demande d'un dossier correctif au greffes
qui sera transmis ultérieurement sous la forme d'un stock partiel.

Bien que les données semblent de meilleure qualité après deux ans de diffusion,
il faut tout de même importer l'ensemble des fichiers transmis depuis le seul et
unique stock du 4 mai 2017, y compris ceux qui sont mal formés... La solution
implémentée consiste à utiliser un parser CSV conforme à la RFC - ce qui ne
devrait soulever aucune erreur à partir de l'année 2019 - et donc d'appliquer un
pré-traitement de mise en conformité sur les fichiers des années 2017 et 2018
qui présentent des défauts.

Pour cela, deux scripts bash sont disponibles dans ce répertoire de sources :
* *clean_csv.bash* qui corrige les erreurs détectées dans les fichiers CSV ;
* *check_rfc4180_compliant.bash* qui permet de vérifier, après coup, que tous
  les fichiers CSV sont dorénavant bien conforme à la RFC.

Le détails des modifications effectuées par le premier script *clean_csv.bash*
n'est pas explicité ici car les corrections réalisées sont documentées en
commentaire dans le script lui même.

#### Exécuter les pré-traitements

Il est nécessaire d'installer quelques dépendances Perl pour que les scripts
puissent fonctionner :

```bash
$ sudo apt-get install libtext-csv-perl
$ sudo cpan install  Text::CSV_XS
```

Ensuite, après avoir récupéré l'ensemble des fichiers de données, exécutez la
commande suivante pour corriger les fichiers invalides :

```bash
$ find <path_to_source_files> -name "*.csv" -print0 | xargs -0I{} clean_csv.bash {}
$ find <path_to_source_files> -name "*.zip" -print0 | xargs -0I{} clean_csv.bash {}
```

Pour vérifier que tous les fichiers respectent à présent le standard du format
CSV vous pouvez lancer la commande ci-dessous :

```bash
$ find <path_to_source_files> -name "*.csv" -print0 | xargs -0I{} check_rfc4180_compliant.bash {}
```

Ce script log les noms de fichiers qui ne sont pas valides au sens de la RFC
4180. Après avoir exécuter le premier script correctif, tous les fichiers de
données devraient être valides. Vous pouvez maintenant [exécuter la tâche
d'import](#import-du-stock) des données en base !

#### Uniformisation des en-têtes de colonnes

Les fichiers CSV transmis ne respectent pas toujours les en-têtes de colonne
de la documentation technique : en fonction des greffes et en fonction du temps
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
En effet, comme les conventions du format CSV ne sont pas toujours respectées,
de même que la procédure d'échange de la donnée entre les greffes et l'INPI, cela
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
$ find flux -type d -exec chmod 755 {} +
$ find flux -type f -exec chmod 644 {} +
```

#### Défaut d'encodage des fichiers CSV
Seulement 2 fichiers de mises à jour quotidiennes (sur environ 1,5 millions de
fichiers à ce jour) ne sont pas encodés en UTF-8 mais en ISO-8859-1. Afin de ne
pas ajouter de complexité supplémentaire au script d'import, ces fichiers ont
été ré-encodés au format UTF-8 manuellement :

* IMR_Donnees_Saisies/tc/flux/2017/05/24/8401/5/8401_5_20170512_212823_11_obs.csv
* IMR_Donnees_Saisies/tc/flux/2017/05/24/5601/5/5601_5_20170512_213441_11_obs.csv

```bash
$ iconv -f iso-8859-1 -t utf-8 file.csv
```

### Les stocks partiels

Certaines mises à jour transmises ne respectent pas les contraintes d'intégrité
de la donné décrite dans la documentation technique et ne sont alors pas
importées en base. Lorsqu'une mise à jour est inapplicable, l'INPI demande le
dossier complet au greffe concerné à des fins de corrections. Ces dossiers
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

Jusqu'ici, les données des Tribunaux d'Instance et des Tribunaux Mixtes de
Commerce étaient transmises au format XML, différent de celui des Tribunaux de
Commerce, et malheureusement inexploitables.

Cette différence de format pour les TITMC ne devrait plus être à partir de la
fin de l'année 2019, période à partir de laquelle les données de ces greffes
seront normalement transmises en respectant le même protocole et le même format
que les TC aujourd'hui.

## Constitution des fiches d'immatriculation au RNCS

Le point d'accès */fiches_identite/:siren* permet d'obtenir la fiche
d'immatriculation principale de l'entreprise au registre national du commerce et
des sociétés pour un numéro siren donné. L'information est valable au jour de la
requête : il n'y a pas d'historique de l'état d'une entreprise à une antérieure.

Pour une entreprise donnée, la fiche est contruite à partir de l'agrégation
de tous les dossiers d'immatriculations - principale et secondaires - présents
en base de données au moment de la requête. Cela demande de faire le tri parmi
différents dossiers pouvant être enregistrés auprès des 148 greffes -
Tribunaux de Commerce et Tribunaux d'Instance et Tribunaux Mixte de Commerce -
qui ont chacun leurs propres règles métier et qui communiquent indépendamment
les mises à jour de leur registre respectif.

Ces disparités de règles et de format compliquent l'exploitation de la donnée ;
dans certains cas, il n'est pas possible de constituer la fiche d'identité de
l'entreprise. L'algorithme et les choix d'implémentation sont détaillés
ci-dessous.

### Contenu de la fiche d'immatriculation principale

La fiche d'immatriculation principale au RNCS représente la carte d'identité à
jour d'une entreprise et contient les informations suivantes :

* le nom du greffe d'immatriculation principale ;
* la raison sociale, le sigle et l'enseigne ;
* l'identifiant de l'entreprise (numéro siren) ;
* la forme juridique ;
* le capital social (montant et devise) ;
* l'adresse du siège (avec les informations de domiciliation le cas échéant) ;
* la durée de vie de la société ;
* la date de création ;
* l'activité (code NAF et détails) ;
* l'adresse de l'établissement principal ;
* l'identité et la fonction des administrateurs et commissaires aux comptes ;
* la date de valeur de la fiche ;
* les observations du Tribunal de Commerce.

### Périmètre couvert par la délivrance d'une fiche d'identité

Aujourd'hui, la fiche d'immatriculation est disponible pour environ 90% des
sociétés enregistrées au RNCS à ce jour.

Compte tenu des difficultées rencontrées à l'import des données des Tribunaux
d'Instance et Tribunaux Mixte de Commerce, il n'est pas encore possible
d'obtenir la fiche d'identité d'une entreprise dont l'immatriculation principale
réside auprès de l'un des ces tribunal.

Le service va continuer d'évoluer pour couvrir un périmètre toujours plus large.
De plus, des dossiers correctifs peuvent être transmis par les greffes et ainsi
corriger par eux même des erreurs rencontrées à la création d'une fiche
d'identité.

### Identification de l'immatriculation principale

Afin d'établir la fiche d'identité, la première étape consiste à identifier
l'immatriculation principale de l'entreprise.

On appelle *dossier principal* tout dossier avec l'attribut
*type_inscription* ayant pour valeur "**P**".

Les données d'identité de la fiche (greffe d'immatriculation, raison sociale,
sigle, forme juridique, ...) sont issues du dossier d'immatriculation
principale.

Un dossier principal est créé à chaque fois qu'une société est immatriculée
chez un greffe, par exemple dans les cas suivant  :
* première inscription dans un Tribunal de Commerce ;
* transfert de siège social à une adresse sous la juridiction d'un
  Tribunal de Commerce différent ;
* nouvelle immatriculation après radiation (un nouveau dossier sera
  créé même si la société est à nouveau immatriculée dans le même greffe
  que lors de la précédente inscription).

A un instant T, une société possède une et une seule immatriculation principale
chez un greffe (tous les autres enregistrements principaux, s'il existent, sont
normalement des dossiers qui ont été radiés). Pour un numéro siren donné, ce
dossier est identifié de la manière suivante :
1. si aucun dossier principal n'est enregistré en base pour ce numéro siren
   les API renvoient un code d'erreur *404 Not Found* avec le message
   "Immatriculation principale non trouvée pour le siren NUM_SIREN." ;
2. si un et un seul dossier principal est trouvé en base, c'est ce dossier
   qui sera utilisé pour constituer la fiche d'identité de l'entreprise ;
3. si plusieurs dossiers principaux sont trouvés en base, le dossier principal
   actif à cet instant est identifié comme étant celui avec l'attribut
   *date_immatriculation* à la date la plus récente. Il y a cependant une
   exception : si l'attribut *date_immatriculation* n'est pas renseigné pour un
   ou plusieurs de ces dossiers principaux, les API renvoient un
   code d'erreur *404 Not Found* avec le message "Immatriculation
   principale non trouvée pour le siren NUM_SIREN." car il n'est alors plus
   possible de décider quel est le bon dossier principal valide. La
   donnée *date_immatriculation* est normalement obligatoire et censé être
   présente dans les données transmisent par les greffes. Il arrive
   cependant, dans certains cas, qu'elle ne soit pas renseignée (dans un peu
   moins de 4000 dossiers).

### Etablissement siège et établissement principal

Les données des établissements siège et principal de la fiche d'identité sont
celles des établissements rattachés au dossier d'immatriculation principale,
quand ils sont présents en base.

Aujourd'hui nous renvoyons une erreur lorsqu'au moins l'un des établissements
est manquant. En cas de doublons (plusieurs établissements taggés comme "siège"
ou "principal" présents en base de données), l'un d'eux est sélectionné
arbitrairement pour constituer la fiche d'identité.

### Données de Gestion, Direction, Administration, Contrôle, Associés ou Membres

Les données d'identité des différents rôles de gestion, administration, contrôle...
affichées dans la fiche sont celles de tous les représentants qui sont rattachés au
dossier d'immatriculation principale préalablement identifié.

### Les décisions judiciaires

Toutes les observations judiciaires rendues par les Tribunaux de Commerce
présentes sur la fiche d'identité sont celles rattachées au dossier
d'immatriculation principale préalablement identifié.

### La date de valeur

La date de valeur indiquée sur la fiche d'identité représente la date à laquelle
les données sont à jour dans le RNCS. Il s'agit de la date de la dernière mise à
jour quotidienne importée en base.

Cette date peut avoir quelques jours de retard par rapport au jour où la requête
est effectuée. En effet, il arrive qu'aucune mise à jour ne soient transmisent
certain jours (le week-end par exemple ; le lundi, la date de valeur sera donc
celle du vendredi d'avant).
