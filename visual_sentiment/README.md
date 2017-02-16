# App Engine and Machine Learning APIS

This is a sample demonstrating how to use App Engine, Datastore, Storage and the
Vision API in Ruby.

## Environment Setup

These are suggestions on how you can setup your environment to begin development
in Ruby. The third-party tools are not recommended and only used as an example. 

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

`gem install bundler`

### Register for Google Cloud Platform

You can register for a free trial by going here:
[https://cloud.google.com/pricing/free](https://cloud.google.com/pricing/free)

### Installing Google Cloud SDK

You can install the Google Cloud SDK by going here:

[https://cloud.google.com/sdk/docs/quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

### Setup the Google Cloud SDK

The first time you use `gcloud`, you will need to set it up by following the
information here:

[https://cloud.google.com/sdk/docs/initializing](https://cloud.google.com/sdk/docs/initializing)

## Overview of the sample

## Sample Setup

After you have setup your environment you can begin using this sample.

1. `git clone http://github.com/frankyn/ruby_appengine_samples.git`
2. `cd ruby_appengine_samples`
3. `bundle install`

## Run the sample locally

1. `bundle exec ruby app.rb`

## Deploy the sample to App Engine

1. gcloud app deploy


