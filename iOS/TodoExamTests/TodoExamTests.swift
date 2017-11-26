//
//  TodoExamTests.swift
//  TodoExamTests
//
//  Created by 山田良 on 2017/11/19.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import RxCocoa
import ObjectMapper
@testable import TodoExam

class APIStub: APIService {
    func getListAPI<T>(model: T) -> Observable<[T]> where T : Mappable, T : IAPIInfomation {
        let one = T(api: self)
        let two = T(api: self)
        let three = T(api: self)
        
        return Observable.just([one, two, three])
    }
    
    func postAPI<T>(model: T) -> Completable where T : Mappable, T : IAPIInfomation {
        return Completable.create(subscribe: { (observer) -> Disposable in
            observer(.completed)
            return Disposables.create()
        })
    }
    
    func updateAPI<T>(model: T) -> Observable<T> where T : Mappable, T : IAPIInfomation {
        return Observable.just(model)
    }
    
    func deleteAPI<T>(model: T) -> Completable where T : Mappable, T : IAPIInfomation {
        return Completable.create(subscribe: { (observer) -> Disposable in
            observer(.completed)
            return Disposables.create()
        })
    }
}

class TodoModelTests: XCTestCase {
    let APIMock = APIStub()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /* TodoModel 一覧取得テスト
     * 期待結果:Todoのリストが取得できること
     */
    func testGetList() {
        let observable = TodoModel(api: APIMock).getList()
        let result = try! observable.toBlocking().last()!
        let resultCount = result.count
        
        XCTAssert(resultCount == 3)
    }
    
    /* TodoModel Postメソッドテスト
     * 期待結果：Completeイベントが発生すること
     */
    func testPost() {
        let observable = TodoModel(api: APIMock).post()
        let result = observable.toBlocking().materialize()
        
        switch result {
        case .completed:
            XCTAssert(true)
        case .failed( _, _):
            XCTAssert(false)
        }
    }
    
    /* TodoModel Updateメソッドテスト
     * 期待結果：TodoModelが返却されること
     */
    func testUpdate() {
        let model = TodoModel(api: APIMock)
        model.title = "test_title"
        let observable = model.update()
        let result = try! observable.toBlocking().last()!
        
        XCTAssert(result === model)
    }
    
    /* TodoModel Deleteメソッドテスト
     * 期待結果：Completeイベントが発生すること
     */
    func testDelete() {
        let observable = TodoModel(api: APIMock).delete()
        let result = observable.toBlocking().materialize()
        
        switch result {
        case .completed:
            XCTAssert(true)
        case .failed( _, _):
            XCTAssert(false)
        }
    }
}

class TodoItemViewControllerViewModelTests: XCTestCase {
    let APIMock = APIStub()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /* TodoItemViewControllerViewModel TodoTitle
     * 条件：修正対象Todoが設定されていないこと。
     * 期待結果：todoのタイトルが空であること
     */
    func testTodoTitle_Empty() {
        var todoModel: TodoModel?
        todoModel = nil

        let vm = TodoItemViewControllerViewModel(
                input: (
                todoTitle: Observable.just("todoTitle"),
                okTaps: Observable.empty(),
                modifyTodo: Observable.just(todoModel)
            ),
            dependency: self.APIMock)
        
        XCTAssert(vm.todoTitle.value.isEmpty)
    }
    
    /* TodoItemViewControllerViewModel TodoTitle
     * 条件：修正対象Todoが設定されている。
     * 期待結果：Add Todoが表示されること
     */
    func testTodoTitle_NotEmpty() {
        var todoModel: TodoModel?
        todoModel = TodoModel(api: APIMock)
        todoModel!.title = "modify_title"
        
        let vm = TodoItemViewControllerViewModel(
            input: (
                todoTitle: Observable.just("todoTitle"),
                okTaps: Observable.empty(),
                modifyTodo: Observable.just(todoModel)
            ),
            dependency: self.APIMock)
        
        // FIXME: メソッドを使っているができれば、RxSwiftを使いたい
        // バインディングのタイミングがどうしても後になって、空の状態になってしまうため、
        // メソッドを使っている。
        vm.screenInitializeForModify()
        
        XCTAssert(vm.todoTitle.value == todoModel!.title)
    }
}

class TodoExamTests: XCTestCase {
    
    let APIMock = APIStub()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
