//
//  AppState.swift
//  SportTimer
//
//  Created by Patrik Potocek on 15/02/2020.
//

import Foundation
import SwiftUIFlux

struct AppState: FluxState {
    private var timerStateStore: DefaultsStore<TimerState> = DefaultsStore(key: "actualTimerConfig")

    var timerState: TimerState

    init() {
        timerState = timerStateStore.wrappedValue ?? TimerState.default
    }

    func save() {
        timerStateStore.wrappedValue = timerState
    }
}
