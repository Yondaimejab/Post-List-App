//
//  String+Extension.swift
//  ImagePostApp
//
//  Created by Joel Alcantara burgos on 7/3/21.
//

import Foundation

extension String {
    var date: Date {
        let dateFormatter = Date.Formatters.longColombia
        dateFormatter.locale = Locale(identifier: "en_CO")
        let newDateString = self.replacingOccurrences(of: "GMT-0500 (Colombia Standard Time)", with: "")
        let resultingDate = dateFormatter.date(from: newDateString)
        return resultingDate ?? Date()
    }
}
