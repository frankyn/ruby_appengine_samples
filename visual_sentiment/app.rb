# Copyright 2017 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "date"
require "sinatra"
require "haml"
require "google/cloud/vision"
require "google/cloud/storage"
require "google/cloud/datastore"

# project id
GoogleCloudProject = "spec-test-ruby-samples"

# storage bucket
BucketName = "spec-test-ruby-samples"

# Datastore Entity
DatastoreEntity = "Faces"

# Datastore Key
DatastoreKey = "Face"

# Handle GET requests for /
get "/" do
  # Create a Cloud Datastore client
  datastore = Google::Cloud::Datastore.new project: GoogleCloudProject

  # Get a list of images with likelyhoods from Cloud Datastore
  image_entries_key = datastore.key DatastoreEntity, DatastoreKey

  # Find all image entries
  @image_entries = []
  @image_entries ||= datastore.find_all image_entries_key

  # Render index page
  haml :index
end

# Handle POST requests for /upload_photo
post "/upload_photo" do
  # Retrieve image from POST request parameters
  image      = params[:file][:tempfile]
  image_name = params[:file][:filename]

  # Create a Cloud Storage client
  storage = Google::Cloud::Storage.new project: GoogleCloudProject

  # Get bucket where image will be stored
  bucket = storage.bucket BucketName

  # Upload image
  uploaded_image = bucket.create_file image.path, "images/#{image.name}"

  # Make image public
  uplaoded_image.acl.public!

  # Create a Cloud Vision API client
  vision = Google::Cloud::Vision.new project: GoogleCloudProject

  # Prepare image vision
  image_for_vision = vision.image image

  # Detect a face
  face = image_for_vision.face

  # Likelyhood of joy
  joy_likelyhood = face.likelihood.joy if face

  # Create a Cloud Datastore client
  datastore = Google::Cloud::Datastore.new project: GoogleCloudProject

  # Create a new image entry
  image_entry = datastore.entity DatastoreEntity, DatastoreKey do |t|
    t["name"]         = image_name
    t["joy"]          = joy_likelyhood
    t["storage_path"] = uploaded_image.public_url
    t["timestamp"]    = DateTime.now
  end

  # Save entry in Datastore
  datastore.save image_entry

  # Redirect back to index
  redirect to("/")
end

__END__

@@ layout
%html
  = yield

@@ index
!!!
%html
  %head
    %title Face Detection Sample
  %body
    %h1 Google Cloud Platform - Face Detection Sample
    %p This Ruby Sinatra application demonstrates App Engine Flexible, Google Cloud Storage, and the Cloud Vision API.
    %form(action="upload_photo" method="POST" enctype="multipart/form-data")
      Upload File:
      %input(type="file" name="file")
      %br/
      %input(type="submit" name="submit" value="Submit")
    - if @image_entries
      - @image_entries.each do |image_entry|
        %p %image_entry.name
        %p %image_tag image_entry.storage_path
        %p %image_entry.joy


