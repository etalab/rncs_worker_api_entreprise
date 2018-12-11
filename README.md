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

## Import des mises à jour quotidiennes

### Tribunaux de Commerce

#### Droits d'accès aux fichiers
Les fichiers CSV relatifs aux représentants étant modifiés avant import
(renommage d'un des titres de colonne "Siren" en doublon) il faut s'assurer que
les fichiers CSV sont accessibles en lecture et en écriture.

`find flux -type f -exec chmod 644 {} +`

#### Défaut d'encodage des fichiers CSV
Seulement 2 fichiers de mises à jour quotidiennes (sur environ 1,5 millions de
fichiers à ce jour) ne sont pas encodés en UTF-8 mais en ISO-8859-1. Afin de ne
pas ajouter de complexité supplémentaire au script d'import, ces fichiers ont
été ré-encodés au format UTF-8 manuellement :

* IMR_Donnees_Saisies/tc/flux/2017/05/24/8401/5/8401_5_20170512_212823_11_obs.csv
* IMR_Donnees_Saisies/tc/flux/2017/05/24/5601/5/5601_5_20170512_213441_11_obs.csv
