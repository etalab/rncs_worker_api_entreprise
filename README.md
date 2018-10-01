# Setup app

    bundle install                    # Install gems
    psql -f postgresql_setup.txt      # Prepare database
    rake db:migrate                   # Run migrations

