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
    GMSServices.provideAPIKey("AIzaSyC9TbKldN2qRj91FxHl1KC3r7KjUlBXOSk")
    GeneratedPluginRegistrant.register(with: self)

    // Notifications
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let e = error { print("🔔 auth error:", e) }
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // APNs success
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let hexToken = deviceToken.map { String(format: "%02x", $0) }.joined()
    print("✅ APNs device token: \(hexToken)")
    Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // APNs fail
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ APNs registration failed:", error)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Foreground notification style
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  // 🔑 PhonePe callback (VERY IMPORTANT)
  override func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

    let userInfo: [String: Any] = [
      "options": options,
      "openUrl": url
    ]
    NotificationCenter.default.post(
      name: NSNotification.Name("ApplicationOpenURLNotification"),
      object: nil,
      userInfo: userInfo
    )
    return true
  }
}
