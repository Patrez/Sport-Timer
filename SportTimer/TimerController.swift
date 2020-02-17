//
//  TimerManager.swift
//  SportTimer
//
//  Created by Patrik Potocek on 15/02/2020.
//

import AVFoundation
import Foundation
import SwiftUIFlux
import UserNotifications

class TimerController {
    let store: Store<AppState>
    let notificationManager: NotificationManager = NotificationManager()

    enum Sound {
        case roundStart, nearRoundEnd, roundEnd, nearRoundStart, half, beep

        var name: String {
            switch self {
            case .roundStart:
                return "roundStart"
            case .roundEnd:
                return "roundEnd"
            case .half:
                return "halfBell"
            case .beep:
                return "beep"
            case .nearRoundEnd:
                return "nearRoundEnd"
            case .nearRoundStart:
                return "nearRoundStart"
            }
        }

        var url: URL {
            Bundle.main.url(forResource: name, withExtension: "wav")!
        }
    }

    var audioPlayer: AVAudioPlayer?

    weak var timer: Timer?

    private let nearEndInterval = 10
    private let countdownCount: TimeInterval = 6

    init(store: Store<AppState>) {
        self.store = store
    }

    func wakeUp() {
        notificationManager.authState(handler: setupNotification)
        if (store.state.timerState.state == .onBreak || store.state.timerState.state == .onRound) && store.state.timerState.pausedTime == nil {
            run()
        }
    }

    func run() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tic(timer:))
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func pause() {
        stop()
        notificationManager.pause()
        store.dispatch(action: TimerActions.Pause(date: Date()))
    }

    func continueTimer() {
        guard let pausedDate = store.state.timerState.pausedTime else {
            return
        }
        let pausedTime = Date().timeIntervalSince(pausedDate)
        notificationManager.reschedule(addTimeInterval: pausedTime)
        store.dispatch(action: TimerActions.Continue(pausedInterval: pausedTime))
        run()
    }

    func reset() {
        notificationManager.clear()
    }

    func scheduleNotifications() {
        play(sound: .roundStart)
        let timerState = store.state.timerState
        let now = Date() 
        (1...timerState.roundCount).forEach { round in
            let roundAndBreakTime = timerState.roundTime + timerState.breakTime

            let roundEndinterval = timerState.roundTime + (round - 1) * roundAndBreakTime
            let endRoundNotification = SportTimerNotification(id: .round_end, round: round, title: "Koniec \(round). kola", message: "", date: now.addingTimeInterval(TimeInterval(roundEndinterval)))

            let halfRoundInterval = timerState.roundTime / 2
            let roundHalfInterval = halfRoundInterval + (round - 1) * roundAndBreakTime
            let halfRoundNotification = SportTimerNotification(id: .round_half, round: round, title: "Polovica \(round). kola", message: "", date: now.addingTimeInterval(TimeInterval(roundHalfInterval)))


            let nearRoundEndInterval = timerState.roundTime - nearEndInterval + (round - 1) * roundAndBreakTime
            if nearRoundEndInterval > 0 {
                let nearRoundEndNotification = SportTimerNotification(id: .round_near_end, round: round, title: "Blízky koniec \(round). kola", message: "", date: now.addingTimeInterval(TimeInterval(nearRoundEndInterval)))
                notificationManager.schedule(notification: nearRoundEndNotification)
            }

            notificationManager.schedule(notifications: [halfRoundNotification, endRoundNotification])

            if round < timerState.roundCount {
                let roundStartInterval = round * roundAndBreakTime
                let roundStartNotification = SportTimerNotification(id: .round_start, round: round, title: "Začiatok \(round). kola", message: "", date: now.addingTimeInterval(TimeInterval(roundStartInterval)))
                notificationManager.schedule(notification: roundStartNotification)

                let nearRoundStartInterval = roundAndBreakTime - nearEndInterval + (round - 1) * roundAndBreakTime
                if nearRoundStartInterval > 0 {
                    let nearRoundStartNotification = SportTimerNotification(id: .round_near_start, round: round, title: "Blízky začiatok \(round). kola", message: "", date: now.addingTimeInterval(TimeInterval(nearRoundStartInterval)))
                    notificationManager.schedule(notification: nearRoundStartNotification)
                }
            }
        }
    }

    func play(sound: Sound) {
        audioPlayer = try? AVAudioPlayer(contentsOf: sound.url)
        audioPlayer?.play()
    }

    private func tic(timer: Timer) {
        let now = Date().clearedNanoseconds
        let timer = store.state.timerState

        if let closestEnd = timer.closestEnd?.clearedNanoseconds, now > closestEnd.addingTimeInterval(-countdownCount), now < closestEnd {
            play(sound: .beep)
        }
        store.dispatch(action: TimerActions.Tic(timerController: self))
    }

    private func setupNotification(for state: UNAuthorizationStatus) {
        switch state {
        case .notDetermined:
            self.notificationManager.askForPermission(handler: self.setupNotification)
        case .denied:
            print("aha")
        case .authorized:
            print("super")
        case .provisional:
            print("wtf")
        default:
            print("pfff")
        }
    }
}
