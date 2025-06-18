// import Flutter
// import UIKit
// import GoogleMaps
//
// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//
//     // Provide the API key for Google Maps
//     GMSServices.provideAPIKey("AIzaSyA5Dqm48zEoIY_KSx1aHGCETkUXKh48OqA")
//
//     // Register the generated Flutter plugins
//     GeneratedPluginRegistrant.register(with: self)
//
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
import UIKit
import Flutter
import Firebase
import GoogleMaps
import UserNotifications
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyA5Dqm48zEoIY_KSx1aHGCETkUXKh48OqA")  // your key
    GeneratedPluginRegistrant.register(with: self)

    // Ask for and register remote notifications
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      if let e = error { print("🔔 auth error:", e) }
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // This is the one & only APNs callback:
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // tell FirebaseAuth about your token – use sandbox in Debug
    #if DEBUG
      Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    #else
      Auth.auth().setAPNSToken(deviceToken, type: .prod)
    #endif
    // for your debugging pleasure, print it too:
    let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
    print("✅ APNs device token: \(hex)")

    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ APNs registration failed:", error)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Optional: show banners when in foreground (iOS 14+)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }
}
