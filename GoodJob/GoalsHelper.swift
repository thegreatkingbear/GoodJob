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
    class func current() -> Goals? {
        // 현재는 현재진행형의 목표가 오직 하나만 있는 걸로 로직을 짬 / 앞으로 어떻게 될지는 모르겠음
        let realm = try! Realm()
        if let goal = realm.objects(Goals.self).filter("isAchieved == false").sorted(byProperty: "startDate", ascending: false).last {
            return goal
        }
        return nil
    }
    
    class func all() -> Results<Goals>? {
        let realm = try! Realm()
        return realm.objects(Goals.self).sorted(byProperty: "startDate", ascending: false)
    }
    
    class func allCount() -> Int {
        if let all = all() {
            return all.count
        }
        return 0
    }
    
    class func add(description: String, desired: Int) -> Void {
        let realm = try! Realm()
        let goal = Goals()
        goal.content = description
        goal.desiredAchievement = desired
        do {
            try realm.write {
                realm.add(goal)
            }
            GoodJobHelper.updateGoal(fromGoal: nil, toGoal: goal)
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
    
    class func completeCurrent() -> Void {
        if let currentGoal = current() {
            if let currentJobs = GoodJobHelper.current(goal: currentGoal) {
                for currentJob in currentJobs {
                    GoodJobHelper.complete(job: currentJob)
                }
            }
        }
    }
}
