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
  import_batch_size: 5
```

## Run bundler

Run `bundle install`

## Database setup

### Create PostgreSQL role and databases for application

`psql -f postgresql_setup.txt`

### Run migrations


`rails db:migrate`
`rails db:migrate RAILS_ENV=test`
