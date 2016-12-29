//
//  Goals.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-25.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import Foundation
import RealmSwift

class Goals: Object {
    dynamic var content: String = ""
    dynamic var startDate = Date()
    dynamic var endDate = Date()
    dynamic var isAchieved = false
    var desiredAchievement = 0
}
