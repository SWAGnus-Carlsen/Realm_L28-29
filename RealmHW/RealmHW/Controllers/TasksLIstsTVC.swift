//
//  TasksLIstsTVC.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 31.01.23.
//

import UIKit
import RealmSwift

class TasksListsTVC: UITableViewController {
    
    // Results - отображает данные в реальном времени
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // выборка из DB + сортировка
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")

        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem],
                                                   animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        let byKeyPath = sender.selectedSegmentIndex == 0 ? "name" : "date"
        tasksLists = tasksLists.sorted(byKeyPath: byKeyPath)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let taskList = tasksLists[indexPath.row]
        cell.textLabel?.text = taskList.name
        cell.detailTextLabel?.text = taskList.tasks.count.description

        return cell
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in

        }

        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeAtions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])

        return swipeAtions
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @objc func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks { [weak self] in
            print("List added or edited")
            self?.tableView.reloadData()
        }
    }

    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil,
                                                complition: @escaping () -> Void)
    {
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
                StorageManager.editList(tasksList, newListName: newListName, complition: complition)
            /// логика создания нового списка
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
                complition()

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
}
