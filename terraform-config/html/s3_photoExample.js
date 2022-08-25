/**
 * Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * This file is licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License. A copy of
 * the License is located at
 *
 * http://aws.amazon.com/apache2.0/
 *
 * This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

//snippet-sourcedescription:[s3_PhotoExample.js demonstrates how to manipulate photos in albums stored in an Amazon S3 bucket.]
//snippet-service:[s3]
//snippet-keyword:[JavaScript]
//snippet-sourcesyntax:[javascript]
//snippet-keyword:[Code Sample]
//snippet-keyword:[Amazon S3]
//snippet-sourcetype:[full-example]
//snippet-sourcedate:[]
//snippet-sourceauthor:[AWS-JSDG]

// ABOUT THIS NODE.JS SAMPLE: This sample is part of the SDK for JavaScript Developer Guide topic at
// https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/s3-example-photo-album.html

// snippet-start:[s3.JavaScript.photoAlbumExample.complete]

// snippet-start:[s3.JavaScript.photoAlbumExample.config]
//var config = require('./config.json');
console.log("--------------->");

var configData = config;
var albumBucketName = configData.albumBucketName; //"imagelabeller";
var bucketRegion = configData.bucketRegion; //"eu-central-1";
var IdentityPoolId = configData.IdentityPoolId; //"eu-central-1:430e77e8-b9c9-44b3-9a1d-e79de366b6da";

AWS.config.update({
  region: bucketRegion,
  credentials: new AWS.CognitoIdentityCredentials({
    IdentityPoolId: IdentityPoolId,
  }),
});

var s3 = new AWS.S3({
  apiVersion: "2006-03-01",
  params: { Bucket: albumBucketName },
});
// snippet-end:[s3.JavaScript.photoAlbumExample.config]

// snippet-start:[s3.JavaScript.photoAlbumExample.viewAlbum]
function viewAlbum(albumName) {
  var albumPhotosKey = encodeURIComponent(albumName) + "/";
  s3.listObjects({ Prefix: albumPhotosKey }, function (err, data) {
    if (err) {
      return alert("There was an error viewing your album: " + err.message);
    }
    // 'this' references the AWS.Response instance that represents the response
    var href = this.request.httpRequest.endpoint.href;
    var bucketUrl = href + albumBucketName + "/";
    const photoExtensions = [
      ".jpg",
      ".png",
      ".svg",
      ".jpeg",
      ".gif",
      ".bmp",
      ".wmf",
    ];

    var photos = data.Contents.filter((photo) =>
      photoExtensions.some((extension) => photo.Key.includes(extension))
    ).map(function (photo) {
      var photoKey = photo.Key;
      var photoUrl = bucketUrl + encodeURIComponent(photoKey);
      return getHtml([
        "<span>",
        "<div>",
        '<img style="width:400px;height:400px;" src="' + photoUrl + '"/>',
        "<textarea readonly id =label_" +
          photoKey.replace(/\s/g, "") +
          " name = label_" +
          photoKey +
          '" rows="7" cols ="20">',
        "Click on Show Labels button to see the labels",
        "</textarea>",
        "</div>",
        "<div>",

        '<button id="deletephoto" onclick="deletePhoto(\'' +
          albumName +
          "','" +
          photoKey +
          "')\">",
        "Delete Photo",
        "</button>",

        '<button id="showLabel" onclick="showLabel(\'' +
          albumName +
          "','" +
          photoKey +
          "')\">",
        "Show Labels",
        "</button>",
        "</span>",
        "</div>",
        "</br>",
        "</span>",
      ]);
    });
    var message = photos.length
      ? "<p></p>"
      : "<p>You do not have any photos in this album. Please add photos.</p>";
    var htmlTemplate = [
      message,
      "<div>",
      getHtml(photos),
      "</div>",
      '<input id="photoupload" type="file" accept="image/*">',
      '<button id="addphoto" onclick="addPhoto(\'' + albumName + "')\">",
      "Upload Photo",
      "</button>",
    ];
    document.getElementById("app").innerHTML = getHtml(htmlTemplate);
  });
}
// snippet-end:[s3.JavaScript.photoAlbumExample.viewAlbum]

// snippet-start:[s3.JavaScript.photoAlbumExample.addPhoto]
function addPhoto(albumName) {
  var files = document.getElementById("photoupload").files;
  if (!files.length) {
    return alert("Please choose a file to upload first.");
  }
  var file = files[0];
  var fileName = file.name;
  var albumPhotosKey = encodeURIComponent(albumName) + "/";

  var photoKey = albumPhotosKey + fileName;

  // Use S3 ManagedUpload class as it supports multipart uploads
  var upload = new AWS.S3.ManagedUpload({
    params: {
      Bucket: albumBucketName,
      Key: photoKey,
      Body: file,
    },
  });

  var promise = upload.promise();

  promise.then(
    function (data) {
      alert("Successfully uploaded photo.");
      viewAlbum(albumName);
    },
    function (err) {
      return alert("There was an error uploading your photo: ", err.message);
    }
  );
}
// snippet-end:[s3.JavaScript.photoAlbumExample.addPhoto]

// snippet-start:[s3.JavaScript.photoAlbumExample.deletePhoto]
function deletePhoto(albumName, photoKey) {
  s3.deleteObject({ Key: photoKey }, function (err, data) {
    if (err) {
      return alert("There was an error deleting your photo: ", err.message);
    }
    alert("Successfully deleted photo.");
    viewAlbum(albumName);
  });
}

function showLabel(albumName, photoKey) {
  // Get the image labels here from api gateway
  //e.preventDefault();

  var data = {
    Records: [
      {
        awsRegion: bucketRegion,
        s3: {
          bucket: {
            name: "imagelabeller-ssem-2022-sij", //albumBucketName,
          },
          object: {
            key: photoKey,
          },
        },
      },
    ],
  };

  $.ajax({
    type: "POST",
    url: configData.APIInvokeURL,
    crossDomain: "true",
    contentType: "application/json; charset=utf-8",
    data: JSON.stringify(data),

    success: function (msg, status, jgXHR) {
      // clear form and show a success message
      if (msg.errorMessage) {
        alert(
          "Error finding the label for this image! Please try to upload another picture."
        );
      } else if (msg.body) {
        msgDetails = JSON.parse(msg.body);
        labels = msgDetails[0]["labels"];
        document.getElementById("label_" + photoKey.replace(/\s/g, "")).value =
          getHtml([
            "Label and Confidence:",
            "---------------------",
            labels[0],
            labels[1],
            labels[2],
            labels[3],
            labels[4],
          ]);
      }
    },
    error: function (response) {
      // show an error message
      alert("UnSuccessfull");
    },
  });
}
// snippet-end:[s3.JavaScript.photoAlbumExample.deletePhoto]

// snippet-end:[s3.JavaScript.photoAlbumExample.complete]
