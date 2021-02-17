//
//  StorageManager.swift
//  RealmTaskApp
//
//  Created by Rihards Lozins on 17/02/2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    //MARK: - Tasks List Methods
    
    static func saveTasksList(_ tasksList: TasksList){
        try! realm.write {
            realm.add(tasksList)
        }
    }
    
    static func deleteList(_ tasksList: TasksList){
        try! realm.write {
            let tasks = tasksList.tasks
            realm.delete(tasks)
            realm.delete(tasksList)
        }
    }
    
    static func editList(_ tasksList: TasksList, newListName: String){
        try! realm.write {
            tasksList.name = newListName
        }
    }
    
    static func makeAllDone(_ tasksList: TasksList){
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    //MARK: - Individual Task Methods
}
