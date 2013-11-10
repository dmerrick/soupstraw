# Soupstraw!

## How do I get started?

    bundle install

## How do I start the application?

Start the app by running:

    rake s

This rake command runs `bundle exec shotgun config.ru` behind the scenes for you and starts the app on Sinatra's default port 4567 and will now be able to view the application in your web browser at this URL [http://localhost:4567](http://localhost:4567).

You'll also want to open a new terminal window to the same directory and run `compass watch` to watch the Sass files for changes.

## How do I add an initial user?

    $ irb # (or tux)

    require './app'
    User.create do |u|
      u.name = "Your Name"
      u.email = "your@email.com"
    end

## Helper Rake Tasks

There are a few helper Rake tasks that will help you to clear and compile your Sass stylesheets as well as a few other helpful tasks. There are also the standard ActiveRecord migration tasks.

    $ rake -T

    rake bitcoin:snapshot      # Take a snapshot of the bitcoin stats
    rake bitcoin:snapshot:all  # Take snapshots for every mining rig
    rake css:clear             # Clear the CSS
    rake css:compile           # Compile CSS
    rake css:compile:prod      # Compile CSS for production
    rake db:create_migration   # create an ActiveRecord migration
    rake db:migrate            # migrate the database (use version with VERSION=n)
    rake db:rollback           # roll back the migration (use steps with STEP=n)
    rake db:schema:dump        # dump schema into file
    rake db:schema:load        # load schema into database
    rake s                     # Run the app

