//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskLists = realm.objects(TaskList.self)
        
        /*
        let shoppingList = TaskList()
        shoppingList.name = "Shopping List"
        
        let moviesList = TaskList(value: ["Movies List", Date(), [["Best film ever"], ["Some another film", "", Date(), true]]])
        
        let milk = Task()
        milk.name = "Milk"
        milk.note = "2l."
        
        let bread = Task(value: ["Bread", "", Date(), true])
        let apples = Task(value: ["name": "Apples", "isComplete": true])
        
        shoppingList.tasks.append(milk)
        shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
        
        DispatchQueue.main.async {
            DataManager.shared.saveTaskList([shoppingList, moviesList])
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.isEditing = tableView.isEditing ? false : true
    }
    
    @IBAction func  addButtonPressed(_ sender: Any) {
        showALert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.textLabel?.text = taskList.name
        let totalCurrent = taskList.tasks.filter("isComplete = false").count
        let total = taskList.tasks.count
        
        switch total {
        case 0:
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.detailTextLabel?.text = "0"
        case (total - totalCurrent):
            cell.detailTextLabel?.text = nil
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        default:
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.detailTextLabel?.text = "\(totalCurrent)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskList = taskLists[indexPath.row]
            DataManager.shared.deleteTaskList(for: taskList)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deletedTaskList = self.taskLists[indexPath.row]
            DataManager.shared.deleteTaskList(for: deletedTaskList)
            let index = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [index], with: .automatic)
        }
        
        let done = UITableViewRowAction(style: .destructive, title: "Done") { (action, indexPath) in
            let taskList = self.taskLists[indexPath.row]
            DataManager.shared.doneTaskList(for: taskList)
            self.tableView.reloadData()
        }
        
        let edit = UITableViewRowAction(style: .destructive, title: "Edit") { (action, indexPath) in
            print("Tap Edit")
            self.showUpdateAlert(indexPath: indexPath)
        }
        
        done.backgroundColor = UIColor.green
        edit.backgroundColor = UIColor.orange
        return [delete, done, edit]
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let currentTask = taskLists[indexPath.row]
//
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.currentList = taskList
    }

}

extension TaskListViewController {
    
    private func showALert() {
        
        let alert = AlertController(title: "New List", message: "Please insert new value", preferredStyle: .alert)
        
        alert.actionWIthTaskList(taskList: nil) { newValue in
            DataManager.shared.saveTaskList(TaskList(value: [newValue]))
            self.tableView.insertRows( at: [IndexPath(row: self.taskLists.count - 1, section: 0)], with: .automatic)
        }
        
        present(alert, animated: true)
    }
    
    private func showUpdateAlert(indexPath: IndexPath) {
        let alert = AlertController(title: "Update List", message: "Please update new value", preferredStyle: .alert)
        let selectedTask = self.taskLists[indexPath.row]
        
        alert.actionWIthTaskList(taskList: selectedTask) { newValue in
            DataManager.shared.updateTaskList(for: selectedTask, update: newValue)
            let index = IndexPath(row: indexPath.row, section: 0)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
        present(alert, animated: true)
    }
    
}
