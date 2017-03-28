# App Engine and Machine Learning API

This is a sample demonstrating how to use App Engine, Datastore, Storage and the
Vision API in Ruby.

## Overview of the sample

In this sample app, you will learn how what it takes to generate an app that
uses the [Machine Learning Vision API](https://cloud.google.com/vision/) to
understand if a persons face is joyful! The sample also uses [Cloud Datastore](https://cloud.google.com/datastore/) to
save metadata for each image and [Cloud Storage](https://cloud.google.com/storage/) to
save images to be displayed later.


## Ruby Environment Setup

You can skip these steps if you're using the `Google Cloud Shell`. These are
suggestions on how you can setup your environment to begin development in Ruby.
The third-party tools are not recommended and only used as an example.

### Installing git

You can install git using the following page:

[https://git-scm.com/book/en/v2/Getting-Started-Installing-Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installing Ruby

You can install the latest version of Ruby using the following page:

[https://www.ruby-lang.org/en/documentation/installation/#package-management-systems](https://www.ruby-lang.org/en/documentation/installation/#package-management-systems)

### Installing Bundler

Bundler is used to download dependency `gems` into your Ruby environment without
manually installing each gem.

Use the following command to install Bundler:

```
    gem install bundler
```

## Google Cloud Platform Setup

Create a new project with the [Google Cloud Platform console](https://console.cloud.google.com/).
Make a note of your project ID, which may be different than your project name.

Make sure to [Enable Billing](https://pantheon.corp.google.com/billing?debugUI=DEVELOPERS)
for your project.

Download the [Google Cloud SDK](https://cloud.google.com/sdk/docs/) to your
local machine. Alternatively, you could use the [Cloud Shell](https://cloud.google.com/shell/docs/quickstart), which comes with the Google Cloud SDK pre-installed.

Initialize the Google Cloud SDK (skip if using Cloud Shell):

```
    gcloud init
```

Create your App Engine application:

```
    gcloud app create
```

Set an environment variable for your project ID, replacing `[YOUR_PROJECT_ID]`
with your project ID:

```
    export GOOGLE_CLOUD_PROJECT=[YOUR_PROJECT_ID]
```

## Getting the sample code

Run the following command to clone the Github repository:

```
    git clone https://github.com/frankyn/ruby_appengine_samples.git
```

Change directory to the sample code location:

```
    cd ruby_appengine_samples/visual_sentiment
```

## Authentication

Enable the APIs using the `gcloud` tool:

```
    gcloud service-management enable vision.googleapis.com
    gcloud service-management enable storage-component.googleapis.com
    gcloud service-management enable datastore.googleapis.com
```
Create a Service Account to access the Google Cloud APIs when testing locally:

```
    gcloud iam service-accounts create hackathon \
    --display-name "My Hackathon Service Account"
```

Give your newly created Service Account appropriate permissions:

```
    gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member serviceAccount:hackathon@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
    --role roles/owner
```

After creating your Service Account, create a Service Account key:

```
    gcloud iam service-accounts keys create ~/key.json --iam-account \
    hackathon@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
```

Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to where
you just put your Service Account key:

```
    export GOOGLE_APPLICATION_CREDENTIALS="/home/${USER}/key.json"
```

## Run the sample locally

Create a Cloud Storage bucket. It is recommended that you name it the same as
your project ID:

```
    gsutil mb gs://${GOOGLE_CLOUD_PROJECT}
```

Set the environment variable `CLOUD_STORAGE_BUCKET`:

```
    export CLOUD_STORAGE_BUCKET=${GOOGLE_CLOUD_PROJECT}
```

Start your application locally:

```
    bundle exec ruby app.rb
```

While it runs go to [http://localhost:4567](http://localhost:4567). You can stop
the server by using `Ctrl + c`.

## Deploy the sample to App Engine

Open `app.yaml` and replace `<your-cloud-storage-bucket>` with the name of your
Cloud Storage bucket.

Deploy your application to App Engine using `gcloud`. Please note that this may
take several minutes.

```
    gcloud app deploy
```

Visit `https://[GOOGLE_CLOUD_PROJECT].appspot.com` to view your deployed application.

