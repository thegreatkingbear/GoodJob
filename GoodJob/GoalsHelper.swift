//
//  GoalsHelper.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-25.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import Foundation
import RealmSwift

class GoalsHelper {
    class func alives() -> [Goals] {
        let realm = try! Realm()
        let goals = realm.objects(Goals.self).filter("isAchieved == false").sorted(byProperty: "startDate", ascending: false)
        return Array(goals)
    }
    
    class func numberOfAlives() -> Int {
        return alives().count
    }
    
    class func add(description: String) -> Void {
        let realm = try! Realm()
        let goal = Goals()
        goal.content = description
        do {
            try realm.write {
                realm.add(goal)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    class func delete(goal: Goals) -> Void {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(goal)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    class func completeAlives() -> Void {
        let realm = try! Realm()
        do {
            for alive in alives() {
                try realm.write {
                    alive.isAchieved = true
                    print(alive)
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
