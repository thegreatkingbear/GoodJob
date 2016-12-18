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
    var stampImageView: UIImageView?
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let job = GoodJobHelper.alives()[indexPath.row]
            GoodJobHelper.delete(job: job) { result in
                if result == true {
                    self.updateThisView()
                } else {
                    
                }
            }
        }
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
            let content = textField.text!
            GoodJobHelper.add(description: content) { result in
                if result == true {
                    self.stampImageView = UIImageView(image: (UIImage(named: "stamp")))
                    self.stampImageView?.frame = CGRect(x: self.view.frame.width/2.0, y: self.view.frame.height/2.0, width: 200, height: 200)
                    self.stampImageView?.center = self.view.center
                    self.view.addSubview(self.stampImageView!)
                    UIView.animate(withDuration: 3.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.stampImageView?.alpha = 0
                    }, completion: { (isCompleted) in
                        self.stampImageView?.removeFromSuperview()
                    })
                } else {
                    
                }
                self.updateThisView()
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
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func completeGoodJobButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "선물 받을 준비가 되었나요?", message: "정말 축하해요!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            GoodJobHelper.completeAlives(handler: { (result) in
                if result == true {
                    
                } else {
                    
                }
                self.updateThisView()
            })
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

