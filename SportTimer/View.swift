//
//  ContentView.swift
//  SportTimer
//
//  Created by Patrik Potocek on 13/01/2020.
//

import SwiftUI
import SwiftUIFlux

struct TimerView: View {
    //@ObservedObject var sportTimer: SportTimerLogic
    @EnvironmentObject private var store: Store<AppState>
    @State private var settingsIsOpen: Bool = false
    @State private var showReset: Bool = false

    let timerController: TimerController

    private func mainButtonTapped() {
        let timerState = store.state.timerState
        if timerState.pausedTime == nil {
            switch timerState.state {
            case .initial:
                start()
            case .onRound, .onBreak:
                pause()
            case .end:
                reset()
            }
        } else {
            continueTimer()
        }
    }

    private func start() {
        store.dispatch(action: TimerActions.InitialStart())
        timerController.scheduleNotifications()
        timerController.run()
    }

    private func reset() {
        showReset = false
        store.dispatch(action: TimerActions.Reset())
        timerController.reset()
    }

    private func pause() {
        showReset = true
        timerController.pause()
    }

    private func continueTimer() {
        showReset = false
        timerController.continueTimer()
    }

    private func settings() -> some View {
        let timer = store.state.timerState
        return SettingsView(selectedRoundIndex: timer.roundTime / 60 - 1, selectedBreakIndex: timer.breakTime / 60 - 1, selectedRoundCountIndex: timer.roundCount - 1).environmentObject(store)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 50) {
                VStack(alignment: .center, spacing: 10) {
                    Text(store.state.timerState.display.info)
                        .font(.subheadline)
                        .fontWeight(.regular)
                    Text(store.state.timerState.display.countdown)
                        .font(.largeTitle)
                        .fontWeight(.light)
                }
                HStack(alignment: .center, spacing: 30) {
                    Button(store.state.timerState.display.button) {
                        self.mainButtonTapped()
                    }
                    if showReset {
                        Button("REŠTART") {
                            self.reset()
                        }
                    }
                }
            }
            Button("Nastavenie") {
                self.settingsIsOpen.toggle()
            }
            .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: -16, y: 15)
        }
        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .center)
        .sheet(isPresented: $settingsIsOpen, onDismiss: {
            self.settingsIsOpen = false
        }) {
            self.settings()
        }
    }
}

struct SettingsView: View {
    var roundValues: [String] = (1...120).map { "\($0) min" }
    var breakValues: [String] = (1...120).map { "\($0) min" }
    var roundCountValues: [String] = (1...13).map { "\($0)" }

    @EnvironmentObject private var store: Store<AppState>
    @State var selectedRoundIndex: Int
    @State var selectedBreakIndex: Int
    @State var selectedRoundCountIndex: Int
    @Environment(\.presentationMode) var presentationMode

    private func use() {
        store.dispatch(action: TimerActions.ConfigureTimer(round: (selectedRoundIndex + 1) * 60, break: (selectedBreakIndex + 1) * 60, count: selectedRoundCountIndex + 1))
        store.state.save()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            HStack {
                InervalPicker(selected: $selectedRoundIndex, header: "Čas kola", values: roundValues)
                InervalPicker(selected: $selectedBreakIndex, header: "Prestávka", values: breakValues)
            }
            InervalPicker(selected: $selectedRoundCountIndex, header: "Počet kôl", values: roundCountValues)
            Button("POUŽIŤ") { self.use() }
        }
        .padding(.top, 40)
        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .top)
    }
}

struct InervalPicker: View {
    @Binding var selected: Int

    let header: String
    let values: [String]

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(header).font(.headline)
            Picker(selection: $selected, label: EmptyView()) {
                ForEach(0..<values.count) {
                    Text(self.values[$0])
                }
            }
            .frame(minWidth: 100, idealWidth: 300, maxWidth: .infinity, minHeight: 100, idealHeight: 150, maxHeight: 200, alignment: .center)
            .clipped()
            .labelsHidden()
        }
    }
}


//struct TimerPreview: PreviewProvider {
//    static var previews: some View {
//
//        TimerView(sportTimer: SportTimerLogic(config: SportTimerLogic.Config.defaultConfig, notificationManager: NotificationManager()))
//            //.previewDevice("iPhone SE")
//    }
//}
