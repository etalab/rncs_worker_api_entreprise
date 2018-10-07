# Setup app

    bundle install                    # Install gems
    psql -f db/postgresql_setup.sql   # Prepare database
    # you should change the path location to somewhere that suits you
    rake project_init:config          # create config files
    rake db:migrate                   # Run migrations
    rake db:migrate RAILS_ENV=test    # Run migrations

