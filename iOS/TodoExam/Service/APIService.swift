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

protocol APIService{
    func getListAPI<T: Mappable & APIInfomation>(model: T) -> Observable<[T]>
    func postAPI<T: Mappable & APIInfomation>(model: T) -> Completable
    func updateAPI<T: Mappable & APIInfomation>(model: T) -> Observable<T>
    func deleteAPI<T: Mappable & APIInfomation>(model: T) -> Completable
}

/*
 * REST APIを実行するサービス
 */
class API: APIService {
    
    func getListAPI<T: Mappable & APIInfomation>(model: T) -> Observable<[T]>{
        return Observable.create { (observer: AnyObserver<[T]>) in
            Alamofire.request(model.baseURL + model.path).responseArray() { (response: DataResponse<[T]>) in
                switch response.result {
                case .success(let modelArray):
                    observer.onNext(modelArray)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func postAPI<T: Mappable & APIInfomation>(model: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            Alamofire.request(model.baseURL + model.path, method: HTTPMethod.post, parameters: model.requestParameter(), encoding: JSONEncoding.default, headers: nil).responseJSON{ (response: DataResponse<Any>) in
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
    
    func updateAPI<T>(model: T) -> Observable<T> where T : Mappable, T : APIInfomation {
        return Observable.create { (observer: AnyObserver<T>) in
            Alamofire.request(model.baseURL + model.path + "/" + model.id.description, method: HTTPMethod.put, parameters: model.requestParameter(), encoding: JSONEncoding.default, headers: nil).responseObject() { (response: DataResponse<T>) in
                switch response.result {
                case .success(let modelArray):
                    observer.onNext(modelArray)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func deleteAPI<T: Mappable & APIInfomation>(model: T) -> Completable {
        return Completable.create { (observer) -> Disposable in
            Alamofire.request(model.baseURL + model.path + "/" + model.id.description, method: HTTPMethod.delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ (response: DataResponse<Any>) in
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
