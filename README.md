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
En effet, comme les conventions du format CSV ne sont pas respectés, de même
que la procédure d'échange de la donnée entre les greffes et l'INPI, cela
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

```bash
iconv -f iso-8859-1 -t utf-8 file.csv
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

Le stock ne contient pas toutes les informations présentes dans les flux précédents.
Des bilans sont présents dans les flux antérieurs au stock, mais aussi l'adresse du
siège par exemple.

C'est pour cela que l'import doit se faire de cette façon :

1. Import des flux du 2017/05/18 au 2018/05/05 (inclu)
2. Import du stock du 2018/05/05
3. Import du reste des flux

Ce qui se matérialise par les commandes suivantes (les différents scripts doivent
être lancés manuellement avec les bons paramètres) :
```
bundle exec rake titmc:flux:load[2018/05/05]
bundle exec rake titmc:stock:load
bundle exec rake titmc:flux:load
```

### Stock

Chaque stock pour un greffe donné est composé de une ou deux transissions, car
une tramission ne peut contenir plus de 50 000 dossiers.

L'import des fichiers contenant 50 000 dossiers prend 1h et consomme 6-8Go de mémoire.
Cela est dû au nombre d'ojets crées ainsi que toutes les associations du modèle.

#### En cours en date du 27/03/2019

L'import par annule et remplace est fonctionnel mais fait perdre énormément de données.
En effet il y a beaucoup plus de données dans les flux que dans le stock (dans le stock
il n'y a aucune adresse de siège, aucun bilan, aucun acte et encore d'autres choses moins
cruciales).

L'import du stock doit donc être revu une fois l'opération d'import de flux fonctionnelle.

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

Il y a 3 types de fichiers de flux :

1. RCS: contient les données d'identité
2. BIL: contient uniquement les bilans
3. ACT: contient uniquement les actes

#### Fichiers type RCS

Contient toutes les données d'identité de l'entreprise et peut être intégré en annule
et rempalce. La clef est le _numéro de gestion_, le _siren_ et le _code greffe_ (cela
n'est pas pour autant facile de retrouver l'entreprise ; cf section suivante)

#### Fichiers type BIL et ACT

Ces fichiers ne contiennent que les actes ou les bilans. La clef pour identifier une
entreprise est le _numéro de gestion_ et le _code greffe_.

Cela génère deux problèmes :

1. Il peut exister plusieurs sirens associés à au couple _numéro de gestion_ et _code greffe_
il est impossible de savoir à quelle entreprise cette donnée fait référence
2. Comme les fichiers BIL/ACT arrivent séparemment des fichiers RCS, il est possible d'avoir
les bilans avant le dossier de l'entreprise et vice et versa. L'import. Ainsi lorsque la donnée
d'identité arrive il faut retrouver les bilans déjà crées et les lier au nouveau dossier. Et
inversement.

#### En cours en date du 27/03/2019

La solution technique pour importer simplement et efficacemment les flux n'a pas été décidé pour
résoudre ces deux problèmes. Et l'import des flux n'est pas encore opérationnel.

La solution actuellement à l'étude et d'importer tant qu'il n'y a pas deux dossiers en conflits
et logger l'erreur précisement. Ainsi les blians et les actes peuvent exister _sans dossier_ (et
non pas avec un dossier vide), cela implique quelques changement dans le modèle.

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
l'immatriculation principale de l'entreprise. Cette information est renseignée
dans le champ *type_inscription* du dossier : "P" pour principale, "S" pour
secondaire.

Les données d'identité de la fiche (greffe d'immatriculation, raison sociale,
sigle, forme juridique, ...) sont celles du dossier d'immatriculation
principale.

Bien que l'immatriculation principale au RNCS soit unique pour une entreprise,
il est parfois compliqué d'identifier la dernière en date. Par exemple, dans le
cas d'un transfert de siège sociale donnant lieu à une nouvelle immatricualtion
dans un greffe différent de celui d'origine, il est possible de trouver deux
immatriculations principales en base pour un même numéro siren. Ceci arrive
lorsque le greffe final transmet la donnée à jour avant le greffe d'origine,
lorsque les champs *date_transfert* ou *date_radiation* ne sont pas renseignés,
ou encore si la mise à jour est rejetée pour avoir causé une erreur à
l'import...

A ce jour, et dans un premier temps, seules sont disponibles les fiches
d'identité pour une entreprise dont une et une seule immatriculation principale
est trouvée en base.

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
