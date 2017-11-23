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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func completeTouched(sender: AnyObject) {
        todo = TodoModel()
        todo?.title = self.titleTextField.text!
        let service = APIService()
        service.postTodo(parameters: (todo?.toJSON())!)
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
