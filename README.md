# HesApp - Subscription Tracker App

## Introduction
HesApp is a subscription tracker application designed to help users manage their subscriptions efficiently. Users can select their subscribed services and visualize their monthly or annual spending.

This application, developed using **SwiftUI**, efficiently manages user data, subscriptions, and service information using Firestore and SwiftData. Upon launch, user data, subscriptions, and service details are downloaded from Firestore. SwiftData is utilized to store this data locally, ensuring that unnecessary internet data retrievals are avoided after the initial launch.
For instance; when a user deletes a subscription, it is removed from both SwiftData and Firestore. The application then fetches the updated data from Firestore, keeping everything in sync.

Additionally, users can customize the app's theme according to their preferences. The application supports two language options: Turkish and English, allowing users to switch between languages seamlessly.


Here's a video of the application on Youtube:

<a href="https://www.youtube.com/watch?v=xzYlwQXcpyA" target="_blank">
    <img src="https://img.youtube.com/vi/xzYlwQXcpyA/maxresdefault.jpg" alt="Watch the video" width="500" />
</a>

