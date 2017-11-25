//
//  TodoModel.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/19.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift
import SwinjectStoryboard
import Swinject

protocol ModelAPI {
    func getList() -> Observable<[TodoModel]>
    func post() -> Completable
    func update() -> Observable<TodoModel>
    func delete() -> Completable
}

class TodoModel: Mappable, IAPIInfomation, ModelAPI {
    let baseURL: String = "http://localhost:3000"
    let path: String = "/todo_items"
    let api: APIService
    
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    
    required convenience init?(map: Map) {
        let c = SwinjectStoryboard.defaultContainer
        let api = c.resolve(APIService.self)!
        self.init(api: api)
    }
    
    init(api: APIService){
        self.api = api
    }
    
    func requestParameter() -> [String : Any] {
        return Mapper<TodoModel>().toJSON(self)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
    }
    
    func getList() -> Observable<[TodoModel]> {
        return api.getListAPI(model: self)
    }
    
    func post() -> Completable {
        return api.postAPI(model: self)
    }
    
    func update() -> Observable<TodoModel> {
        return api.updateAPI(model: self)
    }
    
    func delete() -> Completable {
        return api.deleteAPI(model: self)
    }

}
