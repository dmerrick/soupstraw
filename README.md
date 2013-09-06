# Bitcoin Tracker

## How do I get started?

    bundle install

## How do I start the application?

Start the app by running:

    rake s

This rake command runs `bundle exec shotgun config.ru` behind the scenes for you and starts the app on Sinatra's default port 4567 and will now be able to view the application in your web browser at this URL [http://localhost:4567](http://localhost:4567).

You'll also want to open a new terminal window to the same directory and run `compass watch` to watch the Sass files for changes.

## How do I tell it about my mining rig?

You will need to change the configuration set in `helpers/bitcoin.rb`. If you use Eligius as your pool, you just need to update the `ADDRESS`. Otherwise, you will need to edit `total_mined` to return the total amount you have mined.

You will also need to update the QR code in `public/images/bitcoin_qr_code.png`, because that does not automatically update to reflect your wallet address. Everything else should Just Work though.

## Helper Rake Tasks

There are a few helper Rake tasks that will help you to clear and compile your Sass stylesheets as well as a few other helpful tasks. There is also a generate task, so you can generate a new project at a defined location based on the bootstrap.

    rake -T

    rake css:clear         # Clear the CSS
    rake css:compile       # Compile CSS
    rake css:compile:prod  # Compile CSS for production
    rake s                 # Run the app

