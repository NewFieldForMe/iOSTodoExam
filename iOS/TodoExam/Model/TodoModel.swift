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

/*
 * Modelが持つAPIメソッド
 * Modelに関連するAPIはModelAPIを介して行う
 */
protocol ModelAPI {
    associatedtype ModelType
    func getList() -> Observable<[ModelType]>
    func post() -> Completable
    func update() -> Observable<ModelType>
    func delete() -> Completable
}

/*
 * APIの基本情報となるURLやパスを提供するインターフェース
 */
protocol APIInfomation {
    var baseURL: String { get }
    var path: String { get }
    var id: Int { get }
    func requestParameter() -> [String: Any]
    init(api: APIService)
}

class TodoModel: Mappable, APIInfomation, ModelAPI {
    typealias ModelType = TodoModel
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
    
    required init(api: APIService){
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
