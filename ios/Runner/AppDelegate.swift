import Flutter
import UIKit
import GoogleMaps  

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Provide the API key for Google Maps
    GMSServices.provideAPIKey("AIzaSyA5Dqm48zEoIY_KSx1aHGCETkUXKh48OqA")

    // Register the generated Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}