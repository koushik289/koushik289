import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await updateStatus()
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            await updateStatus()
        }
    }

    @MainActor
    func updateStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        self.authorizationStatus = status
    }
}
