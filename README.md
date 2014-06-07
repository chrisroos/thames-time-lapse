I'm using this to display images captured from the [LapseIt Pro](https://play.google.com/store/apps/details?id=com.ui.LapseItPro&hl=en) app running on my Samsung Galaxy S2. The images are automatically uploaded to S3 using [FolderSync](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.full&hl=en).

## Other infomation about this project

* [Thames time lapse on Trello](https://trello.com/b/lgEc0ano/thames-time-lapse)
* My work notes are in [Fargo](http://thamestimelapse.smallpict.com/)
* There's some data in [Google Drive](https://drive.google.com/folderview?id=0B1Vm0OBha2n1MHV4NVRXc1F1blU&usp=sharing)

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

## Setting up Ubuntu

    # Create a user account that I'll login as
    root$ sudo adduser chrisroos
    root$ sudo adduser chrisroos sudo

    # Update AWS Route 53 (using the web interface) to give the instance a friendly name

    # Copy my ssh public key to the server
    # *NOTE* This is only necessary if you create a new keypair to access this instance
    $ scp ~/.ssh/id_rsa.pub root@thames-time-lapse.chrisroos.co.uk:

    # Add my ssh public key to authorized_keys
    root$ sudo mkdir /home/chrisroos/.ssh
    root$ sudo mv id_rsa.pub /home/chrisroos/.ssh/authorized_keys
    root$ sudo chown -R chrisroos: /home/chrisroos/.ssh/
    root$ sudo chmod 700 /home/chrisroos/.ssh
    root$ sudo chmod 600 /home/chrisroos/.ssh/authorized_keys

    # Update packages
    chrisroos$ sudo apt-get update

    # Install git
    chrisroos$ sudo apt-get install git

    # Install pre-requisites for ruby et al
    chrisroos$ sudo apt-get install build-essential libcurl4-openssl-dev libssl-dev zlib1g-dev ruby-dev apache2-threaded-dev libapr1-dev libaprutil1-dev libreadline-dev

    # Install ruby
    chrisroos$ curl http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz -O
    chrisroos$ tar -xzf ruby-2.1.2.tar.gz
    chrisroos$ cd ruby-2.1.2/
    chrisroos$ ./configure
    chrisroos$ sudo make install

    # Install bundler
    chrisroos$ sudo gem install bundler

    # Install s3cmd
    chrisroos$ sudo apt-get install s3cmd

    # Install Apache 2
    chrisroos$ sudo apt-get install apache2

    # Install Phusion Passenger
    # From https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#install_on_debian_ubuntu
    chrisroos$ gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
    chrisroos$ sudo apt-get install apt-transport-https ca-certificates
    chrisroos$ echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' | sudo tee /etc/apt/sources.list.d/passenger.list
    chrisroos$ sudo chown root: /etc/apt/sources.list.d/passenger.list
    chrisroos$ sudo chmod 600 /etc/apt/sources.list.d/passenger.list
    chrisroos$ sudo apt-get update
    chrisroos$ sudo apt-get install libapache2-mod-passenger
    chrisroos$ sudo a2enmod passenger
    chrisroos$ sudo service apache2 restart

    # Install Node for Rails asset compilation
    chrisroos$ sudo apt-get install nodejs

    # Install postgresql
    chrisroos$ sudo apt-get install postgresql

    # Configure database and user
    chrisroos$ sudo -u postgres psql
    postgres=# create user thames_time_lapse nocreatedb nocreateuser password 'password';
    postgres=# create database thames_time_lapse with owner = thames_time_lapse;

    # Install ImageMagick for image manipulation
    chrisroos$ sudo apt-get install imagemagick

### Installing ffmpeg to create timelapse movies

Before settling on using the binary from gusari.org, I tried a version from jon-severinsson but that seems to be an older version that doesn't support wildcard matching. I also tried to use avconv but that also didn't work with wildcard matching.

    # Use the binary of ffmpeg.
    chrisroos$ curl http://ffmpeg.gusari.org/static/64bit/ffmpeg.static.64bit.latest.tar.gz > ffmpeg.tar.gz
    chrisroos$ tar -xzf ffmpeg.tar.gz
    chrisroos$ rm ffmpeg.tar.gz
    chrisroos$ sudo mv ffmpeg /usr/local/bin/
    chrisroos$ sudo mv ffprobe /usr/local/bin/

## Deploying the app using recap

    $ cap bootstrap
    $ cap deploy:setup

    # Set the DATABASE_URL
    $ cap env:set DATABASE_URL=postgresql://thames_time_lapse:password@localhost/thames_time_lapse

    # Set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY using recap
    $ cap env:set AWS_ACCESS_KEY_ID=<your-access-key>
    $ cap env:set AWS_SECRET_ACCESS_KEY=<your-secret-key>

    # Deploy
    $ cap deploy

    # Set the thames-time-lapse user's shell to bash
    # So that Passenger can pick up environment vars from .bashrc
    chrisroos$ sudo chsh -s /bin/bash thames-time-lapse

    # Configure s3cmd for the thames-time-lapse user
    thames-time-lapse$ s3cmd --configure
    # Access Key: <ACCESS_KEY_FOR_TIME_LAPSE_S3_USER>
    # Secret Key: <SECRET_KEY_FOR_TIME_LAPSE_S3_USER>
    # Encryption password: Leave it blank
    # Path to GPG program: Accept the default
    # Use HTTPS protocol [No]: Accept the default
    # HTTP Proxy server name: Leave it blank

    # Create a .bashrc that loads the recap environment variables
    thames-time-lapse$ echo 'source ~/.recap-env-export' > ~/.bashrc

## Configuring apache

    chrisroos$ sudo vi /etc/apache2/sites-available/thames-time-lapse.chrisroos.co.uk.conf

    # Save the following apache virtual host configuration
    <VirtualHost *:80>
        PassengerRuby /usr/local/bin/ruby
        # Set the user because the config.ru is owned by chrisroos - the user that deployed
        PassengerUser thames-time-lapse
        ServerName thames-time-lapse.chrisroos.co.uk
        DocumentRoot /home/thames-time-lapse/app/public
        <Directory /home/thames-time-lapse/app/public>
            # If Apache version < 2.4
            Allow from all
            Options -MultiViews
            # If Apache version >= 2.4
            Require all granted
        </Directory>
    </VirtualHost>

    # Make the site available to Apache
    chrisroos$ sudo a2ensite thames-time-lapse.chrisroos.co.uk.conf

    # Restart Apache
    chrisroos$ sudo service apache2 reload

## Database dump and restore

    # Create a database dump on the server
    thames-time-lapse$ pg_dump --host="localhost" --username="thames_time_lapse" --format=tar thames_time_lapse | gzip > ./tmp/thames_time_lapse.sql.gz

    # Download the database dump
    $ scp thames-time-lapse.chrisroos.co.uk:/home/thames-time-lapse/app/tmp/thames_time_lapse.sql.gz ./tmp/

    # Restore the database locally
    $ gunzip ./tmp/thames_time_lapse.sql.gz
    $ pg_restore --clean --no-owner --dbname="thames_time_lapse_development" ./tmp/thames_time_lapse.sql
