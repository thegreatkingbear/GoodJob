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
    class func ofGoal(goal: Goals?) -> Results<Jobs>? {
        let realm = try! Realm()
        return realm.objects(Jobs.self).filter("goal == %@", goal as Any).sorted(byProperty: "date", ascending: false)
    }
    
    class func ofGoalCount(goal: Goals?) -> Int {
        if let current = ofGoal(goal: goal) {
            return current.count
        }
        return 0
    }
    
    class func current() -> Results<Jobs>? {
        let realm = try! Realm()
        let goal = GoalsHelper.current()
        return realm.objects(Jobs.self).filter("goal == %@ AND isArchived == false", goal as Any).sorted(byProperty: "date", ascending: false)
    }
    
    class func currentCount() -> Int {
        if let current = current() {
            return current.count
        }
        return 0
    }
    
    class func add(description: String) -> Void {
        let realm = try! Realm()
        let goodJob = Jobs()
        goodJob.content = description
        goodJob.goal = GoalsHelper.current()
        do {
            try realm.write {
                realm.add(goodJob)
            }
            GoalsHelper.checkIfCurrentGoalMet()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    class func delete(job: Jobs) -> Void {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(job)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    class func complete(job: Jobs) -> Void {
        let realm = try! Realm()
        do {
            try realm.write {
                job.isArchived = true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    class func updateGoal(fromGoal: Goals?, toGoal: Goals, completion:@escaping(Bool) -> Void) -> Void {
        let realm = try! Realm()
        if let unassigned = ofGoal(goal: fromGoal) {
            for one in unassigned {
                do {
                    try realm.write {
                        one.goal = toGoal
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            completion(true)
        }
    }
}
