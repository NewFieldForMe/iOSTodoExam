//
//  TodoModel.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/19.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import Foundation
import ObjectMapper

class TodoModel: Mappable {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
        
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
    }
}
