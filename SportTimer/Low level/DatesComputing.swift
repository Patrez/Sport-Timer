//
//  Date+Extensions.swift
//  SportTimer
//
//  Created by Patrik Potocek on 26/01/2020.
//

import Foundation

extension Date {
    var clearedNanoseconds: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second], from: self)) ?? self
    }
}

class TimeFormatters {
    static var countdown: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.allowsFractionalUnits = true
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}
