//
//  GoodJobHelper.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-14.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import Foundation
import RealmSwift

class GoodJobHelper {
    class func alives() -> [Jobs] {
        let realm = try! Realm()
        let jobs = realm.objects(Jobs.self).filter("isArchived == false").sorted(byProperty: "date", ascending: false)
        return Array(jobs)
    }
    
    class func numberOfAlives() -> Int {
        return alives().count
    }
    
    class func add(description: String, completionHandler:@escaping(Bool) -> Void) -> Void {
        let realm = try! Realm()
        let goodJob = Jobs()
        goodJob.content = description
        do {
            try realm.write {
                realm.add(goodJob)
            }
            completionHandler(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
    
    class func completeAlives(handler:@escaping(Bool) -> Void) -> Void {
        let realm = try! Realm()
        do {
            for alive in alives() {
                try realm.write {
                    alive.isArchived = true
                    print(alive)
                }
            }
            handler(true)
        } catch let error as NSError {
            print(error.localizedDescription)
            handler(false)
        }
    }
}
