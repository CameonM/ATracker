import UserNotifications
import SwiftUI

@main
struct YourApp: App {
    init() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                scheduleMonthlyNotification()
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
