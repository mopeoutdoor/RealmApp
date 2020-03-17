//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var currentList: TaskList!
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentList.name
        sortingTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        sortingTasks()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.isEditing = tableView.isEditing ? false : true
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = selectedTask(indexPath: indexPath)
            DataManager.shared.deleteTask(for: task)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deletedTask = self.selectedTask(indexPath: indexPath)
            DataManager.shared.deleteTask(for: deletedTask)
            let index = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [index], with: .automatic)
        }
        
        let done = UITableViewRowAction(style: .destructive, title: "Done") { (action, indexPath) in
            let task = self.selectedTask(indexPath: indexPath)
            DataManager.shared.doneTask(for: task)
            let oldIndex = IndexPath(row: indexPath.row, section: indexPath.section)
            let newIndex = (indexPath.section == 0) ? IndexPath(row: self.completedTasks.count - 1, section: 1) : IndexPath(row: self.currentTasks.count - 1, section: 0)
            self.tableView.moveRow(at: oldIndex, to: newIndex)
        }
        
        let edit = UITableViewRowAction(style: .destructive, title: "Edit") { (action, indexPath) in
            self.showUpdateAlert(indexPath: indexPath)
        }
        
        done.backgroundColor = UIColor.green
        edit.backgroundColor = UIColor.orange
        return [delete, done, edit]
    }

}

// MARK: - Private methods
extension TasksViewController {
    
    private func showAlert() {
        
        let alert = AlertController(title: "New Task", message: "What do you want to do?", preferredStyle: .alert)
        
        alert.actionWithTask(task: nil) { newValue, note in
            DataManager.shared.saveTask(for: self.currentList, with: newValue, and: note)
            self.tableView.insertRows(at: [IndexPath(row: self.currentTasks.count - 1, section: 0)], with: .automatic)
        }
        
        present(alert, animated: true)
    }
    
    private func showUpdateAlert(indexPath: IndexPath) {
        
        let alert = AlertController(title: "Update Task", message: "What do you want to do?", preferredStyle: .alert)
        let task = selectedTask(indexPath: indexPath)
        
        alert.actionWithTask(task: task) { newValue, note in
            DataManager.shared.updateTask(for: task, with: newValue, and: note)
            let index = IndexPath(row: indexPath.row, section: indexPath.section)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
        
        present(alert, animated: true)
    }

    private func selectedTask(indexPath: IndexPath) -> Task {
        return (indexPath.section == 0) ? self.currentTasks[indexPath.row] : self.completedTasks[indexPath.row]
    }
    
    private func sortingTasks() {
        currentTasks = currentList.tasks.filter("isComplete = false")
        completedTasks = currentList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}
