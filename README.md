# SFBG Guide App
> Provide location based plant information in the San Francisco Botanical Garden(SFBG).

## Features

* Explore plants in the SFBG on the map
* Search plants using plant name
* Sort plants by plant type(trees, shrubs, others)
* Save your favorite plants (login required)
* Get notified (while using the app) as you approach to your favorite plants in the SFBG
* Each plant has its own detailed information page including images
* Has a link to the Wikipedia page of specific plant  
* Sign-in using your own email, Facebook or Google login
* After fetching all plants information once, a user can enjoy the app offiline

## Requirements

- iOS 10.3+
- Xcode 8.3
- Cocoapods version 1.21 or later

## Installation

```
$ git clone https://github.com/enzoi/Map_Geofencing.git <YourProjectName>
$ cd <YourProjectName>
$ pod install
$ open <YourProjectName>.xcworkspace
```

To add this app to a Firebase project, use the bundleID from the Xcode project. Download the generated GoogleService-Info.plist file, and copy it to the root directory of the sample you wish to run.
