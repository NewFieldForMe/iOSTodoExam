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

/*
 *  APIService Stub
 */
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

/*
 *  TodoModel 単体テスト
 */
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
        
        XCTAssert(result.title == model.title)
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

/*
 *  TodoItemViewControllerViewModel 単体テスト
 */
class TodoItemViewControllerViewModelTests: XCTestCase {
    let APIMock = APIStub()
    var todoModel: TodoModel?
    let okButton = UIButton()
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /*
     *  修正対象のTodoが設定されていないViewModelを作成
     */
    func makeViewModelEmpty() -> TodoItemViewControllerViewModel{
        todoModel = nil

        return TodoItemViewControllerViewModel(
            input: (
                todoTitle: Observable.just("todoTitle"),
                okTaps: okButton.rx.tap.asObservable(),
                modifyTodo: Observable.just(todoModel)
            ),
            dependency: self.APIMock)
    }
    
    /*
     *  修正対象のTodoが設定されているViewModelを作成
     */
    func makeViewModelModify() -> TodoItemViewControllerViewModel {
        todoModel = TodoModel(api: APIMock)
        todoModel!.title = "modify_title"
        
        return TodoItemViewControllerViewModel(
            input: (
                todoTitle: Observable.just("todoTitle"),
                okTaps: okButton.rx.tap.asObservable(),
                modifyTodo: Observable.just(todoModel)
            ),
            dependency: self.APIMock)
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 作成
     * 条件：修正対象Todoが設定されていない。
     * 期待結果：todoTitleが設定されていること
     * 期待結果：navigationTitleに"Add Todo"が設定されていること
     */
    func testTodoTitle_isCreate() {
        let vm = makeViewModelEmpty()
        
        XCTAssert(vm.todoTitle.value.isEmpty)
        XCTAssert(vm.navigationTitle.value == "Add Todo")
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 修正
     * 条件：修正対象Todoが設定されている。
     * 期待結果：todoTitleが設定されていること
     * 期待結果：navigationTitleに"Edit Todo"が設定されていること
     */
    func testTodoTitle_isModify() {
        let vm = makeViewModelModify()
        XCTAssert(vm.todoTitle.value == todoModel!.title)
        XCTAssert(vm.navigationTitle.value == "Edit Todo")
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 修正
     * 対象：Create実行
     * 条件：修正対象Todoが設定されている。
     * 期待結果：Createが実行されないこと
     */
    func testCreate_isModify() {
        let vm = makeViewModelModify()
        vm.create.subscribe(onNext: { () in
            XCTAssert(false)
        }).disposed(by: disposeBag)
        okButton.sendActions(for: .touchUpInside)
        XCTAssert(true)
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 修正
     * 対象：modify実行
     * 条件：修正対象Todoが設定されている。
     * 期待結果：modifyが実行されること
     */
    func testModify_isModify() {
        let vm = makeViewModelModify()
        var result = false
        vm.modify.subscribe(onNext: { () in
            result = true
        }).disposed(by: disposeBag)
        okButton.sendActions(for: .touchUpInside)
        _ = vm.modify.toBlocking(timeout: 3)
        XCTAssert(result)
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 追加
     * 対象：create実行
     * 条件：修正対象Todoが設定されてない。
     * 期待結果：createが実行されること
     */
    func testCreate_isCreate() {
        let vm = makeViewModelEmpty()
        var result = false
        vm.create.subscribe(onNext: { () in
            result = true
        }).disposed(by: disposeBag)
        okButton.sendActions(for: .touchUpInside)
        _ = vm.create.toBlocking(timeout: 3)
        XCTAssert(result)
    }
    
    /* TodoItemViewControllerViewModel TodoTitle 追加
     * 対象：modify実行
     * 条件：修正対象Todoが設定されてない。
     * 期待結果：modifyが実行されないこと
     */
    func testModify_isCreate() {
        let vm = makeViewModelEmpty()
        vm.modify.subscribe(onNext: { () in
            XCTAssert(false)
        }).disposed(by: disposeBag)
        okButton.sendActions(for: .touchUpInside)
        _ = vm.create.toBlocking(timeout: 3)
        XCTAssert(true)
    }
}
