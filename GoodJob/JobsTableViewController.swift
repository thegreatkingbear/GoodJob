//
//  ViewController.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-14.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import UIKit
import RealmSwift

protocol JobsProtocol {
    func updateCurrentGoal() -> Void
}

class JobsTableViewController: UITableViewController, JobsProtocol {
    
    var currentGoal: Goals?
    var notificationToken: NotificationToken?
    var stampImageView: UIImageView?
    
    //MARK: 뷰 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCurrentGoal()
        
        updateThisView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 테이블 뷰 델리게이트 & 데이터소스
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("행수: \(GoodJobHelper.currentCount())")
        return GoodJobHelper.currentCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Jobs", for: indexPath) as! JobsTableViewCell
        let job = GoodJobHelper.current()?[indexPath.row]
        cell.contents?.text = job?.content
        cell.date?.text = job?.date.toFriendlyDateTimeString(false)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let job = GoodJobHelper.current()?[indexPath.row]
            GoodJobHelper.delete(job: job!)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //MARK: 내부로직
    func updateCurrentGoal() {
        currentGoal = GoalsHelper.current()
        
        updateNotificationToken()
    }
    
    func updateViewTitle(number: Int) -> Void {
        title = "참 잘했어요 \(number)개"
    }
    
    func updateThisView() -> Void {
        updateViewTitle(number: GoodJobHelper.currentCount())
        tableView.reloadData()
    }
    
    func updateNotificationToken() {
        print("update notification token() called")
        notificationToken = nil
        notificationToken = GoodJobHelper.current()?.addNotificationBlock({ (changes) in
            print(changes)
            self.updateViewTitle(number: GoodJobHelper.currentCount())
            switch changes {
            case .initial: self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                let fromRow = {(row: Int) in
                    return IndexPath(row: row, section: 0)}
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: deletions.map(fromRow), with: .left)
                self.tableView.insertRows(at: insertions.map(fromRow), with: .right)
                if insertions.count > 0 {
                    self.showStampImage()
                }
                self.tableView.reloadRows(at: modifications.map(fromRow), with: .automatic)
                print("current count: \(GoodJobHelper.currentCount())")
                self.tableView.endUpdates()
            default: break
            }
        })
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
            self.updateCurrentGoal()
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
        var title = "아직 목표는 정해지지 않았습니다"
        var message = "목표를 정하시려면 편집 버튼을 눌러주세요"
        if let currentGoal = GoalsHelper.current() {
            title = "현재 목표는 \(currentGoal.content)"
            message = "총 \(currentGoal.desiredAchievement)개의 목표 중에 \(GoodJobHelper.currentCount())개를 달성중입니다"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    //MARK: 뷰 세그웨이
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoalsTable" {
            if let dest = segue.destination as? GoalsTableViewController {
                dest.delegate = self
            }
        }
    }
}

