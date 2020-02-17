//
//  Timer.swift
//  SportTimer
//
//  Created by Patrik Potocek on 26/01/2020.
//

import Foundation

//protocol SportTimerDelegate: AnyObject {
//    func tic(config: SportTimerLogic.Config)
//    func finish()
//    func reset()
//}

//struct Display {
//    var info, countdown, button: String
//}

//class SportTimerLogic: ObservableObject { }
//
//    var config: Config
//
//    private let brain: AppBrain
//
//    private var timer: Timer?
//
//    private lazy var currentTime: Int = config.roundTime
//    private lazy var currentRound: Int = 1
//
//    init(config: Config, brain: AppBrain) {
//        self.config = config
//        self.brain = brain
//
//        display = config.display
//
//        if (config.state == .onBreak || config.state == .onRound) && timer == nil {
//            start()
//        }
//    }
//
//    // MARK: INTERFACE
//
//    @Published private(set) var display: Display
//
//    weak var delegate: SportTimerDelegate?
//
//    func configurate(with config: Config) {
//        self.config = config
//
//        if (config.state == .onBreak || config.state == .onRound) && timer == nil {
//            start()
//        }
//    }
//
//    func actionButtonTapped() {
//        if config.pausedTime == nil {
//            switch config.state {
//            case .initial:
//                initialStart()
//            case .onRound, .onBreak:
//                pause()
//            case .end:
//                reset()
//            }
//        } else {
//            continueTimer()
//        }
//    }
//
//    func start() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tic(timer:))
//    }
//
//    func stop() {
//        invalidateTimer()
//    }
//
//    // MARK: LOGIC
//
//    private func initialStart() {
//        config.closestEnd = Date().clearedNanoseconds.addingTimeInterval(config.roundInterval)
//        config.state = .onRound
//        //display = SportTimerLogic.display(for: config)
//        scheduleNotifications()
//        start()
//    }
//
//    private func pause() {
//
//    }
//
//    private func continueTimer() {
//
//    }
//
//    private func reset() {
//        delegate?.reset()
//    }
//
//    private func scheduleNotifications() {
//        (1...config.roundCount).forEach { round in
//            let roundEndinterval = round * config.roundTime + (round - 1) * config.breakTime
//            let endRoundNotification = SportTimerNotification(id: "\(round)_round_end", title: "\(round). round end", message: "", soundName: "", timeInterval: TimeInterval(roundEndinterval))
//            brain.notificationManager.schedule(notification: endRoundNotification)
//
//            if round < config.roundCount {
//                let breakEndInterval = round * config.roundTime + round * config.breakTime
//                let breakNotification = SportTimerNotification(id: "\(round)_break_end", title: "\(round). break end", message: "", soundName: "", timeInterval: TimeInterval(breakEndInterval))
//                brain.notificationManager.schedule(notification: breakNotification)
//            }
//        }
//
//    }
//
//    private func tic(timer: Timer) {
//        //display = SportTimerLogic.display(for: config)
//
//        guard let endTime = config.closestEnd, config.state != .end else {
//            invalidateTimer()
//            return
//        }
//
//        delegate?.tic(config: config)
//
//        if endTime < Date() {
//            if config.state == .onRound {
//                if config.currentRound < config.roundCount {
//                    config.currentRound += 1
//                    config.state = .onBreak
//                    config.closestEnd = endTime.addingTimeInterval(config.breakInterval)
//                } else {
//                    end()
//                }
//            } else if config.state == .onBreak {
//                config.state = .onRound
//                if config.currentRound > config.roundCount {
//                    end()
//                } else {
//                    config.closestEnd = endTime.addingTimeInterval(config.roundInterval)
//                }
//            }
//        }
//    }
//
//    private func end() {
//        config.state = .end
//        delegate?.finish()
//    }
//
//    private func invalidateTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    // MARK: HELPER FUNCTIONS
//}
