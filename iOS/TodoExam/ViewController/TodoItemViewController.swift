//
//  TodoItemViewController.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/20.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import UIKit
import RxSwift

class TodoItemViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    var modifyTodo: TodoModel?
    var disposeBag = DisposeBag()
    var api: APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.okButton.layer.cornerRadius = self.okButton.frame.height / 2
        self.okButton.backgroundColor = UIColor.orange
        
        let vm = TodoItemViewControllerViewModel(input: (
            todoTitle: titleTextField.rx.text.orEmpty.asObservable(),
            okTaps: okButton.rx.tap.asObservable(),
            modifyTodo: Observable.just(self.modifyTodo)
            ),
            dependency: self.api!)
        
        vm.create.subscribe(onNext: { (_) in
            self.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
        }).disposed(by: self.disposeBag)
        
        vm.modify.subscribe(onNext: { (_) in
            self.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
        }).disposed(by: self.disposeBag)
        
        vm.navigationTitle.asObservable()
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.disposeBag)
        
        titleTextField.rx.text.subscribe(onNext: { (title) in
            vm.todoTitle.value = title!
        }, onError: { (error) in
        }, onCompleted: {
        }).disposed(by: self.disposeBag)
        
        vm.todoTitle.asObservable()
            .bind(to: self.titleTextField.rx.text)
            .disposed(by: self.disposeBag)
        
        vm.screenInitializeForModify()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class TodoItemViewControllerViewModel {
    let create: Observable<Void>
    let modify: Observable<Void>
    let modifyTodoModel: Observable<TodoModel>
    var navigationTitle :Variable<String> = Variable<String>("")
    var todoTitle: Variable<String> = Variable<String>("")
    var disposeBag = DisposeBag()

    init(input: (
        todoTitle: Observable<String>,
        okTaps: Observable<Void>,
        modifyTodo: Observable<TodoModel?>
        ),
         dependency:(
        APIService
        )
        ) {
        create = Observable.combineLatest(
                input.okTaps.withLatestFrom(input.todoTitle),
                input.modifyTodo)
            .flatMap { (text, modifyModel) -> Observable<Void> in
                if modifyModel != nil { return Observable.never() }
                let todo = TodoModel(api: dependency)
                todo.title = text
                return todo.post().andThen(Observable<Void>.just(())).asObservable()
            }
        
        modifyTodoModel = input.modifyTodo
            .flatMap { $0.flatMap { Observable.just($0) } ?? Observable.empty() }
        
        modify = Observable.combineLatest(
            input.okTaps.withLatestFrom(todoTitle.asObservable()),
            modifyTodoModel
            )
            .flatMap { (text, todo) -> Observable<TodoModel> in
                todo.title = text
                return todo.update()
            }
            .flatMap({ (model) -> Observable<Void> in
                return Observable.just(())
            })
        
        self.navigationTitle.value = "Add Todo"
        self.todoTitle.value = ""
    }
    
    // FIXME: メソッドを使っているができれば、RxSwiftを使いたい
    // バインディングのタイミングがどうしても後になって、空の状態になってしまうため、
    // メソッドを使っている。
    func screenInitializeForModify(){
        self.modifyTodoModel.subscribe(onNext: { (todo) in
            self.todoTitle.value = todo.title
            self.navigationTitle.value = "Edit Todo"
        }).disposed(by: self.disposeBag)
    }
}

