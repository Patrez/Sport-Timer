//
//  Actions.swift
//  SportTimer
//
//  Created by Patrik Potocek on 15/02/2020.
//

import SwiftUIFlux
import Foundation

struct TimerActions {

    struct InitialStart: Action {}
    struct Reset: Action {}

    struct Pause: Action {
        let date: Date
    }

    struct Continue: Action {
        let pausedInterval: TimeInterval
    }

    struct Tic: Action {
        let timerController: TimerController
    }

    struct ConfigureTimer: Action {
        let round, `break`, count: Int
    }
}
