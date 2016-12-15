//
//  Jobs.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-14.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import Foundation
import RealmSwift

class Jobs: Object {
    dynamic var content: String = ""
    dynamic var date = Date()
    dynamic var isArchived = false
}
