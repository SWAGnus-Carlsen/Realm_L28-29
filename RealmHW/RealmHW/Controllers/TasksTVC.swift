//
//  TasksTVC.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 31.01.23.
//

import UIKit
import RealmSwift

enum TasksTVCFlow {
    case addingNewTask
    case editingTask(task: Task)
}

struct TxtAlertData {
    
    let titleForAlert = "Task value"
    var messageForAlert: String
    let doneButtonForAlert: String
    let cancelTxt = "Cancel"
    
    let newTextFieldPlaceholder = "New task"
    let noteTextFieldPlaceholder = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksTVCFlow: TasksTVCFlow) {
        switch tasksTVCFlow {
            case .addingNewTask:
                messageForAlert = "Please insert new task value"
                doneButtonForAlert = "Save"
            case .editingTask(let task):
                messageForAlert = "Please edit your task"
                doneButtonForAlert = "Update"
                taskName = task.name
                taskNote = task.note
        }
    }
}

final class TasksTVC: UITableViewController {
    
    var currentTasksList: TasksList?
    
    private var notCompletedTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    private var currentTasksListSTR: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        /// title
        title = currentTasksList?.name
        /// filtering tasks
        filteringTasks()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
        currentTasksList?.tasks.forEach {
            currentTasksListSTR?.append($0.name)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Not completed tasks" : "Completed tasks"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }
    
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(tasksTVCFlow: .editingTask(task: task))
        }
        
        let doneText = task.isComplete ? "Not done" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editContextItem.backgroundColor = .purple
        doneContextItem.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }
    
  
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         if fromIndexPath != to {
             
             if fromIndexPath.section == 0,
                to.section == 1 {
                 let task = notCompletedTasks[fromIndexPath.row]
                 StorageManager.makeDone(task)
        
             } else if fromIndexPath.section == 1,
                       to.section == 0{
                 let task = completedTasks[fromIndexPath.row]
                 StorageManager.makeNotDone(task)
             }
         }
     }
     
    
    
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     return true
     }
    
    
    private func filteringTasks() {
        notCompletedTasks = currentTasksList?.tasks.filter("isComplete = false")
        completedTasks = currentTasksList?.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}

// MARK: - Adding And Updating List

extension TasksTVC {
    
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdateList(tasksTVCFlow: .addingNewTask)
    }
    
    private func alertForAddAndUpdateList(tasksTVCFlow: TasksTVCFlow) {
        
        let txtAlertData = TxtAlertData(tasksTVCFlow: tasksTVCFlow)
        
//        UIAlertController.showAlertWithTwoTF(tasksTVCFlow: txtAlertData) { txtAlertData in
//            // тут либо создаем новый либо редактируем
//            switch tasksTVCFlow {
//                case .addingNewTask:
//                    let task = Task()
//                    task.name = txtAlertData.taskName
//                    task.note = txtAlertData.taskNote
//                    guard let currentTasksList = self.currentTasksList else { return }
//                    StorageManager.saveTask(currentTasksList, task: task)
//                case .editingTask(let task):
//                    StorageManager.editTask(task,
//                                            newNameTask: txtAlertData.taskName,
//                                            newNote: txtAlertData.taskNote)
//            }
//        } cancelAction: {
//            // можем что то еще сделать
//        }

        let alert = UIAlertController(title: txtAlertData.titleForAlert,
                                      message: txtAlertData.messageForAlert,
                                      preferredStyle: .alert)
        
        /// UITextField-s
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = txtAlertData.newTextFieldPlaceholder
            taskTextField.text = txtAlertData.taskName
        }

        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = txtAlertData.noteTextFieldPlaceholder
            noteTextField.text = txtAlertData.taskNote
        }

        /// Action-s

        let saveAction = UIAlertAction(title: txtAlertData.doneButtonForAlert,
                                       style: .default) { [weak self] _ in

            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty,
                  let newNote = noteTextField.text, !newNote.isEmpty,
                  let self = self else { return }

            switch tasksTVCFlow {
                case .addingNewTask:
                    let task = Task()
                    task.name = newNameTask
                    task.note = newNote
                    guard let currentTasksList = self.currentTasksList else { return }
                    StorageManager.saveTask(currentTasksList, task: task)
                case .editingTask(let task):
                    StorageManager.editTask(task,
                                            newNameTask: newNameTask,
                                            newNote: newNote)
            }
            self.filteringTasks()
        }

        let cancelAction = UIAlertAction(title: txtAlertData.cancelTxt, style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

