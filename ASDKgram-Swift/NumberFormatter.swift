//
//  NumberFormatter.swift
//  ASDKgram-Swift
//
//  Created by Daniel on 2018/12/5.
//  Copyright © 2018 Daniel. All rights reserved.
//

import Foundation

extension NumberFormatter {
    static let decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
