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
    
    func getTodoList() -> Observable<[TodoModel]>{
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
    
    func postTodo(parameters: [String: Any]) {
        Alamofire.request("http://localhost:3000/todo_items", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<TodoModel>) in
            switch response.result {
            case .success(_):
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func deleteTodo(id: String) -> Completable {
        return Completable.create { (observer) -> Disposable in
            Alamofire.request("http://localhost:3000/todo_items/" + id, method: HTTPMethod.delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ (response: DataResponse<Any>) in
                switch response.result {
                case .success(_):
                    observer(.completed)
                    break
                case .failure(let error):
                    observer(.error(error))
                    break
                }
            }
            return Disposables.create()
        }
    }
}
