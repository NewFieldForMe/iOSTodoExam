//
//  TodoItemViewController.swift
//  TodoExam
//
//  Created by 山田良 on 2017/11/20.
//  Copyright © 2017年 Yamada.Ryo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
 * Todo作成、修正画面
 * modifyTodoプロパティに修正対象のTodoが設定されていれば修正、
 * 設定されていなければ作成画面となる
 */
class TodoItemViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    var modifyTodo: TodoModel?
    var disposeBag = DisposeBag()
    var api: APIService?
    static let controllerIdentifer = "TodoItemViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.okButton.layer.cornerRadius = self.okButton.frame.height / 2
        self.okButton.backgroundColor = UIColor.orange
        
        // ViewModelの作成
        // ControllerのmodifyTodoがnilならOKボタンタップでTodoを作成し、
        // modifyTodoが渡されていればOKボタンタップでTodoを修正する
        let vm = TodoItemViewControllerViewModel(input: (
            todoTitle: titleTextField.rx.text.orEmpty.asObservable(),
            okTaps: okButton.rx.tap.asObservable(),
            modifyTodo: Observable.just(self.modifyTodo)
            ),
            dependency: self.api!)
        
        vm.create.subscribe(onNext: { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error)
        }).disposed(by: self.disposeBag)
        
        vm.modify.subscribe(onNext: { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error)
        }).disposed(by: self.disposeBag)
        
        vm.navigationTitle.asDriver()
            .drive(self.navigationItem.rx.title)
            .disposed(by: self.disposeBag)
        
        vm.todoTitle.asDriver()
            .drive(self.titleTextField.rx.text)
            .disposed(by: self.disposeBag)
        
        titleTextField.rx.text.subscribe(onNext: { (title) in
            vm.todoTitle.value = title!
        }, onError: { (error) in
            print(error)
        }).disposed(by: self.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class TodoItemViewControllerViewModel {
    let create: Observable<Void>                                    // Todo作成通知イベント
    let modify: Observable<Void>                                    // Todo修正通知イベント
    let navigationTitle :Variable<String> = Variable<String>("")    // ナビゲーションバーのタイトル文字列
    let todoTitle: Variable<String> = Variable<String>("")          // Todoのタイトル文字列
    private let disposeBag = DisposeBag()

    init(input: (
        todoTitle: Observable<String>,
        okTaps: Observable<Void>,
        modifyTodo: Observable<TodoModel?>
        ),
         dependency:(
        APIService
        )) {
        // 修正対象のTodoが存在していればTodoModelを流し、
        // nilならemptyを流すストリームを作り、init内部で使用する
        let modifyTodoModel = input.modifyTodo
            .flatMap { $0.flatMap { Observable.just($0) } ?? Observable.empty() }
        
        // Todo作成の実行
        // modifyModelが設定されていなければ、Neverストリームを流す
        create = Observable.combineLatest(
                input.okTaps.withLatestFrom(input.todoTitle),
                input.modifyTodo
            )
            .flatMap { (text, modifyModel) -> Observable<Void> in
                if modifyModel != nil { return Observable.never() }
                let todo = TodoModel(api: dependency)
                todo.title = text
                return todo.post().andThen(Observable<Void>.just(())).asObservable()
            }
        
        // Todo修正の実行
        // modifyModelが設定されていれば、Todoのタイトルを設定してupdateを行う
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
        
        // Todoとナビゲーションバータイトルの初期表示
        todoTitle.value = ""
        navigationTitle.value = "Add Todo"
        
        modifyTodoModel.subscribe(onNext: { [weak self] (model) in
            self?.todoTitle.value = model.title
            self?.navigationTitle.value = "Edit Todo"
        }).disposed(by: disposeBag)
    }
}

