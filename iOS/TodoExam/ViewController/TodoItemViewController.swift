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
        
        let titleObservable = titleTextField.rx.text.orEmpty.asObservable()
        let okObservable = okButton.rx.tap.asObservable()
        okObservable.withLatestFrom(titleObservable)
            .flatMap { (text) -> Observable<TodoModel> in
                self.todo = TodoModel(api: self.api!)
                self.todo?.title = text
                return Observable.just(self.todo!)
            }
            .subscribe(onNext: { (todo) in
                todo.post().subscribe({ (event) in
                    self.navigationController?.popViewController(animated: true)
                }).disposed(by: self.disposeBag)
            }, onError: { (error) in
                print(error)
            }, onCompleted: {
                print("comp")
            })
            .disposed(by: self.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
