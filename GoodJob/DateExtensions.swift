//
//  DateExtensions.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-14.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import Foundation

extension Date {
    func toFriendlyDateTimeString(_ numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        //print(now)
        //print(self)
        let earliest = (now as NSDate).earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        //print(components)
        
        if (components.year! >= 2) {
            return "\(components.year!)년전"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1년전"
            } else {
                return "작년"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)달전"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1달전"
            } else {
                return "지난달"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)주전"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1주전"
            } else {
                return "지난주"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)일전"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1일전"
            } else {
                return "어제"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)시간전"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1시간전"
            } else {
                return "한시간전"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)분전"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1분전"
            } else {
                return "일분전"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)초전"
        } else {
            return "몇초전"
        }
    }
}
