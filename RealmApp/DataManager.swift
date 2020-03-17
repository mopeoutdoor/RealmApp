//
//  DataManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class DataManager {
    static let shared = DataManager()
    
    func saveTaskList(_ taskList: TaskList) {
        try! realm.write {
            realm.add(taskList)
        }
    }
    
    func saveTask(for taskList: TaskList, with newTaskName: String, and newNote: String) {
        do {
            try realm.write {
                let newTask = Task(value: ["name": newTaskName, "note": newNote])
                taskList.tasks.append(newTask)
            }
        } catch let error {
            print(error)
        }
    }
    
    func updateTaskList(for taskList: TaskList, update newName: String) {
        do {
            try realm.write {
                taskList.name = newName
            }
        } catch let error {
            print(error)
        }
    }
   
    func updateTask(for task: Task, with newTaskName: String, and newNote: String) {
        do {
            try realm.write {
                task.name = newTaskName
                task.note = newNote
            }
        } catch let error {
            print(error)
        }
    }

    
    func deleteTaskList(for taskList: TaskList) {
        do {
            try realm.write {
                realm.delete(taskList.tasks)
                realm.delete(taskList)
            }
        } catch let error {
            print(error)
        }
    }
    
    func deleteTask(for task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
        }catch let error {
            print(error)
        }
    }
    
    func doneTaskList(for taskList: TaskList) {
        let tasks = taskList.tasks.filter("isComplete = false")
        let updateStatus = !tasks.isEmpty ? true : false
        let tasksForUpdate = updateStatus ? tasks : taskList.tasks.filter("isComplete = true")
            do {
                try realm.write {
                    for each in tasksForUpdate {
                        each.isComplete = updateStatus
                    }
                }
            } catch let error {
                print(error)
            }
        
    }
    
    func doneTask(for task: Task) {
        do {
            try realm.write {
                task.isComplete = task.isComplete ? false : true
            }
        } catch let error {
            print(error)
        }
    }
}

