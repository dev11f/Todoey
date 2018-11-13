//
//  Item.swift
//  Todoey
//
//  Created by Hyoungbin Kook on 2018. 11. 13..
//  Copyright © 2018년 Hyoungbin Kook. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title:String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var dateCreated:Date?
    
    // Category는 type이 아니기 떄문에 .self를 붙이고, 프로퍼티는 관계의 반대쪽에 있는 값
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
