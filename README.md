# Photo Slider 1.0 Release Notes 

## Overview
This app is an educational project where users can create an account where they will be able to upload photos and see/like photos uploaded by all others users that use the app.

## Technologies used for this project:
* SwiftUI
* Combine
* Firebase
* ComposableArchitecture 

## Technical features:
* Login with email and password.
* Signup with password confirmation (label presented when not matching passwords detected).
* Session persisted until it is explicitly closed by tapping the logout button.
* Home Screen where photos of all users are presented.
* Nav button that filters posts and present only current user photos.
* Dynamic layout that changes after a photo has been selected to present a preview view before uploading it.
* Tapping the selected image will reopen the image picket to change selection.
* Discard button that removes the selection and set the layout back to normal.
* Double tap on an image to like/dislike it. A heart icon is presented at top-left side of the image with the number of total likes for that particular photo.
* Users are not allowed to like their own photos
* Photos present their timestamp at the bottom-right side
* Loading indicator that is trigger any time an external API is called as user feedback

## TODOs:
* Improve liking photos mechanism performance.
* Error handling: present alerts to handle error paths and avoid user confusion in some flows.
* Listen to the Firestore changes and publish the changes to all users in real time when a new photo is uploaded.
* Testing of user flows by creating mock instances of the firebase manager.
* Improve UX to let users know that they can not like their own photos.
* Create a separate screen for user profile.
* Introduce feature to delete posts.

## How to install:
This project does not use cocoa pods, the dependecies are directely managed by SwiftPackageManager so there is not need to run any special command on terminal to make it build, running the project on Xcode should be enough (it might take few minutes at the first launch).
