//
//  AlertModel.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 16.10.23.
//

import Foundation


//MARK: - Enum for alerts
enum TasksTVCFlow {
    case addingNewTask
    case editingTask(task: Task)
}

//MARK: - Alert data
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
