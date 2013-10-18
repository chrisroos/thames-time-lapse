I'm using this to display images captured from the [LapseIt Pro](https://play.google.com/store/apps/details?id=com.ui.LapseItPro&hl=en) app running on my Samsung Galaxy S2. The images are automatically uploaded to S3 using [FolderSync](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.full&hl=en).

## Deploying to Heroku

    # Configure AWS
    $ heroku config:set AWS_ACCESS_KEY_ID=your-access-key
    $ heroku config:set AWS_SECRET_ACCESS_KEY=your-secret-key

    # Regularly poll S3 for image files
    $ heroku addons:add scheduler
    $ heroku addons:open scheduler
    # Add the `rake s3:download_image_information` task to run every 10 minutes

## Embedding the taken at timestamp in the image

    $ ruby add-caption-to-image.rb \
      ~/path/to/2013-10-18-09-08-03.jpg \
      ./latest.jpg \
      "`ruby print-taken-at.rb \
      ~/path/to/2013-10-18-09-08-03.jpg`"

## Creating a time lapse by joining multiple images

The `-f image2` input format allows me to set the `-pattern_type glob` so that I can use the wildcard pattern in the input filename.

    $ ffmpeg -f image2 -pattern_type glob -i "*-time-slice.jpg" thames-time-slice.mp4

## Setting the EC2 instance up

    # Create a user account that I'll login as
    $ sudo adduser chrisroos
    $ sudo adduser chrisroos sudo

    # Update AWS Route 53 (using the web interface) to give the instance a friendly name

    # Copy my ssh public key to the server
    # *NOTE* This is only necessary if you create a new keypair to access this instance
    $ scp -i ~/Downloads/macbook-air.pem ~/.ssh/id_rsa.pub ubuntu@thames-time-lapse.chrisroos.co.uk:

    # Add my ssh public key to authorized_keys
    $ sudo mkdir /home/chrisroos/.ssh
    $ sudo mv id_rsa.pub /home/chrisroos/.ssh/authorized_keys
    $ sudo chown -R chrisroos: /home/chrisroos/.ssh/
    $ sudo chmod 700 /home/chrisroos/.ssh
    $ sudo chmod 600 /home/chrisroos/.ssh/authorized_keys

    # Update packages
    $ sudo apt-get update

    # Install git
    $ sudo apt-get install git

    # Install pre-requisites for ruby et al
    $ sudo apt-get install build-essential libcurl4-openssl-dev libssl-dev zlib1g-dev ruby-dev apache2-threaded-dev libapr1-dev libaprutil1-dev libreadline-dev

    # Install ruby
    $ curl http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.gz -O
    $ tar -xzf ruby-2.0.0-p247.tar.gz
    $ cd ruby-2.0.0-p247/
    $ ./configure
    $ sudo make install

    # Install bundler
    $ sudo gem install bundler

    # Install s3cmd
    $ sudo apt-get install s3cmd

    # Install Apache 2
    $ sudo apt-get install apache2

    # Install Phusion Passenger
    # From http://www.modrails.com/documentation/Users%20guide%20Apache.html#install_on_debian_ubuntu
    $ gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
    $ gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -
    $ sudo apt-get install apt-transport-https
    $ echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger raring main' | sudo tee /etc/apt/sources.list.d/passenger.list
    $ sudo chown root: /etc/apt/sources.list.d/passenger.list
    $ sudo chmod 600 /etc/apt/sources.list.d/passenger.list
    $ sudo apt-get update
    $ sudo apt-get install libapache2-mod-passenger

    # Install Node for Rails asset compilation
    $ sudo apt-get install nodejs

    # Install postgresql
    $ sudo apt-get install postgresql

    # Configure database and user
    $ sudo -u postgres psql
    postgres=# create user thames_time_lapse nocreatedb nocreateuser password 'password';
    postgres=# create database thames_time_lapse with owner = thames_time_lapse;

## Deploying the app using recap

    $ cap bootstrap
    $ cap deploy:setup

    # Set the DATABASE_URL
    $ cap env:set DATABASE_URL=postgresql://thames_time_lapse:password@localhost/thames_time_lapse

    # Deploy
    $ cap deploy

    # Configure s3cmd for the thames-time-lapse user
    $ s3cmd --configure

    # Set the thames-time-lapse user's shell to bash
    # So that Passenger can pick up environment vars from .bashrc
    $ sudo chsh -s /bin/bash thames-time-lapse

    # Create a .bashrc that loads the recap environment variables
    $ sudo su - thames-time-lapse
    $ echo 'source ~/.recap-env-export' > ~/.bashrc

    # Set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY using recap
    $ cap env:set AWS_ACCESS_KEY_ID=<your-access-key>
    $ cap env:set AWS_SECRET_ACCESS_KEY=<your-secret-key>

## Configuring apache

    $ sudo vi /etc/apache2/sites-available/thames-time-lapse.chrisroos.co.uk.conf

    # Save the following apache virtual host configuration
    <VirtualHost *:80>
        PassengerRuby /usr/local/bin/ruby
        # Set the user because the config.ru is owned by chrisroos - the user that deployed
        PassengerUser thames-time-lapse
        ServerName thames-time-lapse.chrisroos.co.uk
        DocumentRoot /home/thames-time-lapse/app/public
        <Directory /home/thames-time-lapse/app/public>
            Allow from all
            Options -MultiViews
        </Directory>
    </VirtualHost>

    # Make the site available to Apache
    $ sudo a2ensite thames-time-lapse.chrisroos.co.uk.conf

    # Restart Apache
    $ sudo service apache2 reload
