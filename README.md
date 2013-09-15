I'm using this to display images captured from the [LapseIt Pro](https://play.google.com/store/apps/details?id=com.ui.LapseItPro&hl=en) app running on my Samsung Galaxy S2. The images are automatically uploaded to S3 using [FolderSync](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.full&hl=en).

## Deploying to Heroku

    # Configure AWS
    $ heroku config:set AWS_ACCESS_KEY_ID=your-access-key
    $ heroku config:set AWS_SECRET_ACCESS_KEY=your-secret-key

    # Regularly poll S3 for image files
    $ heroku addons:add scheduler
    $ heroku addons:open scheduler
    # Add the `rake s3:download_image_information` task to run every 10 minutes

## Creating a time lapse by joining multiple images

The `-f image2` input format allows me to set the `-pattern_type glob` so that I can use the wildcard pattern in the input filename.

    $ ffmpeg -f image2 -pattern_type glob -i "*-time-slice.jpg" thames-time-slice.mp4
