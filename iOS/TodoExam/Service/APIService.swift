//
//  APIService.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/19.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import ObjectMapper
import AlamofireObjectMapper

class APIService {
    
    func getTodoList() ->Observable<[TodoModel]>{
        return Observable.create { (observer: AnyObserver<[TodoModel]>) in
            Alamofire.request("http://localhost:3000/todo_items").responseArray() { (response: DataResponse<[TodoModel]>) in
                switch response.result {
                case .success(let todos):
                    observer.onNext(todos)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func postTodo() {
        Alamofire.request("http://localhost:3000/todo_items", method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<TodoModel>) in
            switch response.result {
            case .success(let todo):
                break
            case .failure(let error):
                break
            }
        }
    }
}
