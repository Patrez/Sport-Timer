//
//  AppReducer.swift
//  SportTimer
//
//  Created by Patrik Potocek on 15/02/2020.
//

import SwiftUIFlux
import Foundation

func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.timerState = timerStateReducer(state: state.timerState, action: action)
    return state
}

func timerStateReducer(state: TimerState, action: Action) -> TimerState {
    var timerState = state
    switch action {

    case _ as TimerActions.InitialStart:
        timerState.closestEnd = Date().clearedNanoseconds.addingTimeInterval(timerState.roundInterval)
        timerState.state = .onRound

    case _ as TimerActions.Reset:
        timerState.closestEnd = nil
        timerState.pausedTime = nil
        timerState.currentRound = 1
        timerState.state = .initial

    case let action as TimerActions.Pause:
        timerState.pausedTime = action.date

    case let action as TimerActions.Continue:
        timerState.closestEnd = timerState.closestEnd?.addingTimeInterval(action.pausedInterval)
        timerState.pausedTime = nil

    case let action as TimerActions.Tic:
        guard let endTime = timerState.closestEnd, timerState.state != .end else {
            action.timerController.stop()
            break
        }

        if endTime < Date() {
            if timerState.state == .onRound {
                if timerState.currentRound < timerState.roundCount {
                    timerState.currentRound += 1
                    timerState.state = .onBreak
                    timerState.closestEnd = endTime.addingTimeInterval(timerState.breakInterval)
                } else {
                    timerState.state = .end
                }
            } else if timerState.state == .onBreak {
                timerState.state = .onRound
                if timerState.currentRound > timerState.roundCount {
                    timerState.state = .end
                } else {
                    timerState.closestEnd = endTime.addingTimeInterval(timerState.roundInterval)
                }
            }
        }

    case let action as TimerActions.ConfigureTimer:
        timerState = TimerState(roundCount: action.count, roundTime: action.round, breakTime: action.break, currentRound: 1, closestEnd: nil, pausedTime: nil, state: .initial)

    default:
        break
    }

    return timerState
}
