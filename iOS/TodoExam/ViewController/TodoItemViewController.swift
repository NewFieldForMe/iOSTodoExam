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
    var todo: TodoModel?
    var disposeBag = DisposeBag()
    var api: APIService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Todo"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completeTouched(sender: AnyObject) {
        guard let api = self.api else {
            fatalError("api service isn't regist DI container.")
        }
        todo = TodoModel(api: api)
        todo?.title = self.titleTextField.text!
        todo?.post()
            .subscribe({ (result: CompletableEvent) in
                switch result {
                case .completed:
                    self.navigationController?.popViewController(animated: true)
                case .error(let value):
                    print("error: \(value)")
                }
            }).disposed(by: disposeBag)
    }
}
