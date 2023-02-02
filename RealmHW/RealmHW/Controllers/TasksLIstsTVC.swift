//
//  TasksLIstsTVC.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 31.01.23.
//

import UIKit
import RealmSwift

class TasksListsTVC: UITableViewController {
    
    var notificationToken: NotificationToken?
    
    // Results - отображает данные в реальном времени
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clean Realm DB
//        StorageManager.deleteAll()

        // выборка из DB + сортировка
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        addTasksListsObserver()

        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem],
                                                   animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        let KeyPath = sender.selectedSegmentIndex == 0 ? "name" : "date"
        tasksLists = tasksLists.sorted(byKeyPath: KeyPath)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let taskList = tasksLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList)
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
        }

        editContextItem.backgroundColor = .purple
        doneContextItem.backgroundColor = .green

        let swipeAtions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])

        return swipeAtions
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TasksTVC,
           let index = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[index.row]
            destinationVC.currentTasksList = tasksList
        }
    }
    
    @objc func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks()
    }
    
    // Делаем alertForAddAndUpdatesListTasks универсальной функцией
    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil) {
        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButtonName = tasksList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            
            guard let newListName = alertTextField.text,
                  !newListName.isEmpty else {
                return
            }

            /// логика редактирования
            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName)
            /// логика создания нового списка
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List Name"
        }
        present(alert, animated: true)
    }
    
    private func addTasksListsObserver() {
        // Realm notification
        notificationToken = tasksLists.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                if !modifications.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: modifications)
                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
                }
                if !deletions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: deletions)
                    self.tableView.deleteRows(at: indexPathArray, with: .automatic)
                }
                if !insertions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: insertions)
                    self.tableView.insertRows(at: indexPathArray, with: .automatic)
                }
            case .error(let error):
                print("error: \(error)")
            }
        }
    }
    
    private func createIndexPathArray(intArr: [Int]) -> [IndexPath] {
        var indexPathArray = [IndexPath]()
        for row in intArr {
            indexPathArray.append(IndexPath(row: row, section: 0))
        }
        return indexPathArray
    }
}
