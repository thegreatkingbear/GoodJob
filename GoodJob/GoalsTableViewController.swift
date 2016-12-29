//
//  GoalsTableViewController.swift
//  GoodJob
//
//  Created by Mookyung Kwak on 2016-12-25.
//  Copyright © 2016 Mookyung Kwak. All rights reserved.
//

import UIKit
import RealmSwift

class GoalsTableViewController: UITableViewController {

    var notificationToken: NotificationToken?
    var stampImageView: UIImageView?
    var delegate: JobsProtocol?
    
    //MARK: 뷰 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // realm의 fine grained notification 사용
        notificationToken = GoalsHelper.all()?.addNotificationBlock({ (changes) in
            //print(changes)
            switch changes {
            case .initial: self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                let fromRow = {(row: Int) in
                    return IndexPath(row: row, section: 0)}
                
                GoalsHelper.checkIfCurrentGoalMet()
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: deletions.map(fromRow), with: .left)
                self.tableView.insertRows(at: insertions.map(fromRow), with: .right)
                if insertions.count > 0 {
                    self.showStampImage()
                }
                self.tableView.reloadRows(at: updates.map(fromRow), with: .none)
                self.tableView.endUpdates()
            default: break
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateThisView()
        
        let realm = try! Realm()
        print(realm.objects(Jobs.self))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: 테이블 뷰 델리게이트 & 데이터소스
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoalsHelper.allCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Goals", for: indexPath) as! GoalsTableViewCell
        if let goal = GoalsHelper.all()?[indexPath.row] {
            //print(goal)
            if goal.isAchieved {
                cell.status?.text = "완료됨"
            } else {
                cell.status?.text = "진행중"
            }
            cell.contents?.text = goal.content
            let count = GoodJobHelper.ofGoalCount(goal: goal)
            cell.achievement?.text = "\(count)\n/\(goal.desiredAchievement)"
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .none {
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //MARK: 내부로직
    func updateThisView() -> Void {
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
    @IBAction func addGoalButtonTapped(_ sender: UIButton) {
        // 진행중인 목표가 완료되어야만 새로운 목표를 설정할 수 있는 로직으로
        if let current = GoalsHelper.current() {
            if current.isAchieved == false {
                let alert = UIAlertController(title: "잠시만요!", message: "기존에 진행중인 목표를 완료해야만 새로운 목표를 추가할 수 있습니다", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // 텍스트 필드 두 개에 각각 상과 도장 갯수를 정해주는 것으로
        let alert = UIAlertController(title: "목표를 정해주세요", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
            let contentTextField = alert.textFields![0] as UITextField
            let content = contentTextField.text!
            let desiredTextField = alert.textFields![1] as UITextField
            let desired = desiredTextField.text!
            //TODO: 여기 두 개의 텍스트 필드를 밸리데이트해서 넘겨주는 로직이 필요하다. 리액티브 코코아로?
            GoalsHelper.add(description: content, desired: Int(desired)!) { (isSuccess) in
                if isSuccess {
                    // 델리게이트 패턴으로 현재 목표를 재설정해준다
                    self.delegate?.updateCurrentGoal()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "상을 적어주세요"
        }
        alert.addTextField { (textField: UITextField!) in
            textField.placeholder = "몇 개의 도장을 받아야 할까요?"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
