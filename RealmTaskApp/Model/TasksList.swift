//
//  TasksList.swift
//  RealmTaskApp
//
//  Created by Rihards Lozins on 17/02/2021.
//

import Foundation
import RealmSwift

class TasksList: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
    
}//End
