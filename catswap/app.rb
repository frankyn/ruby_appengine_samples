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
require "rmagick"

STORAGE_BUCKET_NAME = ENV["CLOUD_STORAGE_BUCKET"] 

DATASTORE_KIND = "Faces"

CAT_IMAGE = "images/cat_face.png"

def bounding_dimensions top_right:, top_left:, bottom_left:
    # Euclidean Distance between the top bound verteces
    width = Math.sqrt((top_left[:x] - top_right[:x])**2 +
                        (top_left[:y] - top_right[:y])**2)

    # Euclidean Distance between the right bound verteces
    height = Math.sqrt((top_left[:x] - bottom_left[:x])**2 +
                       (top_left[:y] - bottom_left[:y])**2)
    [width, height]
end

# Handle GET requests for /
get "/" do
  # Create a Cloud Datastore client
  datastore = Google::Cloud::Datastore.new

  # Get a list of images with likelyhoods from Cloud Datastore
  query = Google::Cloud::Datastore::Query.new
  query.kind DATASTORE_KIND

  @image_entries = datastore.run query

  # Render index page
  haml :index
end

# Handle POST requests for /upload_photo
post "/upload_photo" do
  # Retrieve image from POST request parameters
  image      = params[:file][:tempfile]
  image_name = params[:file][:filename]

  # Create a Cloud Vision API client
  vision = Google::Cloud::Vision.new

  # Prepare image vision
  image_for_vision = vision.image image

  # Detect a face
  face = image_for_vision.face

  if face
    # Found a face to swap!
    # Load human and cat faces
    human_image = Magick::Image.read(image.path).first
    cat_image   = Magick::Image.read(CAT_IMAGE).first

		# Resize cat_face to fit human face bounding box
		# Face bounding box
    human_top_left    = {x: face.bounds.face[0].x,
                         y: face.bounds.face[0].y}
    human_top_right   = {x: face.bounds.face[1].x,
                         y: face.bounds.face[1].y}
    human_bottom_left = {x: face.bounds.face[3].x,
                         y: face.bounds.face[3].y}

		# Get new dimensions for Cat Picture 
		new_dimensions = bounding_dimensions(top_right: human_top_right,
        top_left: human_top_left, bottom_left: human_bottom_left)

		# Resize cat_image
    cat_image.resize! new_dimensions[0], new_dimensions[1] 

		# Create a composite image of the human and cat faces
    human_image.composite!(cat_image, human_top_left[:x],
        human_top_left[:y], Magick::OverCompositeOp)

		# Save the composite image to rendered_face path
    human_image.write image.path 

    # Create a Cloud Storage client
    storage = Google::Cloud::Storage.new

    # Get bucket where image will be stored
    bucket = storage.bucket STORAGE_BUCKET_NAME

    # Upload image
    uploaded_image = bucket.create_file image.path, "images/#{image_name}"

    # Make image public
    uploaded_image.acl.public!

    # Create a Cloud Datastore client
    datastore = Google::Cloud::Datastore.new

    # Create a new image entry
    image_entry = datastore.entity DATASTORE_KIND do |entry|
      entry["name"]         = image_name
      entry["storage_path"] = uploaded_image.public_url
      entry["timestamp"]    = DateTime.now
    end

    # Save entry in Datastore
    datastore.save image_entry
  end

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
    %title CatSwap using Cloud Vision API 
  %body
    %h1 Google Cloud Platform - CatSwap 
    %form(action="upload_photo" method="POST" enctype="multipart/form-data")
      Upload File:
      %input(type="file" name="file")
      %br/
      %input(type="submit" name="submit" value="Submit")

    - if @image_entries
      - @image_entries.each do |image_entry|
        %p
          %img{src: image_entry["storage_path"]}

