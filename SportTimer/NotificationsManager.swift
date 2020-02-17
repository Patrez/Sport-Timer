//
//  NotificationManager.swift
//  SportTimer
//
//  Created by Patrik Potocek on 02/02/2020.
//

import UserNotifications

struct SportTimerNotification: Codable {
    let id: Id
    let round: Int
    let title, message: String
    var date: Date

    enum Id: String, Codable {
        case round_end, round_start, round_half, round_near_end, round_near_start

        var soundName: String {
            switch self {
            case .round_end:
                return TimerController.Sound.roundEnd.name + ".wav"
            case .round_start:
                return TimerController.Sound.roundStart.name + ".wav"
            case .round_half:
                return TimerController.Sound.half.name + ".wav"
            case .round_near_end:
                return TimerController.Sound.nearRoundEnd.name + ".wav"
            case .round_near_start:
                return TimerController.Sound.nearRoundStart.name + ".wav"
            }
        }
    }
}

class NotificationManager: NSObject {
    private let center = UNUserNotificationCenter.current()
    private let notificationsStore = DefaultsStore<[SportTimerNotification]>(key: "notificationsStoreKey")

    override init() {
        super.init()
        center.delegate = self
    }

    func authState(handler: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { setings in
            handler(setings.authorizationStatus)
        }
    }

    func askForPermission(handler: @escaping (UNAuthorizationStatus) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in
            self.authState(handler: handler)
        }
    }

    func schedule(notifications: [SportTimerNotification]) {
        notifications.forEach(schedule(notification:))
    }

    func schedule(notification: SportTimerNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = UNNotificationSound(named: UNNotificationSoundName(notification.id.soundName))
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second, .nanosecond], from: notification.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id = "\(notification.round)|\(notification.id.rawValue)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func pause() {
        center.getPendingNotificationRequests { requests in
            self.notificationsStore.wrappedValue = requests.compactMap(self.sportNotifications(from:))
            self.clear()
        }
    }

    func reschedule(addTimeInterval: TimeInterval) {
        guard var notifications = notificationsStore.wrappedValue else {
            return
        }

        for i in 0...notifications.count - 1 {
            notifications[i].date.addTimeInterval(addTimeInterval)
        }

        schedule(notifications: notifications)
    }

    func clear() {
        center.removeAllPendingNotificationRequests()
    }

    private func sportNotifications(from request: UNNotificationRequest) -> SportTimerNotification? {
        let split = request.identifier.split(separator: "|")
        guard split.count == 2 else {
            return nil
        }
        let id = SportTimerNotification.Id(rawValue: String(split[1]))!
        let round = Int(split[0])!
        let date = Calendar.current.date(from: (request.trigger as! UNCalendarNotificationTrigger).dateComponents)!
        return SportTimerNotification(id: id, round: round, title: request.content.title, message: request.content.body, date: date)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }


}
