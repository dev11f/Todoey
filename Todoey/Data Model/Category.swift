//
//  Category.swift
//  Todoey
//
//  Created by Hyoungbin Kook on 2018. 11. 13..
//  Copyright © 2018년 Hyoungbin Kook. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name:String = ""
    let items = List<Item>()
    
}
