//
//  ViewController.swift
//  ToDoList
//
//  Created by 신희권 on 2023/03/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var TableView: UITableView!
    var doneBtn: UIBarButtonItem?
    var tasks = [Task]() {
        didSet{
            self.saveTasks()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableView.dataSource = self
        self.TableView.delegate = self
        self.doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTap))
        self.loadTaks()
    }
    
    @objc func doneBtnTap(){
        self.navigationItem.leftBarButtonItem = self.editBtn
        self.TableView.setEditing(false, animated: true)
    }
        
    @IBAction func tapEditBtn(_ sender: Any) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneBtn
        self.TableView.setEditing(true, animated: true)
        
    }

    @IBAction func tapAddBtn(_ sender: Any) {
        let alert = UIAlertController(title: "할 일 등록", message: "할 일을 입력해 주세요", preferredStyle: .alert)
        let registerBtn = UIAlertAction(title: "등록", style: .default,handler:
                                            {[weak self] _ in
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.TableView.reloadData()
            
        })
            let cancelBtn = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelBtn)
        alert.addAction(registerBtn)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할  일을 입력해주세요."
        })
        self.present(alert,animated: true,completion: nil)
    }
    
    func saveTasks() {
        let data = self.tasks.map{
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTaks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil}
            return Task(title: title, done: done)
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done{
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneBtnTap()
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.TableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

