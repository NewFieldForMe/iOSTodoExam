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
    
    func getTodoList() {
        Alamofire.request("http://localhost:3000/todo_items").responseArray() { (response: DataResponse<[TodoModel]>) in
            switch response.result {
            case .success(let todos):
                print(todos)
            case .failure(let error): break
                // データ取得エラー
            }
        }
    }
}
