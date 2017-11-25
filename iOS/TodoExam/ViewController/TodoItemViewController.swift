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
    var todo: TodoModel?
    var disposeBag = DisposeBag()
    var api: APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Todo"
        
        self.okButton.layer.cornerRadius = self.okButton.frame.height / 2
        self.okButton.backgroundColor = UIColor.orange
        
        let vm = TodoItemViewControllerViewModel(input: (
            todoTitle: titleTextField.rx.text.orEmpty.asObservable(),
            okTaps: okButton.rx.tap.asObservable()
            ),
            dependency: self.api!)
        
        vm.createTodo.subscribe(onNext: { (_) in
            self.navigationController?.popViewController(animated: true)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
        }).disposed(by: self.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class TodoItemViewControllerViewModel {
    let createTodo: Observable<Void>
    init(input: (
        todoTitle: Observable<String>,
        okTaps: Observable<Void>
        ),
         dependency:(
        APIService
        )
        ) {
        createTodo = input.okTaps.withLatestFrom(input.todoTitle)
            .flatMap { (text) -> Observable<Void> in
                let todo = TodoModel(api: dependency)
                todo.title = text
                return todo.post().andThen(Observable<Void>.just(())).asObservable()
            }
    }
}

