//
//  category.swift
//  Todoey
//
//  Created by Ivan Ivanov on 2/12/21.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    @objc dynamic var color: String?
    let items = List<Items>()
    
        
    
}







