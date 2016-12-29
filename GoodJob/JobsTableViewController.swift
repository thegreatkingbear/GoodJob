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
    
    var currentGoal: Goals?
    var notificationToken: NotificationToken?
    var stampImageView: UIImageView?
    
    //MARK: 뷰 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        notificationToken = GoodJobHelper.current(goal: currentGoal)?.addNotificationBlock({ (changes) in
            print(changes)
            switch changes {
            case .initial: self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                let fromRow = {(row: Int) in
                    return IndexPath(row: row, section: 0)}
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: deletions.map(fromRow), with: .left)
                self.tableView.insertRows(at: insertions.map(fromRow), with: .right)
                if insertions.count > 0 {
                    self.showStampImage()
                }
                self.tableView.reloadRows(at: updates.map(fromRow), with: .none)
                self.tableView.endUpdates()
                self.updateViewTitle(number: GoodJobHelper.currentCount(goal: self.currentGoal))
            default: break
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentGoal = GoalsHelper.current()
        
        let realm = try! Realm()
        print(realm.objects(Jobs.self))
        
        updateThisView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 테이블 뷰 델리게이트 & 데이터소스
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoodJobHelper.currentCount(goal: currentGoal)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Jobs", for: indexPath) as! JobsTableViewCell
        let job = GoodJobHelper.current(goal: currentGoal)?[indexPath.row]
        cell.contents?.text = job?.content
        cell.date?.text = job?.date.toFriendlyDateTimeString(false)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let job = GoodJobHelper.current(goal: currentGoal)?[indexPath.row]
            GoodJobHelper.delete(job: job!)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //MARK: 내부로직
    func updateViewTitle(number: Int) -> Void {
        title = "참 잘했어요 \(number)개"
    }
    
    func updateThisView() -> Void {
        updateViewTitle(number: GoodJobHelper.currentCount(goal: currentGoal))
        tableView.reloadData()
    }
    
    func showStampImage() {
        // 스탬프 이미지를 화면에 띄워줌
        self.stampImageView = UIImageView(image: (UIImage(named: "stamp")))
        self.stampImageView?.frame = CGRect(x: self.view.frame.width/2.0, y: self.view.frame.height/2.0, width: 200, height: 200)
        self.stampImageView?.center = self.view.center
        self.view.addSubview(self.stampImageView!)
        
        // 스탬프가 서서히 보이는 애니메이션 추가
        UIView.animate(withDuration: 3.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.stampImageView?.alpha = 0
        }, completion: { (isCompleted) in
            self.stampImageView?.removeFromSuperview()
        })
    }
    
    //MARK: IBActions
    @IBAction func addGoodJobButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "잘한일을 적어주세요", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            let textField = alert.textFields![0] as UITextField
            let content = textField.text!
            GoodJobHelper.add(description: content)
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
    
    @IBAction func goalsButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "현재 목표는", message: "총 개의 목표 중에 개를 달성중입니다", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            
        }
        let editAction = UIAlertAction(title: "편집", style: .destructive) { (action) in
            // 목표 편집 테이블로 넘어가야 함
            self.performSegue(withIdentifier: "GoalsTable", sender: self)
        }
        alert.addAction(okAction)
        alert.addAction(editAction)
        self.present(alert, animated: true, completion: nil)
    }
}

