//
//  Data+Extension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation

// MARK: - DateFormatter
extension DateFormatter {
    convenience init(withDateFormat dateFormat: String, andLocale locale: String = "es_US") {
        self.init()
        self.dateFormat = dateFormat
        self.locale = Locale(identifier: locale)
        self.amSymbol = "AM"
        self.pmSymbol = "PM"
    }
}

// MARK: - Date
extension Date {
    enum Formatters {
        // UI formatters
        static let short = DateFormatter(withDateFormat: "MMM d") // jan 20
        static let longColombia = DateFormatter(withDateFormat: "EEE MMM dd yyyy HH:mm:ss")
    }

    var short: String {
        return Formatters.short.string(from: self)
    }
}


