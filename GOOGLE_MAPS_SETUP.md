# Google Maps Setup

This app uses Google Maps Flutter to display property locations on a map.

## Prerequisites

1. Get a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (optional, for search functionality)

## Android Setup

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

3. Also add the following permission before the `<application>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## iOS Setup

1. Open `ios/Runner/Info.plist`
2. Add the following keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to show properties on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location to show properties on the map.</string>
```

3. Add your API key in `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Property Location Data

Properties must include `latitude` and `longitude` fields in the database to appear on the map. The Property model has been updated to include these fields.

## Default Location

The map defaults to New York City (40.7128, -74.0060) if no properties with location data are available. You can change this in `lib/features/properties/screens/map_screen.dart` by modifying the `_defaultLocation` constant.
