//
//  TasksListTableViewController.swift
//  RealmTaskApp
//
//  Created by Rihards Lozins on 17/02/2021.
//

import UIKit
import RealmSwift

class TasksListTableViewController: UITableViewController {
    
    var tasksLists: Results<TasksList>!
    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TasksList.self)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    @IBAction func editItemTapped(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
        tableView.reloadData()
    }
    
    
    @IBAction func addNewItemTapped(_ sender: Any) {
        alerForAddAndUpdateList()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as! IndividualTaskTableViewController
            tasksVC.currentTasksList = tasksList
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksListCell", for: indexPath)
        
        let tasksList = tasksLists[indexPath.row]
        //        cell.textLabel?.text = tasksList.name
        cell.selectionStyle = .none
        cell.configure(with: tasksList)
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?  {
        
        let currentList = tasksLists[indexPath.row]
        
        let contextItemDelete = UIContextualAction(style: .destructive, title: "Delete") { _, _,_  in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
        let contextItemEdit = UIContextualAction(style: .destructive, title: "Edit") { _, _,_  in
            self.alerForAddAndUpdateList(currentList, complition: {
                tableView.reloadRows(at: [indexPath], with: .right)
            })
        }
        
        let contextItemDone = UIContextualAction(style: .destructive, title: "Done") { _, _,_  in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .middle)
        }
        
        contextItemDone.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        contextItemEdit.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItemDelete, contextItemEdit, contextItemDone])
        return swipeActions
    }
}

extension TasksListTableViewController {
    
    private func alerForAddAndUpdateList(_ listName: TasksList? = nil, complition: (() -> Void)? = nil) {
        
        var title = "New List"
        var doneButton = "Save"
        
        if listName != nil {
            title = "Edit List"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newList = alertTextField.text , !newList.isEmpty else { return }
            
            if let listName = listName {
                StorageManager.editList(listName, newListName: newList)
                if complition != nil { complition!() }
            } else {
                let tasksList = TasksList()
                tasksList.name = newList
                
                StorageManager.saveTasksList(tasksList)
                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic
                )
            }//else
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
        }
        
        if let listName = listName {
            alertTextField.text = listName.name
        }
        present(alert, animated: true)
    }
}

extension UITableViewCell {
    
    func configure(with tasksList: TasksList) {
        let currentTasks = tasksList.tasks.filter("isComplete = false")
        let completedTasks = tasksList.tasks.filter("isComplete = true")
        
        textLabel?.text = tasksList.name
        
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
            detailTextLabel?.textColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        } else if !completedTasks.isEmpty {
            detailTextLabel?.text = "✓"
            detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            detailTextLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else {
            detailTextLabel?.text = "0"
        }
    }
}//End
