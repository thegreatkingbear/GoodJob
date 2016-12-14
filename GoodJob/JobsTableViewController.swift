//
//  ViewController.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-14.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import UIKit
import RealmSwift

class JobsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveGoodJobs().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Jobs", for: indexPath) as! JobsTableViewCell
        let job = liveGoodJobs()[indexPath.row]
        cell.contents?.text = job.content
        cell.number?.text = "\(indexPath.row)"
        cell.date?.text = job.date.toFriendlyDateTimeString(false)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func liveGoodJobs() -> [Jobs] {
        let realm = try! Realm()
        let jobs = realm.objects(Jobs.self).filter("isArchived == false").sorted(byProperty: "date", ascending: false)
        return Array(jobs)
    }
    
    @IBAction func addGoodJobButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "잘한일을 적어주세요", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            
            let textField = alert.textFields![0] as UITextField
            
            print("firstName \(textField.text)")
            
            let goodJob = Jobs()
            goodJob.content = textField.text!
            let realm = try! Realm()
            try! realm.write {
                realm.add(goodJob)
            }
            
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "오늘의 잘한일은..."
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)    }
}

