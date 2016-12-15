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
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let realm = try! Realm()
        notificationToken = realm.addNotificationBlock({ (notification, realm) in
            self.updateThisView()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateThisView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoodJobHelper.numberOfAlives()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Jobs", for: indexPath) as! JobsTableViewCell
        let job = GoodJobHelper.alives()[indexPath.row]
        cell.contents?.text = job.content
        let orderedNumber = indexPath.row + 1
        cell.number?.text = "\(orderedNumber)"
        cell.date?.text = job.date.toFriendlyDateTimeString(false)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func updateViewTitle(number: Int) -> Void {
        title = "참 잘했어요 \(number)개"
    }
    
    func updateThisView() -> Void {
        updateViewTitle(number: GoodJobHelper.numberOfAlives())
        tableView.reloadData()
    }
    
    @IBAction func addGoodJobButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "잘한일을 적어주세요", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            
            let textField = alert.textFields![0] as UITextField
            
            print("firstName \(textField.text)")
            
            let content = textField.text!
            GoodJobHelper.add(description: content) { _ in
                self.tableView.reloadData()
            }
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

