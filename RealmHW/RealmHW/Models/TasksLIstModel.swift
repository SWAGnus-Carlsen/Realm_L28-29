//
//  TasksLIstModel.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 31.01.23.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}
