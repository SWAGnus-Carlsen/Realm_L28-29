//
//  ListModel.swift
//  RealmHW
//
//  Created by Vitaliy Halai on 31.01.23.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var date = Date()
    @Persisted var isComplete = false
    @Persisted var name = ""
    @Persisted var note = ""
   
}
