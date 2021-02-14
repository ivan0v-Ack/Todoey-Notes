//
//  Items.swift
//  Todoey
//
//  Created by Ivan Ivanov on 2/12/21.
//

import Foundation
import RealmSwift

class Items: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var date: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    
}


